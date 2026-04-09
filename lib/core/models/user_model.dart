enum UserRole {
  rider,
  driver,
  admin
}

class UserModel {
  final String id;
  final UserRole role;
  final String? firstName;
  final String? lastName;
  final String? phone;
  final double trustScore;
  final bool isKycVerified;
  final bool isWomenSafe;
  final DateTime? createdAt;

  UserModel({
    required this.id,
    required this.role,
    this.firstName,
    this.lastName,
    this.phone,
    this.trustScore = 5.0,
    this.isKycVerified = false,
    this.isWomenSafe = false,
    this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      role: UserRole.values.firstWhere(
        (e) => e.name.toLowerCase() == json['role'].toString().toLowerCase(),
        orElse: () => UserRole.rider,
      ),
      firstName: json['first_name'],
      lastName: json['last_name'],
      phone: json['phone'],
      trustScore: (json['trust_score'] as num?)?.toDouble() ?? 5.0,
      isKycVerified: json['is_kyc_verified'] ?? false,
      isWomenSafe: json['is_women_safe'] ?? false,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'role': role.name,
      'first_name': firstName,
      'last_name': lastName,
      'phone': phone,
      'trust_score': trustScore,
      'is_kyc_verified': isKycVerified,
      'is_women_safe': isWomenSafe,
    };
  }
}
