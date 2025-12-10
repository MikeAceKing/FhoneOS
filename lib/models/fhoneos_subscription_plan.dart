class FhoneOSSubscriptionPlan {
  final String id;
  final String code;
  final String name;
  final String description;
  final double priceMonthly;
  final int minutesIncluded;
  final int smsIncluded;
  final String stripePriceId;
  final double profitMarginEur;
  final bool isActive;

  const FhoneOSSubscriptionPlan({
    required this.id,
    required this.code,
    required this.name,
    required this.description,
    required this.priceMonthly,
    required this.minutesIncluded,
    required this.smsIncluded,
    required this.stripePriceId,
    required this.profitMarginEur,
    required this.isActive,
  });

  factory FhoneOSSubscriptionPlan.fromJson(Map<String, dynamic> json) {
    return FhoneOSSubscriptionPlan(
      id: json['id'] as String,
      code: json['code'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      priceMonthly: (json['price_monthly'] as num).toDouble(),
      minutesIncluded: json['minutes_included'] as int? ?? 0,
      smsIncluded: json['sms_included'] as int? ?? 0,
      stripePriceId: json['stripe_price_id'] as String? ?? '',
      profitMarginEur: (json['profit_margin_eur'] as num?)?.toDouble() ?? 0.0,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'description': description,
      'price_monthly': priceMonthly,
      'minutes_included': minutesIncluded,
      'sms_included': smsIncluded,
      'stripe_price_id': stripePriceId,
      'profit_margin_eur': profitMarginEur,
      'is_active': isActive,
    };
  }
}

class SubscriptionUsage {
  final int minutesUsed;
  final int minutesLimit;
  final int smsUsed;
  final int smsLimit;
  final DateTime? periodStart;
  final DateTime? periodEnd;

  const SubscriptionUsage({
    required this.minutesUsed,
    required this.minutesLimit,
    required this.smsUsed,
    required this.smsLimit,
    this.periodStart,
    this.periodEnd,
  });

  double get minutesPercentage =>
      minutesLimit > 0 ? (minutesUsed / minutesLimit) * 100 : 0;
  double get smsPercentage => smsLimit > 0 ? (smsUsed / smsLimit) * 100 : 0;
  int get minutesRemaining =>
      (minutesLimit - minutesUsed).clamp(0, minutesLimit);
  int get smsRemaining => (smsLimit - smsUsed).clamp(0, smsLimit);

  factory SubscriptionUsage.fromJson(Map<String, dynamic> json) {
    return SubscriptionUsage(
      minutesUsed: json['minutes_used'] as int? ?? 0,
      minutesLimit: json['minutes_limit'] as int? ?? 0,
      smsUsed: json['sms_used'] as int? ?? 0,
      smsLimit: json['sms_limit'] as int? ?? 0,
      periodStart: json['period_start'] != null
          ? DateTime.parse(json['period_start'] as String)
          : null,
      periodEnd: json['period_end'] != null
          ? DateTime.parse(json['period_end'] as String)
          : null,
    );
  }
}
