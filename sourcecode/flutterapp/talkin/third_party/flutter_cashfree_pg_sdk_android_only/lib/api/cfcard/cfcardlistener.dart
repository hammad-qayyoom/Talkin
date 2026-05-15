class CFCardListener {
  int? _numberOfCharacters;
  String? _message;
  String? _type;
  dynamic _metaData;

  CFCardListener(int? numberOfCharacters, String? message, String? type,
      dynamic metaData) {
    _numberOfCharacters = numberOfCharacters;
    _type = type;
    _message = message;
    _metaData = metaData;
  }

  int? getNumberOfCharacters() {
    return _numberOfCharacters;
  }

  String? getMessage() {
    return _message;
  }

  String? getType() {
    return _type;
  }

  dynamic getMetaData() {
    return _metaData;
  }
}
