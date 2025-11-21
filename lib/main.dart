import 'package:flutter/material.dart';
import 'package:obppay/providers/user_provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:obppay/screens/kyc_upload_screen.dart';
import 'package:obppay/screens/main_layout.dart';
import 'package:obppay/screens/splash_screen.dart';
import 'package:obppay/themes/light_theme.dart';
import 'package:provider/provider.dart';
import 'providers/theme_provider.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';

import 'themes/dark_theme.dart';


final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

void main() async {

  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase FIRST
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  const AndroidInitializationSettings androidSettings =
  AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initSettings =
  InitializationSettings(android: androidSettings);

  await flutterLocalNotificationsPlugin.initialize(initSettings);

  // Request permission on Android 13+
  await FirebaseMessaging.instance.requestPermission();
  String? token = await FirebaseMessaging.instance.getToken();
  print("FCM TOKEN : $token");


  // 🔔 Listen to notifications while app is in foreground
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    final notification = message.notification;

    if (notification != null) {
      flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'obppay_channel',
            'ObpPay Notifications',
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
      );
    }
  });




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
// 🔔 When user clicks the notification and app opens
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("🔔 Notification opened: ${message.data}");

      final screen = message.data['screen'];

      if (screen == "kyc") {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const KycUploadScreen()),
        );
      }

      if (screen == "transactions") {
        Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const MainLayout(initialIndex: 1)
            ),
        );
        }

            if (screen == "dashboard") {
          Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => MainLayout(initialIndex: 0)
              ),
      );
    }

      // Tu rajoutes d’autres screens ici si besoin
    });
    return MaterialApp(
      debugShowCheckedModeBanner: false,
        theme: lightTheme,
        darkTheme: darkTheme,
        themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,


        //home: const Placeholder(),
      home: const SplashScreen()
    );
  }
}

