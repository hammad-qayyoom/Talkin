import 'package:flutter/material.dart';
import 'package:notisboard/utils/app_color.dart';
import 'package:notisboard/utils/font_style.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:audioplayers/audioplayers.dart';

class RecordingPlaybackScreen extends StatefulWidget {
  final String title;
  final String url;
  final bool isVideo;

  const RecordingPlaybackScreen({
    super.key,
    required this.title,
    required this.url,
    required this.isVideo,
  });

  @override
  State<RecordingPlaybackScreen> createState() => _RecordingPlaybackScreenState();
}

class _RecordingPlaybackScreenState extends State<RecordingPlaybackScreen> {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  final AudioPlayer _audioPlayer = AudioPlayer();

  bool _isPlaying = false;
  bool _isLoading = true;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    try {
      if (widget.url.isEmpty) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
        return;
      }
      if (widget.isVideo) {
        _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(widget.url));
        await _videoPlayerController!.initialize();
        _chewieController = ChewieController(
          videoPlayerController: _videoPlayerController!,
          autoPlay: true,
          looping: false,
          aspectRatio: _videoPlayerController!.value.aspectRatio,
        );
      } else {
        _audioPlayer.onDurationChanged.listen((d) {
          if (mounted && d > Duration.zero) setState(() => _duration = d);
        });
        _audioPlayer.onPositionChanged.listen((p) {
          if (mounted) setState(() => _position = p);
        });
        _audioPlayer.onPlayerStateChanged.listen((state) {
          if (mounted) setState(() => _isPlaying = state == PlayerState.playing);
        });
        await _audioPlayer.setSourceUrl(widget.url);
        final dur = await _audioPlayer.getDuration();
        if (mounted && dur != null && dur > Duration.zero) {
          setState(() => _duration = dur);
        }
        await _audioPlayer.resume();
      }
    } catch (e) {
      debugPrint("Error initializing player: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = duration.inHours;
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    if (hours > 0) {
      return "$hours:$minutes:$seconds";
    }
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          widget.title,
          style: AppFontStyle.fontStyleW600(fontSize: 18, fontColor: Colors.white),
        ),
      ),
      body: Center(
        child: _isLoading
            ? CircularProgressIndicator(color: AppColors.redesignBrandRed)
            : widget.isVideo
                ? _buildVideoPlayer()
                : _buildAudioPlayer(),
      ),
    );
  }

  Widget _buildVideoPlayer() {
    if (widget.url.isEmpty) {
      return const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.cloud_off_rounded, color: Colors.white54, size: 64),
          SizedBox(height: 16),
          Text("Recording not yet uploaded to server", style: TextStyle(color: Colors.white70, fontSize: 14)),
        ],
      );
    }
    if (_chewieController != null && _videoPlayerController != null) {
      return Chewie(controller: _chewieController!);
    } else {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: Colors.white54, size: 64),
          const SizedBox(height: 16),
          Text("Failed to load video", style: TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 8),
          Text(widget.url, style: TextStyle(color: Colors.white38, fontSize: 10), textAlign: TextAlign.center),
        ],
      );
    }
  }

  Widget _buildAudioPlayer() {
    final maxSeconds = _duration.inSeconds > 0 ? _duration.inSeconds.toDouble() : 1.0;
    final currentSeconds = _position.inSeconds.toDouble().clamp(0.0, maxSeconds);
    return Container(
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.mic_rounded, color: AppColors.redesignBrandRed, size: 64),
          const SizedBox(height: 24),
          Slider(
            activeColor: AppColors.redesignBrandRed,
            inactiveColor: Colors.grey.withValues(alpha: 0.3),
            min: 0,
            max: maxSeconds,
            value: currentSeconds,
            onChanged: (value) {
              _audioPlayer.seek(Duration(seconds: value.toInt()));
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_formatDuration(_position), style: const TextStyle(color: Colors.white)),
                Text(_formatDuration(_duration), style: const TextStyle(color: Colors.white)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          CircleAvatar(
            radius: 32,
            backgroundColor: AppColors.redesignBrandRed,
            child: IconButton(
              iconSize: 32,
              color: Colors.white,
              icon: Icon(_isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded),
              onPressed: () {
                if (_isPlaying) {
                  _audioPlayer.pause();
                } else {
                  _audioPlayer.resume();
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
