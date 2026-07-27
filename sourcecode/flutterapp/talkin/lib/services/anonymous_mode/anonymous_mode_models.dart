import 'package:flutter/material.dart';

/// Sentinel value used in [AnonymousModeConfig.copyWith] to distinguish
/// between "not provided" (keep current) and "explicitly set to null".
class _Absent {
  const _Absent();
}

const _absent = _Absent();

class AnonymousMask {
  final String id;
  final String name;
  final String resourcePath;
  final String? thumbnailUrl;
  final IconData? icon;
  final bool isBuiltIn;

  const AnonymousMask({
    required this.id,
    required this.name,
    required this.resourcePath,
    this.thumbnailUrl,
    this.icon,
    this.isBuiltIn = true,
  });

  static const List<AnonymousMask> builtInMasks = [
    AnonymousMask(
      id: 'mask_cat',
      name: 'Cat',
      resourcePath: 'pendantCat',
      icon: Icons.pets,
      isBuiltIn: true,
    ),
    AnonymousMask(
      id: 'mask_dog',
      name: 'Dog',
      resourcePath: 'pendantAnimal',
      icon: Icons.pets,
      isBuiltIn: true,
    ),
    AnonymousMask(
      id: 'mask_rabbit',
      name: 'Rabbit',
      resourcePath: 'pendantBaby',
      icon: Icons.pets,
      isBuiltIn: true,
    ),
    AnonymousMask(
      id: 'mask_deer',
      name: 'Deer',
      resourcePath: 'pendantDeer',
      icon: Icons.pets,
      isBuiltIn: true,
    ),
    AnonymousMask(
      id: 'mask_panda',
      name: 'Panda',
      resourcePath: 'pendantFacefilm',
      icon: Icons.pets,
      isBuiltIn: true,
    ),
    AnonymousMask(
      id: 'mask_clown',
      name: 'Clown',
      resourcePath: 'pendantClown',
      icon: Icons.face,
      isBuiltIn: true,
    ),
    AnonymousMask(
      id: 'mask_cool_girl',
      name: 'Cool Girl',
      resourcePath: 'pendantGirl',
      icon: Icons.face_retouching_natural,
      isBuiltIn: true,
    ),
    AnonymousMask(
      id: 'mask_sailor_moon',
      name: 'Sailor Moon',
      resourcePath: 'pendantFacefilm',
      icon: Icons.stars,
      isBuiltIn: true,
    ),
    AnonymousMask(
      id: 'mask_watermelon',
      name: 'Watermelon',
      resourcePath: 'pendantWatermelon',
      icon: Icons.lunch_dining,
      isBuiltIn: true,
    ),
    AnonymousMask(
      id: 'mask_dive',
      name: 'Dive',
      resourcePath: 'pendantDive',
      icon: Icons.scuba_diving,
      isBuiltIn: true,
    ),
  ];
}

class AnonymousFilter {
  final String id;
  final String name;
  final String resourcePath;
  final String category;
  final bool isBuiltIn;

  const AnonymousFilter({
    required this.id,
    required this.name,
    required this.resourcePath,
    required this.category,
    this.isBuiltIn = true,
  });

  static const List<AnonymousFilter> builtInFilters = [
    AnonymousFilter(id: 'filter_none', name: 'None', resourcePath: '', category: 'none'),
    AnonymousFilter(id: 'filter_natural_creamy', name: 'Creamy', resourcePath: 'Creamy', category: 'natural'),
    AnonymousFilter(id: 'filter_natural_brighten', name: 'Brighten', resourcePath: 'Brighten', category: 'natural'),
    AnonymousFilter(id: 'filter_natural_fresh', name: 'Fresh', resourcePath: 'Fresh', category: 'natural'),
    AnonymousFilter(id: 'filter_natural_autumn', name: 'Autumn', resourcePath: 'Autumn', category: 'natural'),
    AnonymousFilter(id: 'filter_gray_monet', name: 'Monet', resourcePath: 'Cool', category: 'gray'),
    AnonymousFilter(id: 'filter_gray_night', name: 'Night', resourcePath: 'Night', category: 'gray'),
    AnonymousFilter(id: 'filter_gray_filmlike', name: 'Film', resourcePath: 'Film-like', category: 'gray'),
    AnonymousFilter(id: 'filter_dreamy_sunset', name: 'Sunset', resourcePath: 'Sunset', category: 'dreamy'),
    AnonymousFilter(id: 'filter_dreamy_cozily', name: 'Cozy', resourcePath: 'Cozily', category: 'dreamy'),
    AnonymousFilter(id: 'filter_dreamy_sweet', name: 'Sweet', resourcePath: 'Sweet', category: 'dreamy'),
  ];
}

class BeautySettings {
  final double smoothIntensity;
  final double whitenIntensity;
  final double rosyIntensity;
  final double sharpenIntensity;

  const BeautySettings({
    this.smoothIntensity = 50.0,
    this.whitenIntensity = 50.0,
    this.rosyIntensity = 50.0,
    this.sharpenIntensity = 50.0,
  });

  BeautySettings copyWith({
    double? smoothIntensity,
    double? whitenIntensity,
    double? rosyIntensity,
    double? sharpenIntensity,
  }) {
    return BeautySettings(
      smoothIntensity: smoothIntensity ?? this.smoothIntensity,
      whitenIntensity: whitenIntensity ?? this.whitenIntensity,
      rosyIntensity: rosyIntensity ?? this.rosyIntensity,
      sharpenIntensity: sharpenIntensity ?? this.sharpenIntensity,
    );
  }

  bool get isEmpty =>
      smoothIntensity == 0 &&
      whitenIntensity == 0 &&
      rosyIntensity == 0 &&
      sharpenIntensity == 0;

  static const BeautySettings empty = BeautySettings(
    smoothIntensity: 0,
    whitenIntensity: 0,
    rosyIntensity: 0,
    sharpenIntensity: 0,
  );

  static const BeautySettings defaultSettings = BeautySettings();
}

enum BackgroundMode {
  none,
  blur,
  mosaic,
  customImage,
}

class AnonymousModeConfig {
  final bool enabled;
  final String? selectedMaskId;
  final String? selectedFilterId;
  final BeautySettings beautySettings;
  final BackgroundMode backgroundMode;
  final double backgroundBlurIntensity;
  final double backgroundMosaicIntensity;

  const AnonymousModeConfig({
    this.enabled = false,
    this.selectedMaskId,
    this.selectedFilterId,
    this.beautySettings = const BeautySettings(),
    this.backgroundMode = BackgroundMode.none,
    this.backgroundBlurIntensity = 50.0,
    this.backgroundMosaicIntensity = 50.0,
  });

  AnonymousModeConfig copyWith({
    bool? enabled,
    Object? selectedMaskId = _absent,
    Object? selectedFilterId = _absent,
    BeautySettings? beautySettings,
    BackgroundMode? backgroundMode,
    double? backgroundBlurIntensity,
    double? backgroundMosaicIntensity,
  }) {
    return AnonymousModeConfig(
      enabled: enabled ?? this.enabled,
      selectedMaskId: selectedMaskId is _Absent
          ? this.selectedMaskId
          : selectedMaskId as String?,
      selectedFilterId: selectedFilterId is _Absent
          ? this.selectedFilterId
          : selectedFilterId as String?,
      beautySettings: beautySettings ?? this.beautySettings,
      backgroundMode: backgroundMode ?? this.backgroundMode,
      backgroundBlurIntensity: backgroundBlurIntensity ?? this.backgroundBlurIntensity,
      backgroundMosaicIntensity: backgroundMosaicIntensity ?? this.backgroundMosaicIntensity,
    );
  }
}
