# Bones and All

> A customizable chronic condition tracking application for Android, built as a Senior Honors Project at Western Illinois University.

![Flutter](https://img.shields.io/badge/Flutter-3.38.9-blue?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.10.8-blue?logo=dart)
![Node.js](https://img.shields.io/badge/Node.js-v18+-green?logo=node.js)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-18-blue?logo=postgresql)
![License](https://img.shields.io/badge/License-Academic-lightgrey)

---

## Overview

Bones and All is a full stack Android mobile application designed to help users track and monitor chronic health conditions. The app centers around a highly customizable daily questionnaire system, allowing users to define exactly what they want to track — whether that is pain levels, meals, mood, or any custom metric they choose.

The project was developed as part of a comparative research study evaluating the effectiveness of AI models (Claude Sonnet, GitHub Copilot, and ChatGPT) across different stages of the software development lifecycle.

---

## Features

| Feature | Description |
|---|---|
| User Authentication | Secure email and password registration and login using JWT |
| Interactive Body Map | Select and log pain locations on a visual body diagram |
| Pain Tracking | Log pain characteristics, type, and scale (1–10) |
| Custom Questionnaires | Build and personalize tracking templates with custom questions |
| Daily Journaling | Add journal notes alongside questionnaire responses |
| Push Notifications | Optional daily reminders via Firebase Cloud Messaging |
| Data Visualization | View trends and patterns from logged health data |
| Eating Tracker | Log meals by Breakfast, Lunch, Dinner, and Snacks |
| Profile & Settings | Manage account info, notification time, and preferences |

---

## Tech Stack

| Layer | Technology |
|---|---|
| Frontend | Flutter (Dart) |
| Backend | Node.js, Express.js |
| Database | PostgreSQL |
| Notifications | Firebase Cloud Messaging (FCM) |
| Authentication | JSON Web Tokens (JWT) |
| Password Security | bcrypt hashing |
| Communication | HTTP/TLS (SSL encrypted) |

---

## System Architecture

```
Flutter App  →  HTTP/TLS  →  Node.js/Express  →  PostgreSQL
                                    ↓
                          Firebase Cloud Messaging
                                    ↓
                         Flutter App (Push Notifications)
```

The Flutter frontend communicates with the Node.js/Express REST API over encrypted HTTP. The API handles all business logic, authenticates requests via JWT middleware, and interacts with the PostgreSQL database. Firebase Cloud Messaging is triggered server-side via a scheduled cron job to deliver daily push notifications to users.

---

## Project Structure

```
bones-and-all/
├── backend/
│   └── src/
│       ├── db/
│       │   ├── index.js          # Database connection pool
│       │   └── schema.sql        # PostgreSQL table definitions
│       ├── jobs/
│       │   └── dailyReminder.js  # Scheduled FCM notification job
│       ├── middleware/           # JWT auth and request middleware
│       ├── routes/               # API route handlers
│       ├── services/
│       │   └── fcm.js            # Firebase Cloud Messaging service
│       └── app.js                # Express app entry point
│
├── frontend/
│   ├── android/                  # Android build configuration
│   ├── lib/
│   │   └── main.dart             # Flutter app entry point
│   ├── test/
│   │   └── widget_test.dart
│   ├── pubspec.yaml              # Flutter dependencies
│   └── analysis_options.yaml
│
└── docs/
    ├── ActivityDiagram.png
    ├── SystemArchitecture.png
    ├── PrototypeScreens.png
    └── DatabaseSchema.sql
```

---

## Database Schema

PostgreSQL is used with the following six tables:

| Table | Description |
|---|---|
| `users` | Login credentials, profile info, FCM token, and notification preferences |
| `trackable_blocks` | Customizable tracking sections created by the user (e.g. Pain, Food) |
| `questions` | Individual questions belonging to a trackable block |
| `logs` | One daily entry per block per user, includes optional journal entry |
| `questionnaire_responses` | Individual answers to questions within a log entry |
| `notifications` | Push notification history including timestamp and delivery status |

See [`Database Schema`](docs/DatabaseSchema.png) for full table definitions.

---

## API Overview

| Method | Endpoint | Description |
|---|---|---|
| POST | `/api/auth/register` | Register a new user |
| POST | `/api/auth/login` | Login and receive JWT token |
| GET | `/api/blocks` | Get all trackable blocks for a user |
| POST | `/api/blocks` | Create a new trackable block |
| GET | `/api/logs` | Get logs for a user |
| POST | `/api/logs` | Create a new daily log entry |
| POST | `/api/questionnaire` | Save questionnaire responses |
| GET | `/api/notifications` | Get notification history |

> All routes except `/api/auth` require a valid JWT token in the request header.

---

## Getting Started

### Prerequisites
- [Flutter SDK](https://flutter.dev) (v3.38.9+)
- [Node.js](https://nodejs.org) (v18+)
- [PostgreSQL](https://www.postgresql.org) (v15+)
- Firebase Project with FCM enabled
- Android Studio or VS Code

### Backend Setup

Navigate to the backend directory:
```bash
cd backend
```

Install dependencies:
```bash
npm install
```

Create a `.env` file in the `backend/` root:
```
PORT=3000
DB_HOST=localhost
DB_PORT=5432
DB_NAME=bones_and_all
DB_USER=postgres
DB_PASSWORD=your_password
JWT_SECRET=your_jwt_secret
```

Add your `serviceAccountKey.json` from Firebase to the `backend/` root.

Create the database and run the schema:
```bash
psql -U postgres -d bones_and_all -f src/db/schema.sql
```

Start the development server:
```bash
npm run dev
```

Verify the server is running:
```
GET http://localhost:3000/health
```

### Frontend Setup

Navigate to the frontend directory:
```bash
cd frontend
```

Install Flutter dependencies:
```bash
flutter pub get
```

Run the app on a connected Android device or emulator:
```bash
flutter run
```

> **Note:** This app requires a configured `.env` file and Firebase `serviceAccountKey.json` to run locally. These files are excluded from version control for security reasons.

---

## Security

- Passwords are hashed using **bcrypt** before storage
- All API communication is encrypted via **SSL/TLS**
- User sessions are managed using **JSON Web Tokens (JWT)**
- Sensitive credentials (`.env`, `serviceAccountKey.json`) are excluded from version control via `.gitignore`
- Database connections use a **connection pool** with SSL in production

---

## Research Context

This project serves as the application component of a Senior Honors research paper titled:

> *"Through a comparative analysis of three AI models used in the development of the mobile application Bones and All, this study evaluates their effectiveness across different stages of the software development lifecycle to determine best practices for AI-assisted software development."*

**AI Models Evaluated:**
- Claude Sonnet — Primary development assistant
- GitHub Copilot (GPT) — Code completion assistant
- ChatGPT — Comparison and verification

---

## Academic Context

| | |
|---|---|
| **Institution** | Western Illinois University |
| **Program** | Senior Honors Project |
| **Author** | Kaitlyn Morris |
| **Advisor** | Dr. Baramidze |
| **Due Date** | May 8, 2026 |

---

## License

This project was developed as a Senior Honors Project at Western Illinois University, Spring 2026. All rights reserved.
