import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:notisboard/custom/progress_indicator/progress_dialog.dart';
import 'package:notisboard/ui/host_flow/host_listeners_detail_screen/api/host_listener_profile_update_api.dart';
import 'package:notisboard/ui/host_flow/host_listeners_detail_screen/model/host_listener_profile_update_model.dart';
import 'package:notisboard/ui/user_flow/host_verification_screen/api/talk_topic_api.dart';
import 'package:notisboard/ui/user_flow/host_verification_screen/model/talk_topic_model.dart';
import 'package:notisboard/ui/user_flow/splash_screen_page/api/fetch_listener_profile_api.dart';
import 'package:notisboard/ui/user_flow/splash_screen_page/model/fetch_listener_profile_model.dart';
import 'package:notisboard/utils/constant.dart';
import 'package:notisboard/utils/database.dart';
import 'package:notisboard/utils/enums.dart';
import 'package:notisboard/utils/play_policy_topic_filter.dart';
import 'package:notisboard/utils/utils.dart';

class HostListenersDetailController extends GetxController {
  TextEditingController nameCnt = TextEditingController();
  TextEditingController nickNameCnt = TextEditingController();
  TextEditingController introCnt = TextEditingController();
  TextEditingController ratePrivateVideoCallCnt = TextEditingController();
  TextEditingController ratePrivateAudioCallCnt = TextEditingController();
  TextEditingController rateInPersonSessionCnt = TextEditingController();
  TextEditingController clinicNameCnt = TextEditingController();
  TextEditingController clinicAddressCnt = TextEditingController();
  TextEditingController clinicCityCnt = TextEditingController();
  TextEditingController clinicStateCnt = TextEditingController();
  TextEditingController clinicCountryCnt = TextEditingController();
  TextEditingController clinicPostalCodeCnt = TextEditingController();
  TextEditingController clinicFloorSuiteCnt = TextEditingController();
  TextEditingController clinicLandmarkCnt = TextEditingController();
  TextEditingController clinicParkingInfoCnt = TextEditingController();
  TextEditingController clinicContactPhoneCnt = TextEditingController();
  TextEditingController clinicContactEmailCnt = TextEditingController();
  TextEditingController clinicInstructionsCnt = TextEditingController();
  int selectedTopic = 0;
  List<String> allLanguages = [];
  List<String> selectedLanguages = [];
  List<TalkTopic> talkTopic = [];
  TalkTopicsModel? talkTopicsModel;
  bool isLoading = false;
  XFile? xFiles;
  final ImagePicker imagePicker = ImagePicker();
  String? pickImage;
  String? profilePic;
  String? selectedTopicName;
  HostListenerProfileUpdateModel? hostListenerProfileUpdateModel;
  FetchListenerProfileModel? fetchListenerProfileModel;
  List<int> selectedTopics = [];

  @override
  void onInit() {
    super.onInit();
    loadAllLanguages();

    nameCnt.text = Database.fetchListenerProfileModel?.data?.name ?? '';
    nickNameCnt.text = Database.fetchListenerProfileModel?.data?.nickName ?? '';
    introCnt.text = Database.fetchListenerProfileModel?.data?.selfIntro ?? '';
    ratePrivateAudioCallCnt.text = Database
            .fetchListenerProfileModel?.data?.ratePrivateAudioCall
            .toString() ??
        '';
    ratePrivateVideoCallCnt.text = Database
            .fetchListenerProfileModel?.data?.ratePrivateVideoCall
            .toString() ??
        '';
    rateInPersonSessionCnt.text = Database
            .fetchListenerProfileModel?.data?.rateInPersonSession
            .toString() ??
        '';
    
    // Load clinic details
    final clinicDetails = Database.fetchListenerProfileModel?.data?.clinicDetails;
    if (clinicDetails != null) {
      final address = clinicDetails['address'];
      clinicNameCnt.text = clinicDetails['clinicName']?.toString() ?? '';
      clinicAddressCnt.text = address?['full']?.toString() ?? address?['street']?.toString() ?? '';
      clinicCityCnt.text = address?['city']?.toString() ?? '';
      clinicStateCnt.text = address?['state']?.toString() ?? '';
      clinicCountryCnt.text = address?['country']?.toString() ?? '';
      clinicPostalCodeCnt.text = address?['postalCode']?.toString() ?? '';
      clinicFloorSuiteCnt.text = clinicDetails['floorSuite']?.toString() ?? '';
      clinicLandmarkCnt.text = clinicDetails['landmark']?.toString() ?? '';
      clinicParkingInfoCnt.text = clinicDetails['parkingInfo']?.toString() ?? '';
      clinicContactPhoneCnt.text = clinicDetails['contactPhone']?.toString() ?? '';
      clinicContactEmailCnt.text = clinicDetails['contactEmail']?.toString() ?? '';
      clinicInstructionsCnt.text = clinicDetails['consultationInstructions']?.toString() ?? '';
    }
    profilePic = Database.fetchListenerProfileModel?.data?.image;

    final savedLanguages = Database.fetchListenerProfileModel?.data?.language;
    if (savedLanguages != null && savedLanguages.isNotEmpty) {
      selectedLanguages = List<String>.from(savedLanguages);
    } else {
      selectedLanguages = []; // empty if no saved languages
    }

    update([Constant.idLanguageSection]);

    getTalkTopic();
  }

  /// select talk topic
  void selectTopic(int index) {
    if (selectedTopics.contains(index)) {
      selectedTopics.remove(index);
    } else {
      selectedTopics.add(index);
    }
    update([Constant.talkAboutTopic]);
  }

  /// select unselect language
  void toggleLanguage(String language) {
    if (selectedLanguages.contains(language)) {
      selectedLanguages.remove(language);
    } else {
      selectedLanguages.add(language);
      log("selectedLanguages ::: $selectedLanguages");
    }
    update([Constant.idLanguageSection]);
  }

  /// selected language
  bool isSelected(String language) {
    return selectedLanguages.contains(language);
  }

  /// all language
  Future<void> loadAllLanguages() async {
    try {
      final String response =
          await rootBundle.loadString('assets/all_language.json');
      final Map<String, dynamic> data = json.decode(response);

      allLanguages = data.values.map<String>((e) => e.toString()).toList();

      update([Constant.idLanguageSection]); // if using GetX
    } catch (e, st) {
      log('Error loading languages: $e\n$st');
    }
  }

  /// click photo
  takePhoto() async {
    xFiles = await imagePicker.pickImage(
        source: ImageSource.camera, imageQuality: 100);
    if (xFiles != null) {
      pickImage = xFiles!.path;
      log("Camera Image Path ::: $pickImage");
    }
    update();
  }

  /// pick image from gallery
  getImageFromGallery() async {
    xFiles = await imagePicker.pickImage(
        source: ImageSource.gallery, imageQuality: 100);
    if (xFiles != null) {
      pickImage = xFiles!.path;
      log("Gallery Image Path ::: $pickImage");
    }
    update();
  }

  /// get talk topic
  void getTalkTopic() async {
    try {
      isLoading = true;
      update([Constant.talkAboutTopic]);

      var data = await TalkTopicApi.callApi();
      talkTopicsModel = data;
      talkTopic = (data?.talkTopics ?? [])
          .where((topic) => !PlayPolicyTopicFilter.isRestrictedText(
              '${topic.name ?? ''} ${topic.icon ?? ''}'))
          .toList();

      final savedCategoryIds =
          Database.fetchListenerProfileModel?.data?.categoryIds ?? [];
      final savedTopics = PlayPolicyTopicFilter.visibleNames(
          Database.fetchListenerProfileModel?.data?.talkTopics);
      selectedTopics.clear(); // Reset selection

      if (savedCategoryIds.isNotEmpty) {
        for (final savedCategoryId in savedCategoryIds) {
          final matchIndex =
              talkTopic.indexWhere((element) => element.id == savedCategoryId);
          if (matchIndex != -1) {
            selectedTopics.add(matchIndex);
          }
        }
      } else {
        for (var saved in savedTopics) {
          final matchIndex =
              talkTopic.indexWhere((element) => element.name == saved);
          if (matchIndex != -1) {
            selectedTopics.add(matchIndex);
          }
        }
      }

      // /// ✅ Match saved topic name from database
      // final savedTopics = Database.fetchListenerProfileModel?.data?.talkTopics;
      // if (savedTopics != null && savedTopics.isNotEmpty) {
      //   final savedTopicName = savedTopics.first; // Assuming only one is saved
      //   final index = talkTopic.indexWhere((element) => element.name == savedTopicName);
      //   if (index != -1) {
      //     selectedTopic = index;
      //   }
      // }

      update([Constant.talkAboutTopic]);
    } catch (e, st) {
      log('getTalkTopicApi error: $e\n$st');
    } finally {
      isLoading = false;
      update([Constant.talkAboutTopic]);
      log('getTalkTopicApi finally');
    }
  }

  /// save button on tap
  Future<void> onSaveProfile() async {
    Utils.showLog(
        "Click On Save Profile => ${Database.fetchListenerProfileModel?.data?.id}");

    final newAudioPrice = int.tryParse(ratePrivateAudioCallCnt.text.trim()) ?? 0;
    final newVideoPrice = int.tryParse(ratePrivateVideoCallCnt.text.trim()) ?? 0;
    final newInPersonPrice = int.tryParse(rateInPersonSessionCnt.text.trim()) ?? 0;

    final minAudio = Database.settingApiModel?.data?.audioCallRatePrivate ?? 0;
    final maxAudio = Database.settingApiModel?.data?.maxAudioCallRatePrivate ?? 0;
    final minVideo = Database.settingApiModel?.data?.videoCallRatePrivate ?? 0;
    final maxVideo = Database.settingApiModel?.data?.maxVideoCallRatePrivate ?? 0;
    final minInPerson = Database.settingApiModel?.data?.inPersonSessionRatePrivate ?? 0;
    final maxInPerson = Database.settingApiModel?.data?.maxInPersonSessionRatePrivate ?? 0;

    if (newAudioPrice < minAudio) {
      Utils.showToast(Get.context!, 'Audio price cannot be less than $minAudio credits.');
      return;
    }
    if (maxAudio > 0 && newAudioPrice > maxAudio) {
      Utils.showToast(Get.context!, 'Audio price cannot exceed $maxAudio credits.');
      return;
    }

    if (newVideoPrice < minVideo) {
      Utils.showToast(Get.context!, 'Video price cannot be less than $minVideo credits.');
      return;
    }
    if (maxVideo > 0 && newVideoPrice > maxVideo) {
      Utils.showToast(Get.context!, 'Video price cannot exceed $maxVideo credits.');
      return;
    }

    if (newInPersonPrice < minInPerson) {
      Utils.showToast(Get.context!, 'In-Person price cannot be less than $minInPerson credits.');
      return;
    }
    if (maxInPerson > 0 && newInPersonPrice > maxInPerson) {
      Utils.showToast(Get.context!, 'In-Person price cannot exceed $maxInPerson credits.');
      return;
    }

    Get.dialog(const LoadingWidget(),
        barrierDismissible: false); // Start Loading...

    await callEditApi();
  }

  /// listener profile edit
  Future<void> callEditApi() async {
    final languageString = selectedLanguages.isNotEmpty
        ? selectedLanguages.join(',')
        : (Database.fetchListenerProfileModel?.data?.language?.join(',') ?? '');
    final selectedTopicNames = selectedTopics
        .where((index) => index >= 0 && index < talkTopic.length)
        .map((index) => (talkTopic[index].name ?? '').trim())
        .where((name) => name.isNotEmpty)
        .toList();

    final selectedCategoryIds = selectedTopics
        .where((index) => index >= 0 && index < talkTopic.length)
        .map((index) => (talkTopic[index].id ?? '').trim())
        .where((id) => id.isNotEmpty)
        .toList();

    String talkTopics = selectedTopicNames.isNotEmpty
        ? selectedTopicNames.join(',')
        : PlayPolicyTopicFilter.visibleNames(
                Database.fetchListenerProfileModel?.data?.talkTopics)
            .join(',');

    if (selectedTopicName != null && selectedTopicName!.isNotEmpty) {
      talkTopics = selectedTopicName!;
    }

    String categoryIds =
        selectedCategoryIds.isNotEmpty ? selectedCategoryIds.join(',') : '';

    // Build clinic details JSON
    final clinicDetailsMap = {
      'clinicName': clinicNameCnt.text.trim(),
      'address': {
        'full': clinicAddressCnt.text.trim(),
        'street': clinicAddressCnt.text.trim(),
        'city': clinicCityCnt.text.trim(),
        'state': clinicStateCnt.text.trim(),
        'country': clinicCountryCnt.text.trim(),
        'postalCode': clinicPostalCodeCnt.text.trim(),
      },
      'floorSuite': clinicFloorSuiteCnt.text.trim(),
      'landmark': clinicLandmarkCnt.text.trim(),
      'parkingInfo': clinicParkingInfoCnt.text.trim(),
      'contactPhone': clinicContactPhoneCnt.text.trim(),
      'contactEmail': clinicContactEmailCnt.text.trim(),
      'consultationInstructions': clinicInstructionsCnt.text.trim(),
    };

    // Build consultation modes JSON
    final consultationModesMap = {
      'online': true,
      'inPerson': rateInPersonSessionCnt.text.trim().isNotEmpty,
    };

    // Build in-person pricing JSON
    final inPersonPricingMap = {
      'currency': 'USD',
      'oneToOneSession': int.tryParse(rateInPersonSessionCnt.text.trim()) ?? 0,
    };

    hostListenerProfileUpdateModel = await HostListenerProfileUpdateApi.callApi(
      name: nameCnt.text,
      nickName: nickNameCnt.text,
      language: languageString,
      listenerId: Database.fetchListenerProfileModel?.data?.id,
      image: (pickImage == "") ? profilePic : pickImage,
      selfIntro: introCnt.text,
      ratePrivateAudioCall: ratePrivateAudioCallCnt.text,
      ratePrivateVideoCall: ratePrivateVideoCallCnt.text,
      rateInPersonSession: rateInPersonSessionCnt.text,
      talkTopics: talkTopics,
      categoryIds: categoryIds,
      consultationModes: jsonEncode(consultationModesMap),
      inPersonPricing: jsonEncode(inPersonPricingMap),
      clinicDetails: jsonEncode(clinicDetailsMap),
    );

    if (hostListenerProfileUpdateModel?.status == true) {
      fetchListenerProfileModel = await FetchListenerProfileAPi.callApi(
        loginListenerId: Database.fetchListenerProfileModel?.data?.id ?? '',
      );
      Database.fetchListenerProfileModel = fetchListenerProfileModel;
      update();

      Get.close(2);
      fetchListenerProfileModel = await FetchListenerProfileAPi.callApi(
        loginListenerId: Database.fetchListenerProfileModel?.data?.id ?? '',
      );
      Database.fetchListenerProfileModel = fetchListenerProfileModel;
      update();
    } else {
      Utils.showToast(Get.context!, EnumLocale.txtSomeThingWentWrong.name.tr);
    }
  }
}
