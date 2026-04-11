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

### 1. App Overview

![Railway Ticket Verification App](docs/screenshots/Railway%20Ticket%20Verification%20App.png)

### 2. Login, Signup, and Home Screen

![Login Signup and Home Screen](docs/screenshots/Login,%20Signup%20and%20HomeScreen.png)

### 3. Select Train, Scan Ticket, Ticket List, and Verification History

![Select Train Scan Ticket Ticket List and Verification History](docs/screenshots/SelectTrain,%20ScanTicket,%20TicketList%20and%20VerificationHistory.png)

### 4. Valid Ticket Scenario

![Valid Ticket Scenario](docs/screenshots/Valid%20Ticket%20Scenario.png)

### 5. Fraud Ticket Scenario

![Fraud Ticket Scenario](docs/screenshots/Fraud%20Ticket%20Scenario.png)

## Quick Run

```bash
flutter pub get
flutter run
```
