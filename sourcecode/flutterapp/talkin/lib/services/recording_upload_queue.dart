import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:notisboard/socket/socket_emit.dart';
import 'package:notisboard/utils/api.dart';
import 'package:notisboard/utils/api_params.dart';
import 'package:notisboard/utils/database.dart';
import 'package:notisboard/utils/firebse_access_token.dart';
import 'package:notisboard/utils/utils.dart';
import 'package:video_compress/video_compress.dart';

class _PendingUpload {
  final String filePath;
  final String callId;
  final String userId;
  final String expertId;
  final String callType;
  final int durationSeconds;
  final String? compressedPath;
  final int createdAt;

  _PendingUpload({
    required this.filePath,
    required this.callId,
    required this.userId,
    required this.expertId,
    required this.callType,
    required this.durationSeconds,
    this.compressedPath,
    int? createdAt,
  }) : createdAt = createdAt ?? DateTime.now().millisecondsSinceEpoch;

  Map<String, dynamic> toJson() => {
        'filePath': filePath,
        'callId': callId,
        'userId': userId,
        'expertId': expertId,
        'callType': callType,
        'durationSeconds': durationSeconds,
        if (compressedPath != null) 'compressedPath': compressedPath,
        'createdAt': createdAt,
      };

  factory _PendingUpload.fromJson(Map<String, dynamic> json) => _PendingUpload(
        filePath: json['filePath'] ?? '',
        callId: json['callId'] ?? '',
        userId: json['userId'] ?? '',
        expertId: json['expertId'] ?? '',
        callType: json['callType'] ?? 'audio',
        durationSeconds: json['durationSeconds'] ?? 0,
        compressedPath: json['compressedPath'],
        createdAt: json['createdAt'],
      );

  String get uploadFilePath => compressedPath ?? filePath;
}

class RecordingUploadQueue {
  RecordingUploadQueue._();
  static final RecordingUploadQueue instance = RecordingUploadQueue._();

  static const String _storageKey = 'pending_recording_uploads';
  final GetStorage _box = GetStorage();
  bool _isProcessing = false;

  List<_PendingUpload> _getQueue() {
    try {
      final raw = _box.read<String>(_storageKey);
      if (raw == null || raw.isEmpty) return [];
      final list = jsonDecode(raw) as List;
      return list.map((e) => _PendingUpload.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      Utils.showLog("RecordingUploadQueue: error reading queue: $e");
      return [];
    }
  }

  Future<void> _saveQueue(List<_PendingUpload> queue) async {
    try {
      await _box.write(_storageKey, jsonEncode(queue.map((e) => e.toJson()).toList()));
    } catch (e) {
      Utils.showLog("RecordingUploadQueue: error saving queue: $e");
    }
  }

  /// Add a recording to the pending upload queue and start uploading.
  Future<void> enqueue({
    required String filePath,
    required String callId,
    required String userId,
    required String expertId,
    required String callType,
    required int durationSeconds,
    String? compressedPath,
  }) async {
    final entry = _PendingUpload(
      filePath: filePath,
      callId: callId,
      userId: userId,
      expertId: expertId,
      callType: callType,
      durationSeconds: durationSeconds,
      compressedPath: compressedPath,
    );

    final queue = _getQueue();
    queue.add(entry);
    await _saveQueue(queue);

    Utils.showLog("RecordingUploadQueue: enqueued recording for call $callId (${_getQueue().length} pending)");

    // Fire-and-forget: process in background
    unawaited(_processQueue());
  }

  /// Process all pending uploads. Safe to call multiple times — skips if already running.
  Future<void> _processQueue() async {
    if (_isProcessing) return;
    _isProcessing = true;

    try {
      while (true) {
        final queue = _getQueue();
        if (queue.isEmpty) break;

        final entry = queue.first;
        final success = await _uploadEntry(entry);

        if (success) {
          // Remove from queue after success
          final updatedQueue = _getQueue();
          if (updatedQueue.isNotEmpty) {
            updatedQueue.removeAt(0);
            await _saveQueue(updatedQueue);
          }
          Utils.showLog("RecordingUploadQueue: upload succeeded for call ${entry.callId}");
        } else {
          // Failed — stop processing, will retry on next app launch
          Utils.showLog("RecordingUploadQueue: upload failed for call ${entry.callId}, will retry later");
          break;
        }
      }
    } catch (e) {
      Utils.showLog("RecordingUploadQueue: processQueue error: $e");
    } finally {
      _isProcessing = false;
    }
  }

  Future<bool> _uploadEntry(_PendingUpload entry) async {
    try {
      final file = File(entry.uploadFilePath);
      if (!await file.exists()) {
        Utils.showLog("RecordingUploadQueue: file not found: ${entry.uploadFilePath}, skipping");
        return true; // Remove from queue — file doesn't exist
      }

      final size = await file.length();
      Utils.showLog("RecordingUploadQueue: uploading ${entry.callType} recording (${(size / 1024 / 1024).toStringAsFixed(1)} MB) for call ${entry.callId}");

      // Compress video if needed
      String uploadPath = entry.uploadFilePath;
      if (entry.callType == 'video' && size > 5 * 1024 * 1024) {
        Utils.showLog("RecordingUploadQueue: compressing video (${(size / 1024 / 1024).toStringAsFixed(1)} MB)");
        try {
          final MediaInfo? compressed = await VideoCompress.compressVideo(
            entry.uploadFilePath,
            quality: VideoQuality.MediumQuality,
            deleteOrigin: false,
            includeAudio: true,
          );
          if (compressed != null && compressed.file != null && compressed.file!.existsSync()) {
            final compressedSize = await compressed.file!.length();
            Utils.showLog("RecordingUploadQueue: compressed to ${(compressedSize / 1024 / 1024).toStringAsFixed(1)} MB");
            uploadPath = compressed.file!.path;
          } else {
            Utils.showLog("RecordingUploadQueue: compression returned null, using original");
          }
        } catch (compressError) {
          Utils.showLog("RecordingUploadQueue: compression failed: $compressError, using original");
        }
      }

      final uploadFile = File(uploadPath);
      await uploadFile.length();

      final token = await FirebaseAccessToken.onGet();
      if (token == null || token.isEmpty) {
        Utils.showLog("RecordingUploadQueue: auth token unavailable, will retry later");
        return false;
      }

      final uri = Uri.parse(Api.recordingSubscriptionUpload);
      final request = http.MultipartRequest('POST', uri);
      request.headers.addAll({
        ApiParams.key: Api.secretKey,
        ApiParams.authToken: ApiParams.tokenStartPoint + token,
        ApiParams.authUid: Database.loginUserFirebaseId,
      });
      request.files.add(await http.MultipartFile.fromPath('recording', uploadPath));

      final response = await request.send().timeout(const Duration(seconds: 300));
      final responseBody = await response.stream.bytesToString();
      Utils.showLog("RecordingUploadQueue: response ${response.statusCode} $responseBody");

      // Clean up video compress cache
      VideoCompress.deleteAllCache().catchError((_) => false);

      final json = jsonDecode(responseBody);
      if (json['status'] == true) {
        final url = json['url'] as String?;

        // Report to server via socket
        SocketEmit.emitReportRecordingComplete(
          callId: entry.callId,
          userId: entry.userId,
          expertId: entry.expertId,
          callType: entry.callType,
          cloudStorageUrl: url ?? '',
          fileSizeBytes: size,
          durationSeconds: entry.durationSeconds,
        );

        // Delete local file and compressed file after successful upload
        try {
          final originalFile = File(entry.filePath);
          if (await originalFile.exists()) await originalFile.delete();
          if (uploadPath != entry.filePath) {
            final compressedFile = File(uploadPath);
            if (await compressedFile.exists()) await compressedFile.delete();
          }
          Utils.showLog("RecordingUploadQueue: deleted local files for call ${entry.callId}");
        } catch (deleteErr) {
          Utils.showLog("RecordingUploadQueue: failed to delete local files: $deleteErr");
        }

        return true;
      }

      Utils.showLog("RecordingUploadQueue: server returned status=false: $responseBody");
      return false;
    } catch (e) {
      Utils.showLog("RecordingUploadQueue: upload error: $e");
      return false;
    }
  }

  /// Call on app startup to retry any pending uploads from a previous session.
  Future<void> retryPendingUploads() async {
    final queue = _getQueue();
    if (queue.isEmpty) return;
    Utils.showLog("RecordingUploadQueue: found ${queue.length} pending upload(s) from previous session");
    unawaited(_processQueue());
  }

  /// Number of pending uploads.
  int get pendingCount => _getQueue().length;
}
