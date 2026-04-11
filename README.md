# Railway Ticket Verification App

Railway Ticket Verification App is a production-style Flutter mobile application built for railway ticket checkers to scan QR-based tickets, validate traveler details in real time, and record verification decisions with an auditable workflow.

![Railway Ticket Verification App Overview](docs/screenshots/Railway%20Ticket%20Verification%20App.png)

## Overview

The app supports secure checker authentication, train-based ticket filtering, instant QR scanning, and approval or rejection decisions with checker remarks. It was designed with a feature-first and layered structure so each workflow remains modular, maintainable, and easy to scale across transport verification operations.

Demo: https://www.linkedin.com/posts/nithil-sheshan-4a3945210_flutter-dart-firebase-activity-7442473107270868992-gKJN?utm_source=share&utm_medium=member_desktop&rcm=ACoAADWIVHsBQyvJg7MFpZpjndpUXN6v4s4fnlE

## Key Features

- Secure sign up, login, and session handling for authorized ticket checkers
- Train selection flow before scanning to scope verification to active schedules
- Real-time QR scanning and ticket data retrieval
- Ticket approval and rejection with checker remarks
- Fraud alert indication for suspicious or invalid ticket scenarios
- Ticket list view filtered by selected train and date
- Verification history tracking for operational audit and transparency

## Tech Stack

- Flutter and Dart
- Provider for state management
- Firebase Authentication for checker auth flows
- Cloud Firestore for operational data and verification records
- PostgreSQL for backend data integration
- mobile_scanner for camera-based QR scanning
- permission_handler for runtime permissions
- shared_preferences for lightweight local persistence

## Architecture

The app follows a feature-first layered architecture:

- Presentation layer: screens, widgets, and user interaction handling
- Controller layer: state orchestration and verification flow coordination
- Repository layer: data access abstraction across backend sources
- Service layer: Firebase, PostgreSQL, permissions, and local storage integrations

This separation keeps business workflows independent from UI rendering and infrastructure concerns, improving maintainability, testability, and long-term extensibility.

## Patterns and Best Practices

- Feature-first modular organization
- Layered separation of concerns
- Repository-based data access abstraction
- Clear validation and decision flow for ticket verification
- Reusable screen components for scanner, list, and result views
- Persistent local preferences for smoother operator experience

## Screenshots

### Authentication and Home

![Login, Signup and Home Screen](docs/screenshots/Login,%20Signup%20and%20HomeScreen.png)

### Train Selection, Scanner, Ticket List, and History

![Select Train, Scan Ticket, Ticket List and Verification History](docs/screenshots/SelectTrain,%20ScanTicket,%20TicketList%20and%20VerificationHistory.png)

### Valid Ticket Verification

![Valid Ticket Scenario](docs/screenshots/Valid%20Ticket%20Scenario.png)

### Fraud Ticket Verification

![Fraud Ticket Scenario](docs/screenshots/Fraud%20Ticket%20Scenario.png)

## Quick Run

```bash
flutter pub get
flutter run
```

## What This Project Demonstrates

This project reflects practical Flutter engineering for real-world transport operations, including secure authentication, QR-driven verification workflows, backend integration with Firebase and PostgreSQL, modular architecture, and maintainable feature delivery for field-level ticket checking.
