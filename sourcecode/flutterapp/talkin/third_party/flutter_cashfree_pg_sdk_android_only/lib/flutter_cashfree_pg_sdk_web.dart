import 'package:flutter/services.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

class FlutterCashfreePgSdkWeb {
  FlutterCashfreePgSdkWeb();

  static void registerWith(Registrar registrar) {
    final channel = MethodChannel(
      'flutter_cashfree_pg_sdk',
      const StandardMethodCodec(),
      registrar,
    );

    final pluginInstance = FlutterCashfreePgSdkWeb();
    channel.setMethodCallHandler(pluginInstance.handleMethodCall);
  }

  Future<dynamic> handleMethodCall(MethodCall call) async {
    throw PlatformException(
      code: 'Unimplemented',
      details:
          'flutter_cashfree_pg_sdk is configured as Android-only in this app.',
    );
  }
}
