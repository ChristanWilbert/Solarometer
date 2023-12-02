import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:solarometer/model/reading.dart';

class ViewScreen extends StatefulWidget {
  ViewScreen({
    super.key,
  });

  @override
  State<ViewScreen> createState() => _ViewScreenState();
}

class _ViewScreenState extends State<ViewScreen> {
  late Box<ReadingModel> readings = Hive.box<ReadingModel>('readingBox');
  late List<ReadingModel> readingvalues = readings.values.toList();
  late StreamSubscription<BoxEvent> _boxSubscription;
  String yesterday = "", today = "", average = "";

  @override
  void initState() {
    super.initState();
    setState(() {
      readingvalues = readings.values.toList();
      readingvalues.sort((a, b) => a.date.compareTo(b.date));
      readingvalues = readingvalues.reversed.toList();
      computeDashboard();
    });
    _boxSubscription = readings.watch().listen((event) {
      setState(() {
        readingvalues = readings.values.toList();
        readingvalues.sort((a, b) => a.date.compareTo(b.date));
        readingvalues = readingvalues.reversed.toList();
        computeDashboard();
      });
    });
  }

  @override
  void dispose() {
    _boxSubscription
        .cancel(); // Don't forget to cancel the subscription when it's no longer needed
    super.dispose();
  }

  computeProduction(ReadingModel dayreading) {
    DateTime currentdate = DateTime.parse(dayreading.date)!;
    ReadingModel? prevDayReading = readings.get(DateFormat('yyyy-MM-dd')
        .format(currentdate.subtract(const Duration(days: 1))));
    if (prevDayReading != null) {
      dayreading.production = (double.parse(dayreading.reading) -
              double.parse(prevDayReading.reading))
          .toStringAsFixed(1);
      readings.put(dayreading.date, dayreading);
    }
  }

  computeDashboard() {
    DateTime currentdate = DateTime.now();
    setState(() {
      ReadingModel? prevDayReading = readings.get(DateFormat('yyyy-MM-dd')
          .format(currentdate.subtract(const Duration(days: 1))));
      if (prevDayReading != null)
        yesterday = (prevDayReading.production != "")
            ? prevDayReading.production
            : "---";
      else
        yesterday = "---";
      ReadingModel? DayReading =
          readings.get(DateFormat('yyyy-MM-dd').format(currentdate));
      if (DayReading != null)
        today = (DayReading.production != "") ? DayReading.production : "---";
      else
        today = "---";
      double total = 0;
      int count = 0;
      readingvalues.forEach((reading) {
        if (reading.production != "") {
          count++;
          total += double.parse(reading.production);
        }
      });
      average = count > 0 ? (total / count).toStringAsFixed(1) : "---";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        color: const Color(0xFFF2F9FF),
        child: Column(
          children: [
            Stack(children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Card(
                      color: Color(0XFFA3D8F2),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      child: Container(
                        width: 300,
                        height: 160,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                  top: 30.0, left: 20, bottom: 30),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Text(
                                    "YESTERDAY",
                                    style: GoogleFonts.robotoCondensed(
                                        color: Color(0xff3A5A70),
                                        fontWeight: FontWeight.w700,
                                        fontSize: 12),
                                  ),
                                  Text(
                                    yesterday,
                                    style: GoogleFonts.robotoCondensed(
                                        color: Color(0xff02182d),
                                        fontWeight: FontWeight.w700,
                                        fontSize: 40),
                                  ),
                                  Text(
                                    "Kwh",
                                    style: GoogleFonts.inter(
                                        color: Color(0xff203b50),
                                        fontWeight: FontWeight.w300,
                                        fontSize: 20),
                                  )
                                ],
                              ),
                            ),
                            Container(
                              height: 200,
                              width: 100,
                              child: Card(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                elevation: 13,
                                color: Color(0xff02182d),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  top: 30.0, right: 20, bottom: 30),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Text(
                                    "AVERAGE",
                                    style: GoogleFonts.robotoCondensed(
                                        color: Color(0xff3A5A70),
                                        fontWeight: FontWeight.w700,
                                        fontSize: 12),
                                  ),
                                  Text(
                                    average,
                                    style: GoogleFonts.robotoCondensed(
                                        color: Color(0xff02182d),
                                        fontWeight: FontWeight.w700,
                                        fontSize: 40),
                                  ),
                                  Text(
                                    "Kwh",
                                    style: GoogleFonts.inter(
                                        color: Color(0xff203b50),
                                        fontWeight: FontWeight.w300,
                                        fontSize: 20),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                      child: Card(
                        elevation: 13,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        color: Color(0xff02182d),
                        child: Container(
                          height: 180,
                          width: 115,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 10, bottom: 35),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Text(
                                  "TODAY",
                                  style: GoogleFonts.robotoCondensed(
                                      color: Color(0xffD9D9D9),
                                      fontWeight: FontWeight.w700,
                                      fontSize: 25),
                                ),
                                Text(
                                  today,
                                  style: GoogleFonts.robotoCondensed(
                                      color: Color(0xffFFFFFF),
                                      fontWeight: FontWeight.w700,
                                      fontSize: 60),
                                ),
                                Text(
                                  "Kwh",
                                  style: GoogleFonts.inter(
                                      color: Color(0xffD9D9D9),
                                      fontWeight: FontWeight.w300,
                                      fontSize: 20),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              )
            ]),
            Column(
              children: [
                Card(
                  child: Container(
                    width: 300,
                    height: 50,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: const [
                        Text("\tDate\t"),
                        SizedBox(
                          width: 20,
                        ),
                        Text("Reading"),
                        Text("Production")
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: SizedBox(
                width: double.infinity,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: readingvalues.isEmpty
                        ? <Widget>[
                            const Text("empty"),
                          ]
                        : List<Widget>.generate(
                            readingvalues.length,
                            (index) {
                              computeProduction(readingvalues[index]);
                              return GestureDetector(
                                onLongPress: () {
                                  showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Text(
                                              "Remove Entry of ${readingvalues[index].date}"),
                                          content: Text("Are you sure?"),
                                          actions: [
                                            TextButton(
                                                onPressed: () {
                                                  readings.delete(
                                                      readingvalues[index]
                                                          .date);
                                                  Navigator.pop(context);
                                                },
                                                child: Text("Delete")),
                                            TextButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                                child: Text("Cancel")),
                                          ],
                                        );
                                      });
                                },
                                child: Card(
                                  color: const Color(0xFFA3D8F2),
                                  shape: const StadiumBorder(),
                                  child: Container(
                                    width: 300,
                                    height: 50,
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 5),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Card(
                                          color: const Color(0xff02182D),
                                          shape: const StadiumBorder(),
                                          child: SizedBox(
                                            width: 100,
                                            child: Center(
                                              child: Text(
                                                readingvalues[index].date,
                                                style: GoogleFonts.inter(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w700,
                                                    color: Colors.white),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Card(
                                          color: const Color(0xff02182D),
                                          shape: const StadiumBorder(),
                                          child: Container(
                                            width: 60,
                                            child: Center(
                                              child: Text(
                                                readingvalues[index].reading ==
                                                        ""
                                                    ? "---"
                                                    : readingvalues[index]
                                                        .reading,
                                                style: GoogleFonts.inter(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w700,
                                                    color: Colors.white),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Card(
                                          color: const Color(0xff02182D),
                                          shape: const StadiumBorder(),
                                          child: Container(
                                            width: 50,
                                            child: Center(
                                              child: Text(
                                                readingvalues[index]
                                                            .production ==
                                                        ""
                                                    ? "---"
                                                    : readingvalues[index]
                                                        .production,
                                                style: GoogleFonts.inter(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w700,
                                                    color: Colors.white),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ).toList(),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
