class CheckerRemarks {
  final String id;
  final String checkerRemark;
  final bool isApproved;
  final bool isChecked;
  final String bookingId;
  final String checkedBy;
  final DateTime checkedOn;

  CheckerRemarks({
    required this.id,
    required this.checkerRemark,
    required this.isApproved,
    required this.isChecked,
    required this.bookingId,
    required this.checkedBy,
    required this.checkedOn,
  });
}
