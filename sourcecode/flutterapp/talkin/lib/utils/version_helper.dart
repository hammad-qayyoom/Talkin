class VersionHelper {
  /// Parses a semantic version string into integer components [major, minor, patch].
  /// Handles formats such as "1.0.0", "1.5.0", "2.0.0", "1.3.1+44", "v1.2.3-beta", etc.
  static List<int> parse(String? version) {
    if (version == null || version.trim().isEmpty) {
      return [0, 0, 0];
    }

    String cleaned = version.trim();

    // Remove leading 'v' or 'V'
    if (cleaned.startsWith('v') || cleaned.startsWith('V')) {
      cleaned = cleaned.substring(1).trim();
    }

    // Strip build metadata (+...) and prerelease tags (-...)
    if (cleaned.contains('+')) {
      cleaned = cleaned.split('+').first;
    }
    if (cleaned.contains('-')) {
      cleaned = cleaned.split('-').first;
    }

    final parts = cleaned.split('.').map((part) {
      final digits = part.replaceAll(RegExp(r'[^0-9]'), '');
      return int.tryParse(digits) ?? 0;
    }).toList();

    while (parts.length < 3) {
      parts.add(0);
    }

    return parts;
  }

  /// Compares two version strings.
  /// Returns negative if [v1] < [v2], 0 if [v1] == [v2], positive if [v1] > [v2].
  static int compare(String? v1, String? v2) {
    final p1 = parse(v1);
    final p2 = parse(v2);

    final maxLen = p1.length > p2.length ? p1.length : p2.length;

    for (int i = 0; i < maxLen; i++) {
      final num1 = i < p1.length ? p1[i] : 0;
      final num2 = i < p2.length ? p2[i] : 0;

      if (num1 < num2) return -1;
      if (num1 > num2) return 1;
    }

    return 0;
  }

  /// Returns true if [currentVersion] is strictly lower than [targetVersion].
  static bool isVersionBelow(String? currentVersion, String? targetVersion) {
    if (targetVersion == null || targetVersion.trim().isEmpty) return false;
    return compare(currentVersion, targetVersion) < 0;
  }
}
