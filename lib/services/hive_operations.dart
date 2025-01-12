import 'package:hive/hive.dart';
import '../data/beetle_wiki.dart';
import '../main.dart';

class HiveOperationService { //CRUD
  final _favBox = Hive.box<BeetleWiki>(beetleWikiBoxName);

  Future<void> addToFavBox(BeetleWiki data) async {
    return _favBox.put(data.name, data);
  }

  Future<void> addBulkToFavBox(BeetleWiki data) async {
    final _insertMap = <String, BeetleWiki>{data.name: data};
    return _favBox.putAll(_insertMap);
  }

  Future<void> deleteFromFavBox(BeetleWiki data) async {
    return _favBox.delete(data.name);
  }

  Box<BeetleWiki> get favBox => _favBox;

  List<BeetleWiki> get fetchFromFavBox => _favBox.values.toList();
}
