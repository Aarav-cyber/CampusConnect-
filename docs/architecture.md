# CampusConnect Architecture

CampusConnect is structured following Clean Architecture principles to ensure high maintainability, testability, and separation of concerns.

## System Overview

```text
                         ┌───────────────────────┐
                         │       CAMPUSCONNECT   │
                         │      Flutter Mobile   │
                         └───────────┬───────────┘
                                     │
                ┌─────────────────────┼─────────────────────┐
                │                     │                     │
                ▼                     ▼                     ▼
           REST API              WebSocket              Firebase
                │                     │                     │
                │                     │                     ├── Authentication
                │                     │                     ├── Storage
                │                     │                     └── FCM
                │                     │
                ▼                     ▼
         ┌──────────────┐      ┌──────────────┐
         │ API Server   │      │ WS Server    │
         └──────┬───────┘      └──────┬───────┘
                │                     │
                └──────────┬──────────┘
                           ▼
                   ┌───────────────┐
                   │   Database    │
                   └───────────────┘
                           ▲
                           │
                   ┌───────┴───────┐
                   │ Local Storage │
                   │ Flutter       │
                   └───────────────┘
```

## Flutter Clean Architecture Layers

1. **Presentation Layer (`lib/features/*/presentation/` and `lib/shared/widgets/`)**
   - **Screens**: Full view widgets handling layout and lifecycle.
   - **Widgets**: Reusable presentational components (MessageBubble, EventCard, StudentCard, etc.).
   - **State / Providers**: Riverpod/ChangeNotifier providers managing loading, success, error, and empty states.

2. **Domain Layer (`lib/features/*/domain/`)**
   - **Entities**: Core business objects independent of serialization or external frameworks.
   - **Repositories (Interfaces)**: Contracts defining data operations needed by the domain.
   - **Use Cases**: Specific application business actions (e.g. `SendMessage`, `GetEvents`, `ConnectStudent`).

3. **Data Layer (`lib/features/*/data/`)**
   - **Data Sources**:
     - Remote Data Source (REST client via Dio / http).
     - WebSocket Data Source (Real-time socket channel for messages, typing, presence).
     - Local Data Source (Hive / SharedPreferences for offline cache and persistent preferences).
   - **Models**: DTOs that handle JSON serialization, deserialization, and entity mapping.
   - **Repository Implementations**: Implement the domain repository interfaces, coordinating local and remote sources with offline fallback.

4. **Core (`lib/core/`)**
   - **Network**: HTTP client wrappers, interceptors, WebSocket manager with exponential backoff.
   - **Storage**: Secure storage for JWTs and local key-value/document persistence.
   - **Errors**: Domain failure classes and exception handlers.
   - **Utils & Constants**: App constants, date/time formatting, validators, debounce utilities.

## Backend Architecture

The backend follows a layered Node.js/Express service architecture:
- `controllers/`: Handles HTTP requests, input validation, and HTTP responses.
- `services/`: Encapsulates business logic, transactional rules, and cross-cutting concerns.
- `repositories/`: Direct database queries and data access layer.
- `websocket/`: Manages real-time connections, presence, typing indicators, and message broadcasts.
- `middleware/`: Authentication JWT validation, rate limiting, and error handling.
