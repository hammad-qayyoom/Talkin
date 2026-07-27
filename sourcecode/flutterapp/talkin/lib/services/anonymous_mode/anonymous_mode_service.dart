import 'dart:async';
import 'dart:ui';

import 'package:get/get.dart';
import 'package:notisboard/services/anonymous_mode/anonymous_mode_models.dart';
import 'package:notisboard/services/translation/translation_api.dart';
import 'package:notisboard/utils/constant.dart';
import 'package:notisboard/utils/database.dart';
import 'package:notisboard/utils/utils.dart';
import 'package:zego_effects_plugin/zego_effects_plugin.dart';
import 'package:zego_effects_plugin/zego_effects_defines.dart';
import 'package:zego_express_engine/zego_express_engine.dart';

/// Service to manage Anonymous Mode (AR masks, filters, beauty, background effects)
/// using ZEGO Effects SDK integrated with the existing ZEGO Express Engine.
class AnonymousModeService extends GetxController {
  bool _initialized = false;
  @override
  bool get initialized => _initialized;

  AnonymousModeConfig _config = const AnonymousModeConfig();
  AnonymousModeConfig get config => _config;

  bool _isEffectsEnvReady = false;

  // Server-side config (fetched from backend)
  bool _serverEnabled = false;
  bool get serverEnabled => _serverEnabled;
  bool _allowMasks = true;
  bool get allowMasks => _allowMasks;
  bool _allowFilters = true;
  bool get allowFilters => _allowFilters;
  bool _allowBeauty = true;
  bool get allowBeauty => _allowBeauty;
  bool _allowBackgroundBlur = true;
  bool get allowBackgroundBlur => _allowBackgroundBlur;
  bool _isCategoryAllowed = true;
  bool get isCategoryAllowed => _isCategoryAllowed;

  /// Whether anonymous mode is allowed based on server config and category
  bool get isAllowed => _serverEnabled && _isCategoryAllowed;

  final _effects = ZegoEffectsPlugin.instance;

  // ─── Lifecycle ───

  @override
  void onClose() {
    _destroyEffectsEnv();
    super.onClose();
  }

  /// Initialize the ZEGO Effects environment.
  /// Must be called AFTER ZEGO Express engine is created and camera preview is active.
  Future<void> initEffectsEnv({Size? resolution}) async {
    if (_isEffectsEnvReady) return;

    // Step 1: Load resources (copies models + resource bundles from APK assets to cache)
    try {
      await _effects.setResources();
      Utils.showLog("[AnonymousMode] Step 1/4: setResources OK");
    } catch (e) {
      Utils.showLog("[AnonymousMode] Step 1/4: setResources FAILED: $e");
    }

    // Step 2: Activate license
    // Use zegoEffectsAppSign if admin has set a separate Effects SDK key,
    // otherwise fall back to zegoAppSignIn (works for ZEGO Effects SDK v2.1.0+
    // when Effects service is enabled in ZEGO Console).
    final settingData = Database.settingApiModel?.data;
    final effectsAppSign = settingData?.zegoEffectsAppSign?.toString().trim() ?? '';
    final appSign = effectsAppSign.isNotEmpty
        ? effectsAppSign
        : (settingData?.zegoAppSignIn?.toString() ?? '');
    final appIdStr = settingData?.zegoAppId?.toString() ?? '';
    final appId = int.tryParse(appIdStr) ?? 0;

    Utils.showLog("[AnonymousMode] Using appSign source: ${effectsAppSign.isNotEmpty ? 'zegoEffectsAppSign' : 'zegoAppSignIn (fallback)'}");

    if (appId <= 0 || appSign.isEmpty) {
      Utils.showLog("[AnonymousMode] Step 2/4: SKIPPED (missing appId=$appId or appSign)");
      return;
    }

    try {
      final createResult = await _effects.create(appId, appSign);
      Utils.showLog("[AnonymousMode] Step 2/4: create result=$createResult (appId=$appId)");
      if (createResult != 0) {
        Utils.showLog("[AnonymousMode] License activation FAILED with code=$createResult — effects won't work");
        if (Get.context != null) {
          String errorMsg = 'Anonymous Mode effects failed ($createResult).';
          if (createResult == 5100006) {
            errorMsg = 'Zego AI Effects Error (5100006): Please enable "AI Effects" service in ZegoCloud Console & verify your App Package Name.';
          } else {
            errorMsg = 'Zego AI Effects Error ($createResult): Invalid License or AppSign. Please check Zego Console.';
          }
          Utils.showToast(Get.context!, errorMsg);
        }
        return;
      }
    } catch (e) {
      Utils.showLog("[AnonymousMode] Step 2/4: create THREW: $e");
      return;
    }

    // Step 3: Initialize env with resolution
    try {
      final size = resolution ?? const Size(720, 1280);
      final initResult = await _effects.initEnv(size);
      Utils.showLog("[AnonymousMode] Step 3/4: initEnv result=$initResult (size=$size)");
      if (initResult != 0) {
        Utils.showLog("[AnonymousMode] initEnv FAILED with code=$initResult");
        return;
      }
    } catch (e) {
      Utils.showLog("[AnonymousMode] Step 3/4: initEnv THREW: $e");
      return;
    }

    // Step 4: Enable custom video processing — THIS connects Effects SDK to Express Engine pipeline
    try {
      await _effects.enableImageProcessing(true);
      Utils.showLog("[AnonymousMode] Step 4/5: enableImageProcessing(true) OK");
    } catch (e) {
      Utils.showLog("[AnonymousMode] Step 4/5: enableImageProcessing FAILED: $e");
      return;
    }

    // Step 5: Activate Express Engine custom video processing pipeline
    // enableImageProcessing() only registers the handler at Dart plugin level.
    // This call activates the NATIVE pipeline so frames actually flow to onCapturedUnprocessedTextureData.
    // MUST be called before startPreview/startPublishingStream.
    try {
      await ZegoExpressEngine.instance.enableCustomVideoProcessing(
        true,
        ZegoCustomVideoProcessConfig(ZegoVideoBufferType.GLTexture2D),
      );
      Utils.showLog("[AnonymousMode] Step 5/5: enableCustomVideoProcessing(true) OK — native pipeline active");
    } catch (e) {
      Utils.showLog("[AnonymousMode] Step 5/5: enableCustomVideoProcessing FAILED: $e");
      return;
    }

    // Enable face detection (required for pendant/mask positioning)
    try {
      await _effects.enableFaceDetection(true);
      Utils.showLog("[AnonymousMode] Face detection enabled");
    } catch (e) {
      Utils.showLog("[AnonymousMode] enableFaceDetection failed: $e");
    }

    _isEffectsEnvReady = true;
    Utils.showLog("[AnonymousMode] Effects environment FULLY initialized and connected to video pipeline");

    // Re-apply any effects that were selected before init completed
    if (_config.enabled) {
      await _applyAllEffects();
      Utils.showLog("[AnonymousMode] Re-applied pending effects after init");
    }

    // Register error callback for diagnostics
    try {
      await ZegoEffectsPlugin.registerEventCallback(
        onEffectsError: (errorCode, desc) {
          Utils.showLog("[AnonymousMode] EFFECTS ERROR: code=$errorCode desc=$desc");
        },
      );
    } catch (e) {
      Utils.showLog("[AnonymousMode] registerEventCallback failed: $e");
    }
  }

  /// Fetch anonymous mode config from backend.
  /// Optionally pass categoryId to check category-specific restrictions.
  Future<void> fetchConfig({String? categoryId}) async {
    try {
      final data = await TranslationApi.fetchAnonymousConfig(categoryId: categoryId);
      if (data != null) {
        _serverEnabled = data['enabled'] == true;
        _allowMasks = data['allowMasks'] != false;
        _allowFilters = data['allowFilters'] != false;
        _allowBeauty = data['allowBeauty'] != false;
        _allowBackgroundBlur = data['allowBackgroundBlur'] != false;
        _isCategoryAllowed = data['isCategoryAllowed'] != false;
        update([Constant.idAnonymousMode]);
        Utils.showLog("[AnonymousMode] Config fetched: enabled=$_serverEnabled, categoryAllowed=$_isCategoryAllowed");
      }
    } catch (e) {
      Utils.showLog("[AnonymousMode] fetchConfig error: $e");
    }
  }

  /// Destroy the ZEGO Effects environment. Call when leaving the call.
  Future<void> _destroyEffectsEnv() async {
    if (!_isEffectsEnvReady) return;

    // Disable Express Engine custom video processing pipeline first
    try {
      await ZegoExpressEngine.instance.enableCustomVideoProcessing(
        false,
        ZegoCustomVideoProcessConfig(ZegoVideoBufferType.GLTexture2D),
      );
      Utils.showLog("[AnonymousMode] Disabled Express Engine custom video processing");
    } catch (e) {
      Utils.showLog("[AnonymousMode] disableCustomVideoProcessing failed: $e");
    }

    try {
      await _effects.enableImageProcessing(false);
      Utils.showLog("[AnonymousMode] Disabled image processing");
    } catch (e) {
      Utils.showLog("[AnonymousMode] disableImageProcessing failed: $e");
    }
    try {
      await _effects.uninitEnv();
      _isEffectsEnvReady = false;
      Utils.showLog("[AnonymousMode] Effects env destroyed");
    } catch (e) {
      Utils.showLog("[AnonymousMode] Effects env destroy failed: $e");
    }
    try {
      await ZegoEffectsPlugin.destroyEventCallback();
    } catch (_) {}
  }

  // ─── Anonymous Mode Toggle ───

  void toggleAnonymousMode() {
    final newEnabled = !_config.enabled;
    _config = _config.copyWith(enabled: newEnabled);

    if (!newEnabled) {
      _clearAllEffects();
    } else {
      _applyAllEffects();
      savePreferences();
    }

    update([Constant.idAnonymousMode, Constant.idAnonymousPanel]);
    Utils.showLog("[AnonymousMode] toggled: $newEnabled");
  }

  void setAnonymousMode(bool enabled) {
    if (_config.enabled == enabled) return;
    _config = _config.copyWith(enabled: enabled);

    if (!enabled) {
      _clearAllEffects();
    } else {
      _applyAllEffects();
    }

    update([Constant.idAnonymousMode, Constant.idAnonymousPanel]);
  }

  // ─── Mask / Sticker (Pendant) ───

  void selectMask(String? maskId) {
    // Auto-enable anonymous mode if user selects a mask while mode is OFF
    if (!_config.enabled) {
      _config = _config.copyWith(enabled: true);
    }
    _config = _config.copyWith(selectedMaskId: maskId);
    _applyMask(maskId);
    savePreferences();
    update([Constant.idAnonymousMode, Constant.idAnonymousPanel]);
  }

  void clearMask() {
    // Explicitly pass null via sentinel-aware copyWith
    _config = _config.copyWith(selectedMaskId: null);
    _applyMask(null);
    savePreferences();
    update([Constant.idAnonymousMode, Constant.idAnonymousPanel]);
  }

  Future<void> _applyMask(String? maskId) async {
    if (!_isEffectsEnvReady) {
      Utils.showLog("[AnonymousMode] _applyMask skipped — effects env NOT ready. Call initEffectsEnv() first.");
      return;
    }
    try {
      if (maskId == null) {
        await _effects.setPendant('');
        Utils.showLog("[AnonymousMode] Mask cleared");
        return;
      }
      final mask = AnonymousMask.builtInMasks.firstWhere(
        (m) => m.id == maskId,
        orElse: () => const AnonymousMask(id: '', name: '', resourcePath: ''),
      );
      if (mask.resourcePath.isNotEmpty) {
        Utils.showLog("[AnonymousMode] Applying mask: $maskId => ${mask.resourcePath}");
        await _effects.setPendant(mask.resourcePath);
        Utils.showLog("[AnonymousMode] Mask applied: ${mask.resourcePath}");
      } else {
        Utils.showLog("[AnonymousMode] Mask '$maskId' not found in builtInMasks");
      }
    } catch (e) {
      Utils.showLog("[AnonymousMode] applyMask error: $e");
      if (Get.context != null) {
        Utils.showToast(Get.context!, 'Failed to apply mask. Please try again.');
      }
    }
  }

  // ─── Filter ───

  void selectFilter(String? filterId) {
    // Auto-enable anonymous mode if user selects a filter while mode is OFF
    if (!_config.enabled) {
      _config = _config.copyWith(enabled: true);
    }
    _config = _config.copyWith(selectedFilterId: filterId);
    _applyFilter(filterId);
    savePreferences();
    update([Constant.idAnonymousMode, Constant.idAnonymousPanel]);
  }

  Future<void> _applyFilter(String? filterId) async {
    if (!_isEffectsEnvReady) {
      Utils.showLog("[AnonymousMode] _applyFilter skipped — effects env NOT ready.");
      return;
    }
    try {
      if (filterId == null || filterId == 'filter_none') {
        await _effects.setFilter('');
        Utils.showLog("[AnonymousMode] Filter cleared");
        return;
      }
      final filter = AnonymousFilter.builtInFilters.firstWhere(
        (f) => f.id == filterId,
        orElse: () => const AnonymousFilter(id: '', name: '', resourcePath: '', category: ''),
      );
      if (filter.resourcePath.isNotEmpty) {
        Utils.showLog("[AnonymousMode] Applying filter: $filterId => ${filter.resourcePath}");
        await _effects.setFilter(filter.resourcePath);
        Utils.showLog("[AnonymousMode] Filter applied: ${filter.resourcePath}");
      } else {
        Utils.showLog("[AnonymousMode] Filter '$filterId' not found in builtInFilters");
      }
    } catch (e) {
      Utils.showLog("[AnonymousMode] applyFilter error: $e");
      if (Get.context != null) {
        Utils.showToast(Get.context!, 'Failed to apply filter. Please try again.');
      }
    }
  }

  // ─── Beauty Settings ───

  void updateBeautySettings(BeautySettings settings) {
    _config = _config.copyWith(beautySettings: settings);
    _applyBeautySettings(settings);
    savePreferences();
    update([Constant.idAnonymousMode, Constant.idAnonymousPanel]);
  }

  void setSmoothIntensity(double value) {
    final newSettings = _config.beautySettings.copyWith(smoothIntensity: value);
    updateBeautySettings(newSettings);
  }

  void setWhitenIntensity(double value) {
    final newSettings = _config.beautySettings.copyWith(whitenIntensity: value);
    updateBeautySettings(newSettings);
  }

  void setRosyIntensity(double value) {
    final newSettings = _config.beautySettings.copyWith(rosyIntensity: value);
    updateBeautySettings(newSettings);
  }

  void setSharpenIntensity(double value) {
    final newSettings = _config.beautySettings.copyWith(sharpenIntensity: value);
    updateBeautySettings(newSettings);
  }

  Future<void> _applyBeautySettings(BeautySettings settings) async {
    if (!_isEffectsEnvReady) return;
    try {
      // Smooth
      await _effects.enableSmooth(settings.smoothIntensity > 0);
      final smoothParam = ZegoEffectsSmoothParam()
        ..intensity = settings.smoothIntensity.toInt();
      await _effects.setSmoothParam(smoothParam);

      // Whiten
      await _effects.enableWhiten(settings.whitenIntensity > 0);
      final whitenParam = ZegoEffectsWhitenParam()
        ..intensity = settings.whitenIntensity.toInt();
      await _effects.setWhitenParam(whitenParam);

      // Rosy
      await _effects.enableRosy(settings.rosyIntensity > 0);
      final rosyParam = ZegoEffectsRosyParam()
        ..intensity = settings.rosyIntensity.toInt();
      await _effects.setRosyParam(rosyParam);

      // Sharpen
      await _effects.enableSharpen(settings.sharpenIntensity > 0);
      final sharpenParam = ZegoEffectsSharpenParam()
        ..intensity = settings.sharpenIntensity.toInt();
      await _effects.setSharpenParam(sharpenParam);
    } catch (e) {
      Utils.showLog("[AnonymousMode] applyBeauty error: $e");
      if (Get.context != null) {
        Utils.showToast(Get.context!, 'Failed to apply beauty effects. Please try again.');
      }
    }
  }

  // ─── Background Effects ───

  void setBackgroundMode(BackgroundMode mode) {
    _config = _config.copyWith(backgroundMode: mode);
    _applyBackgroundMode(mode);
    savePreferences();
    update([Constant.idAnonymousMode, Constant.idAnonymousPanel]);
  }

  void setBackgroundBlurIntensity(double value) {
    _config = _config.copyWith(backgroundBlurIntensity: value);
    if (_config.backgroundMode == BackgroundMode.blur) {
      _applyBackgroundMode(BackgroundMode.blur);
    }
    update([Constant.idAnonymousPanel]);
  }

  void setBackgroundMosaicIntensity(double value) {
    _config = _config.copyWith(backgroundMosaicIntensity: value);
    if (_config.backgroundMode == BackgroundMode.mosaic) {
      _applyBackgroundMode(BackgroundMode.mosaic);
    }
    update([Constant.idAnonymousPanel]);
  }

  Future<void> _applyBackgroundMode(BackgroundMode mode) async {
    if (!_isEffectsEnvReady) return;
    try {
      switch (mode) {
        case BackgroundMode.none:
          await _effects.enablePortraitSegmentation(false);
          await _effects.enableChromaKey(false);
          break;
        case BackgroundMode.blur:
          await _effects.enablePortraitSegmentation(true);
          await _effects.enablePortraitSegmentationBackgroundBlur(true);
          break;
        case BackgroundMode.mosaic:
          await _effects.enablePortraitSegmentation(true);
          await _effects.enablePortraitSegmentationBackgroundMosaic(true);
          break;
        case BackgroundMode.customImage:
          await _effects.enablePortraitSegmentation(false);
          await _effects.enableChromaKey(true);
          break;
      }
    } catch (e) {
      Utils.showLog("[AnonymousMode] applyBackground error: $e");
      if (Get.context != null) {
        Utils.showToast(Get.context!, 'Failed to apply background effect. Please try again.');
      }
    }
  }

  // ─── Apply All / Clear All ───

  Future<void> _applyAllEffects() async {
    if (!_isEffectsEnvReady) return;

    // Apply beauty settings
    if (!_config.beautySettings.isEmpty) {
      await _applyBeautySettings(_config.beautySettings);
    }

    // Apply mask
    if (_config.selectedMaskId != null) {
      await _applyMask(_config.selectedMaskId);
    }

    // Apply filter
    if (_config.selectedFilterId != null) {
      await _applyFilter(_config.selectedFilterId);
    }

    // Apply background
    if (_config.backgroundMode != BackgroundMode.none) {
      await _applyBackgroundMode(_config.backgroundMode);
    }
  }

  Future<void> _clearAllEffects() async {
    if (!_isEffectsEnvReady) return;

    // Clear beauty
    await _applyBeautySettings(BeautySettings.empty);

    // Clear mask
    await _applyMask(null);

    // Clear filter
    await _applyFilter(null);

    // Clear background
    await _applyBackgroundMode(BackgroundMode.none);
  }

  // ─── Reset ───

  void resetConfig() {
    _config = const AnonymousModeConfig();
    _clearAllEffects();
    update([Constant.idAnonymousMode, Constant.idAnonymousPanel]);
  }

  // ─── Presets for Therapy/Privacy ───

  /// Quick privacy preset: blur background + subtle beauty
  void applyPrivacyPreset() {
    _config = _config.copyWith(
      enabled: true,
      backgroundMode: BackgroundMode.blur,
      beautySettings: const BeautySettings(
        smoothIntensity: 30,
        whitenIntensity: 20,
        rosyIntensity: 10,
        sharpenIntensity: 20,
      ),
      selectedMaskId: null,
      selectedFilterId: null,
    );
    _applyAllEffects();
    update([Constant.idAnonymousMode, Constant.idAnonymousPanel]);
  }

  /// Quick fun preset: cat mask + dreamy filter
  void applyFunPreset() {
    _config = _config.copyWith(
      enabled: true,
      selectedMaskId: 'mask_cat',
      selectedFilterId: 'filter_dreamy_cozily',
      backgroundMode: BackgroundMode.none,
      beautySettings: const BeautySettings(
        smoothIntensity: 40,
        whitenIntensity: 30,
        rosyIntensity: 20,
        sharpenIntensity: 30,
      ),
    );
    _applyAllEffects();
    update([Constant.idAnonymousMode, Constant.idAnonymousPanel]);
  }

  // ─── Preference Persistence ───

  static const _prefKey = 'anonymous_mode_preferences';

  /// Save current config to local storage.
  void savePreferences() {
    try {
      final data = {
        'enabled': _config.enabled,
        'selectedMaskId': _config.selectedMaskId,
        'selectedFilterId': _config.selectedFilterId,
        'backgroundMode': _config.backgroundMode.index,
        'backgroundBlurIntensity': _config.backgroundBlurIntensity,
        'backgroundMosaicIntensity': _config.backgroundMosaicIntensity,
        'smoothIntensity': _config.beautySettings.smoothIntensity,
        'whitenIntensity': _config.beautySettings.whitenIntensity,
        'rosyIntensity': _config.beautySettings.rosyIntensity,
        'sharpenIntensity': _config.beautySettings.sharpenIntensity,
      };
      Constant.storage.write(_prefKey, data);
      Utils.showLog("[AnonymousMode] Preferences saved");
    } catch (e) {
      Utils.showLog("[AnonymousMode] savePreferences error: $e");
    }
  }

  /// Load saved preferences from local storage.
  /// Returns true if preferences were found and applied.
  bool loadSavedPreferences() {
    try {
      final data = Constant.storage.read<Map<String, dynamic>>(_prefKey);
      if (data == null) return false;

      final maskId = data['selectedMaskId'] as String?;
      final filterId = data['selectedFilterId'] as String?;
      final bgModeIndex = data['backgroundMode'] as int? ?? 0;
      final bgMode = BackgroundMode.values[bgModeIndex.clamp(0, BackgroundMode.values.length - 1)];

      final beauty = BeautySettings(
        smoothIntensity: (data['smoothIntensity'] as num?)?.toDouble() ?? 50.0,
        whitenIntensity: (data['whitenIntensity'] as num?)?.toDouble() ?? 50.0,
        rosyIntensity: (data['rosyIntensity'] as num?)?.toDouble() ?? 50.0,
        sharpenIntensity: (data['sharpenIntensity'] as num?)?.toDouble() ?? 50.0,
      );

      _config = _config.copyWith(
        selectedMaskId: maskId,
        selectedFilterId: filterId,
        backgroundMode: bgMode,
        backgroundBlurIntensity: (data['backgroundBlurIntensity'] as num?)?.toDouble() ?? 0.5,
        backgroundMosaicIntensity: (data['backgroundMosaicIntensity'] as num?)?.toDouble() ?? 0.5,
        beautySettings: beauty,
      );

      Utils.showLog("[AnonymousMode] Preferences loaded");
      update([Constant.idAnonymousMode, Constant.idAnonymousPanel]);
      return true;
    } catch (e) {
      Utils.showLog("[AnonymousMode] loadSavedPreferences error: $e");
      return false;
    }
  }

  /// Whether saved preferences exist.
  bool get hasSavedPreferences => Constant.storage.hasData(_prefKey);
}
