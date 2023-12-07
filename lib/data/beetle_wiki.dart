import 'package:hive/hive.dart';
part 'beetle_wiki.g.dart';

@HiveType(typeId: 0)
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
              required this.imagePath,});
  //name
  @HiveField(0)
  String name;
  @HiveField(1)
  String nameSci;
  @HiveField(2)
  String nameJP;
  //custom type
  @HiveField(3)
  Genus genus;
  @HiveField(4)
  Difficulty difficulty;
  @HiveField(5)
  Popularity popularity;
  @HiveField(6)
  Span span;
  //native type
  @HiveField(7)
  int boxSize;
  @HiveField(8)
  String larvaTemp;
  @HiveField(9)
  String larvaTime;
  @HiveField(10)
  String hiberTime;
  @HiveField(11)
  String adultTime;
  @HiveField(12)
  String adultSize;
  @HiveField(13)
  String birth;
  @HiveField(14)
  String imagePath;
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
