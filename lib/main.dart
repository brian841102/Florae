import 'dart:io';

import 'package:background_fetch/background_fetch.dart';
import 'package:florae/screens/error.dart';
import 'package:flutter/material.dart';
import 'data/box.dart';
import 'data/plant.dart';
import 'screens/home_page.dart';
import 'package:florae/notifications.dart' as notify;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

late ObjectBox objectbox;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  objectbox = await ObjectBox.create();

  // Set default locale for background service
  final prefs = await SharedPreferences.getInstance();
  String? locale = Platform.localeName.substring(0, 2);
  await prefs.setString('locale', locale);

  runApp(const FloraeApp());

  BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);
}

/// This "Headless Task" is run when app is terminated.
@pragma('vm:entry-point')
void backgroundFetchHeadlessTask(HeadlessTask task) async {
  var taskId = task.taskId;
  var timeout = task.timeout;
  if (timeout) {
    print("[BackgroundFetch] Headless task timed-out: $taskId");
    BackgroundFetch.finish(taskId);
    return;
  }

  print("[BackgroundFetch] Headless event received: $taskId");

  ObjectBox obx = await ObjectBox.create();

  List<Plant> allPlants = obx.plantBox.getAll();
  List<String> plants = [];
  String notificationTitle = "Plants require care";

  for (Plant p in allPlants) {
    for (Care c in p.cares) {
      var daysSinceLastCare = DateTime.now().difference(c.effected!).inDays;
      print(
          "headless florae plant ${p.name} with days since last care $daysSinceLastCare");
      // Report all unattended care, current and past
      if (daysSinceLastCare != 0 && daysSinceLastCare / c.cycles >= 1) {
        plants.add(p.name);
        break;
      }
    }
  }

  obx.store.close();

  try {
    final prefs = await SharedPreferences.getInstance();

    final String locale = prefs.getString('locale') ?? "en";

    if (AppLocalizations.delegate.isSupported(Locale(locale))) {
      final t = await AppLocalizations.delegate.load(Locale(locale));
      notificationTitle = t.careNotificationTitle;
    } else {
      print("handless florae: unsupported locale " + locale);
    }
  } on Exception catch (_) {
    print("handless florae: Failed to load locale");
  }

  if (plants.isNotEmpty) {
    notify.singleNotification(notificationTitle, plants.join('\n'), 7);
    print("headless florae detected plants " + plants.join(' '));
  } else {
    print("headless florae no plants require care");
  }

  print("[BackgroundFetch] Headless event finished: $taskId");

  BackgroundFetch.finish(taskId);
}

class FloraeApp extends StatelessWidget {
  const FloraeApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    const Color darkTeal = Color.fromARGB(255, 0, 90, 48);
    const Color lightTeal = Color.fromARGB(255, 244, 255, 252);
    return MaterialApp(
        title: 'Florae',
        localizationsDelegates: const [
          AppLocalizations.delegate, // Add this line
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        builder: (BuildContext context, Widget? widget) {
          ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
            return ErrorPage(errorDetails: errorDetails);
          };

          return widget!;
          },
        supportedLocales: const [
          Locale('en'), // English
          Locale('es'), // Spanish
          Locale('fr'), // French
        ],
        theme: ThemeData(
            useMaterial3: true,
            primaryColor: Colors.teal,
            textTheme: const TextTheme(
              labelSmall: TextStyle(
                  fontSize: 14,
                  fontFamily: 'NotoSans',
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
              ),
            ),
            appBarTheme: const AppBarTheme(
              color: lightTeal,
              foregroundColor: Colors.white,
              surfaceTintColor:  Colors.transparent,
            ),
            navigationBarTheme: NavigationBarThemeData(
              backgroundColor: Colors.white,
              shadowColor: Colors.black,
              surfaceTintColor: lightTeal,
              indicatorColor: darkTeal.withOpacity(0.2),
            ),
            floatingActionButtonTheme: FloatingActionButtonThemeData(
              foregroundColor: Colors.white,
              backgroundColor: const Color.fromARGB(255, 0, 155, 115),
              splashColor: Colors.black.withOpacity(0.3),
              elevation: 5.0,
            ),
            dialogTheme: DialogTheme(
              elevation: 10,
              surfaceTintColor:  Colors.white,
              backgroundColor:  Colors.white,
              shadowColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
            ),
            textButtonTheme: TextButtonThemeData(
              style: ButtonStyle(
                foregroundColor: const MaterialStatePropertyAll(Colors.black),
                overlayColor: MaterialStatePropertyAll(darkTeal.withOpacity(0.2)),
              ),
            ),
            cardTheme: const CardTheme(
              surfaceTintColor: Colors.white,
              color: Colors.white,
            ),
            listTileTheme: const ListTileThemeData(
              tileColor: Colors.white,
              selectedTileColor: Colors.white,
            ),
            inputDecorationTheme: InputDecorationTheme(
              focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(width: 2.0, color: Colors.teal)),
              enabledBorder: const UnderlineInputBorder(),
              floatingLabelStyle: MaterialStateTextStyle.resolveWith(
                (Set<MaterialState> states) {
                  final Color color = states.contains(MaterialState.error)
                    ? Theme.of(context).colorScheme.error
                    : Colors.teal;
                  return TextStyle(color: color, letterSpacing: 1.3);
                },
              ),
              fillColor: Colors.teal,
              focusColor: Colors.teal,
              hoverColor: Colors.teal,
            ),
            textSelectionTheme: const TextSelectionThemeData(
              cursorColor: Colors.teal,
              selectionColor: Colors.teal,
              selectionHandleColor: Colors.teal,
            ),
            splashFactory: InkRipple.splashFactory,
            primarySwatch: Colors.teal,
            fontFamily: "NotoSans",
            scaffoldBackgroundColor: const Color.fromARGB(255, 240, 243, 240),
        ),
        debugShowCheckedModeBanner: false,
        home: const MyHomePage(title: 'Today'));
  }
}
