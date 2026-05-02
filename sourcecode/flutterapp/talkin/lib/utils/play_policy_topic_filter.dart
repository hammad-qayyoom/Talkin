class PlayPolicyTopicFilter {
  static const List<String> _restrictedFragments = [
    'health',
    'medical',
    'doctor',
    'stethoscope',
    'therapy',
    'therapist',
    'mental',
    'psycholog',
    'psychiatr',
    'finance',
    'financial',
    'bank',
    'loan',
    'crypto',
    'investment',
    'stock',
    'government',
    'vpn',
  ];

  static bool isRestrictedText(String? value) {
    final normalized = (value ?? '').toLowerCase().trim();
    if (normalized.isEmpty) return false;

    return _restrictedFragments.any(normalized.contains);
  }

  static List<String> visibleNames(Iterable<String>? values) {
    return (values ?? const <String>[])
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .where((item) => !isRestrictedText(item))
        .toList();
  }
}
