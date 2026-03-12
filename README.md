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
| Profile & Settings | Manage account info, notification time, and preferences |

---

## Tech Stack

| Layer | Technology |
|---|---|
| Frontend | Flutter (Dart) | Android mobile UI |
| Backend | Node.js, Express.js | REST API server |
| Database | PostgreSQL | Persisent data storage |
| Notifications | Firebase Cloud Messaging (FCM) | Push notification delivery |
| Authentication | JSON Web Tokens (JWT) | Stateless user authentication |
| Password Security | bcrypt | Password Hashing |
| Communication | HTTP/TLS (SSL encrypted) | Encrypted data transfer |
| Scheduling | node-cron | Daily notification jobs |

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
│       │   ├── index.js                # PostgreSQL connection pool
│       │   └── schema.sql              # All table definitions
│       ├── jobs/
│       │   └── dailyReminder.js        # Scheduled FCM cron job
│       ├── middleware/
│       │   └── auth.js                 # JWT verification middleware
│       ├── routes/
│       │   ├── auth.js                 # Register and login
│       │   ├── blocks.js               # Trackable blocks CRUD
│       │   ├── questions.js            # Questions CRUD
│       │   ├── logs.js                 # Daily log entries CRUD
│       │   ├── questionnaire.js        # Questionnaire responses
│       │   ├── notifications.js        # Notification preferences
│       │   └── profile.js              # User profile management
│       ├── services/
│       │   └── fcm.js                  # Firebase Cloud Messaging service
│       └── app.js                      # Express app entry point
│
├── frontend/
│   ├── android/                        # Android build configuration
│   ├── lib/
│   │   ├── services/
│   │   │   └── auth_service.dart       # Auth API service
│   │   └── main.dart                   # Flutter app entry point
│   ├── test/
│   │   └── widget_test.dart
│   └── pubspec.yaml                    # Flutter dependencies
│
└── docs/
    ├── ActivityDiagram.png
    ├── SystemArchitecture.png
    ├── PrototypeScreens.png
    └── DatabaseSchema.png
```

---

## Database Schema

PostgreSQL is used with the following six tables:

| Table | Description |
|---|---|
| `users` | Login credentials, profile info, FCM token, and notification preferences |
| `blocks` | Customizable block sections created by the user (e.g. Pain, Food) |
| `questions` | Individual questions belonging to a trackable block |
| `logs` | One daily entry per block per user, includes optional journal entry |
| `questionnaire_responses` | Individual answers to questions within a log entry |
| `notifications` | Push notification history including timestamp and delivery status |

See [`Database Schema`](docs/DatabaseSchema.png) for full table definitions.

---
## API Endpoints

All endpoints except `/api/auth` require a valid JWT token in the `Authorization: Bearer <token>` header.

### Auth
| Method | Endpoint | Description |
|---|---|---|
| POST | `/api/auth/register` | Register a new user, returns JWT |
| POST | `/api/auth/login` | Login, returns JWT |

### Blocks
| Method | Endpoint | Description |
|---|---|---|
| POST | `/api/blocks` | Create a new trackable block |
| GET | `/api/blocks` | Get all blocks for logged in user |
| PATCH | `/api/blocks/:id` | Rename or reorder a block |
| DELETE | `/api/blocks/:id` | Delete a block and all associated data |

### Questions
| Method | Endpoint | Description |
|---|---|---|
| POST | `/api/questions` | Add a question to a block |
| GET | `/api/questions/:blockId` | Get all questions for a block |
| PATCH | `/api/questions/:id` | Edit a question |
| DELETE | `/api/questions/:id` | Delete a question |

### Logs
| Method | Endpoint | Description |
|---|---|---|
| POST | `/api/logs` | Create or update a daily log entry |
| GET | `/api/logs/:blockId` | Get all logs for a block |
| GET | `/api/logs/:blockId/:date` | Get a specific log by date |
| PATCH | `/api/logs/:id` | Update a journal entry |
| DELETE | `/api/logs/:id` | Delete a log |

### Questionnaire
| Method | Endpoint | Description |
|---|---|---|
| POST | `/api/questionnaire` | Save an array of responses for a log |
| GET | `/api/questionnaire/:logId` | Get all responses for a log |

### Notifications
| Method | Endpoint | Description |
|---|---|---|
| PATCH | `/api/notifications/preferences` | Update notification settings and FCM token |
| GET | `/api/notifications/preferences` | Get current notification settings |
| GET | `/api/notifications/history` | Get last 50 notifications sent |

### Profile
| Method | Endpoint | Description |
|---|---|---|
| GET | `/api/profile` | Get user profile |
| PATCH | `/api/profile` | Update display name or profile picture |
| DELETE | `/api/profile` | Delete account and all associated data |


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

Create the database in PostgreSQL then run the schema:
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
Expected: { "db": "connected", "time": "<timestamp>" }
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

This project serves as the application component of a Senior Honors research paper:

> *"Through an in-depth analysis of Claude Sonnet as an AI assistant used throughout the development of the mobile application Bones and All, this study evaluates its effectiveness, limitations, and impact across different stages of the software development lifecycle to determine best practices for AI-assisted software development."*

**AI Model Used:** Claude Sonnet (Anthropic) — Primary development assistant throughout planning, design, backend development, frontend development, and documentation.

**SDLC Stages Evaluated:**
- Project planning and architecture design
- Database schema design
- Backend REST API development
- Frontend Flutter development
- Testing and debugging
- Documentation


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
