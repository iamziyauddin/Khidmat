// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'donation_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DonationModelAdapter extends TypeAdapter<DonationModel> {
  @override
  final int typeId = 5;

  @override
  DonationModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DonationModel(
      id: fields[0] as String,
      donorId: fields[1] as String,
      donorName: fields[2] as String,
      applicationId: fields[3] as String,
      applicantName: fields[4] as String,
      category: fields[5] as HelpCategory,
      amount: fields[6] as double?,
      type: fields[7] as DonationType,
      status: fields[8] as DonationStatus,
      createdAt: fields[9] as DateTime,
      updatedAt: fields[10] as DateTime,
      notes: fields[11] as String?,
      paymentReference: fields[12] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, DonationModel obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.donorId)
      ..writeByte(2)
      ..write(obj.donorName)
      ..writeByte(3)
      ..write(obj.applicationId)
      ..writeByte(4)
      ..write(obj.applicantName)
      ..writeByte(5)
      ..write(obj.category)
      ..writeByte(6)
      ..write(obj.amount)
      ..writeByte(7)
      ..write(obj.type)
      ..writeByte(8)
      ..write(obj.status)
      ..writeByte(9)
      ..write(obj.createdAt)
      ..writeByte(10)
      ..write(obj.updatedAt)
      ..writeByte(11)
      ..write(obj.notes)
      ..writeByte(12)
      ..write(obj.paymentReference);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DonationModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class DonationTypeAdapter extends TypeAdapter<DonationType> {
  @override
  final int typeId = 6;

  @override
  DonationType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return DonationType.financial;
      case 1:
        return DonationType.material;
      case 2:
        return DonationType.service;
      default:
        return DonationType.financial;
    }
  }

  @override
  void write(BinaryWriter writer, DonationType obj) {
    switch (obj) {
      case DonationType.financial:
        writer.writeByte(0);
        break;
      case DonationType.material:
        writer.writeByte(1);
        break;
      case DonationType.service:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DonationTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class DonationStatusAdapter extends TypeAdapter<DonationStatus> {
  @override
  final int typeId = 7;

  @override
  DonationStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return DonationStatus.pending;
      case 1:
        return DonationStatus.completed;
      case 2:
        return DonationStatus.cancelled;
      default:
        return DonationStatus.pending;
    }
  }

  @override
  void write(BinaryWriter writer, DonationStatus obj) {
    switch (obj) {
      case DonationStatus.pending:
        writer.writeByte(0);
        break;
      case DonationStatus.completed:
        writer.writeByte(1);
        break;
      case DonationStatus.cancelled:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DonationStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
