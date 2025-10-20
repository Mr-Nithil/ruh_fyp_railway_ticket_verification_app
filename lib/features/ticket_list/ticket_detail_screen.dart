import 'package:flutter/material.dart';
import 'package:ruh_fyp_railway_ticket_verification_app/features/qr_verify/models/booking_detail.dart';

class TicketDetailScreen extends StatelessWidget {
  final BookingDetails booking;
  final String? trainName;

  const TicketDetailScreen({super.key, required this.booking, this.trainName});

  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'N/A';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateStr;
    }
  }

  String _formatTime(dynamic time) {
    if (time == null) return 'N/A';

    try {
      final timeStr = time.toString();

      // Check if it's an Interval type (contains "microseconds")
      if (timeStr.contains('microseconds')) {
        final numericPart = timeStr.split(' ').first;
        final microseconds = int.tryParse(numericPart);

        if (microseconds != null) {
          // Convert microseconds to hours and minutes (time of day)
          final totalSeconds = microseconds ~/ 1000000;
          final hours = totalSeconds ~/ 3600;
          final minutes = (totalSeconds % 3600) ~/ 60;
          return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
        }
      }

      // Fallback for other formats
      return timeStr;
    } catch (e) {
      print('Error formatting time: $e');
      return 'N/A';
    }
  }

  String _formatDateTime(dynamic dateTime) {
    if (dateTime == null) return 'N/A';

    try {
      if (dateTime is DateTime) {
        return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} '
            '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
      }

      // Try parsing as string
      final dt = DateTime.parse(dateTime.toString());
      return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
          '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateTime.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine status
    final bool isChecked = booking.isChecked ?? false;
    final bool isApproved = booking.isApproved ?? false;
    // final bool isApproved = booking.isApproved ?? false;
    // final bool isFraudConfirmed = booking.isFraudConfirmed ?? false;
    // final bool isUserActive = booking.primaryUser?.isActive ?? true;

    Color statusColor;
    String statusText;

    if (booking.isChecked == true) {
      if (booking.isApproved == true) {
        statusColor = Colors.green;
        statusText = 'APPROVED';
      } else {
        statusColor = Colors.red;
        statusText = 'REJECTED';
      }
    } else {
      statusColor = Colors.orange;
      statusText = 'PENDING REVIEW';
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Status Header
            _buildStatusHeader(context, statusColor, statusText),

            const SizedBox(height: 28),

            // Booking Reference Section
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
                    icon: Icons.confirmation_number_outlined,
                    label: 'Booking Reference',
                    value: booking.bookingReference ?? 'N/A',
                    gradientColors: [
                      Colors.blue.shade400,
                      Colors.blue.shade600,
                    ],
                  ),
                  // const SizedBox(height: 12),
                  // _buildModernInfoCard(
                  //   icon: Icons.calendar_today_outlined,
                  //   label: 'Booking On',
                  //   value: _formatDate(booking.bookingDate),
                  //   gradientColors: [
                  //     Colors.blue.shade400,
                  //     Colors.blue.shade600,
                  //   ],
                  // ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // Journey Details
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
                    value: trainName ?? 'N/A',
                    gradientColors: [
                      Colors.green.shade400,
                      Colors.green.shade600,
                    ],
                  ),
                  const SizedBox(height: 12),
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
                  //       '${_formatTime(booking.schedule.arrivalTime)} (${booking.schedule.route?.toStationName ?? 'N/A'})',
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

            // const SizedBox(height: 28),

            // // Payment Section
            // Padding(
            //   padding: const EdgeInsets.symmetric(horizontal: 20),
            //   child: Column(
            //     crossAxisAlignment: CrossAxisAlignment.start,
            //     children: [
            //       const Text(
            //         'Payment Details',
            //         style: TextStyle(
            //           fontSize: 20,
            //           fontWeight: FontWeight.w700,
            //           color: Colors.black87,
            //           letterSpacing: 0.2,
            //         ),
            //       ),
            //       const SizedBox(height: 16),
            //       Container(
            //         padding: const EdgeInsets.all(20),
            //         decoration: BoxDecoration(
            //           gradient: LinearGradient(
            //             begin: Alignment.topLeft,
            //             end: Alignment.bottomRight,
            //             colors: [Colors.white, Colors.amber.shade50],
            //           ),
            //           borderRadius: BorderRadius.circular(16),
            //           boxShadow: [
            //             BoxShadow(
            //               color: Colors.black.withOpacity(0.06),
            //               blurRadius: 15,
            //               offset: const Offset(0, 3),
            //             ),
            //           ],
            //         ),
            //         child: Row(
            //           children: [
            //             Container(
            //               padding: const EdgeInsets.all(12),
            //               decoration: BoxDecoration(
            //                 gradient: LinearGradient(
            //                   colors: [
            //                     Colors.amber.shade400,
            //                     Colors.amber.shade600,
            //                   ],
            //                 ),
            //                 borderRadius: BorderRadius.circular(12),
            //               ),
            //               child: const Icon(
            //                 Icons.payments,
            //                 size: 24,
            //                 color: Colors.white,
            //               ),
            //             ),
            //             const SizedBox(width: 16),
            //             Column(
            //               crossAxisAlignment: CrossAxisAlignment.start,
            //               children: [
            //                 Text(
            //                   'Total Amount',
            //                   style: TextStyle(
            //                     fontSize: 12,
            //                     color: Colors.grey[600],
            //                     fontWeight: FontWeight.w500,
            //                   ),
            //                 ),
            //                 const SizedBox(height: 4),
            //                 Text(
            //                   booking.formattedAmount,
            //                   style: const TextStyle(
            //                     fontSize: 24,
            //                     fontWeight: FontWeight.w800,
            //                     color: Colors.black87,
            //                   ),
            //                 ),
            //               ],
            //             ),
            //           ],
            //         ),
            //       ),
            //     ],
            //   ),
            // ),
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

            // // Contact Information
            // Padding(
            //   padding: const EdgeInsets.symmetric(horizontal: 20),
            //   child: Column(
            //     crossAxisAlignment: CrossAxisAlignment.start,
            //     children: [
            //       const Text(
            //         'Contact Information',
            //         style: TextStyle(
            //           fontSize: 20,
            //           fontWeight: FontWeight.w700,
            //           color: Colors.black87,
            //           letterSpacing: 0.2,
            //         ),
            //       ),
            //       const SizedBox(height: 16),
            //       _buildModernInfoCard(
            //         icon: Icons.email_outlined,
            //         label: 'Email',
            //         value: booking.contactEmail ?? 'N/A',
            //         gradientColors: [
            //           Colors.indigo.shade400,
            //           Colors.indigo.shade600,
            //         ],
            //       ),
            //       const SizedBox(height: 12),
            //       _buildModernInfoCard(
            //         icon: Icons.phone_outlined,
            //         label: 'Phone',
            //         value: booking.contactPhone ?? 'N/A',
            //         gradientColors: [
            //           Colors.indigo.shade400,
            //           Colors.indigo.shade600,
            //         ],
            //       ),
            //     ],
            //   ),
            // ),
            const SizedBox(height: 28),

            // Verification Details (if checked)
            if (isChecked) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Verification Details',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                            letterSpacing: 0.2,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 0, 5, 0),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              isApproved ? 'APPROVED' : 'FLAGGED',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        // gradient: LinearGradient(
                        //   begin: Alignment.topLeft,
                        //   end: Alignment.bottomRight,
                        //   colors: [Colors.white, statusColor.withOpacity(0.1)],
                        // ),
                        borderRadius: BorderRadius.circular(16),
                        // border: Border.all(
                        //   color: statusColor.withOpacity(0.3),
                        //   width: 2,
                        // ),
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
                          if (booking.checker != null) ...[
                            Row(
                              children: [
                                Icon(
                                  Icons.person_outline,
                                  size: 30,
                                  color: statusColor,
                                ),
                                const SizedBox(width: 15),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Checked by',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        booking.checker!.checkerName ??
                                            'Unknown',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                          ],
                          if (booking.checker!.checkerNumber != null) ...[
                            Row(
                              children: [
                                Icon(
                                  Icons.badge_outlined,
                                  size: 30,
                                  color: statusColor,
                                ),
                                const SizedBox(width: 15),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Checked by (ID)',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        booking.checker!.checkerNumber ??
                                            'Unknown',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                          ],
                          if (booking.checkedOn != null) ...[
                            Row(
                              children: [
                                Icon(
                                  Icons.access_time_outlined,
                                  size: 30,
                                  color: statusColor,
                                ),
                                const SizedBox(width: 15),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Checked on',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        _formatDateTime(
                                          booking.checkedOn,
                                        ), // Changed from _formatTime
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                          ],
                          if (booking.checkerRemark != null &&
                              booking.checkerRemark!.isNotEmpty) ...[
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.comment_outlined,
                                  size: 30,
                                  color: statusColor,
                                ),
                                const SizedBox(width: 15),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Remark',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        booking.checkerRemark!,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
            ],

            // Back Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ElevatedButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Back to List'),
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
            ),

            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusHeader(
    BuildContext context,
    Color statusColor,
    String statusText,
  ) {
    final Color statusColorDark = Color.lerp(statusColor, Colors.black, 0.3)!;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [statusColorDark, statusColor],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 32),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
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
              _getStatusIcon(statusText),
              size: 60,
              color: statusColorDark,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            statusText,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: 1.0,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Booking Details',
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

  IconData _getStatusIcon(String statusText) {
    switch (statusText) {
      case 'APPROVED':
        return Icons.check_circle_outline;
      case 'REJECTED':
        return Icons.cancel_outlined;
      // case 'FRAUD CONFIRMED':
      //   return Icons.dangerous_outlined;
      // case 'INACTIVE USER':
      //   return Icons.person_off_outlined;
      default:
        return Icons.pending_outlined;
    }
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
                      passenger.trainClass.displayName,
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
                  Expanded(
                    child: Text(
                      '${passenger.idType}: ${passenger.idNumber}',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[700],
                        fontFamily: 'monospace',
                      ),
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
}
