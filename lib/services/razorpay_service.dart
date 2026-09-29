import 'package:flutter/foundation.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'api_service.dart';

class RazorpayService {
  static const String keyId = 'rzp_test_TfulJJa1j5o9ge';

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

  /// Creates a real Razorpay order via backend, then opens checkout.
  /// Having a backend order_id is REQUIRED to avoid OTP for UPI flows.
  Future<void> openCheckout({
    required double amount,
    required String name,
    required String description,
    required String userEmail,
    required String userPhone,
    required String userName,
    required String userId,
    String? planId,
    String? planName,
    String? purpose,
    Map<String, dynamic>? notes,
  }) async {
    final int amountInPaise = (amount * 100).round();

    // Step 1 – Get a real Razorpay order ID from the backend
    String? orderId;
    try {
      final orderData = await ApiService.createPaymentOrder(
        amount: amount,
        userId: userId,
        purpose: purpose ?? description,
        planId: planId,
        planName: planName,
      );
      orderId = orderData['orderId'] as String?;
      debugPrint('💳 [RazorpayService] Order created: $orderId');
    } catch (e) {
      debugPrint('⚠️ [RazorpayService] Could not create backend order, proceeding without order_id: $e');
    }

    // Step 2 – Build checkout options
    final options = <String, dynamic>{
      'key': keyId,
      'amount': amountInPaise,
      'currency': 'INR',
      'name': 'MediCare+ drconnects24',
      'description': description,
      if (orderId != null && orderId.isNotEmpty && !orderId.startsWith('order_local')) 'order_id': orderId,
      'timeout': 300,
      'prefill': {
        'contact': userPhone.isNotEmpty ? userPhone : '9999999999',
        'email': userEmail.isNotEmpty ? userEmail : 'patient@drconnects24.com',
        'name': userName.isNotEmpty ? userName : 'Patient',
      },
      'theme': {
        'color': '#1E3A8A',
        'hide_topbar': false,
      },
      // Show all payment methods – Razorpay decides the default based on user's device
      'method': {
        'upi': true,
        'card': true,
        'netbanking': true,
        'wallet': true,
        'emi': false,
      },
      'notes': {
        ...?notes,
        'userId': userId,
        'planId': ?planId,
        'planName': ?planName,
      },
    };

    try {
      debugPrint(
        '💳 [RazorpayService] Opening checkout | ₹$amount ($amountInPaise paise) | orderId=$orderId',
      );
      _razorpay.open(options);
    } catch (e) {
      debugPrint('❌ [RazorpayService] Error opening Razorpay checkout: $e');
      _onError?.call(PaymentFailureResponse(
        Razorpay.PAYMENT_CANCELLED,
        e.toString(),
        null,
      ));
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    debugPrint(
      '✅ [RazorpayService] Payment Success | paymentId=${response.paymentId} | orderId=${response.orderId}',
    );
    _onSuccess?.call(response);
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    debugPrint(
      '⚠️ [RazorpayService] Payment Error | code=${response.code} | msg=${response.message}',
    );
    _onError?.call(response);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    debugPrint('💼 [RazorpayService] External Wallet: ${response.walletName}');
    _onExternalWallet?.call(response);
  }

  void dispose() {
    _razorpay.clear();
  }
}
