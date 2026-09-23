import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/wallet_model.dart';

class WalletNotifier extends Notifier<WalletAccount> {
  @override
  WalletAccount build() {
    return _createInitialWallet();
  }

  static WalletAccount _createInitialWallet() {
    final now = DateTime.now();
    final initialTxns = [
      WalletTransaction(
        id: 'TXN-98412',
        title: 'Wallet Loaded via UPI',
        description: 'Auto-credited via Google Pay UPI',
        amount: 1000.0,
        isCredit: true,
        category: WalletTransactionCategory.topUp,
        timestamp: now.subtract(const Duration(days: 2, hours: 3)),
        referenceId: 'UPI-98412048124',
        status: WalletTransactionStatus.completed,
      ),
      WalletTransaction(
        id: 'TXN-98201',
        title: 'Dr. Vipin Sharma Consultation',
        description: 'Teleconsultation payment',
        amount: 499.0,
        isCredit: false,
        category: WalletTransactionCategory.consultation,
        timestamp: now.subtract(const Duration(days: 2, hours: 2)),
        referenceId: 'CONS-98201',
        status: WalletTransactionStatus.completed,
      ),
      WalletTransaction(
        id: 'TXN-98202',
        title: '5% Consultation HealthCash',
        description: 'Care Plan instant cashback',
        amount: 25.0,
        isCredit: true,
        category: WalletTransactionCategory.cashback,
        timestamp: now.subtract(const Duration(days: 2, hours: 1)),
        referenceId: 'CB-98202',
        status: WalletTransactionStatus.completed,
      ),
      WalletTransaction(
        id: 'TXN-97914',
        title: 'Augmentin & Dolo Rx Order',
        description: 'Medicines Express Home Delivery',
        amount: 380.0,
        isCredit: false,
        category: WalletTransactionCategory.pharmacy,
        timestamp: now.subtract(const Duration(days: 4)),
        referenceId: 'RX-97914',
        status: WalletTransactionStatus.completed,
      ),
      WalletTransaction(
        id: 'TXN-97500',
        title: 'Wallet Loaded via NetBanking',
        description: 'HDFC Bank NetBanking top-up',
        amount: 500.0,
        isCredit: true,
        category: WalletTransactionCategory.topUp,
        timestamp: now.subtract(const Duration(days: 6)),
        referenceId: 'NB-97500',
        status: WalletTransactionStatus.completed,
      ),
    ];

    return WalletAccount(
      balance: 1250.0,
      healthCashback: 210.0,
      rewardPoints: 420,
      transactions: initialTxns,
    );
  }

  /// Add money to wallet via UPI / Card / NetBanking
  void addMoney(double amount, String paymentMethod) {
    if (amount <= 0) return;
    final now = DateTime.now();
    final txnId = 'TXN-${now.millisecondsSinceEpoch.toString().substring(7)}';
    final newTxn = WalletTransaction(
      id: txnId,
      title: 'Wallet Loaded via $paymentMethod',
      description: 'Credited directly to MediCare HealthPay',
      amount: amount,
      isCredit: true,
      category: WalletTransactionCategory.topUp,
      timestamp: now,
      referenceId: 'PAY-${now.millisecondsSinceEpoch.toString().substring(6)}',
      status: WalletTransactionStatus.completed,
    );

    state = state.copyWith(
      balance: state.balance + amount,
      transactions: [newTxn, ...state.transactions],
    );
  }

  /// Spend wallet balance (for consultations, medicines, subscriptions)
  bool payWithWallet(
    double amount,
    String purpose, {
    required WalletTransactionCategory category,
    String? referenceId,
  }) {
    if (state.balance < amount) {
      return false; // Insufficient funds
    }

    final now = DateTime.now();
    final txnId = 'TXN-${now.millisecondsSinceEpoch.toString().substring(7)}';
    final ref = referenceId ?? 'REF-${now.millisecondsSinceEpoch.toString().substring(8)}';

    final debitTxn = WalletTransaction(
      id: txnId,
      title: purpose,
      description: 'Paid via MediCare+ HealthPay Wallet',
      amount: amount,
      isCredit: false,
      category: category,
      timestamp: now,
      referenceId: ref,
      status: WalletTransactionStatus.completed,
    );

    // 5% cashback reward
    final cashbackEarned = (amount * 0.05).roundToDouble();
    final pointsEarned = (amount / 10).round();

    final cashbackTxn = WalletTransaction(
      id: 'CB-${now.millisecondsSinceEpoch.toString().substring(7)}',
      title: '5% Health Cashback Reward',
      description: 'Reward credited for $purpose',
      amount: cashbackEarned,
      isCredit: true,
      category: WalletTransactionCategory.cashback,
      timestamp: now.add(const Duration(seconds: 1)),
      referenceId: 'CASHBACK-$ref',
      status: WalletTransactionStatus.completed,
    );

    state = state.copyWith(
      balance: state.balance - amount + cashbackEarned,
      healthCashback: state.healthCashback + cashbackEarned,
      rewardPoints: state.rewardPoints + pointsEarned,
      transactions: [cashbackTxn, debitTxn, ...state.transactions],
    );

    return true;
  }

  /// Redeem points to cash (100 points = ₹10)
  void redeemPoints(int points) {
    if (points <= 0 || points > state.rewardPoints) return;
    final cashAmount = (points / 100) * 10.0;
    final now = DateTime.now();
    final txn = WalletTransaction(
      id: 'RDM-${now.millisecondsSinceEpoch.toString().substring(7)}',
      title: 'Points Redeemed to Cash',
      description: 'Converted $points HealthPoints to Wallet Cash',
      amount: cashAmount,
      isCredit: true,
      category: WalletTransactionCategory.cashback,
      timestamp: now,
      referenceId: 'REDEEM-${now.millisecondsSinceEpoch.toString().substring(8)}',
      status: WalletTransactionStatus.completed,
    );

    state = state.copyWith(
      balance: state.balance + cashAmount,
      rewardPoints: state.rewardPoints - points,
      transactions: [txn, ...state.transactions],
    );
  }
}

final walletProvider = NotifierProvider<WalletNotifier, WalletAccount>(
  WalletNotifier.new,
);
