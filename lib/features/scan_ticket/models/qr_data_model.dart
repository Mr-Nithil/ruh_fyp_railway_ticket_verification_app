/// Main ticket data model representing the complete QR response
class TicketData {
  final String reference;
  final Train train;
  final Journey journey;
  final List<Passenger> passengers;
  final Booking booking;
  final ModelResult modelResult;

  TicketData({
    required this.reference,
    required this.train,
    required this.journey,
    required this.passengers,
    required this.booking,
    required this.modelResult,
  });

  /// Create TicketData from JSON
  factory TicketData.fromJson(Map<String, dynamic> json) {
    return TicketData(
      reference: json['reference'] ?? '',
      train: Train.fromJson(json['train'] ?? {}),
      journey: Journey.fromJson(json['journey'] ?? {}),
      passengers:
          (json['passengers'] as List<dynamic>?)
              ?.map((p) => Passenger.fromJson(p as Map<String, dynamic>))
              .toList() ??
          [],
      booking: Booking.fromJson(json['booking'] ?? {}),
      modelResult: ModelResult.fromJson(json['modelResult'] ?? {}),
    );
  }

  /// Convert TicketData to JSON
  Map<String, dynamic> toJson() {
    return {
      'reference': reference,
      'train': train.toJson(),
      'journey': journey.toJson(),
      'passengers': passengers.map((p) => p.toJson()).toList(),
      'booking': booking.toJson(),
      'modelResult': modelResult.toJson(),
    };
  }

  /// Get total number of passengers
  int get passengerCount => passengers.length;

  /// Get primary passenger
  Passenger? get primaryPassenger {
    try {
      return passengers.firstWhere(
        (p) => p.name.toLowerCase().contains('primary'),
      );
    } catch (e) {
      return passengers.isNotEmpty ? passengers.first : null;
    }
  }

  /// Check if ticket is valid (not fraudulent)
  bool get isValid => !modelResult.isFraud;

  /// Check if ticket is fraudulent
  bool get isFraudulent => modelResult.isFraud;

  /// Get fraud status message
  String get fraudStatusMessage {
    if (modelResult.isFraud) {
      return 'FRAUD DETECTED: ${modelResult.fraudReason}';
    }
    return 'VALID TICKET';
  }
}

/// Train information model
class Train {
  final String number;
  final String name;

  Train({required this.number, required this.name});

  factory Train.fromJson(Map<String, dynamic> json) {
    return Train(number: json['number'] ?? '', name: json['name'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'number': number, 'name': name};
  }

  /// Get formatted train info
  String get formattedInfo => '$name ($number)';
}

/// Journey information model
class Journey {
  final String from;
  final String to;
  final String date;
  final String departure;
  final String arrival;

  Journey({
    required this.from,
    required this.to,
    required this.date,
    required this.departure,
    required this.arrival,
  });

  factory Journey.fromJson(Map<String, dynamic> json) {
    return Journey(
      from: json['from'] ?? '',
      to: json['to'] ?? '',
      date: json['date'] ?? '',
      departure: json['departure'] ?? '',
      arrival: json['arrival'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'from': from,
      'to': to,
      'date': date,
      'departure': departure,
      'arrival': arrival,
    };
  }

  /// Get formatted route
  String get route => '$from → $to';

  /// Get formatted date and time
  String get formattedDateTime => '$date at $departure';

  /// Get journey duration (if parseable)
  String? get duration {
    try {
      final dep = _parseTime(departure);
      final arr = _parseTime(arrival);
      if (dep != null && arr != null) {
        final diff = arr.difference(dep);
        final hours = diff.inHours;
        final minutes = diff.inMinutes % 60;
        return '${hours}h ${minutes}m';
      }
    } catch (e) {
      // Ignore parsing errors
    }
    return null;
  }

  DateTime? _parseTime(String time) {
    try {
      final parts = time.split(':');
      if (parts.length >= 2) {
        return DateTime(2025, 1, 1, int.parse(parts[0]), int.parse(parts[1]));
      }
    } catch (e) {
      // Ignore parsing errors
    }
    return null;
  }
}

/// Passenger information model
class Passenger {
  final String name;
  final String gender;
  final String seat;
  final String idType;
  final String idNumber;

  Passenger({
    required this.name,
    required this.gender,
    required this.seat,
    required this.idType,
    required this.idNumber,
  });

  factory Passenger.fromJson(Map<String, dynamic> json) {
    return Passenger(
      name: json['name'] ?? '',
      gender: json['gender'] ?? '',
      seat: json['seat'] ?? '',
      idType: json['idType'] ?? '',
      idNumber: json['idNumber'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'gender': gender,
      'seat': seat,
      'idType': idType,
      'idNumber': idNumber,
    };
  }

  /// Check if this is the primary passenger
  bool get isPrimary => name.toLowerCase().contains('primary');

  /// Check if this is a dependent
  bool get isDependent => name.toLowerCase().contains('dependent');

  /// Check if ID is provided
  bool get hasId => idType != '-' && idNumber != '-' && idType.isNotEmpty;

  /// Get cleaned name (without markers like Primary, Dependent)
  String get cleanName {
    return name
        .replaceAll(RegExp(r'\(Primary\)', caseSensitive: false), '')
        .replaceAll(RegExp(r'\(Dependent\)', caseSensitive: false), '')
        .trim();
  }

  /// Get formatted passenger info
  String get formattedInfo => '$name - Seat: $seat';
}

/// Booking information model
class Booking {
  final String date;
  final String total;

  Booking({required this.date, required this.total});

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(date: json['date'] ?? '', total: json['total'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'date': date, 'total': total};
  }

  /// Get formatted booking date
  String get formattedDate => date;

  /// Get total amount (cleaned)
  String get amount => total.replaceAll('Rs:', '').replaceAll('Rs.', '').trim();

  /// Parse total amount as number (if possible)
  double? get amountAsNumber {
    try {
      final cleaned = amount.replaceAll(',', '').replaceAll(' ', '');
      return double.parse(cleaned);
    } catch (e) {
      return null;
    }
  }
}

/// Model result for fraud detection
class ModelResult {
  final bool isFraud;
  final String fraudReason;

  ModelResult({required this.isFraud, required this.fraudReason});

  factory ModelResult.fromJson(Map<String, dynamic> json) {
    // Parse isFraud - handle both boolean and string "True"/"False"
    bool fraudStatus = false;
    final isFraudValue = json['isFraud'];

    if (isFraudValue is bool) {
      fraudStatus = isFraudValue;
    } else if (isFraudValue is String) {
      fraudStatus = isFraudValue.toLowerCase() == 'true';
    }

    return ModelResult(
      isFraud: fraudStatus,
      fraudReason: json['fraudReason'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'isFraud': isFraud.toString(), 'fraudReason': fraudReason};
  }

  /// Get status as string
  String get statusText => isFraud ? 'FRAUD' : 'VALID';

  /// Get status color indicator
  String get statusEmoji => isFraud ? '❌' : '✅';

  /// Check if ticket passed validation
  bool get isValidTicket => !isFraud;
}
