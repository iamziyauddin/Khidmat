// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'application_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ApplicationModelAdapter extends TypeAdapter<ApplicationModel> {
  @override
  final int typeId = 2;

  @override
  ApplicationModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ApplicationModel(
      id: fields[0] as String,
      applicantId: fields[1] as String,
      applicantName: fields[2] as String,
      applicantPhone: fields[3] as String,
      applicantAge: fields[4] as int,
      address: fields[5] as String,
      category: fields[6] as HelpCategory,
      description: fields[7] as String,
      amountNeeded: fields[8] as double?,
      documentPaths: (fields[9] as List).cast<String>(),
      status: fields[10] as ApplicationStatus,
      createdAt: fields[11] as DateTime,
      updatedAt: fields[12] as DateTime,
      donorId: fields[13] as String?,
      helpProvidedAt: fields[14] as DateTime?,
      rejectionReason: fields[15] as String?,
      isUrgent: fields[16] as bool,
      amountReceived: fields[17] as double,
      donationIds: (fields[18] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, ApplicationModel obj) {
    writer
      ..writeByte(19)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.applicantId)
      ..writeByte(2)
      ..write(obj.applicantName)
      ..writeByte(3)
      ..write(obj.applicantPhone)
      ..writeByte(4)
      ..write(obj.applicantAge)
      ..writeByte(5)
      ..write(obj.address)
      ..writeByte(6)
      ..write(obj.category)
      ..writeByte(7)
      ..write(obj.description)
      ..writeByte(8)
      ..write(obj.amountNeeded)
      ..writeByte(9)
      ..write(obj.documentPaths)
      ..writeByte(10)
      ..write(obj.status)
      ..writeByte(11)
      ..write(obj.createdAt)
      ..writeByte(12)
      ..write(obj.updatedAt)
      ..writeByte(13)
      ..write(obj.donorId)
      ..writeByte(14)
      ..write(obj.helpProvidedAt)
      ..writeByte(15)
      ..write(obj.rejectionReason)
      ..writeByte(16)
      ..write(obj.isUrgent)
      ..writeByte(17)
      ..write(obj.amountReceived)
      ..writeByte(18)
      ..write(obj.donationIds);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ApplicationModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class HelpCategoryAdapter extends TypeAdapter<HelpCategory> {
  @override
  final int typeId = 3;

  @override
  HelpCategory read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return HelpCategory.medical;
      case 1:
        return HelpCategory.housing;
      case 2:
        return HelpCategory.education;
      case 3:
        return HelpCategory.marriage;
      case 4:
        return HelpCategory.orphan;
      case 5:
        return HelpCategory.other;
      default:
        return HelpCategory.medical;
    }
  }

  @override
  void write(BinaryWriter writer, HelpCategory obj) {
    switch (obj) {
      case HelpCategory.medical:
        writer.writeByte(0);
        break;
      case HelpCategory.housing:
        writer.writeByte(1);
        break;
      case HelpCategory.education:
        writer.writeByte(2);
        break;
      case HelpCategory.marriage:
        writer.writeByte(3);
        break;
      case HelpCategory.orphan:
        writer.writeByte(4);
        break;
      case HelpCategory.other:
        writer.writeByte(5);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HelpCategoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ApplicationStatusAdapter extends TypeAdapter<ApplicationStatus> {
  @override
  final int typeId = 4;

  @override
  ApplicationStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ApplicationStatus.pending;
      case 1:
        return ApplicationStatus.verified;
      case 2:
        return ApplicationStatus.fulfilled;
      case 3:
        return ApplicationStatus.rejected;
      default:
        return ApplicationStatus.pending;
    }
  }

  @override
  void write(BinaryWriter writer, ApplicationStatus obj) {
    switch (obj) {
      case ApplicationStatus.pending:
        writer.writeByte(0);
        break;
      case ApplicationStatus.verified:
        writer.writeByte(1);
        break;
      case ApplicationStatus.fulfilled:
        writer.writeByte(2);
        break;
      case ApplicationStatus.rejected:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ApplicationStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
