import 'package:postgres/postgres.dart';

class TrainSchedule {
  final String? scheduleId;
  final String? trainId;
  final String? trainName;
  final String? routeId;
  final String? routeName;
  final String? fromStationId;
  final String? fromStationName;
  final String? toStationId;
  final String? toStationName;
  final Time? departureTime;
  final Time? arrivalTime;
  final bool? isActive;

  TrainSchedule({
    this.scheduleId,
    this.trainId,
    this.trainName,
    this.routeId,
    this.routeName,
    this.fromStationId,
    this.fromStationName,
    this.toStationId,
    this.toStationName,
    this.departureTime,
    this.arrivalTime,
    this.isActive,
  });

  @override
  String toString() {
    return 'TrainSchedule(scheduleId: $scheduleId, trainName: $trainName, routeName: $routeName, '
        'from: $fromStationName, to: $toStationName, departure: $departureTime, arrival: $arrivalTime)';
  }
}
