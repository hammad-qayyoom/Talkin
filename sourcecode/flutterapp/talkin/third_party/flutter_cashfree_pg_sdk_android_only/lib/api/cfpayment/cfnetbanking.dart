class CFNetbankingBuilder {
  String? _channel = "link";
  int? _netbankingBankCode;

  CFNetbankingBuilder();

  CFNetbankingBuilder setChannel(String channel) {
    _channel = channel;
    return this;
  }

  CFNetbankingBuilder setBankCode(int bankCode) {
    _netbankingBankCode = bankCode;
    return this;
  }

  String getChannel() {
    return _channel!;
  }

  int getBankCode() {
    return _netbankingBankCode!;
  }

  CFNetbanking build() {
    return CFNetbanking(this);
  }
}

class CFNetbanking {
  String? _channel = "link";
  int? _netbankingBankCode;

  CFNetbanking(CFNetbankingBuilder builder) {
    _channel = builder.getChannel();
    _netbankingBankCode = builder.getBankCode();
  }

  String getChannel() {
    return _channel!;
  }

  int getBankCode() {
    return _netbankingBankCode!;
  }
}
