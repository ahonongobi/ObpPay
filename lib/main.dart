import 'package:flutter/material.dart';
import 'package:obppay/providers/user_provider.dart';
import 'package:obppay/screens/splash_screen.dart';
import 'package:obppay/themes/light_theme.dart';
import 'package:provider/provider.dart';
import 'providers/theme_provider.dart';
import 'themes/dark_theme.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()), // ✅ Add this
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: themeProvider.isDarkMode ? darkTheme : lightTheme,

        //home: const Placeholder(),
      home: const SplashScreen()
    );
  }
}

