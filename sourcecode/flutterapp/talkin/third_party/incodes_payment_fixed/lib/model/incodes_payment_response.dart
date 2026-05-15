/// [IncodesPaymentResponse] model class for managing payment responses.
class IncodesPaymentResponse {
  String message;
  bool paymentStatus;
  String paymentId;

  IncodesPaymentResponse(
    this.message,
    this.paymentStatus,
    this.paymentId,
  );
}
