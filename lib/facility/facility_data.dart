import 'package:csv/csv.dart';
import 'package:flutter/services.dart';
import 'package:project/facility/facility_init.dart';

class FacilityService {
  Future<List<Facility>> loadFacilitiesFromCsv() async {
    List<Facility> facilities = [];
    try {
      final dataframe = await rootBundle.loadString("assets/facilities.csv");

      final List<List<dynamic>> listData = const CsvToListConverter().convert(
        dataframe,
      );

      final header = listData[0];
      final nameIndex = header.indexOf('시설명');
      final latIndex = header.indexOf('시설위도');
      final lngIndex = header.indexOf('시설경도');
      final typeIndex = header.indexOf('시설유형명');

      for (var i = 1; i < listData.length; i++) {
        final row = listData[i];
        final lat = double.tryParse(row[latIndex].toString());
        final lng = double.tryParse(row[lngIndex].toString());
        final facilityName = row[nameIndex].toString();
        final facilityType = row[typeIndex].toString();

        if (lat != null && lng != null && lat != 0.0 && lng != 0.0) {
          facilities.add(
            Facility.fromCsvDate(
              name: facilityName,
              type: facilityType,
              lat: lat,
              lng: lng,
            ),
          );
        }
      }
      return facilities;
    } catch (e) {
      print('facility_service에서 오류 발생: $e');
      return facilities;
    }
  }
}
