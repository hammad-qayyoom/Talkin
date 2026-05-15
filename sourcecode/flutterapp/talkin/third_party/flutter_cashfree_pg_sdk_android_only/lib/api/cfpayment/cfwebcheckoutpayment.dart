import '../../utils/cfexceptionconstants.dart';
import '../../utils/cfexceptions.dart';
import '../cfsession/cfsession.dart';
import '../cftheme/cftheme.dart';
import 'cfpayment.dart';

class CFWebCheckoutPaymentBuilder {
  CFSession? _session;
  CFTheme _cfTheme = CFThemeBuilder().build();
  CFWebCheckoutPaymentBuilder();

  CFWebCheckoutPaymentBuilder setSession(CFSession session) {
    _session = session;
    return this;
  }

  CFWebCheckoutPayment build() {
    if (_session == null) {
      throw CFException(CFExceptionConstants.sessionNotPresent);
    }
    return CFWebCheckoutPayment(this);
  }

  CFWebCheckoutPaymentBuilder setTheme(CFTheme cfTheme) {
    _cfTheme = cfTheme;
    return this;
  }

  CFSession getSession() {
    return _session!;
  }

  CFTheme getTheme() {
    return _cfTheme;
  }
}

class CFWebCheckoutPayment extends CFPayment {
  late CFSession _session;
  CFTheme _cfTheme = CFThemeBuilder().build();

  // Constructor
  CFWebCheckoutPayment(CFWebCheckoutPaymentBuilder builder) {
    _session = builder.getSession();
    _cfTheme = builder.getTheme();
  }

  CFSession getSession() {
    return _session;
  }

  CFTheme getTheme() {
    return _cfTheme;
  }
}
