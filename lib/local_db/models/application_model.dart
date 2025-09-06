import 'package:hive/hive.dart';

part 'application_model.g.dart';

@HiveType(typeId: 2)
class ApplicationModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String applicantId;

  @HiveField(2)
  final String applicantName;

  @HiveField(3)
  final String applicantPhone;

  @HiveField(4)
  final int applicantAge;

  @HiveField(5)
  final String address;

  @HiveField(6)
  final HelpCategory category;

  @HiveField(7)
  final String description;

  @HiveField(8)
  final double? amountNeeded;

  @HiveField(9)
  final List<String> documentPaths;

  @HiveField(10)
  final ApplicationStatus status;

  @HiveField(11)
  final DateTime createdAt;

  @HiveField(12)
  final DateTime updatedAt;

  @HiveField(13)
  final String? donorId;

  @HiveField(14)
  final DateTime? helpProvidedAt;

  @HiveField(15)
  final String? rejectionReason;

  @HiveField(16)
  final bool isUrgent;

  @HiveField(17)
  final double amountReceived;

  @HiveField(18)
  final List<String> donationIds;

  ApplicationModel({
    required this.id,
    required this.applicantId,
    required this.applicantName,
    required this.applicantPhone,
    required this.applicantAge,
    required this.address,
    required this.category,
    required this.description,
    this.amountNeeded,
    required this.documentPaths,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.donorId,
    this.helpProvidedAt,
    this.rejectionReason,
    this.isUrgent = false,
    this.amountReceived = 0.0,
    this.donationIds = const [],
  });

  ApplicationModel copyWith({
    String? id,
    String? applicantId,
    String? applicantName,
    String? applicantPhone,
    int? applicantAge,
    String? address,
    HelpCategory? category,
    String? description,
    double? amountNeeded,
    List<String>? documentPaths,
    ApplicationStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? donorId,
    DateTime? helpProvidedAt,
    String? rejectionReason,
    bool? isUrgent,
    double? amountReceived,
    List<String>? donationIds,
  }) {
    return ApplicationModel(
      id: id ?? this.id,
      applicantId: applicantId ?? this.applicantId,
      applicantName: applicantName ?? this.applicantName,
      applicantPhone: applicantPhone ?? this.applicantPhone,
      applicantAge: applicantAge ?? this.applicantAge,
      address: address ?? this.address,
      category: category ?? this.category,
      description: description ?? this.description,
      amountNeeded: amountNeeded ?? this.amountNeeded,
      documentPaths: documentPaths ?? this.documentPaths,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      donorId: donorId ?? this.donorId,
      helpProvidedAt: helpProvidedAt ?? this.helpProvidedAt,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      isUrgent: isUrgent ?? this.isUrgent,
      amountReceived: amountReceived ?? this.amountReceived,
      donationIds: donationIds ?? this.donationIds,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'applicantId': applicantId,
      'applicantName': applicantName,
      'applicantPhone': applicantPhone,
      'applicantAge': applicantAge,
      'address': address,
      'category': category.name,
      'description': description,
      'amountNeeded': amountNeeded,
      'documentPaths': documentPaths,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'donorId': donorId,
      'helpProvidedAt': helpProvidedAt?.toIso8601String(),
      'rejectionReason': rejectionReason,
      'isUrgent': isUrgent,
      'amountReceived': amountReceived,
      'donationIds': donationIds,
    };
  }

  factory ApplicationModel.fromJson(Map<String, dynamic> json) {
    return ApplicationModel(
      id: json['id'],
      applicantId: json['applicantId'],
      applicantName: json['applicantName'],
      applicantPhone: json['applicantPhone'],
      applicantAge: json['applicantAge'],
      address: json['address'],
      category: HelpCategory.values.firstWhere(
        (e) => e.name == json['category'],
      ),
      description: json['description'],
      amountNeeded: json['amountNeeded']?.toDouble(),
      documentPaths: List<String>.from(json['documentPaths'] ?? []),
      status: ApplicationStatus.values.firstWhere(
        (e) => e.name == json['status'],
      ),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      donorId: json['donorId'],
      helpProvidedAt: json['helpProvidedAt'] != null
          ? DateTime.parse(json['helpProvidedAt'])
          : null,
      rejectionReason: json['rejectionReason'],
      isUrgent: json['isUrgent'] ?? false,
      amountReceived: json['amountReceived']?.toDouble() ?? 0.0,
      donationIds: List<String>.from(json['donationIds'] ?? []),
    );
  }
}

@HiveType(typeId: 3)
enum HelpCategory {
  @HiveField(0)
  medical,

  @HiveField(1)
  housing,

  @HiveField(2)
  education,

  @HiveField(3)
  marriage,

  @HiveField(4)
  orphan,

  @HiveField(5)
  other,
}

@HiveType(typeId: 4)
enum ApplicationStatus {
  @HiveField(0)
  pending,

  @HiveField(1)
  verified,

  @HiveField(2)
  fulfilled,

  @HiveField(3)
  rejected,
}
