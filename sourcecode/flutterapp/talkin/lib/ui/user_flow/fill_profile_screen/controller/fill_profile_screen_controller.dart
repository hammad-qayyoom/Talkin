import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:notisboard/custom/custom_country_picker/country_picker.dart';
import 'package:notisboard/custom/progress_indicator/progress_dialog.dart';
import 'package:notisboard/routes/app_routes.dart';
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

class FillProfileScreenController extends GetxController {
  static const int _minimumAllowedAge = 18;

  final formKey = GlobalKey<FormState>();
  XFile? xFiles;
  String? name;
  String? email;
  String? photo;
  String? pickImage;
  TextEditingController dateController = TextEditingController();
  TextEditingController genderController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController nickNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController numberController = TextEditingController();
  TextEditingController flagController = TextEditingController();
  TextEditingController countryController = TextEditingController();

  EditProfileModel? editProfileModel;
  FetchLoginUserProfileModel? fetchLoginUserProfileModel;
  // MainScreenController mainScreenController = Get.put(MainScreenController());
  int selectedIndex = 0; // Already hase
  String? dialCode;

  final ImagePicker imagePicker = ImagePicker();
  dynamic args = Get.arguments;

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

  @override
  void onInit() async {
    // await getDataFromArgs();
    // await setDataFromArgs();

    // Set default gender if not stored
    if (Database.loginUserGender.isEmpty) {
      selectedIndex = 0;
      final defaultGender = EnumLocale.txtMale.name.tr;
      genderController.text = defaultGender;
      Database.onSetLoginUserGender(defaultGender);
    } else {
      // Set textfield value from database
      genderController.text = Database.loginUserGender;
      selectedIndex = Database.loginUserGender.toLowerCase() ==
              EnumLocale.txtFemale.name.tr.toLowerCase()
          ? 1
          : 0;
    }
    nameController.text =
        Database.fetchLoginUserProfileModel?.user?.fullName ?? '';
    emailController.text =
        Database.fetchLoginUserProfileModel?.user?.email ?? '';
    numberController.text =
        Database.fetchLoginUserProfileModel?.user?.phoneNumber ?? '';
    photo = Database.fetchLoginUserProfileModel?.user?.profilePic ?? '';
    dialCode = Database.dialCode;

    super.onInit();
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
    genderController.text = selectedGenderText;

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

  /// Get image from gallery
  getImageFromGallery() async {
    xFiles = await imagePicker.pickImage(
        source: ImageSource.gallery, imageQuality: 100);
    if (xFiles != null) {
      pickImage = xFiles!.path;
      log("Gallery Image Path ::: $pickImage");
    }
    update();
  }

  /// Get image from camera
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

    if (photo == "" && pickImage == null) {
      Utils.showToast(
          Get.context!, EnumLocale.txtPleaseSelectProfileImage.name.tr);
    } else if (nickNameController.text.trim().isEmpty) {
      Utils.showToast(Get.context!, EnumLocale.txtPleaseEnterNickName.name.tr);
    } else if (numberController.text.trim().isEmpty) {
      Utils.showToast(
          Get.context!, EnumLocale.txtPleaseEnterMobileNumber.name.tr);
    } else {
      Get.dialog(const LoadingWidget(),
          barrierDismissible: false); // Start Loading...

      await callEditApi();
    }
  }

  /// fill profile api
  Future<void> callEditApi({String? image}) async {
    final token = await FirebaseAccessToken.onGet();
    final parsedBirthDate = _parseBirthDate(dateController.text);
    final normalizedBirthDate = parsedBirthDate == null
        ? dateController.text.trim()
        : DateFormat('yyyy-MM-dd').format(parsedBirthDate);
    final resolvedAge =
        parsedBirthDate == null ? null : _calculateAge(parsedBirthDate);

    log('Database.countryCode  ::::  ${Database.selectedCountryCode}');
    editProfileModel = await EditProfileApi.callApi(
      country: countryController.text,
      countryFlag: flagController.text,
      countryCode: Database.selectedCountryCode,
      uid: Database.loginUserFirebaseId,
      birthDate: normalizedBirthDate,
      age: resolvedAge ?? 25,
      image: pickImage == "" ? photo : pickImage,
      nickName: nickNameController.text,
      gender: Database.loginUserGender,
      phoneNumber: numberController.text,
      fullName: nameController.text,
      email: emailController.text,
    );

    if (editProfileModel?.status == true) {
      Database.fetchLoginUserProfileModel =
          await FetchLoginUserProfileApi.callApi(
              loginUserId: Database.loginUserFirebaseId, token: token ?? '');
      Database.onSetLoginUserProfilePic(
          Database.fetchLoginUserProfileModel?.user?.profilePic ?? "");
      Database.onSetLoginUserName(
          Database.fetchLoginUserProfileModel!.user!.fullName!);
      Database.onSetLoginUserNickName(
          Database.fetchLoginUserProfileModel?.user?.nickName ?? "");
      Database.onSetLoginUserEmail(
          Database.fetchLoginUserProfileModel!.user!.email!);
      Database.onSetLoginUserCountry(
          Database.fetchLoginUserProfileModel!.user!.country!);
      Database.onSetLoginUserCountryFlag(
          Database.fetchLoginUserProfileModel!.user!.countryFlag!);
      Database.onSetLoginUserBirthDate(
          Database.fetchLoginUserProfileModel?.user?.birthDate ?? "");
      Database.onSetLoginUserGender(
          Database.fetchLoginUserProfileModel?.user?.gender ?? "Male");
      Database.onSetLoginUserPhoneNumber(
          Database.fetchLoginUserProfileModel?.user?.phoneNumber ?? "");
      Database.fetchLoginUserProfileModel = fetchLoginUserProfileModel;

      log(" loginUserProfilePic ::: ${Database.loginUserProfilePic}");

      update([Constant.idProfile]);

      log("${Database.fetchLoginUserProfileModel?.user}");
      fetchLoginUserProfileModel = await FetchLoginUserProfileApi.callApi(
          loginUserId: Database.loginUserFirebaseId, token: token ?? '');
      Database.fetchLoginUserProfileModel = fetchLoginUserProfileModel;

      update();

      Database.onSetFillProfile(true);
      _closeLoadingIfOpen();

      if (Database.fetchLoginUserProfileModel?.user?.isListener == true) {
        Get.toNamed(AppRoutes.hostBottomBar);
      } else {
        Get.toNamed(AppRoutes.bottomBar);
      }
    } else {
      _closeLoadingIfOpen();
      Utils.showToast(
          Get.context!,
          editProfileModel?.message?.trim().isNotEmpty == true
              ? editProfileModel!.message!
              : EnumLocale.txtSomeThingWentWrong.name.tr);
    }
  }

  /// Country select
  Future<void> onChangeCountry(BuildContext context) async {
    debugPrint("onChangeCountry Called");

    CustomCountryPicker.pickCountry(
      context,
      false,
      (country) {
        flagController.text = country.flagEmoji;
        countryController.text = country.name;
        update([Constant.idChangeCountry]);
        debugPrint(
            "Country selected: ${country.name}, Flag: ${country.flagEmoji}");
        Utils.showLog(
            "Selected Country => Flag: ${flagController.text}, Name: ${countryController.text}");
      },
    );

    update([Constant.idChangeCountry]);
  }
}
