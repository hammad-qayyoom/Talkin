import 'package:flutter_cashfree_pg_sdk/api/cfcard/cfcardwidget.dart';

class CFCardBuilder {
  String? _cardExpiryMonth;
  String? _cardExpiryYear;
  String? _cardCvv;
  String? _cardHolderName;
  String? _instrumentId;
  CFCardWidget? _cardWidget;

  CFCardBuilder();

  CFCardBuilder setCardExpiryMonth(String cardExpiryMonth) {
    _cardExpiryMonth = cardExpiryMonth;
    return this;
  }

  CFCardBuilder setCardExpiryYear(String cardExpiryYear) {
    _cardExpiryYear = cardExpiryYear;
    return this;
  }

  CFCardBuilder setCardCVV(String cardCvv) {
    _cardCvv = cardCvv;
    return this;
  }

  CFCardBuilder setCardHolderName(String cardHolderName) {
    _cardHolderName = cardHolderName;
    return this;
  }

  CFCardBuilder setCardWidget(CFCardWidget cardWidget) {
    _cardWidget = cardWidget;
    return this;
  }

  CFCardBuilder setInstrumentId(String instrumentId) {
    _instrumentId = instrumentId;
    return this;
  }

  String getCardExpiryMonth() {
    return _cardExpiryMonth ?? "";
  }

  String getCardExpiryYear() {
    return _cardExpiryYear ?? "";
  }

  String getCardCvv() {
    return _cardCvv ?? "";
  }

  String getCardHolderName() {
    return _cardHolderName ?? "";
  }

  CFCardWidget? getCardNumber() {
    return _cardWidget;
  }

  String? getInstrumentId() {
    return _instrumentId;
  }

  CFCard build() {
    return CFCard(this);
  }
}

class CFCard {
  String? _cardExpiryMonth;
  String? _cardExpiryYear;
  String? _cardCvv;
  String? _cardHolderName;
  String? _instrumentId;
  CFCardWidget? _cardWidget;

  CFCard(CFCardBuilder builder) {
    _cardExpiryMonth = builder.getCardExpiryMonth();
    _cardExpiryYear = builder.getCardExpiryYear();
    _cardCvv = builder.getCardCvv();
    _cardHolderName = builder.getCardHolderName();
    _cardWidget = builder.getCardNumber();
    _instrumentId = builder.getInstrumentId();
  }

  String? getInstrumentId() {
    return _instrumentId;
  }

  String getCardExpiryMonth() {
    return _cardExpiryMonth ?? "";
  }

  String getCardExpiryYear() {
    return _cardExpiryYear ?? "";
  }

  String getCardCvv() {
    return _cardCvv ?? "";
  }

  String getCardHolderName() {
    return _cardHolderName ?? "";
  }

  CFCardWidget? getCardNumber() {
    return _cardWidget;
  }
}
