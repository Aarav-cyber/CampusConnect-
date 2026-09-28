# CampusConnect 🎓📱⚡

> **Real-Time Student Networking & Campus Community Platform**
> Built with Flutter, Node.js, WebSockets, REST APIs, and Local Persistence.

---

## 🌟 Overview

CampusConnect brings together the entire university experience into a single real-time cross-platform mobile application:
- **Student Discovery**: Search peers by skill, major/department, graduation year, or interests.
- **One-on-One & Group Messaging**: Instant messaging powered by WebSockets, with typing indicators, online presence, and read receipts.
- **Campus Communities**: Join clubs, societies, and interest groups with dedicated discussion feeds and chat rooms.
- **Event Discovery & Registration**: Browse campus hackathons, workshops, and symposiums with one-tap registration.
- **Smart Notifications**: Categorized alerts for events, connection requests, and community announcements.
- **Offline & Resilient Architecture**: Local cache with seamless reconnection and optimistic UI updates.

---

## 🏗️ Architecture

CampusConnect follows **Clean Architecture** principles across both the mobile client and backend server:

```text
lib/
├── app/                  # App initialization, routes, theme
├── core/                 # Networking, constants, error handling, local storage
├── features/
│   ├── auth/             # Authentication & session persistence
│   ├── profile/          # Student profile view and editing
│   ├── students/         # Student discovery, search, filtering, connections
│   ├── chat/             # 1-to-1 & group WebSocket real-time messaging
│   ├── communities/      # Campus communities, member listings, feeds
│   ├── events/           # Event discovery, filtering, and registration
│   └── notifications/    # Real-time notifications and alerts
└── shared/               # Reusable widgets and models

backend/
├── src/
│   ├── controllers/      # HTTP request/response handlers
│   ├── middleware/       # JWT authentication and validation
│   ├── models/           # Persistent JSON/relational database store
│   ├── repositories/     # Data access layer
│   ├── routes/           # REST endpoints
│   ├── websocket/        # Real-time ConnectionManager and WebSocket protocol
│   └── index.js          # Server entrypoint
```

---

## 🚀 Quick Start Guide

### 1. Prerequisites
- **Node.js** (v18+)
- **Flutter SDK** (v3.19+)

### 2. Backend Setup & Run
```bash
cd backend
npm install
npm test       # Run end-to-end REST & WebSocket test suite
npm start      # Starts server on http://localhost:5000 and ws://localhost:5000/ws
```

### 3. Flutter App Setup & Run
```bash
# In the app root directory
flutter pub get
flutter run
```

---

## 📡 API & WebSocket Protocols

Detailed specifications are documented in the [`docs/`](file:///c:/fullstack/flutter/app/docs) folder:
- [Architecture Guide](file:///c:/fullstack/flutter/app/docs/architecture.md)
- [REST API Reference](file:///c:/fullstack/flutter/app/docs/api.md)
- [WebSocket Protocol](file:///c:/fullstack/flutter/app/docs/websocket.md)
- [Database Schema](file:///c:/fullstack/flutter/app/docs/database.md)

---

## 🔑 Demo Credentials

| Role | Email | Password |
|---|---|---|
| Student (Lead) | `aarav@university.edu` | `password123` |
| Student (AI Researcher) | `rahul@university.edu` | `password123` |
| Student (UI/UX) | `anjali@university.edu` | `password123` |
| Student (Cyber Sec) | `ankush@university.edu` | `password123` |
