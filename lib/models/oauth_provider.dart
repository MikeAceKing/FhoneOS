class OAuthProvider {
  final String id;
  final String name;
  final String iconUrl;
  final bool isEnabled;

  OAuthProvider({
    required this.id,
    required this.name,
    required this.iconUrl,
    required this.isEnabled,
  });

  factory OAuthProvider.fromJson(Map<String, dynamic> json) {
    return OAuthProvider(
      id: json['id'] as String,
      name: json['name'] as String,
      iconUrl: json['icon_url'] as String,
      isEnabled: json['is_enabled'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon_url': iconUrl,
      'is_enabled': isEnabled,
    };
  }

  static List<OAuthProvider> getDefaultProviders() {
    return [
      OAuthProvider(
        id: 'google',
        name: 'Google',
        iconUrl:
            'https://cdn.jsdelivr.net/npm/simple-icons@v9/icons/google.svg',
        isEnabled: true,
      ),
      OAuthProvider(
        id: 'microsoft',
        name: 'Microsoft',
        iconUrl:
            'https://cdn.jsdelivr.net/npm/simple-icons@v9/icons/microsoft.svg',
        isEnabled: true,
      ),
      OAuthProvider(
        id: 'apple',
        name: 'Apple',
        iconUrl: 'https://cdn.jsdelivr.net/npm/simple-icons@v9/icons/apple.svg',
        isEnabled: true,
      ),
    ];
  }
}
