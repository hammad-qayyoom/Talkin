enum CFUPIChannel {
  collect,
  intent,
  intentWithUi,
}

class CFUPIBuilder {
  CFUPIChannel? _channel;
  String? _upiId;

  CFUPIBuilder();

  CFUPIBuilder setChannel(CFUPIChannel channel) {
    _channel = channel;
    return this;
  }

  CFUPIBuilder setUPIID(String upiId) {
    _upiId = upiId;
    return this;
  }

  String getUPIID() {
    return _upiId!;
  }

  CFUPIChannel getChannel() {
    return _channel!;
  }

  CFUPI build() {
    if (_channel == CFUPIChannel.intentWithUi) {
      _upiId = "";
    }
    return CFUPI(this);
  }
}

class CFUPI {
  CFUPIChannel? _channel;
  String? _upiId;

  CFUPI(CFUPIBuilder builder) {
    _channel = builder.getChannel();
    _upiId = builder.getUPIID();
  }

  String getUPIID() {
    return _upiId!;
  }

  CFUPIChannel getChannel() {
    return _channel!;
  }
}
