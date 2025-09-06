import 'package:hive/hive.dart';
import 'application_model.dart';

part 'donation_model.g.dart';

@HiveType(typeId: 5)
class DonationModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String donorId;

  @HiveField(2)
  final String donorName;

  @HiveField(3)
  final String applicationId;

  @HiveField(4)
  final String applicantName;

  @HiveField(5)
  final HelpCategory category;

  @HiveField(6)
  final double? amount;

  @HiveField(7)
  final DonationType type;

  @HiveField(8)
  final DonationStatus status;

  @HiveField(9)
  final DateTime createdAt;

  @HiveField(10)
  final DateTime updatedAt;

  @HiveField(11)
  final String? notes;

  @HiveField(12)
  final String? paymentReference;

  DonationModel({
    required this.id,
    required this.donorId,
    required this.donorName,
    required this.applicationId,
    required this.applicantName,
    required this.category,
    this.amount,
    required this.type,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.notes,
    this.paymentReference,
  });

  DonationModel copyWith({
    String? id,
    String? donorId,
    String? donorName,
    String? applicationId,
    String? applicantName,
    HelpCategory? category,
    double? amount,
    DonationType? type,
    DonationStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? notes,
    String? paymentReference,
  }) {
    return DonationModel(
      id: id ?? this.id,
      donorId: donorId ?? this.donorId,
      donorName: donorName ?? this.donorName,
      applicationId: applicationId ?? this.applicationId,
      applicantName: applicantName ?? this.applicantName,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      notes: notes ?? this.notes,
      paymentReference: paymentReference ?? this.paymentReference,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'donorId': donorId,
      'donorName': donorName,
      'applicationId': applicationId,
      'applicantName': applicantName,
      'category': category.name,
      'amount': amount,
      'type': type.name,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'notes': notes,
      'paymentReference': paymentReference,
    };
  }

  factory DonationModel.fromJson(Map<String, dynamic> json) {
    return DonationModel(
      id: json['id'],
      donorId: json['donorId'],
      donorName: json['donorName'],
      applicationId: json['applicationId'],
      applicantName: json['applicantName'],
      category: HelpCategory.values.firstWhere(
        (e) => e.name == json['category'],
      ),
      amount: json['amount']?.toDouble(),
      type: DonationType.values.firstWhere((e) => e.name == json['type']),
      status: DonationStatus.values.firstWhere((e) => e.name == json['status']),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      notes: json['notes'],
      paymentReference: json['paymentReference'],
    );
  }
}

@HiveType(typeId: 6)
enum DonationType {
  @HiveField(0)
  financial,

  @HiveField(1)
  material,

  @HiveField(2)
  service,
}

@HiveType(typeId: 7)
enum DonationStatus {
  @HiveField(0)
  pending,

  @HiveField(1)
  completed,

  @HiveField(2)
  cancelled,
}
