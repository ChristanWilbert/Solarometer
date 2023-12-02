import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:solarometer/RegisterDataScreen.dart';
import 'package:solarometer/ViewScreen.dart';
import 'package:solarometer/model/reading.dart';

void main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(ReadingModelAdapter());
  await Hive.openBox<ReadingModel>('readingBox');

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Solarometer',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'SOLAROMETER'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
            child: Text(
          widget.title,
          style: GoogleFonts.robotoCondensed(),
        )),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ViewScreen(),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 8, right: 8),
        child: FloatingActionButton(
            onPressed: () {
              showModalBottomSheet<void>(
                context: context,
                isDismissible: false,
                useSafeArea: true,
                isScrollControlled: true,
                builder: (BuildContext context) {
                  return RegisterDataScreen();
                },
              );
            },
            child: Icon(Icons.add)),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
