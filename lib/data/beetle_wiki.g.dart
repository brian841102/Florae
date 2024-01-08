// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'beetle_wiki.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BeetleWikiAdapter extends TypeAdapter<BeetleWiki> {
  @override
  final int typeId = 0;

  @override
  BeetleWiki read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BeetleWiki(
      name: fields[0] as String,
      nameSci: fields[1] as String,
      nameJP: fields[2] as String,
      genus: fields[3] as Genus,
      difficulty: fields[4] as Difficulty?,
      popularity: fields[5] as Popularity?,
      span: fields[6] as Span?,
      boxSize: fields[7] as String?,
      larvaTemp: fields[8] as String?,
      larvaTime: fields[9] as String?,
      hiberTime: fields[10] as String?,
      adultTime: fields[11] as String?,
      adultSize: fields[12] as String?,
      birth: fields[13] as String?,
      imagePath: fields[14] as String,
      imagePathR: fields[15] as String,
      isFavorite: fields[16] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, BeetleWiki obj) {
    writer
      ..writeByte(17)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.nameSci)
      ..writeByte(2)
      ..write(obj.nameJP)
      ..writeByte(3)
      ..write(obj.genus)
      ..writeByte(4)
      ..write(obj.difficulty)
      ..writeByte(5)
      ..write(obj.popularity)
      ..writeByte(6)
      ..write(obj.span)
      ..writeByte(7)
      ..write(obj.boxSize)
      ..writeByte(8)
      ..write(obj.larvaTemp)
      ..writeByte(9)
      ..write(obj.larvaTime)
      ..writeByte(10)
      ..write(obj.hiberTime)
      ..writeByte(11)
      ..write(obj.adultTime)
      ..writeByte(12)
      ..write(obj.adultSize)
      ..writeByte(13)
      ..write(obj.birth)
      ..writeByte(14)
      ..write(obj.imagePath)
      ..writeByte(15)
      ..write(obj.imagePathR)
      ..writeByte(16)
      ..write(obj.isFavorite);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BeetleWikiAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class GenusAdapter extends TypeAdapter<Genus> {
  @override
  final int typeId = 1;

  @override
  Genus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return Genus.Cyclommatus;
      case 1:
        return Genus.Dorcus;
      case 2:
        return Genus.Lucanus;
      case 3:
        return Genus.Neolucanus;
      case 4:
        return Genus.Odontolabis;
      case 5:
        return Genus.Prosopocoilus;
      default:
        return Genus.Cyclommatus;
    }
  }

  @override
  void write(BinaryWriter writer, Genus obj) {
    switch (obj) {
      case Genus.Cyclommatus:
        writer.writeByte(0);
        break;
      case Genus.Dorcus:
        writer.writeByte(1);
        break;
      case Genus.Lucanus:
        writer.writeByte(2);
        break;
      case Genus.Neolucanus:
        writer.writeByte(3);
        break;
      case Genus.Odontolabis:
        writer.writeByte(4);
        break;
      case Genus.Prosopocoilus:
        writer.writeByte(5);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GenusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class DifficultyAdapter extends TypeAdapter<Difficulty> {
  @override
  final int typeId = 2;

  @override
  Difficulty read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return Difficulty.Easy;
      case 1:
        return Difficulty.Medium;
      case 2:
        return Difficulty.Hard;
      case 3:
        return Difficulty.Expert;
      default:
        return Difficulty.Easy;
    }
  }

  @override
  void write(BinaryWriter writer, Difficulty obj) {
    switch (obj) {
      case Difficulty.Easy:
        writer.writeByte(0);
        break;
      case Difficulty.Medium:
        writer.writeByte(1);
        break;
      case Difficulty.Hard:
        writer.writeByte(2);
        break;
      case Difficulty.Expert:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DifficultyAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PopularityAdapter extends TypeAdapter<Popularity> {
  @override
  final int typeId = 3;

  @override
  Popularity read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return Popularity.One;
      case 1:
        return Popularity.Two;
      case 2:
        return Popularity.Three;
      case 3:
        return Popularity.Four;
      case 4:
        return Popularity.Five;
      default:
        return Popularity.One;
    }
  }

  @override
  void write(BinaryWriter writer, Popularity obj) {
    switch (obj) {
      case Popularity.One:
        writer.writeByte(0);
        break;
      case Popularity.Two:
        writer.writeByte(1);
        break;
      case Popularity.Three:
        writer.writeByte(2);
        break;
      case Popularity.Four:
        writer.writeByte(3);
        break;
      case Popularity.Five:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PopularityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SpanAdapter extends TypeAdapter<Span> {
  @override
  final int typeId = 4;

  @override
  Span read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return Span.Short;
      case 1:
        return Span.Medium;
      case 2:
        return Span.Long;
      default:
        return Span.Short;
    }
  }

  @override
  void write(BinaryWriter writer, Span obj) {
    switch (obj) {
      case Span.Short:
        writer.writeByte(0);
        break;
      case Span.Medium:
        writer.writeByte(1);
        break;
      case Span.Long:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SpanAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BeetleWiki _$BeetleWikiFromJson(Map<String, dynamic> json) => BeetleWiki(
      name: json['name'] as String? ?? 'Empty',
      nameSci: json['nameSci'] as String? ?? 'Empty',
      nameJP: json['nameJP'] as String? ?? 'Empty',
      genus: $enumDecodeNullable(_$GenusEnumMap, json['genus']) ??
          Genus.Cyclommatus,
      difficulty: $enumDecodeNullable(_$DifficultyEnumMap, json['difficulty']),
      popularity: $enumDecodeNullable(_$PopularityEnumMap, json['popularity']),
      span: $enumDecodeNullable(_$SpanEnumMap, json['span']),
      boxSize: json['boxSize'] as String?,
      larvaTemp: json['larvaTemp'] as String?,
      larvaTime: json['larvaTime'] as String?,
      hiberTime: json['hiberTime'] as String?,
      adultTime: json['adultTime'] as String?,
      adultSize: json['adultSize'] as String?,
      birth: json['birth'] as String?,
      imagePath: json['imagePath'] as String? ?? 'assets/images/cmf.png',
      imagePathR: json['imagePathR'] as String? ?? 'assets/images/cmf_r.png',
      isFavorite: json['isFavorite'] as bool? ?? false,
    );

Map<String, dynamic> _$BeetleWikiToJson(BeetleWiki instance) =>
    <String, dynamic>{
      'name': instance.name,
      'nameSci': instance.nameSci,
      'nameJP': instance.nameJP,
      'genus': _$GenusEnumMap[instance.genus]!,
      'difficulty': _$DifficultyEnumMap[instance.difficulty],
      'popularity': _$PopularityEnumMap[instance.popularity],
      'span': _$SpanEnumMap[instance.span],
      'boxSize': instance.boxSize,
      'larvaTemp': instance.larvaTemp,
      'larvaTime': instance.larvaTime,
      'hiberTime': instance.hiberTime,
      'adultTime': instance.adultTime,
      'adultSize': instance.adultSize,
      'birth': instance.birth,
      'imagePath': instance.imagePath,
      'imagePathR': instance.imagePathR,
      'isFavorite': instance.isFavorite,
    };

const _$GenusEnumMap = {
  Genus.Cyclommatus: 'Cyclommatus',
  Genus.Dorcus: 'Dorcus',
  Genus.Lucanus: 'Lucanus',
  Genus.Neolucanus: 'Neolucanus',
  Genus.Odontolabis: 'Odontolabis',
  Genus.Prosopocoilus: 'Prosopocoilus',
};

const _$DifficultyEnumMap = {
  Difficulty.Easy: 'Easy',
  Difficulty.Medium: 'Medium',
  Difficulty.Hard: 'Hard',
  Difficulty.Expert: 'Expert',
};

const _$PopularityEnumMap = {
  Popularity.One: 'One',
  Popularity.Two: 'Two',
  Popularity.Three: 'Three',
  Popularity.Four: 'Four',
  Popularity.Five: 'Five',
};

const _$SpanEnumMap = {
  Span.Short: 'Short',
  Span.Medium: 'Medium',
  Span.Long: 'Long',
};
