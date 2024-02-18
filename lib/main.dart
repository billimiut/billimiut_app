import 'package:billimiut_app/providers/place.dart';
import 'package:billimiut_app/providers/posts.dart';
import 'package:billimiut_app/providers/user.dart';
import 'package:billimiut_app/screens/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:billimiut_app/screens/splash_screen.dart';
import 'package:billimiut_app/screens/login_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'providers/image_list.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await dotenv.load(fileName: ".env");
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(
        create: (context) => ImageList(),
      ),
      ChangeNotifierProvider(
        create: (context) => User(),
      ),
      ChangeNotifierProvider(
        create: (context) => Posts(),
      ),
      ChangeNotifierProvider(
        create: (context) => Place(),
      ),
    ],
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  MyApp({super.key});
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/', // 앱이 처음 실행될 때 표시될 라우트입니다.
      routes: {
        '/': (context) => const SplashScreen(), // 초기화면
        '/login': (context) => const LoginScreen(), // 로그인 화면
        '/main': (context) => const MainScreen(), // 메인 화면
      },
    );
  }
}
