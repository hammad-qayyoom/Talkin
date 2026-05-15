import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:notisboard/custom/custom_country_picker/country_picker.dart';
import 'package:notisboard/custom/progress_indicator/progress_dialog.dart';
import 'package:notisboard/ui/user_flow/edit_profile_screen/api/edit_profile_api.dart';
import 'package:notisboard/ui/user_flow/edit_profile_screen/model/edit_profile_model.dart';
import 'package:notisboard/ui/user_flow/splash_screen_page/api/fetch_login_user_profile_api.dart';
import 'package:notisboard/ui/user_flow/splash_screen_page/model/fetch_login_user_profile_model.dart';
import 'package:notisboard/utils/app_asset.dart';
import 'package:notisboard/utils/app_color.dart';
import 'package:notisboard/utils/constant.dart';
import 'package:notisboard/utils/database.dart';
import 'package:notisboard/utils/enums.dart';
import 'package:notisboard/utils/firebse_access_token.dart';
import 'package:notisboard/utils/font_style.dart';
import 'package:notisboard/utils/utils.dart';

class EditProfileController extends GetxController {
  static const int _minimumAllowedAge = 18;

  final formKey = GlobalKey<FormState>();
  TextEditingController dateController = TextEditingController();
  TextEditingController nickNameCnt = TextEditingController();
  TextEditingController nameCnt = TextEditingController();
  TextEditingController emailCnt = TextEditingController();
  TextEditingController passwordCnt = TextEditingController();
  TextEditingController confirmPasswordCnt = TextEditingController();
  TextEditingController genderCnt = TextEditingController();
  TextEditingController mobileNumberCnt = TextEditingController();
  TextEditingController flagController = TextEditingController();
  TextEditingController countryController = TextEditingController();
  // MainScreenController mainScreenController = Get.put(MainScreenController());
  XFile? xFiles;
  final ImagePicker imagePicker = ImagePicker();
  int selectedIndex = 0; // Already hase
  String? profilePic;
  String? pickImage;
  EditProfileModel? editProfileModel;
  String? dialCode;

  FetchLoginUserProfileModel? fetchLoginUserProfileModel;

  bool get canEditEmail => Database.loginType != 5;

  bool get shouldShowPasswordFields =>
      Database.isGuestMode || Database.loginType == 2 || Database.loginType == 4;

  @override
  void onInit() {
    log("Database.loginUserNickName  :: ${Database.loginUserNickName}");
    log("Database.loginUserBirthDate :: ${Database.loginUserBirthDate}");
    log("Database.loginUserEmail  :: ${Database.loginUserEmail}");
    log("Database.loginUserNickName  :: ${Database.loginUserNickName}");
    log("Database.loginUserGender  :: ${Database.loginUserGender}");
    log("Database.loginUserPhoneNumber  :: ${Database.loginUserPhoneNumber}");
    log("Database.loginUserProfilePic  ::  ${Database.loginUserProfilePic}");
    log("fetchLoginUserProfileModel?.user?.country  ::  ${fetchLoginUserProfileModel?.user?.country ?? ''}");
    log("fetchLoginUserProfileModel?.user?.countryFlag  ::  ${fetchLoginUserProfileModel?.user?.countryFlag ?? ''}");

    dateController.text = Database.loginUserBirthDate;
    nameCnt.text = Database.loginUserName;
    emailCnt.text = Database.loginUserEmail;
    nickNameCnt.text = Database.loginUserNickName;
    genderCnt.text = Database.loginUserGender;
    mobileNumberCnt.text = Database.loginUserPhoneNumber;
    countryController.text = Database.country;
    flagController.text = Database.countryFlag;
    profilePic = Database.loginUserProfilePic;
    dialCode = Database.dialCode;

    if (Database.loginUserGender.toLowerCase() ==
        EnumLocale.txtFemale.name.tr.toLowerCase()) {
      selectedIndex = 1;
    } else {
      selectedIndex = 0;
    }

    super.onInit();
  }

  DateTime? _parseBirthDate(String value) {
    final rawValue = value.trim();
    if (rawValue.isEmpty) return null;

    final directParse = DateTime.tryParse(rawValue);
    if (directParse != null) return directParse;

    final formats = <String>[
      'dd / MM / yyyy',
      'dd/MM/yyyy',
      'MM / dd / yyyy',
      'MM/dd/yyyy',
      'yyyy-MM-dd',
    ];

    for (final format in formats) {
      try {
        return DateFormat(format).parseStrict(rawValue);
      } catch (_) {
        // Try the next known date format.
      }
    }

    return null;
  }

  int _calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    final hasBirthdayPassedThisYear = now.month > birthDate.month ||
        (now.month == birthDate.month && now.day >= birthDate.day);

    if (!hasBirthdayPassedThisYear) {
      age -= 1;
    }

    return age;
  }

  void _closeLoadingIfOpen() {
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }
  }

  List<Map<String, dynamic>> gender = [
    {
      "txt": EnumLocale.txtMale.name.tr,
      "image": AppAsset.maleImage,
    },
    {
      "txt": EnumLocale.txtFemale.name.tr,
      "image": AppAsset.femaleImage,
    },
  ];

  /// select gender
  void selectGender(int index) {
    selectedIndex = index;
    final selectedGenderText = gender[selectedIndex]['txt'] ?? 'Male';
    genderCnt.text = selectedGenderText;

    // Save selected gender locally
    Database.onSetLoginUserGender(selectedGenderText ?? 'Male');

    log("Database.loginUserGender :: ${Database.loginUserGender}");

    update([Constant.idGenderSelect]);
    // update();
  }

  /// select date
  Future<void> selectDate(BuildContext context) async {
    final now = DateTime.now();
    final DateTime latestAllowedDate =
        DateTime(now.year - _minimumAllowedAge, now.month, now.day);

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: latestAllowedDate,
      firstDate: DateTime(1900),
      lastDate: latestAllowedDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            dividerColor: Colors.transparent,
            colorScheme: ColorScheme.light(
              primary: AppColors.appColor,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.appColor,
                textStyle: AppFontStyle.fontStyleW600(
                  fontSize: 14,
                  fontColor: AppColors.appColor,
                ),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      dateController.text =
          "${picked.day.toString().padLeft(2, '0')} / ${picked.month.toString().padLeft(2, '0')} / ${picked.year}";
      update(); // For GetBuilder to update
    }
  }

  /// Image Picker from gallery
  getImageFromGallery() async {
    xFiles = await imagePicker.pickImage(
        source: ImageSource.gallery, imageQuality: 100);
    if (xFiles != null) {
      pickImage = xFiles!.path;
      log("Gallery Image Path ::: $pickImage");
    }
    update();
  }

  /// Take Photo
  takePhoto() async {
    xFiles = await imagePicker.pickImage(
        source: ImageSource.camera, imageQuality: 100);
    if (xFiles != null) {
      pickImage = xFiles!.path;
      log("Camera Image Path ::: $pickImage");
    }
    update();
  }

  /// save profile button on tap
  Future<void> onSaveProfile() async {
    Utils.showLog("Click On Save Profile => ${Database.loginUserId}");

    if (nickNameCnt.text.trim().isEmpty) {
      Utils.showToast(Get.context!, EnumLocale.txtPleaseEnterNickName.name.tr);
    } else {
      Get.dialog(const LoadingWidget(),
          barrierDismissible: false); // Start Loading...

      await callEditApi();
    }
  }

  /// edit profile api
  Future<void> callEditApi({String? image}) async {
    final token = await FirebaseAccessToken.onGet();
    final email = emailCnt.text.trim().toLowerCase();
    final password = passwordCnt.text.trim();
    final confirmPassword = confirmPasswordCnt.text.trim();

    if (email.isNotEmpty &&
        !RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email)) {
      _closeLoadingIfOpen();
      Utils.showToast(Get.context!, "Please enter a valid email address");
      return;
    }

    if ((password.isNotEmpty || confirmPassword.isNotEmpty) &&
        email.isEmpty) {
      _closeLoadingIfOpen();
      Utils.showToast(Get.context!, "Email is required to set a password");
      return;
    }

    if (password.isNotEmpty || confirmPassword.isNotEmpty) {
      if (password.length < 6) {
        _closeLoadingIfOpen();
        Utils.showToast(Get.context!, "Password must be at least 6 characters");
        return;
      }

      if (password != confirmPassword) {
        _closeLoadingIfOpen();
        Utils.showToast(Get.context!, "Passwords do not match");
        return;
      }

      final linked = await _linkEmailPasswordCredential(
        email: email,
        password: password,
      );
      if (!linked) {
        _closeLoadingIfOpen();
        return;
      }
    }

    final parsedBirthDate = _parseBirthDate(dateController.text);
    final normalizedBirthDate = parsedBirthDate == null
        ? dateController.text.trim()
        : DateFormat('yyyy-MM-dd').format(parsedBirthDate);
    final resolvedAge =
        parsedBirthDate == null ? null : _calculateAge(parsedBirthDate);

    log('Database.countryCode  ::::  ${Database.selectedCountryCode}');
    log('countryController.text  ::::  ${countryController.text}');
    log('flagController.text  ::::  ${flagController.text}');

    debugPrint("Calling EditProfileApi with following data:");
    debugPrint("country: ${countryController.text}");
    debugPrint("countryFlag: ${flagController.text}");
    debugPrint("countryCode: ${Database.selectedCountryCode}");
    debugPrint("uid: ${Database.loginUserFirebaseId}");
    debugPrint("birthDate: $normalizedBirthDate");
    debugPrint("age: $resolvedAge");
    debugPrint("image: ${pickImage == "" ? profilePic : pickImage}");
    debugPrint("nickName: ${nickNameCnt.text}");
    debugPrint("gender: ${Database.loginUserGender}");
    debugPrint("phoneNumber: ${mobileNumberCnt.text}");
    debugPrint("fullName: ${nameCnt.text}");

    editProfileModel = await EditProfileApi.callApi(
      country: countryController.text,
      countryFlag: flagController.text,
      countryCode: Database.selectedCountryCode,
      uid: Database.loginUserFirebaseId,
      birthDate: "2000-01-01",
      age: 25,
      image: pickImage == "" ? profilePic : pickImage,
      nickName: nickNameCnt.text,
      gender: Database.loginUserGender,
      phoneNumber: mobileNumberCnt.text,
      fullName: nameCnt.text,
      email: email,
      newPassword: password,
      confirmPassword: confirmPassword,
    );

    debugPrint("Calling EditProfileApi with following data:");
    debugPrint("country: ${countryController.text}");
    debugPrint("countryFlag: ${flagController.text}");
    debugPrint("countryCode: ${Database.selectedCountryCode}");
    debugPrint("uid: ${Database.loginUserFirebaseId}");
    debugPrint("birthDate: $normalizedBirthDate");
    debugPrint("age: $resolvedAge");
    debugPrint("image: ${pickImage == "" ? profilePic : pickImage}");
    debugPrint("nickName: ${nickNameCnt.text}");
    debugPrint("gender: ${Database.loginUserGender}");
    debugPrint("phoneNumber: ${mobileNumberCnt.text}");
    debugPrint("fullName: ${nameCnt.text}");

    if (editProfileModel?.status == true) {
      Database.onSetFillProfile(true);
      Utils.showToast(
          Get.context!, EnumLocale.txtProfileUpdateSuccessfully.name.tr);
      fetchLoginUserProfileModel = await FetchLoginUserProfileApi.callApi(
          loginUserId: Database.loginUserFirebaseId, token: token ?? '');

      Database.onSetLoginUserProfilePic(
          fetchLoginUserProfileModel?.user?.profilePic ?? "");
      Database.onSetLoginUserName(fetchLoginUserProfileModel!.user!.fullName!);
      Database.onSetLoginUserNickName(
          fetchLoginUserProfileModel?.user?.nickName ?? "");
      Database.onSetLoginUserEmail(fetchLoginUserProfileModel!.user!.email!);
      Database.onSetLoginType(fetchLoginUserProfileModel?.user?.loginType ??
          Database.loginType);
      if (password.isNotEmpty) {
        Database.onSetGuestMode(false);
      }
      Database.onSetLoginUserCountry(
          fetchLoginUserProfileModel!.user!.country!);
      Database.onSetLoginUserCountryFlag(
          fetchLoginUserProfileModel!.user!.countryFlag!);
      Database.onSetLoginUserBirthDate(
          fetchLoginUserProfileModel?.user?.birthDate ?? "");
      Database.onSetLoginUserGender(
          fetchLoginUserProfileModel?.user?.gender ?? "Male");
      Database.onSetLoginUserPhoneNumber(
          fetchLoginUserProfileModel?.user?.phoneNumber ?? "");
      Database.fetchLoginUserProfileModel = fetchLoginUserProfileModel;

      update([Constant.idProfile]);

      Get.close(2);
      fetchLoginUserProfileModel = await FetchLoginUserProfileApi.callApi(
          loginUserId: Database.loginUserFirebaseId, token: token ?? '');
      Database.fetchLoginUserProfileModel = fetchLoginUserProfileModel;

      update();
    } else {
      _closeLoadingIfOpen();
      Utils.showToast(
          Get.context!,
          editProfileModel?.message?.trim().isNotEmpty == true
              ? editProfileModel!.message!
              : EnumLocale.txtSomeThingWentWrong.name.tr);
    }
  }

  Future<bool> _linkEmailPasswordCredential({
    required String email,
    required String password,
  }) async {
    try {
      final user = firebase_auth.FirebaseAuth.instance.currentUser;
      if (user == null) {
        Utils.showToast(Get.context!, "Please login again to set password");
        return false;
      }

      final credential = firebase_auth.EmailAuthProvider.credential(
        email: email,
        password: password,
      );

      final providerIds =
          user.providerData.map((provider) => provider.providerId).toSet();

      if (providerIds.contains('password')) {
        if ((user.email ?? '').toLowerCase() != email) {
          await user.verifyBeforeUpdateEmail(email);
        }
        await user.updatePassword(password);
      } else {
        await user.linkWithCredential(credential);
      }

      return true;
    } on firebase_auth.FirebaseAuthException catch (error) {
      final message = switch (error.code) {
        'email-already-in-use' =>
          'This email is already linked to another account.',
        'credential-already-in-use' =>
          'This email is already linked to another account.',
        'requires-recent-login' =>
          'Please logout and login again before setting a password.',
        _ => error.message ?? 'Unable to set password. Please try again.',
      };
      Utils.showToast(Get.context!, message);
      return false;
    } catch (error) {
      Utils.showLog("Set password failed => $error");
      Utils.showToast(Get.context!, "Unable to set password. Please try again.");
      return false;
    }
  }

  /// Country
  Future<void> onChangeCountry(BuildContext context) async {
    CustomCountryPicker.pickCountry(
      context,
      false,
      (country) {
        flagController.text = country.flagEmoji;
        countryController.text = country.name;
        update([Constant.idChangeCountry]);
        debugPrint(
            "Country selected: ${country.name}, Flag: ${country.flagEmoji}");
        log("Selected Country => Flag: ${flagController.text}, Name: ${countryController.text}");
      },
    );

    update([Constant.idChangeCountry]);
  }
}
