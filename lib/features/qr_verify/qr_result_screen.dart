import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:ruh_fyp_railway_ticket_verification_app/features/qr_verify/models/qr_data_model.dart';

class QRResultScreen extends StatelessWidget {
  final String qrData;

  const QRResultScreen({super.key, required this.qrData});

  @override
  Widget build(BuildContext context) {
    TicketData? ticket;
    String? errorMessage;

    // Try to parse the QR data
    try {
      final jsonData = json.decode(qrData);
      ticket = TicketData.fromJson(jsonData);
    } catch (e) {
      errorMessage = 'Invalid ticket data';
    }

    // Determine colors based on fraud status
    final bool isFraud = ticket?.isFraudulent ?? false;
    final Color statusColor = isFraud ? Colors.red : Colors.green;
    final Color statusColorDark = isFraud
        ? Colors.red.shade700
        : Colors.green.shade700;

    return SafeArea(
      top: false,
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          // title: const Text(
          //   'Ticket Verification',
          //   style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: 0.5),
          // ),
          backgroundColor: statusColorDark,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: errorMessage != null
            ? _buildErrorView(errorMessage)
            : _buildTicketView(context, ticket!, statusColor, statusColorDark),
      ),
    );
  }

  Widget _buildErrorView(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 100, color: Colors.red.shade700),
            const SizedBox(height: 20),
            const Text(
              'Ticket Error (Please try again)',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text('Scan Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade700,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 15,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTicketView(
    BuildContext context,
    TicketData ticket,
    Color statusColor,
    Color statusColorDark,
  ) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Status Header Section
          _buildStatusHeader(ticket, statusColor, statusColorDark),

          const SizedBox(height: 28),

          // Ticket Reference Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Booking Reference',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 16),
                _buildModernInfoCard(
                  icon: Icons.confirmation_number_outlined,
                  label: 'Reference Number',
                  value: ticket.reference,
                  gradientColors: [Colors.blue.shade400, Colors.blue.shade600],
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // Train & Journey Details
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Journey Details',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 16),
                _buildModernInfoCard(
                  icon: Icons.train_outlined,
                  label: 'Train',
                  value: ticket.train.formattedInfo,
                  gradientColors: [
                    Colors.green.shade400,
                    Colors.green.shade600,
                  ],
                ),
                const SizedBox(height: 12),
                _buildModernInfoCard(
                  icon: Icons.location_on_outlined,
                  label: 'Route',
                  value: ticket.journey.route,
                  gradientColors: [
                    Colors.green.shade400,
                    Colors.green.shade600,
                  ],
                ),
                const SizedBox(height: 12),
                _buildModernInfoCard(
                  icon: Icons.calendar_today_outlined,
                  label: 'Date',
                  value: ticket.journey.date,
                  gradientColors: [
                    Colors.green.shade400,
                    Colors.green.shade600,
                  ],
                ),
                const SizedBox(height: 12),
                _buildModernInfoCard(
                  icon: Icons.access_time_outlined,
                  label: 'Departure - Arrival',
                  value:
                      '${ticket.journey.departure} - ${ticket.journey.arrival}',
                  gradientColors: [
                    Colors.green.shade400,
                    Colors.green.shade600,
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // Passengers Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Passengers',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${ticket.passengerCount}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ...ticket.passengers.map((passenger) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildPassengerCard(passenger),
                  );
                }).toList(),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // Booking Details
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Booking Information',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 16),
                _buildModernInfoCard(
                  icon: Icons.payment_outlined,
                  label: 'Total Amount',
                  value: ticket.booking.total,
                  gradientColors: [
                    Colors.orange.shade400,
                    Colors.orange.shade600,
                  ],
                ),
                const SizedBox(height: 12),
                _buildModernInfoCard(
                  icon: Icons.event_outlined,
                  label: 'Booked On',
                  value: ticket.booking.date,
                  gradientColors: [
                    Colors.orange.shade400,
                    Colors.orange.shade600,
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // Action Buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                if (ticket.isFraudulent)
                  ElevatedButton.icon(
                    onPressed: () {
                      _showConfirmationDialog(context, ticket);
                    },
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('Flag Ticket'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                if (!ticket.isFraudulent)
                  ElevatedButton.icon(
                    onPressed: () {
                      _showConfirmationDialog(context, ticket);
                    },
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('Approve Ticket'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.qr_code_scanner),
                  label: const Text('Scan Another'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    minimumSize: const Size(double.infinity, 50),
                    side: BorderSide(color: Colors.grey.shade400),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 48),
        ],
      ),
    );
  }

  Widget _buildStatusHeader(
    TicketData ticket,
    Color statusColor,
    Color statusColorDark,
  ) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [statusColorDark, statusColor],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              ticket.isFraudulent
                  ? Icons.error_outline
                  : Icons.verified_outlined,
              size: 60,
              color: statusColorDark,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            ticket.isFraudulent ? 'SUSPICION DETECTED' : 'VALID TICKET',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: 1.0,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          if (!ticket.isFraudulent)
            Text(
              'Please confirm the ticket details and passenger identification before approval.',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.white.withOpacity(0.95),
                letterSpacing: 0.3,
              ),
              textAlign: TextAlign.center,
            ),
          if (ticket.isFraudulent)
            Text(
              'Please review the ticket details and passenger identification carefully.',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.white.withOpacity(0.95),
                letterSpacing: 0.3,
              ),
              textAlign: TextAlign.center,
            ),
        ],
      ),
    );
  }

  Widget _buildModernInfoCard({
    required IconData icon,
    required String label,
    required String value,
    required List<Color> gradientColors,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: gradientColors,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 24, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  overflow: TextOverflow.visible,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPassengerCard(Passenger passenger) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Colors.purple.shade50],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: passenger.isPrimary
                      ? Colors.purple.shade700
                      : Colors.purple.shade400,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  passenger.isPrimary ? Icons.person : Icons.people_outline,
                  size: 24,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            passenger.cleanName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        if (passenger.isPrimary) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.purple.shade700,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'PRIMARY',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                        if (passenger.isDependent) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade600,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'DEPENDENT',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${passenger.gender} • Seat: ${passenger.seat}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (passenger.hasId) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.badge_outlined, size: 16, color: Colors.grey[700]),
                  const SizedBox(width: 8),
                  Text(
                    '${passenger.idType}: ${passenger.idNumber}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700],
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showConfirmationDialog(BuildContext context, TicketData ticket) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle_outline, color: Colors.green),
            SizedBox(width: 10),
            Text('Confirm Approval'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Are you sure you want to approve this ticket?'),
            const SizedBox(height: 12),
            Text(
              'Reference: ${ticket.reference}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('Passengers: ${ticket.passengerCount}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
              // Here you can add logic to save verification record
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade700,
              foregroundColor: Colors.white,
            ),
            child: const Text('Approve'),
          ),
        ],
      ),
    );
  }
}
