import 'dart:io';
import 'dart:convert';
import 'package:background_fetch/background_fetch.dart';
import 'package:florae/screens/error.dart';
import 'package:florae/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'data/box.dart';
import 'data/plant.dart';
import 'data/beetle_wiki.dart';
import 'screens/home_page.dart';
import 'package:florae/notifications.dart' as notify;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'states/ruler_magnification_provider.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

const String beetleWikiBoxName = "beetleWikiBox";
late ObjectBox objectbox;
late Box beetleWikiBox;
GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  objectbox = await ObjectBox.create();

  // Set default locale for background service
  final prefs = await SharedPreferences.getInstance();
  String? locale = Platform.localeName.substring(0, 2);
  await prefs.setString('locale', locale);
  // initialize hive
  await Hive.initFlutter();
  Hive.registerAdapter(BeetleWikiAdapter());
  Hive.registerAdapter(GenusAdapter());
  Hive.registerAdapter(DifficultyAdapter());
  Hive.registerAdapter(PopularityAdapter());
  Hive.registerAdapter(SpanAdapter());
  beetleWikiBox = await Hive.openBox(beetleWikiBoxName);
  await loadJsonDataToHive();
  await ScreenUtil.ensureScreenSize();
  //runApp(const FloraeApp());
  runApp(
    ChangeNotifierProvider(
      create: (context) => RulerMagnificationProvider(),
      child: const FloraeApp(),
    ),
  );

  BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);
}

Future<void> loadJsonDataToHive() async {
  final String data = await rootBundle.loadString("assets/jsons/beetle_wiki.json");
  List jsonList = json.decode(data);
  final List<BeetleWiki> beetleWikiList = jsonList.map((val) => BeetleWiki.fromJson(val)).toList();
  await beetleWikiBox.clear();
  for (var beetleWiki in beetleWikiList) {
    beetleWikiBox.add(beetleWiki);
  }
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
  const FloraeApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    const Color darkTeal = Color.fromARGB(255, 0, 90, 48);
    const Color lightTeal = Color.fromARGB(255, 244, 255, 252);
    ScreenUtil.init(context);
    return MaterialApp(
        title: 'Florae',
        localizationsDelegates: const [
          AppLocalizations.delegate, // Add this line
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        // builder: (BuildContext context, Widget? widget) {
        //   ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
        //     return ErrorPage(errorDetails: errorDetails);
        //   };

        //   return widget!;
        // },
        supportedLocales: const [
          Locale('en'), // English
          Locale('zh'), // Chinese
          Locale('es'), // Spanish
          Locale('fr'), // French
        ],
        theme: ThemeData(
          useMaterial3: true,
          //primaryColor: Colors.teal,
          brightness: Brightness.light,
          colorScheme: ColorScheme.fromSeed(
            seedColor: darkTeal,
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.transparent,
            titleTextStyle: TextStyle(
                color: Colors.black54,
                fontSize: 30,
                fontWeight: FontWeight.w800,
                fontFamily: "NotoSans"),
            elevation: 0,
          ),
          navigationBarTheme: NavigationBarThemeData(
            iconTheme: MaterialStateProperty.all<IconThemeData>(
                const IconThemeData(color: darkTeal)
              ),
            labelTextStyle: MaterialStateProperty.resolveWith((state) {
              if (state.contains(MaterialState.selected)) {
                return const TextStyle(color: darkTeal, fontSize: 12);
              } else {
                return const TextStyle(color: Colors.black, fontSize: 12);
              }
            }),
            backgroundColor: Colors.white,
            shadowColor: Colors.black,
            surfaceTintColor: Colors.white,
          ),
          floatingActionButtonTheme: FloatingActionButtonThemeData(
            foregroundColor: Colors.white,
            backgroundColor: const Color.fromARGB(255, 0, 155, 115),
            splashColor: Colors.black.withOpacity(0.2),
          ),
          dialogTheme: DialogThemeData(
            elevation: 10,
            surfaceTintColor: Colors.white,
            backgroundColor: Colors.white,
            shadowColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            actionsPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
          ),
          textButtonTheme: TextButtonThemeData(
            style: ButtonStyle(
              foregroundColor: const MaterialStatePropertyAll(Colors.black),
              overlayColor: MaterialStatePropertyAll(darkTeal.withOpacity(0.2)),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ButtonStyle(
              foregroundColor: const MaterialStatePropertyAll(Colors.white),
              overlayColor: MaterialStatePropertyAll(Colors.black.withOpacity(0.1)),
              backgroundColor: const MaterialStatePropertyAll(Color.fromARGB(255, 30, 107, 63)),
              shape: MaterialStatePropertyAll(
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(24))),
              elevation: MaterialStateProperty.resolveWith<double>((Set<MaterialState> states) {
                if (states.contains(MaterialState.pressed)) return 0.0; // Elevation when pressed
                else return 0.0; // Elevation when not pressed
              }),
            ),
          ),
          cardTheme: const CardThemeData(
            surfaceTintColor: Colors.white,
            color: Colors.white,
          ),
          listTileTheme: const ListTileThemeData(
            tileColor: Colors.transparent,
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
                return TextStyle(color: color, letterSpacing: 1.2);
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
          //splashFactory: InkSparkle.splashFactory,
          //primarySwatch: Colors.teal,
          fontFamily: "NotoSans",
          scaffoldBackgroundColor: const Color.fromARGB(255, 240, 243, 240),
          snackBarTheme: SnackBarThemeData(
            contentTextStyle: TextStyle(color: Colors.green.shade500),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            behavior: SnackBarBehavior.floating,
          ),
        ),
        debugShowCheckedModeBanner: false,
        home: const SplashScreen(),//const MyHomePage(),
        builder: FToastBuilder(),
        navigatorKey: navigatorKey,
    );
  }
}
