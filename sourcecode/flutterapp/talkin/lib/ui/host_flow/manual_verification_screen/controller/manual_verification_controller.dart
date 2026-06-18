import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:notisboard/ui/host_flow/manual_verification_screen/api/verification_status_api.dart';
import 'package:notisboard/ui/host_flow/manual_verification_screen/api/verification_submit_api.dart';
import 'package:notisboard/ui/host_flow/manual_verification_screen/model/verification_status_model.dart';
import 'package:notisboard/utils/utils.dart';

class ManualVerificationController extends GetxController {
  final List<File> selectedFiles = [];
  final Rx<VerificationStatusData?> verificationStatusData = Rx(null);
  final isLoading = false.obs;
  final isSubmitting = false.obs;
  final submitMessage = ''.obs;
  final submitSuccess = false.obs;
  final errorMessage = ''.obs;

  static const int maxFiles = 5;

  @override
  void onInit() {
    fetchVerificationStatus();
    super.onInit();
  }

  Future<void> fetchVerificationStatus() async {
    isLoading.value = true;
    errorMessage.value = '';
    update();
    try {
      final result = await VerificationStatusApi.callApi();
      if (result?.status == true && result?.data != null) {
        verificationStatusData.value = result!.data;
      } else {
        errorMessage.value = result?.message ?? 'Failed to load verification status';
      }
    } catch (_) {
      errorMessage.value = 'Unable to connect. Please check your internet.';
    }
    isLoading.value = false;
    update();
  }

  Future<void> pickFiles() async {
    final remainingSlots = maxFiles - selectedFiles.length;
    if (remainingSlots <= 0) {
      Utils.showToast(Get.context!, 'You can upload up to $maxFiles files.');
      return;
    }

    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );

    if (result != null && result.paths.isNotEmpty) {
      final newFiles = result.paths
          .where((path) => path != null)
          .map((path) => File(path!))
          .toList();

      final totalAfterAdd = selectedFiles.length + newFiles.length;
      if (totalAfterAdd > maxFiles) {
        final canAdd = maxFiles - selectedFiles.length;
        selectedFiles.addAll(newFiles.take(canAdd));
        Utils.showToast(Get.context!, 'Maximum $maxFiles files allowed. Added $canAdd more.');
      } else {
        selectedFiles.addAll(newFiles);
      }
      update();
    }
  }

  void removeFile(int index) {
    selectedFiles.removeAt(index);
    update();
  }

  Future<void> submitVerification() async {
    if (selectedFiles.isEmpty) {
      Utils.showToast(Get.context!, 'Please select at least one document.');
      return;
    }

    isSubmitting.value = true;
    submitMessage.value = '';
    update();

    try {
      final result = await VerificationSubmitApi.callApi(
        filePaths: selectedFiles.map((f) => f.path).toList(),
      );

      if (result != null) {
        submitSuccess.value = result.status;
        submitMessage.value = result.message;

        if (result.status) {
          selectedFiles.clear();
          await fetchVerificationStatus();
        }
      } else {
        submitMessage.value = 'Something went wrong. Please try again.';
        submitSuccess.value = false;
      }
    } catch (_) {
      submitMessage.value = 'Something went wrong. Please try again.';
      submitSuccess.value = false;
    }

    isSubmitting.value = false;
    update();
  }
}
