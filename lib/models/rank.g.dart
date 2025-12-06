// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rank.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RankAdapter extends TypeAdapter<Rank> {
  @override
  final typeId = 5;

  @override
  Rank read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return Rank.cfs;
      case 1:
        return Rank.maj;
      case 2:
        return Rank.lta;
      case 3:
        return Rank.wo2;
      case 4:
        return Rank.wo1;
      case 5:
        return Rank.ssg;
      case 6:
        return Rank.sgt;
      case 7:
        return Rank.sgt3;
      case 8:
        return Rank.sgt2;
      case 9:
        return Rank.sgt1;
      case 10:
        return Rank.cpl;
      case 11:
        return Rank.lcpl;
      case 12:
        return Rank.pte;
      case 13:
        return Rank.cp;
      case 14:
        return Rank.unknown;
      default:
        return Rank.cfs;
    }
  }

  @override
  void write(BinaryWriter writer, Rank obj) {
    switch (obj) {
      case Rank.cfs:
        writer.writeByte(0);
      case Rank.maj:
        writer.writeByte(1);
      case Rank.lta:
        writer.writeByte(2);
      case Rank.wo2:
        writer.writeByte(3);
      case Rank.wo1:
        writer.writeByte(4);
      case Rank.ssg:
        writer.writeByte(5);
      case Rank.sgt:
        writer.writeByte(6);
      case Rank.sgt3:
        writer.writeByte(7);
      case Rank.sgt2:
        writer.writeByte(8);
      case Rank.sgt1:
        writer.writeByte(9);
      case Rank.cpl:
        writer.writeByte(10);
      case Rank.lcpl:
        writer.writeByte(11);
      case Rank.pte:
        writer.writeByte(12);
      case Rank.cp:
        writer.writeByte(13);
      case Rank.unknown:
        writer.writeByte(14);
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RankAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
