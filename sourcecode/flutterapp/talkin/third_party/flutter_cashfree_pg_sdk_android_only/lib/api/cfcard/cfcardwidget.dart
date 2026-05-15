import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfcard/cfcardvalidator.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfnetwork/cf_network_manager.dart';
import 'dart:convert';
import '../cferrorresponse/cferrorresponse.dart';
import '../cfsession/cfsession.dart';
import 'cfcardlistener.dart';

class CFCardWidget extends StatefulWidget {
  final InputDecoration? inputDecoration;
  final TextStyle? textStyle;
  final CFSession? cfSession;
  final void Function(CFCardListener) cardListener;

  const CFCardWidget({
    super.key,
    required this.inputDecoration,
    required this.textStyle,
    required this.cardListener,
    required this.cfSession,
  });

  @override
  State<CFCardWidget> createState() => CFCardWidgetState();
}

class CFCardWidgetState extends State<CFCardWidget> {
  final TextEditingController _controller = TextEditingController();
  CFCardValidator cfCardValidator = CFCardValidator();
  dynamic _tdrJson;
  dynamic _cardbinJson;
  String _firstEightDigits = "";

  Image _suffixIcon = Image.asset(
    'packages/flutter_cashfree_pg_sdk/assets/credit-card-default.png',
    width: 30,
    height: 25,
    fit: BoxFit.fitHeight,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20.0),
      child: TextField(
        controller: _controller,
        keyboardType: TextInputType.number,
        style: widget.textStyle,
        decoration: InputDecoration(
          icon: widget.inputDecoration?.icon,
          iconColor: widget.inputDecoration?.iconColor,
          label: widget.inputDecoration?.label,
          labelText: widget.inputDecoration?.labelText,
          labelStyle: widget.inputDecoration?.labelStyle,
          floatingLabelStyle: widget.inputDecoration?.floatingLabelStyle,
          helperText: widget.inputDecoration?.helperText,
          helperStyle: widget.inputDecoration?.helperStyle,
          helperMaxLines: widget.inputDecoration?.helperMaxLines,
          hintText: "XXXX XXXX XXXX XXXX",
          hintStyle: widget.inputDecoration?.hintStyle,
          hintTextDirection: widget.inputDecoration?.hintTextDirection,
          hintMaxLines: 1,
          errorText: widget.inputDecoration?.errorText,
          errorStyle: widget.inputDecoration?.errorStyle,
          errorMaxLines: 1,
          floatingLabelBehavior: widget.inputDecoration?.floatingLabelBehavior,
          floatingLabelAlignment:
              widget.inputDecoration?.floatingLabelAlignment,
          isCollapsed: widget.inputDecoration?.isCollapsed ?? false,
          contentPadding: widget.inputDecoration?.contentPadding,
          prefixIcon: widget.inputDecoration?.prefixIcon,
          prefixIconConstraints: widget.inputDecoration?.prefixIconConstraints,
          prefix: widget.inputDecoration?.prefix,
          prefixText: widget.inputDecoration?.prefixText,
          prefixStyle: widget.inputDecoration?.prefixStyle,
          prefixIconColor: widget.inputDecoration?.prefixIconColor,
          suffixIcon: Transform.translate(
              offset: const Offset(-10.0, 0.0), child: _suffixIcon),
          suffix: widget.inputDecoration?.suffix,
          suffixText: widget.inputDecoration?.suffixText,
          suffixStyle: widget.inputDecoration?.suffixStyle,
          suffixIconColor: widget.inputDecoration?.suffixIconColor,
          suffixIconConstraints: const BoxConstraints(
              minWidth: 25, minHeight: 25, maxWidth: 30, maxHeight: 25),
          counter: widget.inputDecoration?.counter,
          counterText: widget.inputDecoration?.counterText,
          counterStyle: widget.inputDecoration?.counterStyle,
          filled: widget.inputDecoration?.filled,
          fillColor: widget.inputDecoration?.fillColor,
          focusColor: widget.inputDecoration?.focusColor,
          hoverColor: widget.inputDecoration?.hoverColor,
          errorBorder: widget.inputDecoration?.errorBorder,
          focusedBorder: widget.inputDecoration?.focusedBorder,
          focusedErrorBorder: widget.inputDecoration?.focusedErrorBorder,
          disabledBorder: widget.inputDecoration?.disabledBorder,
          enabledBorder: widget.inputDecoration?.enabledBorder,
          border: widget.inputDecoration?.border,
          enabled: widget.inputDecoration!.enabled,
          semanticCounterText: widget.inputDecoration?.semanticCounterText,
          alignLabelWithHint: widget.inputDecoration?.alignLabelWithHint,
          constraints: widget.inputDecoration?.constraints,
        ),
        maxLines: 1,
        onChanged: _handleTextChanged,
        maxLength: 19,
      ),
    );
  }

  Future<void> _handleTextChanged(String newText) async {
    // Remove any existing spaces from the input
    var completeResponse = {};
    String textWithoutSpaces = newText.replaceAll(' ', '');

    // Add spaces after every 4 characters
    String formattedText = '';
    for (int i = 0; i < textWithoutSpaces.length; i += 4) {
      int end = i + 4;
      if (end > textWithoutSpaces.length) {
        end = textWithoutSpaces.length;
      }
      formattedText += textWithoutSpaces.substring(i, end);
      if (end != textWithoutSpaces.length) {
        formattedText += ' ';
      }
    }

    // Update the text field's content
    if (formattedText != _controller.text) {
      _controller.value = TextEditingValue(
        text: formattedText,
        selection: TextSelection.collapsed(offset: formattedText.length),
      );
    }
    if (textWithoutSpaces.length == 8) {
      _firstEightDigits = textWithoutSpaces;
      var tdrResponse =
          await CFNetworkManager().getTDR(widget.cfSession!, textWithoutSpaces);
      var cardbinResponse = await CFNetworkManager()
          .getCardBin(widget.cfSession!, textWithoutSpaces);
      _tdrJson = null;
      _cardbinJson = null;
      if (tdrResponse.statusCode == 200) {
        _tdrJson = json.decode(tdrResponse.body);
        completeResponse["tdr_info"] = _tdrJson;
      }
      if (cardbinResponse.statusCode == 200) {
        _cardbinJson = jsonDecode(cardbinResponse.body);
        completeResponse["card_bin_info"] = _cardbinJson;
      }
    } else if (textWithoutSpaces.length > 8) {
      if (_firstEightDigits == textWithoutSpaces.substring(0, 8)) {
        completeResponse["tdr_info"] = _tdrJson;
        completeResponse["card_bin_info"] = _cardbinJson;
      } else {
        _firstEightDigits = textWithoutSpaces.substring(0, 8);
        var tdrResponse = await CFNetworkManager()
            .getTDR(widget.cfSession!, _firstEightDigits);
        var cardbinResponse = await CFNetworkManager()
            .getCardBin(widget.cfSession!, _firstEightDigits);
        _tdrJson = null;
        _cardbinJson = null;
        if (tdrResponse.statusCode == 200) {
          _tdrJson = json.decode(tdrResponse.body);
          completeResponse["tdr_info"] = _tdrJson;
        }
        if (cardbinResponse.statusCode == 200) {
          _cardbinJson = jsonDecode(cardbinResponse.body);
          completeResponse["card_bin_info"] = _cardbinJson;
        }
      }
    }
    if (textWithoutSpaces.length < 8) {
      _cardbinJson = null;
      _tdrJson = null;
    }
    if (_cardbinJson != null) {
      var scheme = _cardbinJson["scheme"] as String;
      var brand = cfCardValidator.detectCardBrand(scheme);
      switch (brand) {
        case CFCardBrand.mastercard:
          setState(() {
            _suffixIcon = Image.asset(
              'packages/flutter_cashfree_pg_sdk/assets/mastercard.png',
              width: 30,
              height: 25,
              fit: BoxFit.fitWidth,
            );
          });
          break;
        case CFCardBrand.jcb:
          setState(() {
            _suffixIcon = Image.asset(
              'packages/flutter_cashfree_pg_sdk/assets/jcb.png',
              width: 30,
              height: 25,
              fit: BoxFit.fitWidth,
            );
          });
          break;
        case CFCardBrand.discover:
          setState(() {
            _suffixIcon = Image.asset(
              'packages/flutter_cashfree_pg_sdk/assets/discover.png',
              width: 30,
              height: 25,
              fit: BoxFit.fitWidth,
            );
          });
          break;
        case CFCardBrand.amex:
          setState(() {
            _suffixIcon = Image.asset(
              'packages/flutter_cashfree_pg_sdk/assets/amex.png',
              width: 30,
              height: 25,
              fit: BoxFit.fitWidth,
            );
          });
          break;
        case CFCardBrand.visa:
          setState(() {
            _suffixIcon = Image.asset(
              'packages/flutter_cashfree_pg_sdk/assets/visa.png',
              width: 30,
              height: 25,
              fit: BoxFit.fitWidth,
            );
          });
          break;
        case CFCardBrand.rupay:
          setState(() {
            _suffixIcon = Image.asset(
              'packages/flutter_cashfree_pg_sdk/assets/rupay.png',
              width: 30,
              height: 25,
              fit: BoxFit.fitWidth,
            );
          });
          break;
        default:
          setState(() {
            _suffixIcon = Image.asset(
              'packages/flutter_cashfree_pg_sdk/assets/credit-card-default.png',
              width: 30,
              height: 25,
              fit: BoxFit.fitHeight,
            );
          });
          break;
      }
    } else {
      if (textWithoutSpaces.length == 7) {
        setState(() {
          _suffixIcon = Image.asset(
            'packages/flutter_cashfree_pg_sdk/assets/credit-card-default.png',
            width: 30,
            height: 25,
            fit: BoxFit.fitHeight,
          );
        });
      }
    }
    completeResponse["luhn_check_info"] = "SUCCESS";
    if (!cfCardValidator.luhnCheck(textWithoutSpaces)) {
      completeResponse["luhn_check_info"] = "FAIL";
    }
    completeResponse["card_length"] = textWithoutSpaces.length;
    widget.cardListener(CFCardListener(
        textWithoutSpaces.length,
        "This contains all the information about the card.",
        "card_info",
        completeResponse));
  }

  void completePayment(
      final void Function(String) verifyPayment,
      final void Function(CFErrorResponse, String) onError,
      String cardCvv,
      String cardHolderName,
      String cardExpiryMonth,
      String cardExpiryYear,
      Map<String, dynamic> session,
      bool savePaymentMethod,
      String? instrumentId) {
    Map<String, String> card = {};

    if (instrumentId != null) {
      card = {
        "instrument_id": instrumentId,
        "card_cvv": cardCvv,
      };
    } else {
      card = {
        "card_holder_name": cardHolderName,
        "card_cvv": cardCvv,
        "card_expiry_month": cardExpiryMonth,
        "card_expiry_year": cardExpiryYear,
        "card_number": _controller.text.replaceAll(' ', ''),
      };
    }

    Map<String, dynamic> data = {
      "session": session,
      "card": card,
      "save_payment_method": savePaymentMethod,
    };

    // Create Method channel here
    MethodChannel methodChannel =
        const MethodChannel('flutter_cashfree_pg_sdk');
    methodChannel.invokeMethod("doCardPayment", data).then((value) {
      if (value != null) {
        final body = json.decode(value);
        var status = body["status"] as String;
        switch (status) {
          case "exception":
            var data = body["data"] as Map<String, dynamic>;
            var cfErrorResponse = CFErrorResponse(
                "FAILED",
                data["message"] as String,
                "invalid_request",
                "invalid_request");
            onError(
                cfErrorResponse, session["order_id"] ?? "order_id_not_found");
            break;
          case "success":
            var data = body["data"] as Map<String, dynamic>;
            verifyPayment(data["order_id"] as String);
            break;
          case "failed":
            var data = body["data"] as Map<String, dynamic>;
            var errorResponse = CFErrorResponse(
                data["status"] as String,
                data["message"] as String,
                data["code"] as String,
                data["type"] as String);
            onError(errorResponse, data["order_id"] as String);
            break;
        }
      }
    });
  }
}
