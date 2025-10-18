import 'package:flutter/material.dart';
import 'package:ruh_fyp_railway_ticket_verification_app/features/qr_verify/models/booking_detail.dart';
import 'package:ruh_fyp_railway_ticket_verification_app/features/ticket_list/repository/ticket_list_repository.dart';

class TicketListController extends ChangeNotifier {
  TicketListRepository _ticketListRepository = TicketListRepository();

  List<BookingDetails>? _bookings;
  List<BookingDetails>? get bookings => _bookings;
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> fetchBookings(String scheduleId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final fetchedBookings = await _ticketListRepository
          .fetchBookingsByScheduleId(scheduleId);
      _bookings = fetchedBookings;
    } catch (e) {
      _bookings = null;
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
