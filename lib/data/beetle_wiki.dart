import 'package:hive/hive.dart';
part 'beetle_wiki.g.dart';

@HiveType(typeId: 1)
class BeetleWiki {
  BeetleWiki({required this.name, required this.period});
  @HiveField(0)
  String name;

  @HiveField(1)
  int period;
}
