import 'package:flutter/material.dart';
import 'pages/loading_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
   WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
);
    runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nest',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: LoadingPage(), 
    );
  }
 }
      