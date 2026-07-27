import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notisboard/services/anonymous_mode/anonymous_mode_models.dart';
import 'package:notisboard/services/anonymous_mode/anonymous_mode_service.dart';
import 'package:notisboard/utils/app_color.dart';
import 'package:notisboard/utils/constant.dart';

/// Toggle button for Anonymous Mode in the video call control tray.
class AnonymousModeToggle extends StatelessWidget {
  final VoidCallback? onTap;
  final double size;

  const AnonymousModeToggle({super.key, this.onTap, this.size = 36});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AnonymousModeService>(
      id: Constant.idAnonymousMode,
      builder: (service) {
        final isActive = service.config.enabled;
        final isAllowed = service.isAllowed;

        if (!isAllowed) return const SizedBox.shrink();

        return GestureDetector(
          onTap: onTap ?? () => service.toggleAnonymousMode(),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: isActive
                  ? AppColors.redesignBrandRed.withValues(alpha: 0.25)
                  : Colors.white.withValues(alpha: 0.08),
              shape: BoxShape.circle,
              border: Border.all(
                color: isActive
                    ? AppColors.redesignBrandRed.withValues(alpha: 0.5)
                    : Colors.white.withValues(alpha: 0.15),
                width: 1,
              ),
            ),
            child: Icon(
              Icons.theater_comedy_rounded,
              size: size * 0.6,
              color: isActive
                  ? const Color(0xFFE8829A)
                  : Colors.white.withValues(alpha: 0.7),
            ),
          ),
        );
      },
    );
  }
}

/// Full Anonymous Mode Panel — bottom sheet with tabs for masks, filters, beauty, background.
void showAnonymousModePanel(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _AnonymousModePanel(),
  );
}

class _AnonymousModePanel extends StatefulWidget {
  const _AnonymousModePanel();

  @override
  State<_AnonymousModePanel> createState() => _AnonymousModePanelState();
}

class _AnonymousModePanelState extends State<_AnonymousModePanel>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AnonymousModeService>(
      id: Constant.idAnonymousPanel,
      builder: (service) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.55,
          decoration: BoxDecoration(
            color: AppColors.redesignBrandDark.withValues(alpha: 0.95),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 10),
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header with toggle
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.theater_comedy_rounded,
                            color: Color(0xFFE8829A), size: 20),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'Anonymous Mode',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // Master toggle
                        Switch(
                          value: service.config.enabled,
                          onChanged: (_) => service.toggleAnonymousMode(),
                          activeThumbColor: AppColors.redesignBrandRed,
                          activeTrackColor: AppColors.redesignBrandRed.withValues(alpha: 0.4),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Quick presets row
                    Row(
                      children: [
                        _PresetButton(
                          label: 'Privacy',
                          icon: Icons.blur_on,
                          onTap: () => service.applyPrivacyPreset(),
                        ),
                        const SizedBox(width: 8),
                        _PresetButton(
                          label: 'Fun',
                          icon: Icons.face_retouching_natural,
                          onTap: () => service.applyFunPreset(),
                        ),
                        if (service.hasSavedPreferences) ...[
                          const SizedBox(width: 8),
                          _PresetButton(
                            label: 'Last Used',
                            icon: Icons.history,
                            onTap: () => service.loadSavedPreferences(),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // Tab bar
              TabBar(
                controller: _tabController,
                labelColor: const Color(0xFFE8829A),
                unselectedLabelColor: Colors.white.withValues(alpha: 0.5),
                indicatorColor: AppColors.redesignBrandRed,
                indicatorSize: TabBarIndicatorSize.label,
                labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                tabs: const [
                  Tab(text: 'Masks'),
                  Tab(text: 'Filters'),
                  Tab(text: 'Beauty'),
                  Tab(text: 'Background'),
                ],
              ),

              // Tab content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _MaskTab(service: service),
                    _FilterTab(service: service),
                    _BeautyTab(service: service),
                    _BackgroundTab(service: service),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PresetButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _PresetButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: Colors.white.withValues(alpha: 0.7)),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(fontSize: 10, color: Colors.white.withValues(alpha: 0.7))),
          ],
        ),
      ),
    );
  }
}

// ─── Mask Tab ───

class _MaskTab extends StatelessWidget {
  final AnonymousModeService service;
  const _MaskTab({required this.service});

  @override
  Widget build(BuildContext context) {
    final masks = AnonymousMask.builtInMasks;
    final selectedId = service.config.selectedMaskId;

    return Padding(
      padding: const EdgeInsets.all(12),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
        ),
        itemCount: masks.length + 1, // +1 for "None"
        itemBuilder: (context, index) {
          if (index == 0) {
            return _MaskItem(
              name: 'None',
              icon: Icons.close,
              isSelected: selectedId == null,
              onTap: () => service.clearMask(),
            );
          }
          final mask = masks[index - 1];
          return _MaskItem(
            name: mask.name,
            icon: mask.icon,
            isSelected: selectedId == mask.id,
            onTap: () => service.selectMask(mask.id),
          );
        },
      ),
    );
  }
}

class _MaskItem extends StatelessWidget {
  final String name;
  final IconData? icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _MaskItem({
    required this.name,
    this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.redesignBrandRed.withValues(alpha: 0.3)
              : Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.redesignBrandRed
                : Colors.white.withValues(alpha: 0.12),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon ?? Icons.emoji_emotions_rounded,
              size: 24,
              color: isSelected
                  ? const Color(0xFFE8829A)
                  : Colors.white.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 4),
            Text(
              name,
              style: TextStyle(
                fontSize: 9,
                color: isSelected
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Filter Tab ───

class _FilterTab extends StatelessWidget {
  final AnonymousModeService service;
  const _FilterTab({required this.service});

  @override
  Widget build(BuildContext context) {
    final filters = AnonymousFilter.builtInFilters;
    final selectedId = service.config.selectedFilterId ?? 'filter_none';

    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final filter = filters[index];
          return _FilterItem(
            name: filter.name,
            isSelected: selectedId == filter.id,
            category: filter.category,
            onTap: () => service.selectFilter(filter.id),
          );
        },
      ),
    );
  }
}

class _FilterItem extends StatelessWidget {
  final String name;
  final bool isSelected;
  final String category;
  final VoidCallback onTap;

  const _FilterItem({
    required this.name,
    required this.isSelected,
    required this.category,
    required this.onTap,
  });

  Color get _categoryColor {
    switch (category) {
      case 'natural':
        return const Color(0xFF4CAF50);
      case 'gray':
        return const Color(0xFF9E9E9E);
      case 'dreamy':
        return const Color(0xFFE91E63);
      default:
        return Colors.white.withValues(alpha: 0.4);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 72,
        decoration: BoxDecoration(
          color: isSelected
              ? _categoryColor.withValues(alpha: 0.25)
              : Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? _categoryColor : Colors.white.withValues(alpha: 0.12),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: _categoryColor.withValues(alpha: isSelected ? 0.6 : 0.25),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.auto_awesome,
                size: 18,
                color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              name,
              style: TextStyle(
                fontSize: 10,
                color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Beauty Tab ───

class _BeautyTab extends StatelessWidget {
  final AnonymousModeService service;
  const _BeautyTab({required this.service});

  @override
  Widget build(BuildContext context) {
    final beauty = service.config.beautySettings;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _BeautySlider(
            label: 'Smooth',
            value: beauty.smoothIntensity,
            onChanged: (v) => service.setSmoothIntensity(v),
          ),
          _BeautySlider(
            label: 'Whiten',
            value: beauty.whitenIntensity,
            onChanged: (v) => service.setWhitenIntensity(v),
          ),
          _BeautySlider(
            label: 'Rosy',
            value: beauty.rosyIntensity,
            onChanged: (v) => service.setRosyIntensity(v),
          ),
          _BeautySlider(
            label: 'Sharpen',
            value: beauty.sharpenIntensity,
            onChanged: (v) => service.setSharpenIntensity(v),
          ),
        ],
      ),
    );
  }
}

class _BeautySlider extends StatelessWidget {
  final String label;
  final double value;
  final ValueChanged<double> onChanged;

  const _BeautySlider({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ),
          ),
          Expanded(
            child: SliderTheme(
              data: SliderThemeData(
                activeTrackColor: AppColors.redesignBrandRed,
                inactiveTrackColor: Colors.white.withValues(alpha: 0.15),
                thumbColor: const Color(0xFFE8829A),
                overlayColor: AppColors.redesignBrandRed.withValues(alpha: 0.2),
                trackHeight: 3,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
              ),
              child: Slider(
                value: value,
                min: 0,
                max: 100,
                onChanged: onChanged,
              ),
            ),
          ),
          SizedBox(
            width: 32,
            child: Text(
              '${value.toInt()}',
              style: TextStyle(
                fontSize: 11,
                color: Colors.white.withValues(alpha: 0.5),
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Background Tab ───

class _BackgroundTab extends StatelessWidget {
  final AnonymousModeService service;
  const _BackgroundTab({required this.service});

  @override
  Widget build(BuildContext context) {
    final currentMode = service.config.backgroundMode;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Background mode options
          Row(
            children: [
              _BackgroundOption(
                label: 'None',
                icon: Icons.videocam_off,
                isSelected: currentMode == BackgroundMode.none,
                onTap: () => service.setBackgroundMode(BackgroundMode.none),
              ),
              const SizedBox(width: 10),
              _BackgroundOption(
                label: 'Blur',
                icon: Icons.blur_on,
                isSelected: currentMode == BackgroundMode.blur,
                onTap: () => service.setBackgroundMode(BackgroundMode.blur),
              ),
              const SizedBox(width: 10),
              _BackgroundOption(
                label: 'Mosaic',
                icon: Icons.grid_on,
                isSelected: currentMode == BackgroundMode.mosaic,
                onTap: () => service.setBackgroundMode(BackgroundMode.mosaic),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Intensity sliders (conditional)
          if (currentMode == BackgroundMode.blur)
            _BeautySlider(
              label: 'Blur',
              value: service.config.backgroundBlurIntensity,
              onChanged: (v) => service.setBackgroundBlurIntensity(v),
            ),
          if (currentMode == BackgroundMode.mosaic)
            _BeautySlider(
              label: 'Mosaic',
              value: service.config.backgroundMosaicIntensity,
              onChanged: (v) => service.setBackgroundMosaicIntensity(v),
            ),
        ],
      ),
    );
  }
}

class _BackgroundOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _BackgroundOption({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.redesignBrandRed.withValues(alpha: 0.25)
                : Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? AppColors.redesignBrandRed
                  : Colors.white.withValues(alpha: 0.12),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 24,
                color: isSelected
                    ? const Color(0xFFE8829A)
                    : Colors.white.withValues(alpha: 0.6),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: isSelected
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.6),
                ),
               ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Shows a pre-call anonymous mode setup dialog for video calls.
/// Returns true if the user chose to join with anonymous mode, false otherwise.
Future<bool> showPreCallAnonymousSetupDialog(BuildContext context) async {
  if (!Get.isRegistered<AnonymousModeService>()) return false;
  final service = Get.find<AnonymousModeService>();
  if (!service.isAllowed) return false;

  return await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _PreCallAnonymousSetupSheet(service: service),
  ) ?? false;
}

class _PreCallAnonymousSetupSheet extends StatefulWidget {
  final AnonymousModeService service;

  const _PreCallAnonymousSetupSheet({required this.service});

  @override
  State<_PreCallAnonymousSetupSheet> createState() => _PreCallAnonymousSetupSheetState();
}

class _PreCallAnonymousSetupSheetState extends State<_PreCallAnonymousSetupSheet> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<AnonymousModeService>(
      id: Constant.idAnonymousPanel,
      builder: (service) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.45,
          decoration: BoxDecoration(
            color: AppColors.redesignBrandDark.withValues(alpha: 0.95),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 10),
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    const Icon(Icons.theater_comedy_rounded,
                        color: Color(0xFFE8829A), size: 20),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Anonymous Mode',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    // Master toggle
                    Switch(
                      value: service.config.enabled,
                      onChanged: (_) => service.toggleAnonymousMode(),
                      activeThumbColor: AppColors.redesignBrandRed,
                      activeTrackColor: AppColors.redesignBrandRed.withValues(alpha: 0.4),
                    ),
                  ],
                ),
              ),

              // Quick options
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    _QuickOptionChip(
                      label: 'Privacy',
                      icon: Icons.blur_on,
                      isSelected: service.config.backgroundMode == BackgroundMode.blur,
                      onTap: () => service.applyPrivacyPreset(),
                    ),
                    const SizedBox(width: 8),
                    _QuickOptionChip(
                      label: 'Fun',
                      icon: Icons.face_retouching_natural,
                      isSelected: service.config.selectedMaskId != null,
                      onTap: () => service.applyFunPreset(),
                    ),
                    if (service.hasSavedPreferences) ...[
                      const SizedBox(width: 8),
                      _QuickOptionChip(
                        label: 'Last Used',
                        icon: Icons.history,
                        isSelected: false,
                        onTap: () => service.loadSavedPreferences(),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Current selections summary
              if (service.config.enabled)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: AppColors.redesignBrandRed,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _buildSummaryText(service),
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              const Spacer(),

              // Join buttons
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: Text(
                          'Join Normally',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (!service.config.enabled) {
                            service.toggleAnonymousMode();
                          }
                          Navigator.of(context).pop(true);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.redesignBrandRed,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: Text(
                          'Join Anonymously',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _buildSummaryText(AnonymousModeService service) {
    final parts = <String>[];
    if (service.config.selectedMaskId != null) {
      final mask = AnonymousMask.builtInMasks.firstWhere(
        (m) => m.id == service.config.selectedMaskId,
        orElse: () => const AnonymousMask(id: '', name: 'Mask', resourcePath: ''),
      );
      parts.add('Mask: ${mask.name}');
    }
    if (service.config.selectedFilterId != null) {
      final filter = AnonymousFilter.builtInFilters.firstWhere(
        (f) => f.id == service.config.selectedFilterId,
        orElse: () => const AnonymousFilter(id: '', name: 'Filter', resourcePath: '', category: ''),
      );
      parts.add('Filter: ${filter.name}');
    }
    if (service.config.backgroundMode != BackgroundMode.none) {
      parts.add('Background: ${service.config.backgroundMode.name}');
    }
    if (!service.config.beautySettings.isEmpty) {
      parts.add('Beauty: On');
    }
    return parts.isEmpty ? 'Anonymous mode enabled' : parts.join(' · ');
  }
}

class _QuickOptionChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _QuickOptionChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.redesignBrandRed.withValues(alpha: 0.3)
              : Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.redesignBrandRed.withValues(alpha: 0.5)
                : Colors.white.withValues(alpha: 0.15),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: const Color(0xFFE8829A)),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: isSelected ? 1.0 : 0.7),
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
