class SubscriptionUsage {
  final String id;
  final String accountId;
  final String subscriptionId;
  final DateTime periodStart;
  final DateTime periodEnd;
  final int minutesUsed;
  final int smsUsed;
  final int minutesRemaining;
  final int smsRemaining;
  final bool isBundleExceeded;
  final DateTime lastUpdated;

  const SubscriptionUsage({
    required this.id,
    required this.accountId,
    required this.subscriptionId,
    required this.periodStart,
    required this.periodEnd,
    required this.minutesUsed,
    required this.smsUsed,
    required this.minutesRemaining,
    required this.smsRemaining,
    required this.isBundleExceeded,
    required this.lastUpdated,
  });

  factory SubscriptionUsage.fromJson(Map<String, dynamic> json) {
    return SubscriptionUsage(
      id: json['id'] as String,
      accountId: json['account_id'] as String,
      subscriptionId: json['subscription_id'] as String,
      periodStart: DateTime.parse(json['period_start'] as String),
      periodEnd: DateTime.parse(json['period_end'] as String),
      minutesUsed: json['minutes_used'] as int? ?? 0,
      smsUsed: json['sms_used'] as int? ?? 0,
      minutesRemaining: json['minutes_remaining'] as int? ?? 0,
      smsRemaining: json['sms_remaining'] as int? ?? 0,
      isBundleExceeded: json['is_bundle_exceeded'] as bool? ?? false,
      lastUpdated: DateTime.parse(json['last_updated'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'account_id': accountId,
      'subscription_id': subscriptionId,
      'period_start': periodStart.toIso8601String(),
      'period_end': periodEnd.toIso8601String(),
      'minutes_used': minutesUsed,
      'sms_used': smsUsed,
      'minutes_remaining': minutesRemaining,
      'sms_remaining': smsRemaining,
      'is_bundle_exceeded': isBundleExceeded,
      'last_updated': lastUpdated.toIso8601String(),
    };
  }

  double get minutesUsagePercentage {
    final total = minutesUsed + minutesRemaining;
    return total > 0 ? (minutesUsed / total) * 100 : 0.0;
  }

  double get smsUsagePercentage {
    final total = smsUsed + smsRemaining;
    return total > 0 ? (smsUsed / total) * 100 : 0.0;
  }

  bool get isNearLimit {
    return minutesUsagePercentage >= 80 || smsUsagePercentage >= 80;
  }

  String get statusMessage {
    if (isBundleExceeded) {
      return 'Bundel opgebruikt';
    } else if (isNearLimit) {
      return 'Bijna limiet bereikt';
    } else {
      return 'Actief';
    }
  }

  SubscriptionUsage copyWith({
    String? id,
    String? accountId,
    String? subscriptionId,
    DateTime? periodStart,
    DateTime? periodEnd,
    int? minutesUsed,
    int? smsUsed,
    int? minutesRemaining,
    int? smsRemaining,
    bool? isBundleExceeded,
    DateTime? lastUpdated,
  }) {
    return SubscriptionUsage(
      id: id ?? this.id,
      accountId: accountId ?? this.accountId,
      subscriptionId: subscriptionId ?? this.subscriptionId,
      periodStart: periodStart ?? this.periodStart,
      periodEnd: periodEnd ?? this.periodEnd,
      minutesUsed: minutesUsed ?? this.minutesUsed,
      smsUsed: smsUsed ?? this.smsUsed,
      minutesRemaining: minutesRemaining ?? this.minutesRemaining,
      smsRemaining: smsRemaining ?? this.smsRemaining,
      isBundleExceeded: isBundleExceeded ?? this.isBundleExceeded,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}
