import 'package:postgres/postgres.dart';
import 'package:ruh_fyp_railway_ticket_verification_app/features/qr_verify/models/booking_detail.dart';
import 'package:ruh_fyp_railway_ticket_verification_app/features/qr_verify/services/postgres_db_service.dart';

class TransactionRepository {
  final PostgresDbService dbService = PostgresDbService();

  /// Fetches booking details by BookingId with all related data from multiple tables
  ///
  /// This method performs a complex JOIN query across multiple tables:
  /// - RW_SYS_Booking (main booking table)
  /// - RW_SET_Schedule (schedule information)
  /// - RW_SET_Route (route information)
  /// - RW_SET_Station (from and to station details)
  /// - RW_SYS_BookingPassenger (passengers associated with booking - max 5)
  /// - RW_SET_TrainClass (train class details)
  Future<BookingDetails?> fetchBookingById(String bookingId) async {
    try {
      // Connect to database
      await dbService.connect();

      // Complex query to fetch all related data with multiple joins
      final query = '''
        SELECT 
          b."Id" as "BookingId",
          b."ScheduleId",
          b."BookingDate",
          b."TravelDate",
          b."TotalAmount",
          b."ContactEmail",
          b."ContactPhone",
          
          s."RouteId",
          s."DepartureTime",
          s."ArrivalTime",
          
          r."RouteName",
          r."FromStationId",
          r."ToStationId",
          
          fs."StationName" as "FromStationName",
          ts."StationName" as "ToStationName",
          
          bp."PassengerName",
          bp."Age",
          bp."Gender",
          bp."IdType",
          bp."IdNumber",
          bp."SeatNumber",
          bp."ClassId",
          bp."IsDependent",
          bp."IsPrimary",
          
          tc."ClassName"
          
        FROM "RW_SYS_Booking" b
        LEFT JOIN "RW_SET_Schedule" s ON b."ScheduleId" = s."Id"
        LEFT JOIN "RW_SET_Route" r ON s."RouteId" = r."Id"
        LEFT JOIN "RW_SET_Station" fs ON r."FromStationId" = fs."Id"
        LEFT JOIN "RW_SET_Station" ts ON r."ToStationId" = ts."Id"
        LEFT JOIN "RW_SYS_BookingPassenger" bp ON b."Id" = bp."BookingId"
        LEFT JOIN "RW_SET_TrainClass" tc ON bp."ClassId" = tc."Id"
        WHERE b."Id" = @bookingId
        ORDER BY bp."IsPrimary" DESC NULLS LAST, bp."IsDependent" ASC NULLS LAST;
      ''';

      // Execute query with parameter
      final result = await dbService.connection.execute(
        Sql.named(query),
        parameters: {'bookingId': bookingId},
      );

      // Close connection
      if (dbService.connection.isOpen) {
        await dbService.close();
      }

      // Check if any results found
      if (result.isEmpty) {
        return null;
      }

      // Map results to BookingDetails object
      return _mapResultsToBookingDetails(result);
    } catch (e) {
      print('❌ Error fetching booking by ID: $e');
      await dbService.close();
      rethrow;
    }
  }

  /// Maps database query results to BookingDetails object
  BookingDetails _mapResultsToBookingDetails(Result result) {
    // Get first row for booking-level data (same across all rows)
    final firstRow = result.first.toColumnMap();

    // Extract route details
    final routeDetails = RouteDetails(
      routeId: firstRow['RouteId']?.toString(),
      routeName: firstRow['RouteName']?.toString(),
      fromStationId: firstRow['FromStationId']?.toString(),
      toStationId: firstRow['ToStationId']?.toString(),
      fromStationName: firstRow['FromStationName']?.toString(),
      toStationName: firstRow['ToStationName']?.toString(),
    );

    // Extract schedule details
    final scheduleDetails = ScheduleDetails(
      scheduleId: firstRow['ScheduleId']?.toString(),
      departureTime: _parseTime(firstRow['DepartureTime']),
      arrivalTime: _parseTime(firstRow['ArrivalTime']),
      route: routeDetails,
    );

    // Extract passengers from all rows (max 5)
    final passengers = <PassengerDetails>[];
    for (final row in result) {
      final rowMap = row.toColumnMap();

      // Only add passenger if PassengerName exists (in case of LEFT JOIN with no passengers)
      if (rowMap['PassengerName'] != null) {
        // Check if IdType is null - means it's a dependent
        final idType = rowMap['IdType']?.toString();
        final isDependent =
            rowMap['IsDependent'] as bool? ??
            (idType == null || idType.isEmpty);

        final trainClass = TrainClassDetails(
          classId: rowMap['ClassId']?.toString(),
          className: rowMap['ClassName']?.toString(),
        );

        passengers.add(
          PassengerDetails(
            passengerName: rowMap['PassengerName']?.toString() ?? '',
            age: _parseInt(rowMap['Age']),
            gender: rowMap['Gender']?.toString(),
            idType: idType,
            idNumber: rowMap['IdNumber']?.toString(),
            seatNumber: rowMap['SeatNumber']?.toString(),
            isDependent: isDependent,
            isPrimary: rowMap['IsPrimary'] as bool? ?? false,
            trainClass: trainClass,
          ),
        );
      }
    }

    // Create and return complete BookingDetails
    return BookingDetails(
      bookingId: firstRow['BookingId']?.toString() ?? '',
      scheduleId: firstRow['ScheduleId']?.toString(),
      bookingDate: firstRow['BookingDate']?.toString(),
      travelDate: firstRow['TravelDate']?.toString(),
      totalAmount: _parseDouble(firstRow['TotalAmount']),
      contactEmail: firstRow['ContactEmail']?.toString(),
      contactPhone: firstRow['ContactPhone']?.toString(),
      schedule: scheduleDetails,
      passengers: passengers,
    );
  }

  /// Helper method to safely parse double values from database
  double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) {
      try {
        return double.parse(value);
      } catch (e) {
        print('⚠️ Failed to parse double from string: $value');
        return null;
      }
    }
    return null;
  }

  /// Helper method to safely parse int values from database
  int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) {
      try {
        return int.parse(value);
      } catch (e) {
        print('⚠️ Failed to parse int from string: $value');
        return null;
      }
    }
    return null;
  }

  /// Helper method to safely parse Time values from database
  /// Handles both Time and Interval types from PostgreSQL
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
