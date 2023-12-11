import 'package:get_it/get_it.dart';
import 'services/hive_operations.dart';

GetIt locator = GetIt.instance;

void setupLocator() {
  locator.registerLazySingleton<HiveOperationService>(() => HiveOperationService());
}
