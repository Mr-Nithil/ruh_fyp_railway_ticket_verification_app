import 'package:flutter/material.dart';
import 'package:postgres/postgres.dart';
import 'package:ruh_fyp_railway_ticket_verification_app/features/schedule/controller/schedule_controller.dart';
import 'package:ruh_fyp_railway_ticket_verification_app/features/schedule/models/train_schedule.dart';
import 'package:ruh_fyp_railway_ticket_verification_app/services/shared_preferences_service.dart';

class TrainSelectionPopup extends StatefulWidget {
  final VoidCallback onTrainSelected;

  const TrainSelectionPopup({super.key, required this.onTrainSelected});

  @override
  State<TrainSelectionPopup> createState() => _TrainSelectionPopupState();
}

class _TrainSelectionPopupState extends State<TrainSelectionPopup> {
  final ScheduleController _scheduleController = ScheduleController();
  final SharedPreferencesService _prefsService = SharedPreferencesService();
  String? _selectedScheduleId;

  @override
  void initState() {
    super.initState();
    _loadSelectedSchedule();
  }

  Future<void> _loadSelectedSchedule() async {
    final scheduleId = await _prefsService.getSelectedScheduleId();
    if (mounted) {
      setState(() {
        _selectedScheduleId = scheduleId;
      });
    }
  }

  Future<void> _selectTrain(TrainSchedule schedule) async {
    // Save to SharedPreferences
    await _prefsService.saveSelectedSchedule(
      scheduleId: schedule.scheduleId ?? '',
      trainName: schedule.trainName,
      routeInfo:
          '${schedule.fromStationName ?? ''} → ${schedule.toStationName ?? ''}',
    );

    setState(() {
      _selectedScheduleId = schedule.scheduleId;
    });

    // Show success message
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Train selected: ${schedule.trainName ?? 'Unknown'}',
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );

      // Notify parent and close
      widget.onTrainSelected();
      Navigator.of(context).pop();
    }
  }

  String _formatTime(Time? time) {
    if (time == null) return 'N/A';
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
          maxWidth: MediaQuery.of(context).size.width * 0.9,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.green.shade600, Colors.green.shade800],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.train, color: Colors.white, size: 28),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Select Train Schedule',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Choose the train you want to verify',
                          style: TextStyle(fontSize: 13, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Train List
            Expanded(
              child: FutureBuilder<List<TrainSchedule>?>(
                future: _scheduleController.fetchTrainSchedules(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.green,
                            ),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Loading train schedules...',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 64,
                              color: Colors.red.shade300,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Failed to Load Schedules',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'An error occurred while fetching train schedules. Please try again later.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final schedules = snapshot.data ?? [];

                  if (schedules.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.train_outlined,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'No Active Trains',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'There are no active train schedules available.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: schedules.length,
                    itemBuilder: (context, index) {
                      final schedule = schedules[index];
                      final isSelected =
                          _selectedScheduleId == schedule.scheduleId;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.green.shade50
                              : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? Colors.green
                                : Colors.grey.shade300,
                            width: isSelected ? 2 : 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: InkWell(
                          onTap: () => _selectTrain(schedule),
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Train Name and Selection Icon
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.green.shade100,
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
                                      child: Text(
                                        schedule.trainName ?? 'Unknown Train',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: isSelected
                                              ? Colors.green.shade800
                                              : Colors.black87,
                                        ),
                                      ),
                                    ),
                                    if (isSelected)
                                      Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: Colors.green,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.check,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 12),

                                // Route Information
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'From',
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: Colors.grey[600],
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              schedule.fromStationName ?? 'N/A',
                                              style: const TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black87,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Icon(
                                        Icons.arrow_forward,
                                        color: Colors.grey[400],
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'To',
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: Colors.grey[600],
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              schedule.toStationName ?? 'N/A',
                                              style: const TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black87,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12),

                                // Time Information
                                Row(
                                  children: [
                                    Icon(
                                      Icons.access_time,
                                      size: 16,
                                      color: Colors.grey[600],
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Departure: ${_formatTime(schedule.departureTime)}',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey[700],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Text(
                                      'Arrival: ${_formatTime(schedule.arrivalTime)}',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey[700],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            // Footer with info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Select a train to enable ticket scanning',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
