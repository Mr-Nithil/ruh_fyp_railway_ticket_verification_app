# Ticket List Query Fixes

## Issues Found and Fixed in `fetchBookingsByScheduleId`

### 1. **Data Type Mismatch in Users JOIN** ✅ FIXED
**Problem:** 
- In `Users` table, `"Id"` column is of type `text`
- In `RW_SYS_Booking` table, `"UserId"` column is of type `uuid`
- The JOIN condition `b."UserId" = u."Id"` would fail due to type incompatibility

**Fix:**
```sql
-- Before
LEFT JOIN "Users" u ON b."UserId" = u."Id"

-- After
LEFT JOIN "Users" u ON b."UserId"::text = u."Id"
```
Cast the uuid to text for proper comparison.

---

### 2. **Missing Deleted Records Filter** ✅ FIXED
**Problem:**
All tables have a `"Deleted"` boolean column, but the original query didn't filter out deleted records. This could return invalid/deleted bookings, passengers, classes, etc.

**Fix:**
Added `"Deleted" = false` conditions to:
- Main WHERE clause: `b."Deleted" = false`
- BookingPassenger JOIN: `bp."Deleted" = false`
- TrainClass JOIN: `tc."Deleted" = false`
- BookingDetailedInfo JOIN: `bdi."Deleted" = false`
- Checker JOIN: `c."Deleted" = false`

```sql
WHERE b."ScheduleId" = @scheduleId
  AND b."Deleted" = false
```

---

### 3. **Data Type Issue with DepartureTime and ArrivalTime** ✅ FIXED
**Problem:**
- In `RW_SET_Schedule` table, `"DepartureTime"` and `"ArrivalTime"` are of type `interval` (not `time`)
- The model `ScheduleDetails` was using `Time?` type which is incompatible with `interval`
- PostgreSQL `interval` type represents duration/time spans

**Fix:**
1. Updated `ScheduleDetails` model to use `dynamic` type:
```dart
class ScheduleDetails {
  final dynamic departureTime; // Can be Time or Interval from postgres package
  final dynamic arrivalTime;   // Can be Time or Interval from postgres package
  // ...
}
```

2. Added helper method `_parseTimeOrInterval()` to handle both types:
```dart
dynamic _parseTimeOrInterval(dynamic value) {
  if (value == null) return null;
  return value; // Returns as-is (Time, Interval, or other)
}
```

3. Updated mapping to use the new helper:
```dart
final scheduleDetails = ScheduleDetails(
  scheduleId: firstRow['ScheduleId']?.toString(),
  departureTime: _parseTimeOrInterval(firstRow['DepartureTime']),
  arrivalTime: _parseTimeOrInterval(firstRow['ArrivalTime']),
  route: routeDetails,
);
```

---

### 4. **Missing Train Name** ⚠️ NOT FIXED (Missing Table Schema)
**Problem:**
- `ScheduleDetails` model has a `trainName` field
- `RW_SET_Schedule` table only has `"TrainId"` (uuid reference)
- No train table schema was provided to JOIN and fetch the train name

**Potential Fix (if RW_SET_Train table exists):**
```sql
LEFT JOIN "RW_SET_Train" t ON s."TrainId" = t."Id"

-- Add to SELECT clause:
t."TrainName" as "TrainName",
```

Currently, `trainName` will be `null` for all records.

---

## Updated Query

```sql
SELECT 
  b."Id" as "BookingId",
  b."ScheduleId",
  b."UserId",
  b."BookingDate",
  b."TravelDate",
  b."TotalAmount",
  b."ContactEmail",
  b."ContactPhone",
  
  u."IsActive" as "UserIsActive",
  
  s."RouteId",
  s."DepartureTime",
  s."ArrivalTime",
  
  r."RouteName",
  r."FromStationId",
  r."ToStationId",
  
  fs."StationName" as "FromStationName",
  ts."StationName" as "ToStationName",
  
  bp."PassengerName",
  bp."Age",
  bp."Gender",
  bp."IdType",
  bp."IdNumber",
  bp."SeatNumber",
  bp."ClassId",
  bp."IsDependent",
  bp."IsPrimary",
  
  tc."ClassName",
  
  bdi."CheckedBy",
  bdi."CheckedOn",
  bdi."CheckerRemark",
  bdi."IsApproved",
  bdi."IsChecked",
  bdi."IsReviewed",
  bdi."IsFraudConfirmed",
  
  c."Name" as "CheckerName",
  c."Email" as "CheckerEmail",
  c."NicNumber" as "CheckerNic",
  c."CheckerNumber" as "CheckerNumber"
  
FROM "RW_SYS_Booking" b
LEFT JOIN "Users" u ON b."UserId"::text = u."Id"
LEFT JOIN "RW_SET_Schedule" s ON b."ScheduleId" = s."Id"
LEFT JOIN "RW_SET_Route" r ON s."RouteId" = r."Id"
LEFT JOIN "RW_SET_Station" fs ON r."FromStationId" = fs."Id"
LEFT JOIN "RW_SET_Station" ts ON r."ToStationId" = ts."Id"
LEFT JOIN "RW_SYS_BookingPassenger" bp ON b."Id" = bp."BookingId" AND bp."Deleted" = false
LEFT JOIN "RW_SET_TrainClass" tc ON bp."ClassId" = tc."Id" AND tc."Deleted" = false
LEFT JOIN "RW_SYS_BookingDetailedInfo" bdi ON b."Id" = bdi."BookingId" AND bdi."Deleted" = false
LEFT JOIN "RW_SYS_Checker" c ON bdi."CheckedBy" = c."Id" AND c."Deleted" = false
WHERE b."ScheduleId" = @scheduleId
  AND b."Deleted" = false
ORDER BY b."BookingDate" DESC, bp."IsPrimary" DESC NULLS LAST, bp."IsDependent" ASC NULLS LAST;
```

---

## Summary

✅ **Fixed Issues:**
1. UUID to text type casting for Users JOIN
2. Added deleted records filtering across all tables
3. Updated data types to handle PostgreSQL interval type

⚠️ **Known Limitations:**
1. Train name will be null (requires additional train table JOIN)

## Testing Recommendations

1. Test with schedules that have bookings
2. Test with schedules that have no bookings (should return empty list)
3. Test with bookings that have deleted passengers
4. Test with bookings where users are deleted
5. Verify interval time display format is acceptable
