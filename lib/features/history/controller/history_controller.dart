import 'package:flutter/material.dart';
import 'package:ruh_fyp_railway_ticket_verification_app/features/history/repository/history_repository.dart';
import 'package:ruh_fyp_railway_ticket_verification_app/features/scan_ticket/models/booking_detail.dart';

class HistoryController extends ChangeNotifier {
  final HistoryRepository _historyRepository = HistoryRepository();

  List<BookingDetails>? _checkingHistory;
  List<BookingDetails>? get checkingHistory => _checkingHistory;
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> fetchCheckingHistory(String checkerId, String scheduleId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final history = await _historyRepository.fetchCheckingHistoryByCheckerId(
        checkerId,
        scheduleId,
      );
      _checkingHistory = history;
    } catch (e) {
      _checkingHistory = null;
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
