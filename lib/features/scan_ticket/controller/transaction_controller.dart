import 'package:flutter/material.dart';
import 'package:ruh_fyp_railway_ticket_verification_app/features/scan_ticket/models/booking_detail.dart';
import 'package:ruh_fyp_railway_ticket_verification_app/features/scan_ticket/models/checker_remarks_model.dart';
import 'package:ruh_fyp_railway_ticket_verification_app/features/scan_ticket/models/fraud_booking_model.dart';
import 'package:ruh_fyp_railway_ticket_verification_app/features/select_train/models/train_schedule.dart';
import 'package:ruh_fyp_railway_ticket_verification_app/features/scan_ticket/repository/transaction_repository.dart';

class TransactionController extends ChangeNotifier {
  final TransactionRepository _transactionRepository = TransactionRepository();

  BookingDetails? _bookingDetails;
  BookingDetails? get bookingDetails => _bookingDetails;
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  List<FraudBooking>? _fraudBookings;
  List<FraudBooking>? get fraudBookings => _fraudBookings;

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

  Future<bool> updateCheckerRemarks({required CheckerRemarks remarks}) async {
    return await _transactionRepository.updateCheckerRemarks(
      bookingId: remarks.bookingId,
      checkedBy: remarks.checkedBy,
      isApproved: remarks.isApproved,
      checkerRemark: remarks.checkerRemark,
    );
  }

  Future<void> fetchFraudConfirmedBookings(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final fraudBookings = await _transactionRepository
          .getFraudConfirmedBookingsByUserID(userId);
      _fraudBookings = fraudBookings;
    } catch (e) {
      _fraudBookings = null;
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
