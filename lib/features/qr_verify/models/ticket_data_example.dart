import 'dart:convert';
import 'package:ruh_fyp_railway_ticket_verification_app/features/qr_verify/models/qr_data_model.dart';

/// Example usage of the TicketData model with fraud detection
void main() {
  // Example JSON string (from QR code)
  const qrJsonString = '''
  {
    "reference": "BK202510074245",
    "train": {"number": "1002", "name": "Podi Menike"},
    "journey": {
      "from": "Colombo Fort",
      "to": "Kandy",
      "date": "2025-10-08",
      "departure": "08:47",
      "arrival": "11:55"
    },
    "passengers": [
      {
        "name": "Ryan Perera (Primary)",
        "gender": "Male",
        "seat": "1A01",
        "idType": "NIC",
        "idNumber": "222222222222"
      },
      {
        "name": "Ryan Small Perera (Dependent)",
        "gender": "Male",
        "seat": "1A02",
        "idType": "-",
        "idNumber": "-"
      },
      {
        "name": "Ryan Wife Perera",
        "gender": "Female",
        "seat": "1A03",
        "idType": "NIC",
        "idNumber": "7686456563"
      }
    ],
    "booking": {"date": "2025-10-07 01:49", "total": "Rs: 5000"},
    "modelResult": {
      "isFraud": "True",
      "fraudReason": "More than 5 Tickets in consecutive Intervals"
    }
  }
  ''';

  // Parse from QR string
  final jsonData = json.decode(qrJsonString);
  final ticket = TicketData.fromJson(jsonData);

  // Display ticket information
  print('=== TICKET INFORMATION ===');
  print('Reference: ${ticket.reference}');
  print('Train: ${ticket.train.formattedInfo}');
  print('Route: ${ticket.journey.route}');
  print('Date: ${ticket.journey.date}');
  print('Departure: ${ticket.journey.departure}');
  print('Arrival: ${ticket.journey.arrival}');
  print('Duration: ${ticket.journey.duration ?? 'N/A'}');
  print('Passengers: ${ticket.passengerCount}');
  print('Total: ${ticket.booking.total}');
  print('');

  // Display fraud detection result
  print('=== FRAUD DETECTION ===');
  print(
    'Status: ${ticket.modelResult.statusEmoji} ${ticket.modelResult.statusText}',
  );
  print('Is Fraudulent: ${ticket.isFraudulent}');
  if (ticket.isFraudulent) {
    print('Reason: ${ticket.modelResult.fraudReason}');
    print('⚠️  WARNING: ${ticket.fraudStatusMessage}');
  } else {
    print('✅ Ticket is valid');
  }
  print('');

  // Display passengers
  print('=== PASSENGERS ===');
  for (var i = 0; i < ticket.passengers.length; i++) {
    final passenger = ticket.passengers[i];
    print('${i + 1}. ${passenger.name}');
    print('   Gender: ${passenger.gender}');
    print('   Seat: ${passenger.seat}');
    if (passenger.hasId) {
      print('   ID: ${passenger.idType} - ${passenger.idNumber}');
    }
    if (passenger.isPrimary) {
      print('   [PRIMARY PASSENGER]');
    }
    if (passenger.isDependent) {
      print('   [DEPENDENT]');
    }
    print('');
  }

  // Verification decision
  print('=== VERIFICATION DECISION ===');
  if (ticket.isValid) {
    print('✅ ALLOW BOARDING');
  } else {
    print('❌ DENY BOARDING');
    print('Reason: ${ticket.modelResult.fraudReason}');
  }
}

/// Example helper functions
class TicketHelper {
  /// Parse QR code string to TicketData
  static TicketData parseQRCode(String qrString) {
    try {
      final jsonData = json.decode(qrString);
      return TicketData.fromJson(jsonData);
    } catch (e) {
      throw Exception('Invalid QR code data: $e');
    }
  }

  /// Validate and verify ticket
  static Map<String, dynamic> verifyTicket(TicketData ticket) {
    final result = <String, dynamic>{};

    // Check fraud detection
    result['isFraudulent'] = ticket.isFraudulent;
    result['fraudReason'] = ticket.modelResult.fraudReason;

    // Check required fields
    result['hasReference'] = ticket.reference.isNotEmpty;
    result['hasPassengers'] = ticket.passengers.isNotEmpty;
    result['hasPrimaryPassenger'] = ticket.primaryPassenger != null;

    // Overall decision
    result['allowBoarding'] =
        ticket.isValid &&
        result['hasReference'] == true &&
        result['hasPassengers'] == true &&
        result['hasPrimaryPassenger'] == true;

    result['status'] = result['allowBoarding'] == true ? 'APPROVED' : 'DENIED';

    return result;
  }

  /// Generate verification summary
  static String generateSummary(TicketData ticket) {
    final buffer = StringBuffer();
    buffer.writeln('TICKET VERIFICATION SUMMARY');
    buffer.writeln('=' * 40);
    buffer.writeln('Reference: ${ticket.reference}');
    buffer.writeln('Train: ${ticket.train.formattedInfo}');
    buffer.writeln('Route: ${ticket.journey.route}');
    buffer.writeln('Date: ${ticket.journey.date}');
    buffer.writeln('Passengers: ${ticket.passengerCount}');
    buffer.writeln('');
    buffer.writeln('FRAUD DETECTION:');
    buffer.writeln('Status: ${ticket.modelResult.statusText}');
    if (ticket.isFraudulent) {
      buffer.writeln('⚠️  FRAUD DETECTED');
      buffer.writeln('Reason: ${ticket.modelResult.fraudReason}');
      buffer.writeln('');
      buffer.writeln('DECISION: ❌ DENY BOARDING');
    } else {
      buffer.writeln('✅ Valid Ticket');
      buffer.writeln('');
      buffer.writeln('DECISION: ✅ ALLOW BOARDING');
    }
    buffer.writeln('=' * 40);

    return buffer.toString();
  }

  /// Get color code based on fraud status
  static String getStatusColor(TicketData ticket) {
    return ticket.isValid ? 'GREEN' : 'RED';
  }

  /// Check if ticket should be flagged for manual review
  static bool needsManualReview(TicketData ticket) {
    // Flag for manual review if fraud detected
    if (ticket.isFraudulent) {
      return true;
    }

    // Flag if primary passenger has no ID
    final primary = ticket.primaryPassenger;
    if (primary != null && !primary.hasId) {
      return true;
    }

    return false;
  }

  /// Get all warnings for the ticket
  static List<String> getWarnings(TicketData ticket) {
    final warnings = <String>[];

    if (ticket.isFraudulent) {
      warnings.add('FRAUD DETECTED: ${ticket.modelResult.fraudReason}');
    }

    if (ticket.primaryPassenger == null) {
      warnings.add('No primary passenger found');
    }

    if (ticket.passengers.isEmpty) {
      warnings.add('No passengers listed');
    }

    final primary = ticket.primaryPassenger;
    if (primary != null && !primary.hasId) {
      warnings.add('Primary passenger has no ID');
    }

    return warnings;
  }
}
