import 'package:flutter/material.dart';
import 'package:ruh_fyp_railway_ticket_verification_app/features/schedule/models/train_schedule.dart';
import 'package:ruh_fyp_railway_ticket_verification_app/features/schedule/repository/schedule_repository.dart';

class ScheduleController extends ChangeNotifier {
  final ScheduleRepository _scheduleRepository = ScheduleRepository();

  Future<List<TrainSchedule>?> fetchTrainSchedules() async {
    final schedules = await _scheduleRepository.fetchTrainSchedule();
    return schedules;
  }
}
