class SubscriptionPlan {
  final String id;
  final String code;
  final String name;
  final String? description;
  final double priceMonthly;
  final double priceYearly;
  final int minutesIncluded;
  final int smsIncluded;
  final int numbersIncluded;
  final String aiLevel;
  final int aiPromptsIncluded;
  final bool isActive;
  final String? stripePriceId;
  final double profitMarginEur;

  SubscriptionPlan({
    required this.id,
    required this.code,
    required this.name,
    this.description,
    required this.priceMonthly,
    required this.priceYearly,
    required this.minutesIncluded,
    required this.smsIncluded,
    required this.numbersIncluded,
    required this.aiLevel,
    required this.aiPromptsIncluded,
    required this.isActive,
    this.stripePriceId,
    required this.profitMarginEur,
  });

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlan(
      id: json['id'] as String,
      code: json['code'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      priceMonthly: (json['price_monthly'] as num).toDouble(),
      priceYearly: (json['price_yearly'] as num).toDouble(),
      minutesIncluded: json['minutes_included'] as int? ?? 0,
      smsIncluded: json['sms_included'] as int? ?? 0,
      numbersIncluded: json['numbers_included'] as int? ?? 0,
      aiLevel: json['ai_level'] as String? ?? 'none',
      aiPromptsIncluded: json['ai_prompts_included'] as int? ?? 0,
      isActive: json['is_active'] as bool? ?? true,
      stripePriceId: json['stripe_price_id'] as String?,
      profitMarginEur: (json['profit_margin_eur'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'description': description,
      'price_monthly': priceMonthly,
      'price_yearly': priceYearly,
      'minutes_included': minutesIncluded,
      'sms_included': smsIncluded,
      'numbers_included': numbersIncluded,
      'ai_level': aiLevel,
      'ai_prompts_included': aiPromptsIncluded,
      'is_active': isActive,
      'stripe_price_id': stripePriceId,
      'profit_margin_eur': profitMarginEur,
    };
  }
}
