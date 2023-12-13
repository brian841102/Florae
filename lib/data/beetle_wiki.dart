import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
part 'beetle_wiki.g.dart';

@HiveType(typeId: 0)
@JsonSerializable()//fieldRename: FieldRename.snake
class BeetleWiki {
  BeetleWiki({required this.name,
              required this.nameSci,
              required this.nameJP,
              required this.genus,
              required this.difficulty,
              required this.popularity,
              required this.span,
              required this.boxSize,
              required this.larvaTemp,
              required this.larvaTime,
              required this.hiberTime,
              required this.adultTime,
              required this.adultSize,
              required this.birth,
              required this.imagePath,
              required this.isFavorite});
  //name
  @HiveField(0)
  @JsonKey(name: 'name', defaultValue: 'Empty')
  String name;
  @HiveField(1)
  @JsonKey(name: 'nameSci', defaultValue: 'Empty')
  String nameSci;
  @HiveField(2)
  @JsonKey(name: 'nameJP', defaultValue: 'Empty')
  String nameJP;
  //custom type
  @HiveField(3)
  @JsonKey(name: 'genus', defaultValue: 'Empty')
  Genus genus;
  @HiveField(4)
  @JsonKey(name: 'difficulty')
  Difficulty? difficulty;
  @HiveField(5)
  @JsonKey(name: 'popularity')
  Popularity? popularity;
  @HiveField(6)
  @JsonKey(name: 'span')
  Span? span;
  //native type
  @HiveField(7)
  @JsonKey(name: 'boxSize')
  int? boxSize;
  @HiveField(8)
  @JsonKey(name: 'larvaTemp')
  String? larvaTemp;
  @HiveField(9)
  @JsonKey(name: 'larvaTime')
  String? larvaTime;
  @HiveField(10)
  @JsonKey(name: 'hiberTime')
  String? hiberTime;
  @HiveField(11)
  @JsonKey(name: 'adultTime')
  String? adultTime;
  @HiveField(12)
  @JsonKey(name: 'adultSize')
  String? adultSize;
  @HiveField(13)
  @JsonKey(name: 'birth')
  String? birth;
  @HiveField(14)
  @JsonKey(name: 'imagePath', defaultValue: 'assets/images/cmf.png')
  String imagePath;
  @HiveField(15)
  @JsonKey(name: 'isFavorite', defaultValue: false)
  bool isFavorite;
  
  /// A necessary factory constructor for creating a new instance
  /// from a map. Pass the map to the generated `_$BeetleWikiFromJson()` constructor.
  factory BeetleWiki.fromJson(Map<String, dynamic> json) => _$BeetleWikiFromJson(json);

  /// `toJson` is the convention for a class to declare support for serialization
  /// to JSON. The implementation simply calls the private, generated
  /// helper method `_$BeetleWikiToJson`.
  Map<String, dynamic> toJson() => _$BeetleWikiToJson(this);
}

@HiveType(typeId: 1)
enum Genus {
  @HiveField(0)
  Cyclommatus,
  @HiveField(1)
  Dorcus,
  @HiveField(2)
  Lucanus,
  @HiveField(3)
  Neolucanus,
  @HiveField(4)
  Odontolabis,
  @HiveField(5)
  Prosopocoilus,
}
const genuses = <Genus, String>{
  Genus.Cyclommatus: "Cyclommatus",
  Genus.Dorcus: "Dorcus",
  Genus.Lucanus: "Lucanus",
  Genus.Neolucanus: "Neolucanus",
  Genus.Odontolabis: "Odontolabis",
  Genus.Prosopocoilus: "Prosopocoilus",
};

@HiveType(typeId: 2)
enum Difficulty {
  @HiveField(0)
  Easy,
  @HiveField(1)
  Medium,
  @HiveField(2)
  Hard,
  @HiveField(3)
  Expert,
}
const diffuculties = <Difficulty, String>{
  Difficulty.Easy: "容易",
  Difficulty.Medium: "普通",
  Difficulty.Hard: "困難",
  Difficulty.Expert: "專家",
};

@HiveType(typeId: 3)
enum Popularity {
  @HiveField(0)
  One,
  @HiveField(1)
  Two,
  @HiveField(2)
  Three,
  @HiveField(3)
  Four,
  @HiveField(4)
  Five,
}
const popularities = <Popularity, String>{
  Popularity.One: "一星級",
  Popularity.Two: "二星級",
  Popularity.Three: "三星級",
  Popularity.Four: "四星級",
  Popularity.Five: "五星級",
};

@HiveType(typeId: 4)
enum Span {
  @HiveField(0)
  Short,
  @HiveField(1)
  Medium,
  @HiveField(2)
  Long,
}
const spans = <Span, String>{
  Span.Short: "短",
  Span.Medium: "中",
  Span.Long: "長",
};
