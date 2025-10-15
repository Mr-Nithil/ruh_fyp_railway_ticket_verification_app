import 'package:postgres/postgres.dart';

/// Complete booking details with all related information
class BookingDetails {
  final String bookingId;
  final String? scheduleId;
  final String? bookingDate;
  final String? travelDate;
  final double? totalAmount;
  final String? contactEmail;
  final String? contactPhone;
  final ScheduleDetails schedule;
  final List<PassengerDetails> passengers;

  BookingDetails({
    required this.bookingId,
    this.scheduleId,
    this.bookingDate,
    this.travelDate,
    this.totalAmount,
    this.contactEmail,
    this.contactPhone,
    required this.schedule,
    required this.passengers,
  });

  /// Get number of passengers (max 5)
  int get passengerCount => passengers.length;

  /// Get primary passenger
  PassengerDetails? get primaryPassenger {
    try {
      return passengers.firstWhere((p) => p.isPrimary);
    } catch (e) {
      return null;
    }
  }

  /// Get dependent passengers
  List<PassengerDetails> get dependentPassengers {
    return passengers.where((p) => p.isDependent).toList();
  }

  /// Get formatted total amount
  String get formattedAmount =>
      totalAmount != null ? 'Rs. ${totalAmount!.toStringAsFixed(2)}' : 'N/A';

  /// Get route information
  String get routeInfo => schedule.route?.routeInfo ?? 'N/A';

  /// Get journey time
  String get journeyTime => schedule.formattedTime;
}

/// Schedule details from RW_SET_Schedule table
class ScheduleDetails {
  final String? scheduleId;
  final Time? departureTime;
  final Time? arrivalTime;
  final RouteDetails? route;

  ScheduleDetails({
    this.scheduleId,
    this.departureTime,
    this.arrivalTime,
    this.route,
  });

  /// Get formatted time
  String get formattedTime {
    if (departureTime != null && arrivalTime != null) {
      return '$departureTime - $arrivalTime';
    }
    return 'N/A';
  }
}

/// Route details from RW_SET_Route table
class RouteDetails {
  final String? routeId;
  final String? routeName;
  final String? fromStationId;
  final String? toStationId;
  final String? fromStationName;
  final String? toStationName;

  RouteDetails({
    this.routeId,
    this.routeName,
    this.fromStationId,
    this.toStationId,
    this.fromStationName,
    this.toStationName,
  });

  /// Get route information (From -> To)
  String get routeInfo {
    if (fromStationName != null && toStationName != null) {
      return '$fromStationName → $toStationName';
    }
    return routeName ?? 'N/A';
  }

  /// Get full route description
  String get fullDescription {
    final route = routeInfo;
    return routeName != null ? '$routeName ($route)' : route;
  }
}

/// Passenger details from RW_SYS_BookingPassenger table
class PassengerDetails {
  final String passengerName;
  final int? age;
  final String? gender;
  final String? idType;
  final String? idNumber;
  final String? seatNumber;
  final bool isDependent;
  final bool isPrimary;
  final TrainClassDetails trainClass;

  PassengerDetails({
    required this.passengerName,
    this.age,
    this.gender,
    this.idType,
    this.idNumber,
    this.seatNumber,
    this.isDependent = false,
    this.isPrimary = false,
    required this.trainClass,
  });

  /// Check if passenger has valid ID (if IdType is null, it's a dependent)
  bool get hasValidId =>
      idType != null &&
      idType!.isNotEmpty &&
      idNumber != null &&
      idNumber!.isNotEmpty;

  /// Get passenger type (Primary/Dependent)
  String get passengerType {
    if (isPrimary) return 'Primary';
    if (isDependent) return 'Dependent';
    return 'Passenger';
  }

  /// Get formatted passenger info
  String get formattedInfo {
    final info = StringBuffer(passengerName);
    if (age != null) info.write(' ($age)');
    if (seatNumber != null) info.write(' - Seat: $seatNumber');
    return info.toString();
  }
}

/// Train class details from RW_SET_TrainClass table
class TrainClassDetails {
  final String? classId;
  final String? className;

  TrainClassDetails({this.classId, this.className});

  /// Get class name or default
  String get displayName => className ?? 'Standard Class';
}
