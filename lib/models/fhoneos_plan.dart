class FhoneOSPlan {
  final String id;
  final String code;
  final String name;
  final String description;
  final double priceMonthly;
  final double priceYearly;
  final int minutesIncluded;
  final int smsIncluded;
  final int phoneNumbersIncluded;
  final String? stripePriceId;
  final bool isActive;
  final DateTime? createdAt;

  const FhoneOSPlan({
    required this.id,
    required this.code,
    required this.name,
    required this.description,
    required this.priceMonthly,
    required this.priceYearly,
    required this.minutesIncluded,
    required this.smsIncluded,
    required this.phoneNumbersIncluded,
    this.stripePriceId,
    this.isActive = true,
    this.createdAt,
  });

  factory FhoneOSPlan.fromJson(Map<String, dynamic> json) {
    return FhoneOSPlan(
      id: json['id'] as String,
      code: json['code'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      priceMonthly: (json['price_monthly'] as num).toDouble(),
      priceYearly: (json['price_yearly'] as num?)?.toDouble() ?? 0.0,
      minutesIncluded: json['minutes_included'] as int? ?? 0,
      smsIncluded: json['sms_included'] as int? ?? 0,
      phoneNumbersIncluded: json['phone_numbers_included'] as int? ?? 1,
      stripePriceId: json['stripe_price_id'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
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
      'phone_numbers_included': phoneNumbersIncluded,
      'stripe_price_id': stripePriceId,
      'is_active': isActive,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  String get formattedPrice => '€${priceMonthly.toStringAsFixed(2)} / maand';

  String get bundleDetails =>
      '$minutesIncluded minuten • $smsIncluded sms • $phoneNumbersIncluded nummer';

  FhoneOSPlan copyWith({
    String? id,
    String? code,
    String? name,
    String? description,
    double? priceMonthly,
    double? priceYearly,
    int? minutesIncluded,
    int? smsIncluded,
    int? phoneNumbersIncluded,
    String? stripePriceId,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return FhoneOSPlan(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      description: description ?? this.description,
      priceMonthly: priceMonthly ?? this.priceMonthly,
      priceYearly: priceYearly ?? this.priceYearly,
      minutesIncluded: minutesIncluded ?? this.minutesIncluded,
      smsIncluded: smsIncluded ?? this.smsIncluded,
      phoneNumbersIncluded: phoneNumbersIncluded ?? this.phoneNumbersIncluded,
      stripePriceId: stripePriceId ?? this.stripePriceId,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
