import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:solarometer/model/reading.dart';

class RegisterDataScreen extends StatefulWidget {
  const RegisterDataScreen({
    super.key,
  });

  @override
  State<RegisterDataScreen> createState() => _RegisterDataScreenState();
}

class _RegisterDataScreenState extends State<RegisterDataScreen> {
  TextEditingController dateinput = TextEditingController();
  TextEditingController reading = TextEditingController();
  TextEditingController powerGeneration = TextEditingController();
  Box<ReadingModel> readings = Hive.box<ReadingModel>("readingBox");
  bool isenabled = true;
  ReadingModel? prevDayReading;
  @override
  void initState() {
    dateinput.text = "";
    reading.text = "";
    powerGeneration.text = "";
    isenabled = true;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    closeDataRegScreen() => {Navigator.pop(context)};

    return Container(
      padding: const EdgeInsets.all(15),
      child: Center(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                  child: const Icon(Icons.close),
                  onTap: () => Navigator.pop(context),
                )
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                TextField(
                  controller: dateinput, //editing controller of this TextField
                  decoration: const InputDecoration(
                      icon: Icon(Icons.calendar_today), //icon of text field
                      labelText: "Enter Date" //label text of field
                      ),
                  readOnly:
                      true, //set it true, so that user will not able to edit text
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(
                            2000), //DateTime.now() - not to allow to choose before today.
                        lastDate: DateTime.now());

                    if (pickedDate != null) {
                      String formattedDate =
                          DateFormat('yyyy-MM-dd').format(pickedDate);
                      //formatted date output using intl package =>  2021-03-16
                      //you can implement different kind of Date Format here according to your requirement

                      setState(() {
                        dateinput.text =
                            formattedDate; //set output date to TextField value.
                        prevDayReading = readings.get(DateFormat('yyyy-MM-dd')
                            .format(DateTime.parse(dateinput.text)
                                .subtract(const Duration(days: 1))));
                        if (prevDayReading != null)
                          isenabled = false;
                        else
                          isenabled = true;
                      });
                    } else {
                      print("Date is not selected");
                    }
                  },
                ),
                TextField(
                  controller: reading,
                  onChanged: (text) {
                    if (!isenabled &&
                        dateinput.text != "" &&
                        reading.text != "") {
                      setState(() {
                        powerGeneration.text = (double.parse(reading.text) -
                                    double.parse(prevDayReading!.reading))
                                .toStringAsFixed(1) ??
                            "";
                      });
                    }
                  },
                  decoration: const InputDecoration(
                      icon: Icon(Icons.troubleshoot_sharp), //icon of text field
                      labelText: "Enter Reading" //label text of field
                      ),
                  readOnly:
                      false, //set it true, so that user will not able to edit text
                ),
                TextField(
                  enabled: isenabled,
                  controller: powerGeneration,
                  decoration: const InputDecoration(
                      icon: Icon(Icons
                          .energy_savings_leaf_outlined), //icon of text field
                      labelText: "Power Generation"
                      //label text of field
                      ),
                  readOnly:
                      false, //set it true, so that user will not able to edit text
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton.icon(
                      onPressed: () async {
                        // ignore: use_build_context_synchronously
                        showDialog<void>(
                          context: context,
                          barrierDismissible: false, // user must tap button!
                          builder: (BuildContext context) {
                            return (powerGeneration.text == "" ||
                                    double.parse(powerGeneration.text) >= 0)
                                ? AlertDialog(
                                    title: const Text('Date Entry'),
                                    content: SingleChildScrollView(
                                      child: ListBody(
                                        children: <Widget>[
                                          Text(
                                              "${dateinput.text}: power generation ${powerGeneration.text}Kwh "),
                                          Text(
                                              "Latest meter reading: ${reading.text}")
                                        ],
                                      ),
                                    ),
                                    actions: <Widget>[
                                      TextButton(
                                        child: const Text('Add Data'),
                                        onPressed: () async {
                                          await readings.put(
                                              dateinput.text,
                                              ReadingModel(
                                                  dateinput.text,
                                                  reading.text,
                                                  powerGeneration.text));
                                          closeDataRegScreen();
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                    ],
                                  )
                                : AlertDialog(
                                    title: const Text('Please Check Reading'),
                                    content: SingleChildScrollView(
                                      child: ListBody(
                                        children: <Widget>[
                                          Text(
                                              "${dateinput.text}: power generation ${powerGeneration.text}Kwh "),
                                          Text("power generation cannot be -ve")
                                        ],
                                      ),
                                    ),
                                    actions: <Widget>[
                                      TextButton(
                                        child: const Text('ok'),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                    ],
                                  );
                          },
                        );
                      },
                      icon: const Icon(Icons.cloud_upload_rounded),
                      label: const Text("Update")),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
