// import 'package:car_mechanics/screen/car_mechanics_info.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'infoHandler/app_info.dart';
import 'splashScreen/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => AppInfo(),
        )
      ],
      child: MaterialApp(
        title: 'Final Year Project',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(),
        home: const SplashScreen(),
        // home: const CarMechanicsInfoScreen(),
      ),
    );
  }
}
