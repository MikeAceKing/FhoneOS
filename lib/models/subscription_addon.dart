class SubscriptionAddon {
  final String id;
  final String code;
  final String name;
  final String description;
  final String type;
  final double price;
  final double yearlyPrice;
  final bool isActive;
  final Map<String, dynamic>? details;

  SubscriptionAddon({
    required this.id,
    required this.code,
    required this.name,
    required this.description,
    required this.type,
    required this.price,
    required this.yearlyPrice,
    required this.isActive,
    this.details,
  });

  factory SubscriptionAddon.fromJson(Map<String, dynamic> json) {
    return SubscriptionAddon(
      id: json['id'] as String,
      code: json['code'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      type: json['type'] as String,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      yearlyPrice: (json['price'] as num?)?.toDouble() ?? 0.0 * 12,
      isActive: json['is_active'] as bool? ?? true,
      details: json['details'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'description': description,
      'type': type,
      'price': price,
      'is_active': isActive,
      'details': details,
    };
  }

  static List<SubscriptionAddon> getAIAddons() {
    return [
      SubscriptionAddon(
        id: 'ai_lite',
        code: 'ai_lite_addon',
        name: 'AI Lite',
        description: '100 prompts per maand',
        type: 'feature',
        price: 5.0,
        yearlyPrice: 60.0,
        isActive: true,
        details: {'prompts': 100},
      ),
      SubscriptionAddon(
        id: 'ai_pro',
        code: 'ai_pro_addon',
        name: 'AI Pro',
        description: '1000 prompts per maand',
        type: 'feature',
        price: 15.0,
        yearlyPrice: 180.0,
        isActive: true,
        details: {'prompts': 1000},
      ),
      SubscriptionAddon(
        id: 'ai_unlimited',
        code: 'ai_unlimited_addon',
        name: 'AI Unlimited',
        description: 'Onbeperkte prompts',
        type: 'feature',
        price: 25.0,
        yearlyPrice: 300.0,
        isActive: true,
        details: {'prompts': -1},
      ),
    ];
  }

  static List<SubscriptionAddon> getNumberAddons() {
    return [
      SubscriptionAddon(
        id: 'extra_eu_number',
        code: 'extra_eu_number',
        name: 'Extra EU nummer',
        description: 'Aanvullend Europees telefoonnummer',
        type: 'phone_number',
        price: 5.0,
        yearlyPrice: 60.0,
        isActive: true,
        details: {'region': 'EU'},
      ),
      SubscriptionAddon(
        id: 'extra_usa_number',
        code: 'extra_usa_number',
        name: 'Extra USA nummer',
        description: 'Aanvullend Amerikaans telefoonnummer',
        type: 'phone_number',
        price: 3.0,
        yearlyPrice: 36.0,
        isActive: true,
        details: {'region': 'USA'},
      ),
      SubscriptionAddon(
        id: 'extra_international_number',
        code: 'extra_international_number',
        name: 'Extra internationaal nummer',
        description: 'Aanvullend internationaal telefoonnummer',
        type: 'phone_number',
        price: 7.0,
        yearlyPrice: 84.0,
        isActive: true,
        details: {'region': 'INTERNATIONAL'},
      ),
    ];
  }

  static List<SubscriptionAddon> getBundleAddons() {
    return [
      SubscriptionAddon(
        id: 'extra_100_min',
        code: 'extra_100_min',
        name: '+100 minuten',
        description: '100 extra belminuten per maand',
        type: 'feature',
        price: 3.0,
        yearlyPrice: 36.0,
        isActive: true,
        details: {'minutes': 100},
      ),
      SubscriptionAddon(
        id: 'extra_500_min',
        code: 'extra_500_min',
        name: '+500 minuten',
        description: '500 extra belminuten per maand',
        type: 'feature',
        price: 10.0,
        yearlyPrice: 120.0,
        isActive: true,
        details: {'minutes': 500},
      ),
      SubscriptionAddon(
        id: 'extra_100_sms',
        code: 'extra_100_sms',
        name: '+100 SMS',
        description: '100 extra SMS-berichten per maand',
        type: 'feature',
        price: 2.0,
        yearlyPrice: 24.0,
        isActive: true,
        details: {'sms': 100},
      ),
      SubscriptionAddon(
        id: 'extra_500_sms',
        code: 'extra_500_sms',
        name: '+500 SMS',
        description: '500 extra SMS-berichten per maand',
        type: 'feature',
        price: 7.0,
        yearlyPrice: 84.0,
        isActive: true,
        details: {'sms': 500},
      ),
    ];
  }
}
