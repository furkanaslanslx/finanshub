import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/instance_manager.dart';
import 'package:hub/firebase_options.dart';
import 'package:hub/services/api_service.dart';
import 'package:hub/services/variables.dart';
import 'package:hub/v/drawer_view.dart' as custom;
import 'package:hub/vm/all_vms.dart';
import 'package:hub/vm/themenotifier.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  Get.put<custom.DrawerController>(custom.DrawerController());
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  ApiService apiService = ApiService();
  await apiService.initialize();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  final prefs = await SharedPreferences.getInstance();

  final String? themeModeString = prefs.getString(themeModeKey);
  ThemeMode themeMode;
  switch (themeModeString) {
    case 'light':
      themeMode = ThemeMode.light;
      break;
    case 'dark':
      themeMode = ThemeMode.dark;
      break;
    case 'system':
      themeMode = ThemeMode.system;
      break;
    default:
      themeMode = ThemeMode.system;
      break;
  }

  final String? iconColorString = prefs.getString(iconColorKey);
  Color iconColor;
  if (iconColorString != null && iconColorString.length == 8) {
    try {
      int colorInt = int.parse(iconColorString, radix: 16);
      iconColor = Color(colorInt);
    } catch (e) {
      iconColor = themeNotifier.iconColor;
    }
  } else {
    iconColor = const Color(0xFFFD4F46);
  }
  themeNotifier = ThemeNotifier(themeMode, iconColor);

  final bool isFirstLaunch = prefs.getBool(isFirstLaunchKey) ?? true;
  await initializeDateFormatting('tr_TR', null);

  runApp(
    Root(
      themeMode: themeMode,
      iconColor: iconColor,
      isFirstLaunch: isFirstLaunch,
    ),
  );
}

class Root extends StatelessWidget {
  const Root({
    super.key,
    required this.themeMode,
    required this.iconColor,
    required this.isFirstLaunch,
  });

  final ThemeMode themeMode;
  final Color iconColor;
  final bool isFirstLaunch;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ThemeNotifier>.value(
      value: themeNotifier,
      builder: (context, child) {
        return Consumer<ThemeNotifier>(
          builder: (context, themeNotifier, child) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: lightTheme(context),
              darkTheme: darkTheme(context),
              themeMode: themeNotifier.themeMode,
              home: custom.DrawerView(isFirstLaunch: isFirstLaunch),
            );
          },
        );
      },
    );
  }

  ThemeData lightTheme(BuildContext context) {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: themeNotifier.iconColor),
      primaryColor: themeNotifier.iconColor,
      appBarTheme: AppBarTheme(
        backgroundColor: themeNotifier.iconColor,
        foregroundColor: Colors.white,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: themeNotifier.iconColor,
      ),
      buttonTheme: ButtonThemeData(
        buttonColor: themeNotifier.iconColor,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: themeNotifier.iconColor,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: themeNotifier.iconColor,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: themeNotifier.iconColor),
        ),
      ),
      useMaterial3: true,
    );
  }

  ThemeData darkTheme(BuildContext context) {
    return ThemeData.dark().copyWith(
      colorScheme: ColorScheme.fromSeed(seedColor: themeNotifier.iconColor, brightness: Brightness.dark),
      primaryColor: themeNotifier.iconColor,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: themeNotifier.iconColor,
      ),
      buttonTheme: ButtonThemeData(
        buttonColor: themeNotifier.iconColor,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: themeNotifier.iconColor,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: themeNotifier.iconColor,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: themeNotifier.iconColor),
        ),
      ),
    );
  }
}
