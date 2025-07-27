import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';
import 'screens/Splash-Screens/SplashScreen.dart';
import 'package:provider/provider.dart';
import 'package:fyp_project1/screens/SharedScreen/theme_provider.dart';
       import 'services/notification_service.dart'; // 👈 add this

// 👇 Handle background notifications
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  debugPrint('📩 Background notification: ${message.notification?.title}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();
  } catch (e) {
    if (e.toString().contains('duplicate-app')) {
      print('⚠️ Firebase already initialized, skipping');
    } else {
      rethrow;
    }
  }


  // ✅ Setup background message handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // ✅ Initialize notification handling

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'DTMS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: themeProvider.currentTheme,
      home: SplashScreen(),
    );
  }
}
