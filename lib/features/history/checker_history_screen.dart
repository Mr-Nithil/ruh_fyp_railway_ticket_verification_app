import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:postgres/postgres.dart';
import 'package:provider/provider.dart';
import 'package:ruh_fyp_railway_ticket_verification_app/features/history/controller/history_controller.dart';
import 'package:ruh_fyp_railway_ticket_verification_app/features/history/history_detail_screen.dart';
import 'package:ruh_fyp_railway_ticket_verification_app/features/scan_ticket/models/booking_detail.dart';
import 'package:ruh_fyp_railway_ticket_verification_app/services/firestore_service.dart';
import 'package:ruh_fyp_railway_ticket_verification_app/services/shared_preferences_service.dart';

class CheckerHistoryScreen extends StatefulWidget {
  const CheckerHistoryScreen({super.key});

  @override
  State<CheckerHistoryScreen> createState() => _CheckerHistoryScreenState();
}

class _CheckerHistoryScreenState extends State<CheckerHistoryScreen> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirestoreService _firestoreService = FirestoreService();
  final SharedPreferencesService _prefsService = SharedPreferencesService();
  String? _checkerId;
  String? _selectedScheduleId;
  String? _selectedTrainName;
  String? _selectedRouteInfo;
  DateTime? _selectedDate;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCheckerHistory();
  }

  Future<void> _loadCheckerHistory() async {
    final uid = _firebaseAuth.currentUser?.uid;
    final scheduleId = await _prefsService.getSelectedScheduleId();
    final trainName = await _prefsService.getSelectedTrainName();
    final routeInfo = await _prefsService.getSelectedRouteInfo();
    if (uid != null) {
      final user = await _firestoreService.getUserDocument(uid);
      if (user != null && mounted) {
        setState(() {
          _checkerId = user.postgresId;
        });

        if (mounted) {
          setState(() {
            _selectedScheduleId = scheduleId;
            _selectedTrainName = trainName;
            _selectedRouteInfo = routeInfo;
          });

          if (scheduleId != null && scheduleId.isNotEmpty) {
            final historyController = Provider.of<HistoryController>(
              context,
              listen: false,
            );

            await historyController.fetchCheckingHistory(
              _checkerId!,
              scheduleId,
            );
          }
        }

        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
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

  String _formatTime(dynamic time) {
    if (time == null) return 'N/A';

    // Handle Time type
    if (time is Time) {
      final hour = time.hour.toString().padLeft(2, '0');
      final minute = time.minute.toString().padLeft(2, '0');
      return '$hour:$minute';
    }

    // Handle Interval type (from PostgreSQL)
    // Check if it has the properties we need instead of type checking
    try {
      // Try accessing Interval properties (hours and minutes)
      final dynamic intervalTime = time;
      if (intervalTime.hours != null && intervalTime.minutes != null) {
        final hour = intervalTime.hours.toString().padLeft(2, '0');
        final minute = intervalTime.minutes.toString().padLeft(2, '0');
        return '$hour:$minute';
      }
    } catch (e) {
      // If properties don't exist, fall through
    }

    return 'N/A';
  }

  Future<void> _showDateFilterDialog() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.green.shade700,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _clearDateFilter() {
    setState(() {
      _selectedDate = null;
    });
  }

  List<BookingDetails> _filterBookingsByDate(List<BookingDetails> bookings) {
    if (_selectedDate == null) {
      return bookings;
    }

    return bookings.where((booking) {
      if (booking.travelDate == null) return false;

      try {
        final bookingDate = DateTime.parse(booking.travelDate!);
        return bookingDate.year == _selectedDate!.year &&
            bookingDate.month == _selectedDate!.month &&
            bookingDate.day == _selectedDate!.day;
      } catch (e) {
        return false;
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            // Header Section
            _buildHeader(),

            // Train Info Card
            if (_selectedTrainName != null) _buildTrainInfoCard(),

            // Date Filter Info
            if (_selectedDate != null) _buildDateFilterCard(),

            // History List
            Expanded(
              child: Consumer<HistoryController>(
                builder: (context, controller, child) {
                  if (_isLoading || controller.isLoading) {
                    return _buildLoadingView();
                  }

                  final history = controller.checkingHistory;

                  if (history == null || history.isEmpty) {
                    return _buildEmptyView();
                  }

                  final filteredHistory = _filterBookingsByDate(history);

                  if (filteredHistory.isEmpty) {
                    return _buildNoResultsView();
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      if (_checkerId != null) {
                        await controller.fetchCheckingHistory(
                          _checkerId!,
                          _selectedScheduleId ?? '',
                        );
                      }
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredHistory.length,
                      itemBuilder: (context, index) {
                        final booking = filteredHistory[index];
                        return _buildHistoryCard(booking);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateFilterCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Colors.green.shade50],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200, width: 1),
      ),
      child: Row(
        children: [
          Icon(Icons.calendar_today, size: 18, color: Colors.green.shade700),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Filtered by: ${_formatDate(_selectedDate.toString())}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.green.shade700,
              ),
            ),
          ),
          GestureDetector(
            onTap: _clearDateFilter,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(Icons.close, size: 16, color: Colors.red.shade700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.green.shade600, Colors.green.shade800],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
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
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Checking History',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'View all your verified tickets',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              Consumer<HistoryController>(
                builder: (context, controller, child) {
                  final history = controller.checkingHistory;
                  if (history != null && history.isNotEmpty) {
                    final filteredCount = _filterBookingsByDate(history).length;
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '$filteredCount',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade700,
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTrainInfoCard() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Colors.blue.shade50],
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.blue.shade400, Colors.blue.shade600],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.train, size: 24, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _selectedTrainName ?? 'N/A',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                if (_selectedRouteInfo != null)
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          _selectedRouteInfo!,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Filter Button
          GestureDetector(
            onTap: _showDateFilterDialog,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: _selectedDate != null
                    ? LinearGradient(
                        colors: [Colors.green.shade400, Colors.green.shade600],
                      )
                    : LinearGradient(
                        colors: [Colors.grey.shade300, Colors.grey.shade400],
                      ),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: (_selectedDate != null ? Colors.green : Colors.grey)
                        .withOpacity(0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.filter_list,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ],
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
            'Loading history...',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 100, color: Colors.grey[400]),
          const SizedBox(height: 20),
          Text(
            'No Checking History',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your verified tickets will appear here',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultsView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 80, color: Colors.orange.shade300),
            const SizedBox(height: 20),
            const Text(
              'No History for Selected Date',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'No verified tickets found for ${_formatDate(_selectedDate.toString())}. Try selecting a different date.',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: _clearDateFilter,
                  icon: const Icon(Icons.clear),
                  label: const Text('Clear Filter'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 15,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _showDateFilterDialog,
                  icon: const Icon(Icons.calendar_today),
                  label: const Text('Change Date'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 15,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryCard(BookingDetails booking) {
    final isApproved = booking.isApproved ?? false;
    final statusColor = isApproved ? Colors.green : Colors.red;

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => HistoryDetailScreen(booking: booking),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
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
        child: Column(
          children: [
            // Header with status
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        isApproved ? Icons.check_circle : Icons.cancel,
                        color: statusColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isApproved ? 'APPROVED' : 'REJECTED',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    booking.bookingReference ?? 'N/A',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Train Info
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.train,
                          color: Colors.green.shade700,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              booking.schedule.trainName ?? 'N/A',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              booking.routeInfo,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Divider(color: Colors.grey.shade300, height: 1),
                  const SizedBox(height: 12),
                  // Details Grid
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoItem(
                          icon: Icons.verified_user,
                          label: 'Checked On',
                          value: _formatDate(booking.checkedOn),
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: Colors.grey.shade300,
                      ),
                      Expanded(
                        child: _buildInfoItem(
                          icon: Icons.people,
                          label: 'Passengers',
                          value: booking.passengerCount.toString(),
                        ),
                      ),
                    ],
                  ),
                  // const SizedBox(height: 12),
                  // Row(
                  //   children: [
                  //     Expanded(
                  //       child: _buildInfoItem(
                  //         icon: Icons.calendar_today,
                  //         label: 'Travel Date',
                  //         value: _formatDate(booking.travelDate),
                  //       ),
                  //     ),
                  //     Container(
                  //       width: 1,
                  //       height: 40,
                  //       color: Colors.grey.shade300,
                  //     ),
                  //     Expanded(
                  //       child: _buildInfoItem(
                  //         icon: Icons.payment,
                  //         label: 'Amount',
                  //         value: booking.formattedAmount,
                  //       ),
                  //     ),
                  //   ],
                  // ),
                ],
              ),
            ),
            // Footer
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Tap to view details',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: Colors.grey[400],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, size: 18, color: Colors.grey[600]),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
