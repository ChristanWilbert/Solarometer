import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:solarometer/model/reading.dart';

class ViewScreen extends StatelessWidget {
  ViewScreen({
    super.key,
  });
  late Box<ReadingModel> readings = Hive.box<ReadingModel>('readingBox');
  late List<ReadingModel> readingvalues = readings.values.toList();

  @override
  Widget build(BuildContext context) {
    readingvalues.sort((a, b) => a.date.compareTo(b.date));
    readingvalues = readingvalues.reversed.toList();
    computeProduction(ReadingModel dayreading) {
      DateTime currentdate = DateTime.parse(dayreading.date)!;
      ReadingModel? prevDayReading = readings.get(DateFormat('yyyy-MM-dd')
          .format(currentdate.subtract(Duration(days: 1))));
      if (prevDayReading != null) {
        dayreading.production = (double.parse(dayreading.reading) -
                double.parse(prevDayReading.reading))
            .toStringAsFixed(1);
      }
    }

    ;
    return Container(
      color: Color.fromRGBO(240, 202, 87, 1),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                child: Icon(Icons.close),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Card(
                child: Container(
                  width: 100,
                  height: 100,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          Column(
            children: [
              Card(
                child: Container(
                  width: 300,
                  height: 50,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text("\tDate\t"),
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
                              onLongPress: () {},
                              child: Card(
                                child: Container(
                                  width: 300,
                                  height: 50,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      Text(readingvalues[index].date),
                                      Text(readingvalues[index].reading == ""
                                          ? "---"
                                          : readingvalues[index].reading),
                                      Text(readingvalues[index].production == ""
                                          ? "---"
                                          : readingvalues[index].production)
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
    );
  }
}
