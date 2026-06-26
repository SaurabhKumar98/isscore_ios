// ══════════════════════════════════════════════════════════════════════════════
// WALLET MODELS
// File: lib/data/models/api_models/wallet/wallet_models.dart
// ══════════════════════════════════════════════════════════════════════════════

// ── 1. Wallet Balance ─────────────────────────────────────────────────────────
class WalletBalance {
  final double monetaryBalance;
  final double rewardPoints;

  WalletBalance({required this.monetaryBalance, required this.rewardPoints});

  factory WalletBalance.fromJson(Map<String, dynamic>? json) {
    return WalletBalance(
      monetaryBalance: (json?['monetaryBalance'] as num?)?.toDouble() ?? 0.0,
      rewardPoints: (json?['rewardPoints'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

// ── 2. Razorpay Order (from /recharge/initiate) ───────────────────────────────
class RazorpayOrder {
  final String orderId;
  final int amount; // paise
  final String currency;
  final String key;

  RazorpayOrder({
    required this.orderId,
    required this.amount,
    required this.currency,
    required this.key,
  });

  factory RazorpayOrder.fromJson(Map<String, dynamic>? json) {
    return RazorpayOrder(
      orderId: json?['orderId'] as String? ?? '',
      amount: (json?['amount'] as num?)?.toInt() ?? 0,
      currency: json?['currency'] as String? ?? 'INR',
      key: json?['key'] as String? ?? '',
    );
  }
}

// ── 3. Recharge Confirm Response ──────────────────────────────────────────────
class RechargeResult {
  final double balance;

  RechargeResult({required this.balance});

  factory RechargeResult.fromJson(Map<String, dynamic>? json) {
    return RechargeResult(
      balance: (json?['balance'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

// ── 4. Points History Item ───────────────────────────────────────────────────
class PointsHistoryItem {
  final String id;
  final String type; // 'earned' | 'spent'
  final double amount;
  final String source;
  final String description;
  final String? referenceId;
  final String? referenceType;
  final double balanceAfter;
  final DateTime? createdAt;

  PointsHistoryItem({
    required this.id,
    required this.type,
    required this.amount,
    required this.source,
    required this.description,
    this.referenceId,
    this.referenceType,
    required this.balanceAfter,
    this.createdAt,
  });

  bool get isEarned => type == 'earned';

  factory PointsHistoryItem.fromJson(Map<String, dynamic>? json) {
    return PointsHistoryItem(
      id: json?['_id'] as String? ?? json?['id'] as String? ?? '',
      type: json?['type'] as String? ?? '',
      amount: (json?['amount'] as num?)?.toDouble() ?? 0.0,
      source: json?['source'] as String? ?? '',
      description: json?['description'] as String? ?? '',
      referenceId: json?['referenceId'] as String?,
      referenceType: json?['referenceType'] as String?,
      balanceAfter: (json?['balanceAfter'] as num?)?.toDouble() ?? 0.0,
      createdAt: json?['createdAt'] != null
          ? DateTime.tryParse(json!['createdAt'] as String)
          : null,
    );
  }
}

// ── 5. Points History Response (with pagination) ──────────────────────────────
class PointsHistoryResponse {
  final List<PointsHistoryItem> items;
  final int page;
  final int limit;
  final int total;
  final int pages;

  PointsHistoryResponse({
    required this.items,
    required this.page,
    required this.limit,
    required this.total,
    required this.pages,
  });

 factory PointsHistoryResponse.fromJson(Map<String, dynamic>? json) {
  final dataList = json?['data'];   // ✅ FIX
  final meta = json?['meta'];       // ✅ FIX

  final List<PointsHistoryItem> items = [];
  if (dataList is List) {
    for (final e in dataList) {
      if (e is Map<String, dynamic>) {
        items.add(PointsHistoryItem.fromJson(e));
      }
    }
  }

  return PointsHistoryResponse(
    items: items,
    page: (meta?['page'] as num?)?.toInt() ?? 1,
    limit: (meta?['limit'] as num?)?.toInt() ?? 10,
    total: (meta?['total'] as num?)?.toInt() ?? 0,
    pages: (meta?['pages'] as num?)?.toInt() ?? 1,
  );
}

}

// ── 6. Convert Points Response ────────────────────────────────────────────────
class ConvertPointsResult {
  final double monetaryBalance;
  final double rewardPoints;

  ConvertPointsResult({
    required this.monetaryBalance,
    required this.rewardPoints,
  });

  factory ConvertPointsResult.fromJson(Map<String, dynamic>? json) {
    return ConvertPointsResult(
      monetaryBalance: (json?['monetaryBalance'] as num?)?.toDouble() ?? 0.0,
      rewardPoints: (json?['rewardPoints'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
