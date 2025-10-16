import 'package:flutter/material.dart';
import 'package:ruh_fyp_railway_ticket_verification_app/features/qr_verify/models/booking_detail.dart';
import 'package:ruh_fyp_railway_ticket_verification_app/features/home/models/train_schedule.dart';
import 'package:ruh_fyp_railway_ticket_verification_app/features/qr_verify/repository/transaction_repository.dart';

class TransactionController extends ChangeNotifier {
  final TransactionRepository _transactionRepository = TransactionRepository();

  BookingDetails? _bookingDetails;
  BookingDetails? get bookingDetails => _bookingDetails;
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> fetchBookingDetails(String bookingId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final details = await _transactionRepository.fetchBookingById(bookingId);
      _bookingDetails = details;
    } catch (e) {
      _bookingDetails = null;
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
