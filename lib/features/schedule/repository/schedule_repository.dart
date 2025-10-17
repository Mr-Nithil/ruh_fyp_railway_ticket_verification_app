import 'package:postgres/postgres.dart';
import 'package:ruh_fyp_railway_ticket_verification_app/features/schedule/models/train_schedule.dart';
import 'package:ruh_fyp_railway_ticket_verification_app/services/postgres_db_service.dart';

class ScheduleRepository {
  final PostgresDbService dbService = PostgresDbService();

  Future<List<TrainSchedule>?> fetchTrainSchedule() async {
    try {
      // Connect to database
      await dbService.connect();

      // Complex query to fetch all active schedules with related data
      final query = '''
        SELECT 
          s."Id" as "ScheduleId",
          s."TrainId",
          s."RouteId",
          s."DepartureTime",
          s."ArrivalTime",
          s."IsActive",
          
          t."TrainName",
          
          r."RouteName",
          r."FromStationId",
          r."ToStationId",
          
          fs."StationName" as "FromStationName",
          ts."StationName" as "ToStationName"
          
        FROM "RW_SET_Schedule" s
        LEFT JOIN "RW_SET_Train" t ON s."TrainId" = t."Id"
        LEFT JOIN "RW_SET_Route" r ON s."RouteId" = r."Id"
        LEFT JOIN "RW_SET_Station" fs ON r."FromStationId" = fs."Id"
        LEFT JOIN "RW_SET_Station" ts ON r."ToStationId" = ts."Id"
        WHERE s."IsActive" = true
        ORDER BY s."DepartureTime" ASC;
      ''';

      // Execute query
      final result = await dbService.connection.execute(Sql.named(query));

      // Close connection
      if (dbService.connection.isOpen) {
        await dbService.close();
      }

      // Check if any results found
      if (result.isEmpty) {
        return [];
      }

      // Map results to list of TrainSchedule objects
      return _mapResultsToTrainSchedules(result);
    } catch (e) {
      print('❌ Error fetching train schedules: $e');
      await dbService.close();
      rethrow;
    }
  }

  /// Maps database query results to list of TrainSchedule objects
  List<TrainSchedule> _mapResultsToTrainSchedules(Result result) {
    final schedules = <TrainSchedule>[];

    for (final row in result) {
      final rowMap = row.toColumnMap();

      schedules.add(
        TrainSchedule(
          scheduleId: rowMap['ScheduleId']?.toString(),
          trainId: rowMap['TrainId']?.toString(),
          trainName: rowMap['TrainName']?.toString(),
          routeId: rowMap['RouteId']?.toString(),
          routeName: rowMap['RouteName']?.toString(),
          fromStationId: rowMap['FromStationId']?.toString(),
          fromStationName: rowMap['FromStationName']?.toString(),
          toStationId: rowMap['ToStationId']?.toString(),
          toStationName: rowMap['ToStationName']?.toString(),
          departureTime: _parseTime(rowMap['DepartureTime']),
          arrivalTime: _parseTime(rowMap['ArrivalTime']),
          isActive: rowMap['IsActive'] as bool?,
        ),
      );
    }

    return schedules;
  }

  Time? _parseTime(dynamic value) {
    if (value == null) return null;

    // If it's already a Time object, return it
    if (value is Time) return value;

    // If it's an Interval (duration from midnight), convert to Time
    if (value is Interval) {
      try {
        // Get total microseconds from interval
        final microseconds = value.microseconds;

        // Convert to Duration
        final duration = Duration(microseconds: microseconds);

        // Extract hours, minutes, seconds, microseconds
        final hours = duration.inHours;
        final minutes = duration.inMinutes.remainder(60);
        final seconds = duration.inSeconds.remainder(60);
        final remainingMicros = duration.inMicroseconds.remainder(1000000);

        // Create Time object
        return Time(hours, minutes, seconds, remainingMicros);
      } catch (e) {
        print('⚠️ Failed to parse Time from Interval: $e');
        return null;
      }
    }

    // If it's a String, try to parse it
    if (value is String) {
      try {
        // Try parsing as "HH:MM:SS" format
        final parts = value.split(':');
        if (parts.length >= 2) {
          final hours = int.parse(parts[0]);
          final minutes = int.parse(parts[1]);
          final seconds = parts.length > 2
              ? int.parse(parts[2].split('.')[0])
              : 0;
          return Time(hours, minutes, seconds, 0);
        }
      } catch (e) {
        print('⚠️ Failed to parse Time from string: $value');
      }
    }

    return null;
  }
}
