import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesService {
  static const String _selectedScheduleIdKey = 'selected_schedule_id';
  static const String _selectedTrainNameKey = 'selected_train_name';
  static const String _selectedRouteInfoKey = 'selected_route_info';

  /// Save selected train schedule details
  Future<void> saveSelectedSchedule({
    required String scheduleId,
    String? trainName,
    String? routeInfo,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_selectedScheduleIdKey, scheduleId);
    if (trainName != null) {
      await prefs.setString(_selectedTrainNameKey, trainName);
    }
    if (routeInfo != null) {
      await prefs.setString(_selectedRouteInfoKey, routeInfo);
    }
  }

  /// Get selected schedule ID
  Future<String?> getSelectedScheduleId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_selectedScheduleIdKey);
  }

  /// Get selected train name
  Future<String?> getSelectedTrainName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_selectedTrainNameKey);
  }

  /// Get selected route info
  Future<String?> getSelectedRouteInfo() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_selectedRouteInfoKey);
  }

  /// Check if a train schedule is selected
  Future<bool> hasSelectedSchedule() async {
    final scheduleId = await getSelectedScheduleId();
    return scheduleId != null && scheduleId.isNotEmpty;
  }

  /// Clear selected schedule
  Future<void> clearSelectedSchedule() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_selectedScheduleIdKey);
    await prefs.remove(_selectedTrainNameKey);
    await prefs.remove(_selectedRouteInfoKey);
  }

  /// Get all selected schedule details
  Future<Map<String, String?>> getSelectedScheduleDetails() async {
    return {
      'scheduleId': await getSelectedScheduleId(),
      'trainName': await getSelectedTrainName(),
      'routeInfo': await getSelectedRouteInfo(),
    };
  }
}
