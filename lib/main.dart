import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:untitled3/screens/Signup page.dart';
import 'package:untitled3/screens/display setting screen.dart';
import 'package:untitled3/screens/front screen.dart';
import 'package:untitled3/screens/home screen.dart';
import 'package:untitled3/screens/login page.dart';
import 'package:untitled3/screens/onbondring screens.dart';
import 'package:untitled3/screens/profile page.dart';
import 'package:untitled3/screens/theme provider.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => DisplaySettingsProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<bool> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final displaySettings = Provider.of<DisplaySettingsProvider>(context);

    final highContrast = displaySettings.highContrast;

    final ColorScheme lightColorScheme = highContrast
        ? ColorScheme.highContrastLight()
        : ColorScheme.light();

    final ColorScheme darkColorScheme = highContrast
        ? ColorScheme.highContrastDark()
        : ColorScheme.dark();

    final Color lightTextColor = highContrast ? Colors.black : Colors.black87;
    final Color darkTextColor = highContrast ? Colors.white : Colors.white70;

    TextTheme getTextTheme(String fontFamily, double fontSizeFactor) {
      return TextTheme(
        displayLarge: TextStyle(fontFamily: fontFamily, fontSize: 57 * fontSizeFactor),
        displayMedium: TextStyle(fontFamily: fontFamily, fontSize: 45 * fontSizeFactor),
        displaySmall: TextStyle(fontFamily: fontFamily, fontSize: 36 * fontSizeFactor),
        headlineLarge: TextStyle(fontFamily: fontFamily, fontSize: 32 * fontSizeFactor),
        headlineMedium: TextStyle(fontFamily: fontFamily, fontSize: 28 * fontSizeFactor),
        headlineSmall: TextStyle(fontFamily: fontFamily, fontSize: 24 * fontSizeFactor),
        titleLarge: TextStyle(fontFamily: fontFamily, fontSize: 22 * fontSizeFactor),
        titleMedium: TextStyle(fontFamily: fontFamily, fontSize: 16 * fontSizeFactor),
        titleSmall: TextStyle(fontFamily: fontFamily, fontSize: 14 * fontSizeFactor),
        bodyLarge: TextStyle(fontFamily: fontFamily, fontSize: 16 * fontSizeFactor),
        bodyMedium: TextStyle(fontFamily: fontFamily, fontSize: 14 * fontSizeFactor),
        bodySmall: TextStyle(fontFamily: fontFamily, fontSize: 12 * fontSizeFactor),
        labelLarge: TextStyle(fontFamily: fontFamily, fontSize: 14 * fontSizeFactor),
        labelMedium: TextStyle(fontFamily: fontFamily, fontSize: 12 * fontSizeFactor),
        labelSmall: TextStyle(fontFamily: fontFamily, fontSize: 11 * fontSizeFactor),
      );
    }


    final TextTheme lightTextTheme = getTextTheme(
      displaySettings.fontFamily,
      displaySettings.fontSize / 16.0,
    );

    final TextTheme darkTextTheme = getTextTheme(
      displaySettings.fontFamily,
      displaySettings.fontSize / 16.0,
    );


    // Build the light theme
    final lightTheme = ThemeData(
      brightness: Brightness.light,
      fontFamily: displaySettings.fontFamily, // Set globally
      colorScheme: lightColorScheme,
      primaryColor: lightColorScheme.primary,
      textTheme: lightTextTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: lightColorScheme.primary,
        foregroundColor: lightTextColor,
      ),
    );

    // Build the dark theme
    final darkTheme = ThemeData(
      brightness: Brightness.dark,
      fontFamily: displaySettings.fontFamily, // Set globally
      colorScheme: darkColorScheme,
      primaryColor: darkColorScheme.primary,
      textTheme: darkTextTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: darkColorScheme.primary,
        foregroundColor: darkTextColor,
      ),
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Login App',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeProvider.themeMode,
      home: FutureBuilder<bool>(
        future: checkLoginStatus(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          return snapshot.data == true ? NewAccountScreen() : Frnt();
        },
      ),
      routes: {
        '/front': (context) => Frnt(),
        '/newAccount': (context) => NewAccountScreen(),
        '/features': (context) => OnboardingScreen(),
        '/login': (context) => Log(),
        '/profile': (context) => MyProfileScreen(),
        '/home': (context) => HomeScreen(),
      },
    );
  }
}
