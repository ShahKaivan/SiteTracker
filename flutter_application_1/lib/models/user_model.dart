// User model
class UserModel {
  final String id;
  final String mobileNumber;
  final String countryCode;
  final String? fullName;
  final String? role;
  final bool isMobileVerified;
  final String? profileImageUrl;
  final DateTime createdAt;
  final DateTime? lastLoginAt;

  UserModel({
    required this.id,
    required this.mobileNumber,
    required this.countryCode,
    this.fullName,
    this.role,
    required this.isMobileVerified,
    this.profileImageUrl,
    required this.createdAt,
    this.lastLoginAt,
  });

  // Create UserModel from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      mobileNumber: json['mobile_number'] as String,
      countryCode: json['country_code'] as String,
      fullName: json['full_name'] as String?,
      role: json['role'] as String?,
      isMobileVerified: json['is_mobile_verified'] as bool? ?? false,
      profileImageUrl: json['profile_image_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      lastLoginAt: json['last_login_at'] != null
          ? DateTime.parse(json['last_login_at'] as String)
          : null,
    );
  }

  // Convert UserModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mobile_number': mobileNumber,
      'country_code': countryCode,
      'full_name': fullName,
      'role': role,
      'is_mobile_verified': isMobileVerified,
      'profile_image_url': profileImageUrl,
      'created_at': createdAt.toIso8601String(),
      'last_login_at': lastLoginAt?.toIso8601String(),
    };
  }

  // Create a copy with updated fields
  UserModel copyWith({
    String? id,
    String? mobileNumber,
    String? countryCode,
    String? fullName,
    String? role,
    bool? isMobileVerified,
    String? profileImageUrl,
    DateTime? createdAt,
    DateTime? lastLoginAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      countryCode: countryCode ?? this.countryCode,
      fullName: fullName ?? this.fullName,
      role: role ?? this.role,
      isMobileVerified: isMobileVerified ?? this.isMobileVerified,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }
}
