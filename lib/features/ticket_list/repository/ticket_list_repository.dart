import 'package:postgres/postgres.dart';
import 'package:ruh_fyp_railway_ticket_verification_app/features/scan_ticket/models/booking_detail.dart';
import 'package:ruh_fyp_railway_ticket_verification_app/services/postgres_db_service.dart';

class TicketListRepository {
  final PostgresDbService dbService = PostgresDbService();

  /// Fetches all Bookings associated with a given ScheduleId
  ///
  /// This method performs a complex JOIN query across multiple tables:
  /// - RW_SYS_Booking (main booking table)
  /// - Users (user active status)
  /// - RW_SET_Schedule (schedule information)
  /// - RW_SET_Route (route information)
  /// - RW_SET_Station (from and to station details)
  /// - RW_SYS_BookingPassenger (passengers associated with booking - max 5)
  /// - RW_SET_TrainClass (train class details)
  /// - RW_SYS_BookingDetailedInfo (booking verification details)
  /// - RW_SYS_Checker (checker information)
  Future<List<BookingDetails>?> fetchBookingsByScheduleId(
    String scheduleId,
  ) async {
    try {
      // Connect to database
      await dbService.connect();

      // Single complex query to fetch all related data with multiple joins
      final query = '''
        SELECT 
          b."Id" as "BookingId",
          b."BookingReference",
          b."ScheduleId",
          b."UserId",
          b."BookingDate",
          b."TravelDate",
          b."TotalAmount",
          b."ContactEmail",
          b."ContactPhone",
          
          u."IsActive" as "UserIsActive",
          
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
          
          tc."ClassName",
          
          bdi."CheckedBy",
          bdi."CheckedOn",
          bdi."CheckerRemark",
          bdi."IsApproved",
          bdi."IsChecked",
          bdi."IsReviewed",
          bdi."IsFraudConfirmed",
          
          c."Name" as "CheckerName",
          c."Email" as "CheckerEmail",
          c."NicNumber" as "CheckerNic",
          c."CheckerNumber" as "CheckerNumber"
          
        FROM "RW_SYS_Booking" b
        LEFT JOIN "Users" u ON b."UserId"::text = u."Id"
        LEFT JOIN "RW_SET_Schedule" s ON b."ScheduleId" = s."Id"
        LEFT JOIN "RW_SET_Route" r ON s."RouteId" = r."Id"
        LEFT JOIN "RW_SET_Station" fs ON r."FromStationId" = fs."Id"
        LEFT JOIN "RW_SET_Station" ts ON r."ToStationId" = ts."Id"
        LEFT JOIN "RW_SYS_BookingPassenger" bp ON b."Id" = bp."BookingId" AND bp."Deleted" = false
        LEFT JOIN "RW_SET_TrainClass" tc ON bp."ClassId" = tc."Id" AND tc."Deleted" = false
        LEFT JOIN "RW_SYS_BookingDetailedInfo" bdi ON b."Id" = bdi."BookingId" AND bdi."Deleted" = false
        LEFT JOIN "RW_SYS_Checker" c ON bdi."CheckedBy" = c."Id" AND c."Deleted" = false
        WHERE b."ScheduleId" = @scheduleId
          AND b."Deleted" = false
        ORDER BY b."BookingDate" DESC, bp."IsPrimary" DESC NULLS LAST, bp."IsDependent" ASC NULLS LAST;
      ''';

      // Execute query with parameter
      final result = await dbService.connection.execute(
        Sql.named(query),
        parameters: {'scheduleId': scheduleId},
      );

      // Close connection
      if (dbService.connection.isOpen) {
        await dbService.close();
      }

      // Check if any results found
      if (result.isEmpty) {
        return [];
      }

      // Map results to list of BookingDetails objects
      return _mapResultsToBookingsList(result);
    } catch (e) {
      print('❌ Error fetching bookings by schedule ID: $e');
      await dbService.close();
      return null;
    }
  }

  /// Maps database query results to list of BookingDetails objects
  /// Groups rows by BookingId since each booking can have multiple passenger rows
  List<BookingDetails> _mapResultsToBookingsList(Result result) {
    // Group rows by BookingId
    final Map<String, List<ResultRow>> groupedByBooking = {};

    for (final row in result) {
      final rowMap = row.toColumnMap();
      final bookingId = rowMap['BookingId']?.toString() ?? '';

      if (!groupedByBooking.containsKey(bookingId)) {
        groupedByBooking[bookingId] = [];
      }
      groupedByBooking[bookingId]!.add(row);
    }

    // Create BookingDetails for each booking
    final List<BookingDetails> bookingsList = [];

    for (final bookingId in groupedByBooking.keys) {
      final rows = groupedByBooking[bookingId]!;
      final firstRow = rows.first.toColumnMap();

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
        departureTime: _parseTimeOrInterval(firstRow['DepartureTime']),
        arrivalTime: _parseTimeOrInterval(firstRow['ArrivalTime']),
        route: routeDetails,
      );

      // Extract passengers from all rows (max 5)
      final passengers = <PassengerDetails>[];
      for (final row in rows) {
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

      // Create BookingDetails object
      final booking = BookingDetails(
        bookingId: bookingId,
        bookingReference: firstRow['BookingReference']?.toString(),
        scheduleId: firstRow['ScheduleId']?.toString(),
        userId: firstRow['UserId']?.toString(),
        primaryUser: PrimaryUser(isActive: firstRow['UserIsActive'] as bool?),
        bookingDate: firstRow['BookingDate']?.toString(),
        travelDate: firstRow['TravelDate']?.toString(),
        totalAmount: _parseDouble(firstRow['TotalAmount']),
        contactEmail: firstRow['ContactEmail']?.toString(),
        contactPhone: firstRow['ContactPhone']?.toString(),
        schedule: scheduleDetails,
        passengers: passengers,
        isReviewed: firstRow['IsReviewed'] as bool?,
        isFraudConfirmed: firstRow['IsFraudConfirmed'] as bool?,
        checkedOn: firstRow['CheckedOn']?.toString(),
        checkerRemark: firstRow['CheckerRemark']?.toString(),
        isApproved: firstRow['IsApproved'] as bool?,
        isChecked: firstRow['IsChecked'] as bool?,
        checker: firstRow['CheckedBy'] != null
            ? Checker(
                checkerId: firstRow['CheckedBy']?.toString(),
                checkerName: firstRow['CheckerName']?.toString(),
                checkerEmail: firstRow['CheckerEmail']?.toString(),
                checkerNic: firstRow['CheckerNic']?.toString(),
                checkerNumber: firstRow['CheckerNumber']?.toString(),
              )
            : null,
      );

      bookingsList.add(booking);
    }

    return bookingsList;
  }

  /// Helper method to parse integer values
  int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    if (value is num) return value.toInt();
    return null;
  }

  /// Helper method to parse double values
  double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    if (value is num) return value.toDouble();
    return null;
  }

  /// Helper method to parse Time values (for timestamps)
  Time? _parseTime(dynamic value) {
    if (value == null) return null;
    if (value is Time) return value;
    return null;
  }

  /// Helper method to parse Time or Interval values
  /// DepartureTime and ArrivalTime in RW_SET_Schedule are stored as interval type
  /// The postgres package returns them as Interval objects which can be used similarly to Time
  dynamic _parseTimeOrInterval(dynamic value) {
    if (value == null) return null;
    // Return the value as-is, whether it's Time, Interval, or another type
    // The ScheduleDetails model uses Time? but Interval from postgres package
    // should be compatible for display purposes
    return value;
  }
}
