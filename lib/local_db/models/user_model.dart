import 'package:hive/hive.dart';

part 'user_model.g.dart';

@HiveType(typeId: 0)
class UserModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String phone;

  @HiveField(3)
  final int age;

  @HiveField(4)
  final String city;

  @HiveField(5)
  final String? photoPath;

  @HiveField(6)
  final UserRole role;

  @HiveField(7)
  final bool isVerified;

  @HiveField(8)
  final DateTime createdAt;

  @HiveField(9)
  final DateTime updatedAt;

  UserModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.age,
    required this.city,
    this.photoPath,
    required this.role,
    this.isVerified = false,
    required this.createdAt,
    required this.updatedAt,
  });

  UserModel copyWith({
    String? id,
    String? name,
    String? phone,
    int? age,
    String? city,
    String? photoPath,
    UserRole? role,
    bool? isVerified,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      age: age ?? this.age,
      city: city ?? this.city,
      photoPath: photoPath ?? this.photoPath,
      role: role ?? this.role,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'age': age,
      'city': city,
      'photoPath': photoPath,
      'role': role.name,
      'isVerified': isVerified,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      phone: json['phone'],
      age: json['age'],
      city: json['city'],
      photoPath: json['photoPath'],
      role: UserRole.values.firstWhere((e) => e.name == json['role']),
      isVerified: json['isVerified'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}

@HiveType(typeId: 1)
enum UserRole {
  @HiveField(0)
  applicant,

  @HiveField(1)
  donor,
}
