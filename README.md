# Bones and All

A mobile application for Android designed to help users track and monitor chronic conditions through personalized daily questionnaires, journaling, and data visualization.

---

## Features

- **User Authentication** — Email and password registration and login
- **Interactive Body Map** — Select pain locations on a visual body diagram
- **Pain Tracking** — Log pain characteristics, scale (1–10), and area
- **Custom Questionnaires** — Build and personalize tracking templates
- **Daily Journaling** — Add notes alongside questionnaire responses
- **Push Notifications** — Optional daily reminders via Firebase Cloud Messaging
- **Data Visualization** — View trends and patterns from logged data
- **Eating Tracker** — Log meals by Breakfast, Lunch, Dinner, and Snacks
- **Profile & Settings** — Manage account info and notification preferences

---

## Tech Stack

| Layer | Technology |
|---|---|
| Frontend | Flutter (Dart) |
| Backend | Node.js, Express.js |
| Database | PostgreSQL |
| Notifications | Firebase Cloud Messaging (FCM) |
| Security | SSL/TLS, Connection Pooling |

---

## Project Structure

```
bones-and-all/
├── backend/
│   └── src/
│       ├── db/
│       │   └── index.js          # Database connection pool
│       ├── jobs/
│       │   └── dailyReminder.js  # Scheduled notification job
│       ├── middleware/           # Auth and request middleware
│       ├── routes/               # API route handlers
│       ├── services/
│       │   └── fcm.js            # Firebase Cloud Messaging service
│       └── app.js                # Express app entry point
│
├── frontend/
│   ├── android/                  # Android build config
│   ├── lib/
│   │   └── main.dart             # Flutter app entry point
│   ├── test/
│   │   └── widget_test.dart
│   ├── web/                      # Web build assets
│   ├── windows/                  # Windows build config
│   ├── pubspec.yaml              # Flutter dependencies
│   └── analysis_options.yaml
│
└── docs/
    ├── ActivityDiagram.png
    ├── DatabaseSchema
    ├── PrototypeScreens.png
    └── SystemArchitecture.png
```


## Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install)
- [Node.js](https://nodejs.org/) (v18+)
- [PostgreSQL](https://www.postgresql.org/)
- [Firebase Project](https://firebase.google.com/) with FCM enabled
- Android Studio or VS Code

---

### Backend Setup

1. Navigate to the backend directory:
   ```bash
   cd backend
   ```

2. Install dependencies:
   ```bash
   npm install
   ```

3. Create a `.env` file in the `backend/` root:
   ```env
   PORT=your_port
   DATABASE_URL=your_postgresql_connection_string
   JWT_SECRET=your_jwt_secret
   ```

4. Add your `serviceAccountKey.json` from Firebase to the `backend/` root.

5. Start the server:
   ```bash
   node src/app.js
   ```

---

### Frontend Setup

1. Navigate to the frontend directory:
   ```bash
   cd frontend
   ```

2. Install Flutter dependencies:
   ```bash
   flutter pub get
   ```

3. Run the app on a connected Android device or emulator:
   ```bash
   flutter run
   ```

---

## Database
PostgreSQL is used with the following tables:

- `users` — Stores login credentials, profile information, and notification preferences including FCM token and daily reminder time.
- `blocks` — Customizable tracking sections created by the user (e.g. Pain, Food). Each user can have multiple blocks, which appear on the main page.
- `questions` — Individual questions belonging to a block (e.g. "Rate your pain"). Each block can have multiple questions.
- `logs` — A daily entry for a specific block. One log is created per block per day when the user fills out their questionnaire, and also holds the optional journal entry.
- `questionnaire_responses` — The actual answer to an individual question within a log (e.g. "7.5" for a pain rating). Each log can have multiple responses.
- `notifications` — A record of every push notification sent to a user, including timestamp and delivery status, used for history tracking and debugging.

---

## Security

- Passwords are hashed before storage
- All communication is encrypted via SSL/TLS
- Sensitive credentials (`.env`, `serviceAccountKey.json`) are excluded from version control

---

## License

This project was developed as a Senior Honors Project at Western Illinois University Spring 2026.
