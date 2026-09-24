enum WalletTransactionCategory {
  topUp,
  consultation,
  pharmacy,
  cashback,
  subscription,
}

enum WalletTransactionStatus {
  completed,
  pending,
  failed,
}

class WalletTransaction {
  final String id;
  final String title;
  final String description;
  final double amount;
  final bool isCredit;
  final WalletTransactionCategory category;
  final DateTime timestamp;
  final String referenceId;
  final WalletTransactionStatus status;

  const WalletTransaction({
    required this.id,
    required this.title,
    required this.description,
    required this.amount,
    required this.isCredit,
    required this.category,
    required this.timestamp,
    required this.referenceId,
    this.status = WalletTransactionStatus.completed,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'amount': amount,
      'isCredit': isCredit,
      'category': category.name,
      'timestamp': timestamp.toIso8601String(),
      'referenceId': referenceId,
      'status': status.name,
    };
  }

  factory WalletTransaction.fromJson(Map<String, dynamic> json) {
    return WalletTransaction(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      amount: (json['amount'] as num).toDouble(),
      isCredit: json['isCredit'] as bool,
      category: WalletTransactionCategory.values.firstWhere(
        (c) => c.name == json['category'],
        orElse: () => WalletTransactionCategory.topUp,
      ),
      timestamp: DateTime.parse(json['timestamp'] as String),
      referenceId: json['referenceId'] as String,
      status: WalletTransactionStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => WalletTransactionStatus.completed,
      ),
    );
  }
}

class WalletAccount {
  final double balance;
  final double healthCashback;
  final int rewardPoints;
  final List<WalletTransaction> transactions;

  const WalletAccount({
    required this.balance,
    required this.healthCashback,
    required this.rewardPoints,
    required this.transactions,
  });

  WalletAccount copyWith({
    double? balance,
    double? healthCashback,
    int? rewardPoints,
    List<WalletTransaction>? transactions,
  }) {
    return WalletAccount(
      balance: balance ?? this.balance,
      healthCashback: healthCashback ?? this.healthCashback,
      rewardPoints: rewardPoints ?? this.rewardPoints,
      transactions: transactions ?? this.transactions,
    );
  }

  factory WalletAccount.fromJson(Map<String, dynamic> json) {
    return WalletAccount(
      balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
      healthCashback: (json['totalCashbackEarned'] as num?)?.toDouble() ??
          (json['healthCashback'] as num?)?.toDouble() ??
          0.0,
      rewardPoints: (json['rewardPoints'] as num?)?.toInt() ?? 200,
      transactions: (json['transactions'] as List<dynamic>?)
              ?.map((t) => WalletTransaction.fromJson(t as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'balance': balance,
      'healthCashback': healthCashback,
      'rewardPoints': rewardPoints,
      'transactions': transactions.map((t) => t.toJson()).toList(),
    };
  }
}
