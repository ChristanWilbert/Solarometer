import 'dart:typed_data';

import 'package:hive/hive.dart';
part 'reading.g.dart';

@HiveType(typeId: 0)
class ReadingModel {
  @HiveField(0)
  final String date;

  @HiveField(1)
  final String reading;

  @HiveField(2)
  String production;

  ReadingModel(this.date, this.reading, this.production);
}
