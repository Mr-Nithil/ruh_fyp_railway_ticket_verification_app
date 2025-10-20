class FraudBooking {
  final String id;
  final String? userId;
  final String? bookingId;
  final String? bookingReference;
  final String? route;
  final String? bookingDate;
  final bool? isReviewed;
  final bool? isFraudConfirmed;
  final int? fraudScore;

  FraudBooking({
    required this.id,
    this.userId,
    this.bookingId,
    this.bookingReference,
    this.route,
    this.bookingDate,
    this.isReviewed,
    this.isFraudConfirmed,
    this.fraudScore,
  });
}
