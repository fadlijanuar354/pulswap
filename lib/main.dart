import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'package:pulswap/LandingPage.dart';
import 'package:pulswap/provider/metamask.dart';
import 'package:web3dart/web3dart.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // This widget is the root of your application.

  @override
  void initState() {
    super.initState();
  }

  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (context) => MetamaskProvider()..init(),
        builder: (context, child) {
          return MaterialApp(
            // initialRoute: '/',
            // onGenerateRoute: Flurorouter.router.generator,
            theme: ThemeData(
                textTheme: GoogleFonts.poppinsTextTheme(
              Theme.of(context).textTheme,
            )),
            title: 'PULSWAP',
            home: const LandingPage(),
            debugShowCheckedModeBanner: false,
          );
        });
  }
}
