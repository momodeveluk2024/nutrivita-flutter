class AppUser {
  const AppUser({
    required this.id,
    required this.email,
    required this.displayName,
    required this.units,
    required this.locale,
    required this.timezone,
    this.emailVerifiedAt,
  });

  final String id;
  final String email;
  final String displayName;
  final String units;
  final String locale;
  final String timezone;
  final DateTime? emailVerifiedAt;

  bool get isEmailVerified => emailVerifiedAt != null;

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] as String,
      email: json['email'] as String,
      displayName: json['display_name'] as String? ?? 'Friend',
      units: json['units'] as String? ?? 'metric',
      locale: json['locale'] as String? ?? 'en',
      timezone: json['timezone'] as String? ?? 'UTC',
      emailVerifiedAt: json['email_verified_at'] == null
          ? null
          : DateTime.tryParse(json['email_verified_at'] as String),
    );
  }

  String get initials {
    final parts = displayName
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    return parts.take(2).map((p) => p[0].toUpperCase()).join();
  }
}
