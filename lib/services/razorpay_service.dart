import 'package:flutter/foundation.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class RazorpayService {
  static const String keyId = 'rzp_test_TfulJJa1j5o9ge';
  static const String keySecret = 'EzDvFSt6r9AN683yV1EY3JUM';

  late Razorpay _razorpay;
  Function(PaymentSuccessResponse)? _onSuccess;
  Function(PaymentFailureResponse)? _onError;
  Function(ExternalWalletResponse)? _onExternalWallet;

  RazorpayService() {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void init({
    required Function(PaymentSuccessResponse) onSuccess,
    required Function(PaymentFailureResponse) onError,
    Function(ExternalWalletResponse)? onExternalWallet,
  }) {
    _onSuccess = onSuccess;
    _onError = onError;
    _onExternalWallet = onExternalWallet;
  }

  void openCheckout({
    required double amount,
    required String name,
    required String description,
    required String userEmail,
    required String userPhone,
    required String userName,
    String? orderId,
    Map<String, dynamic>? notes,
  }) {
    final int amountInPaise = (amount * 100).round();

    final options = {
      'key': keyId,
      'amount': amountInPaise,
      'name': 'MediCare+ drconnects24',
      'description': description,
      if (orderId != null && orderId.isNotEmpty) 'order_id': orderId,
      'timeout': 180,
      'prefill': {
        'contact': userPhone.isNotEmpty ? userPhone : '+919876543210',
        'email': userEmail.isNotEmpty ? userEmail : 'patient@drconnects24.com',
        'name': userName.isNotEmpty ? userName : 'Patient',
      },
      'theme': {
        'color': '#1E3A8A', // MediCare+ Primary Blue
      },
      'external': {
        'wallets': ['paytm']
      },
      'notes': notes ?? {},
    };

    try {
      debugPrint('💳 [RazorpayService] Opening checkout for ₹$amount (₹${amountInPaise / 100}) with key $keyId');
      _razorpay.open(options);
    } catch (e) {
      debugPrint('❌ [RazorpayService] Error opening Razorpay checkout: $e');
      if (_onError != null) {
        _onError!(PaymentFailureResponse(
          Razorpay.PAYMENT_CANCELLED,
          e.toString(),
          null,
        ));
      }
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    debugPrint('✅ [RazorpayService] Payment Success: PaymentID=${response.paymentId}, OrderID=${response.orderId}');
    if (_onSuccess != null) {
      _onSuccess!(response);
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    debugPrint('⚠️ [RazorpayService] Payment Error: Code=${response.code}, Message=${response.message}');
    if (_onError != null) {
      _onError!(response);
    }
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    debugPrint('💼 [RazorpayService] External Wallet Selected: ${response.walletName}');
    if (_onExternalWallet != null) {
      _onExternalWallet!(response);
    }
  }

  void dispose() {
    _razorpay.clear();
  }
}
