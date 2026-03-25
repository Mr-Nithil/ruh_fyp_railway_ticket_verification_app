# Railway Ticket Verification App

A mobile app for railway ticket checkers to scan and verify QR tickets, make approval decisions, and maintain verification history.

## Demo

- [LinkedIn Demo Video](https://www.linkedin.com/posts/nithil-sheshan-4a3945210_flutter-dart-firebase-activity-7442473107270868992-gKJN?utm_source=share&utm_medium=member_desktop&rcm=ACoAADWIVHsBQyvJg7MFpZpjndpUXN6v4s4fnlE)

## Key Features

- Secure checker authentication
- Train schedule selection before scanning
- QR code scanning and ticket data retrieval
- Ticket approval and rejection with checker remarks
- Fraud alert display for flagged tickets
- Ticket list for selected train/date
- Checker verification history view

## Tech Stack

- Flutter (Dart)
- Provider (state management)
- Firebase Authentication
- Cloud Firestore
- PostgreSQL
- mobile_scanner
- permission_handler
- shared_preferences

## Architecture (Simple)

Feature-first + layered structure:

- UI (screens/widgets)
- Controllers (state and flow)
- Repositories (data operations)
- Services (Firebase, PostgreSQL, permissions, local storage)

## Screenshots

### 1. Login Procedure and Home Screen
![Login Flow](docs/screenshots/login-flow.png)

### 2. Train Selection
![Train List](docs/screenshots/train-list.png)

### 3. QR Scanning
![QR Scanner](docs/screenshots/qr.png)

### 4. Ticket Details Displayed After Successful Retrieval
![Ticket Details Success](docs/screenshots/ticket-details-success.png)

### 5. Ticket Approval and Rejection Interface
![Verification Interface](docs/screenshots/verification.png)

### 6. Fraud Alert Notification Displayed for a Flagged Ticket
![Fraud Result](docs/screenshots/fraud-result.png)

### 7. Ticket List for Selected Train and Date
![Ticket List](docs/screenshots/ticket-list.png)

### 8. Checker Verification History Screen
![Checker History](docs/screenshots/history.png)

## Quick Run

```bash
flutter pub get
flutter run
```
