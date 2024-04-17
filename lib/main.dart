import 'package:flutter/material.dart';
import 'package:kandinsky_flutter/presentation/main_page.dart';
import 'package:env_flutter/env_flutter.dart';

void main() async {
  await dotenv.load(fileNames: ["assets/key.env"]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xff9ebe4f)
        ).copyWith(primary: const Color(0xff9ebe4f)),
        useMaterial3: true,
      ),
      home: const MainPage(),
    );
  }
}
