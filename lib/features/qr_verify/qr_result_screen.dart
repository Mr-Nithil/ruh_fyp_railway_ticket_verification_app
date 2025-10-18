import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:postgres/postgres.dart';
import 'package:provider/provider.dart';
import 'package:ruh_fyp_railway_ticket_verification_app/services/shared_preferences_service.dart';
import 'package:ruh_fyp_railway_ticket_verification_app/features/qr_verify/controller/transaction_controller.dart';
import 'package:ruh_fyp_railway_ticket_verification_app/features/qr_verify/models/booking_detail.dart';

class QRResultScreen extends StatefulWidget {
  final String qrData;

  const QRResultScreen({super.key, required this.qrData});

  @override
  State<QRResultScreen> createState() => _QRResultScreenState();
}

class _QRResultScreenState extends State<QRResultScreen> {
  bool _isLoading = true;
  BookingDetails? _bookingDetails;
  String? _errorMessage;
  bool _suspicionDetected = false;
  String _bookingId = '';
  String _bookingRef = '';
  bool _isCheckedBefore = false;
  bool _isApprovedTicket = false;
  Color statusColor = Colors.grey;
  Color statusColorDark = Colors.grey.shade700;

  final SharedPreferencesService _prefsService = SharedPreferencesService();

  @override
  void initState() {
    super.initState();
    // Schedule the loading after the first frame to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _decodeQRData(widget.qrData);
      _loadBookingDetails();
    });
  }

  void _decodeQRData(String qrData) {
    try {
      // Decode base64 string
      final decodedBytes = base64Decode(qrData);
      final decodedString = utf8.decode(decodedBytes);

      // Split by pipe separator
      final parts = decodedString.split('|').map((e) => e.trim()).toList();

      if (parts.length >= 2) {
        setState(() {
          _bookingId = parts[0].trim();
          print('Booking ID: $_bookingId');
          _bookingRef = parts[1].trim();
          print('Booking Reference: $_bookingRef');
        });
      } else {
        // If format is unexpected, log error
        debugPrint('Unexpected QR data format: $decodedString');
      }
    } catch (e) {
      // Handle decode errors
      debugPrint('Error decoding QR data: $e');
      setState(() {
        _errorMessage = 'Invalid QR code format';
      });
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'N/A';

    try {
      final date = DateTime.parse(dateStr);
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateStr;
    }
  }

  String _formatTime(Time? time) {
    if (time == null) return 'N/A';
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Future<void> _loadBookingDetails() async {
    if (!mounted) return;

    final transactionController = Provider.of<TransactionController>(
      context,
      listen: false,
    );

    try {
      // Use the decoded booking ID for fetching details
      await transactionController.fetchBookingDetails(_bookingId);

      if (!mounted) return;

      final selectedScheduleId = await _prefsService.getSelectedScheduleId();

      setState(() {
        _bookingDetails = transactionController.bookingDetails;
        _isLoading = false;

        if (_bookingDetails!.scheduleId != selectedScheduleId) {
          print('Selected Schedule ID: $selectedScheduleId');
          print('Ticket Schedule ID: ${_bookingDetails!.scheduleId}');
          setState(() {
            _errorMessage = 'Ticket does not match selected train schedule';
            _isLoading = false;
            return;
          });
        }

        if (transactionController.bookingDetails!.isReviewed == true &&
            transactionController.bookingDetails!.isFraudConfirmed == true) {
          _suspicionDetected = true;
        }

        if (transactionController.bookingDetails!.isChecked == true) {
          _isCheckedBefore = true;
        }

        if (transactionController.bookingDetails!.isApproved == true) {
          _isApprovedTicket = true;
        }
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = 'Invalid ticket data or booking not found';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine colors based on fraud status

    if (_isCheckedBefore) {
      statusColor = _isApprovedTicket ? Colors.green : Colors.red;
      statusColorDark = _isApprovedTicket
          ? Colors.green.shade700
          : Colors.red.shade700;
    } else {
      statusColor = _suspicionDetected ? Colors.red : Colors.green;
      statusColorDark = _suspicionDetected
          ? Colors.red.shade700
          : Colors.green.shade700;
    }

    return SafeArea(
      top: false,
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        // appBar: AppBar(
        //   backgroundColor: statusColorDark,
        //   foregroundColor: Colors.white,
        //   elevation: 0,
        //   //automaticallyImplyLeading: false,
        // ),
        body: _isLoading
            ? _buildLoadingView()
            : _errorMessage != null
            ? _buildErrorView(_errorMessage!)
            : _buildTicketView(
                context,
                _bookingDetails!,
                statusColor,
                statusColorDark,
              ),
      ),
    );
  }

  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.green.shade700),
          ),
          const SizedBox(height: 20),
          const Text(
            'Verifying Ticket...',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please wait while we fetch booking details',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
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
              onPressed: () {
                Navigator.of(context).pop();
              },
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
    BookingDetails booking,
    Color statusColor,
    Color statusColorDark,
  ) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Status Header Section
          _buildStatusHeader(booking, statusColor, statusColorDark),

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
                  value: _bookingRef,
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
                  value: booking.schedule.trainName ?? 'N/A',
                  gradientColors: [
                    Colors.green.shade400,
                    Colors.green.shade600,
                  ],
                ),
                const SizedBox(height: 16),
                _buildModernInfoCard(
                  icon: Icons.location_on_outlined,
                  label: 'Route',
                  value: booking.routeInfo,
                  gradientColors: [
                    Colors.green.shade400,
                    Colors.green.shade600,
                  ],
                ),
                const SizedBox(height: 12),
                _buildModernInfoCard(
                  icon: Icons.calendar_today_outlined,
                  label: 'Travel Date',
                  value: _formatDate(booking.travelDate),
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
                      '${_formatTime(booking.schedule.departureTime)} - ${_formatTime(booking.schedule.arrivalTime)}',
                  gradientColors: [
                    Colors.green.shade400,
                    Colors.green.shade600,
                  ],
                ),
                // const SizedBox(height: 12),
                // _buildModernInfoCard(
                //   icon: Icons.access_time_outlined,
                //   label: 'Arrival',
                //   value:
                //       '${_formatTime(booking.schedule.arrivalTime)} (${booking.schedule.route!.toStationName})',
                //   gradientColors: [
                //     Colors.green.shade400,
                //     Colors.green.shade600,
                //   ],
                // ),
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
                        '${booking.passengerCount}',
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
                ...booking.passengers.map((passenger) {
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
                  value: booking.formattedAmount,
                  gradientColors: [
                    Colors.orange.shade400,
                    Colors.orange.shade600,
                  ],
                ),
                const SizedBox(height: 12),
                _buildModernInfoCard(
                  icon: Icons.event_outlined,
                  label: 'Booked On',
                  value: _formatDate(booking.bookingDate),
                  gradientColors: [
                    Colors.orange.shade400,
                    Colors.orange.shade600,
                  ],
                ),
                if (booking.contactEmail != null) ...[
                  const SizedBox(height: 12),
                  _buildModernInfoCard(
                    icon: Icons.email_outlined,
                    label: 'Contact Email',
                    value: booking.contactEmail!,
                    gradientColors: [
                      Colors.orange.shade400,
                      Colors.orange.shade600,
                    ],
                  ),
                ],
                if (booking.contactPhone != null) ...[
                  const SizedBox(height: 12),
                  _buildModernInfoCard(
                    icon: Icons.phone_outlined,
                    label: 'Contact Phone',
                    value: booking.contactPhone!,
                    gradientColors: [
                      Colors.orange.shade400,
                      Colors.orange.shade600,
                    ],
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 28),

          // Action Buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                if (!_isCheckedBefore)
                  ElevatedButton.icon(
                    onPressed: () {
                      _showConfirmationDialog(context, booking);
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
                if (!_isCheckedBefore)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 12),
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _showConfirmationDialog(context, booking);
                      },
                      icon: const Icon(Icons.flag_outlined),
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
                  ),
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.home_outlined),
                  label: const Text('Back to Home'),
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
    BookingDetails booking,
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
          if (!_isCheckedBefore)
            Column(
              children: [
                const SizedBox(height: 90),
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
                    _suspicionDetected
                        ? Icons.error_outline
                        : Icons.verified_outlined,
                    size: 60,
                    color: statusColorDark,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  _suspicionDetected ? 'SUSPICION DETECTED' : 'VALID TICKET',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 1.0,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                if (!_suspicionDetected)
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
                if (_suspicionDetected)
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
          if (_isCheckedBefore)
            Column(
              children: [
                const SizedBox(height: 90),
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
                    _isApprovedTicket
                        ? Icons.error_outline
                        : Icons.verified_outlined,
                    size: 60,
                    color: statusColorDark,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'ALREADY CHECKED',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 1.0,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                if (_isApprovedTicket)
                  Text(
                    'This ticket has already been approved.',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withOpacity(0.95),
                      letterSpacing: 0.3,
                    ),
                    textAlign: TextAlign.center,
                  ),
                if (!_isApprovedTicket)
                  Text(
                    'This ticket has already been flagged.',
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

  Widget _buildPassengerCard(PassengerDetails passenger) {
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
                            passenger.passengerName,
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
                      '${passenger.gender ?? 'N/A'}   •   Age: ${passenger.age ?? 'N/A'}   •   Seat: ${passenger.seatNumber ?? 'N/A'}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${passenger.trainClass.displayName}',
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
          if (passenger.hasValidId) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.badge_outlined, size: 18, color: Colors.grey[700]),
                  const SizedBox(width: 8),
                  Text(
                    '${passenger.idType}: ${passenger.idNumber}',
                    style: TextStyle(
                      fontSize: 15,
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

  void _showConfirmationDialog(BuildContext context, BookingDetails booking) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              _suspicionDetected
                  ? Icons.flag_outlined
                  : Icons.check_circle_outline,
              color: _suspicionDetected ? Colors.red : Colors.green,
            ),
            const SizedBox(width: 10),
            Text(_suspicionDetected ? 'Flag Ticket' : 'Confirm Approval'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _suspicionDetected
                  ? 'Are you sure you want to flag this ticket as suspicious?'
                  : 'Are you sure you want to approve this ticket?',
            ),
            const SizedBox(height: 12),
            Text(
              'Reference: ${booking.bookingId}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('Passengers: ${booking.passengerCount}'),
            if (booking.routeInfo != 'N/A') Text('Route: ${booking.routeInfo}'),
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
              backgroundColor: _suspicionDetected
                  ? Colors.red.shade700
                  : Colors.green.shade700,
              foregroundColor: Colors.white,
            ),
            child: Text(_suspicionDetected ? 'Flag' : 'Approve'),
          ),
        ],
      ),
    );
  }
}
