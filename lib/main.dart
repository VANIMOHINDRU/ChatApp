import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:chat/pages/account.dart';
import 'package:chat/pages/login.dart';
import 'package:chat/pages/spash.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await dotenv.load(fileName: ".env");
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
    authOptions:
        const FlutterAuthClientOptions(authFlowType: AuthFlowType.pkce),
  );

  runApp(const MyApp());
}

final supabase =
    Supabase.instance.client; //access the client that was initialized

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    supabase.auth.onAuthStateChange.listen((event) async {
      if (event.event == AuthChangeEvent.signedIn) {
        await FirebaseMessaging.instance.requestPermission();
        final fcmToken = await FirebaseMessaging.instance.getToken();
        if (fcmToken != null) {
          await _setFcmToken(fcmToken);
        }
      }
    });
    FirebaseMessaging.instance.onTokenRefresh.listen((fcmToken) async {
      await _setFcmToken(fcmToken);
    });

    FirebaseMessaging.onMessage.listen((payload) {
      final notification = payload.notification;
      if (notification != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(' ${notification.title} ${notification.body}')));
      }
    });
  }

  Future<void> _setFcmToken(String fcmToken) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId != null) {
      await supabase.from('profiles').upsert({
        'id': userId,
        'fcm_token': fcmToken,
      });
    }
  }

  void _showNotification(RemoteMessage message) {
    print('New message: ${message.notification?.title}');
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
        seedColor: const Color.fromARGB(206, 253, 199, 100),
      )),
      initialRoute: '/',
      routes: {
        '/': (context) {
          return const SplashPage();
        },
        '/login': (context) {
          return const LoginPage();
        },
        '/account': (context) {
          return const Account();
        }
      },
    );
  }
}
