# CampusConnect WebSocket Protocol

Endpoint: `ws://localhost:5000/ws`

## Connection Lifecycle

1. Client connects with query param `token` or sends `auth` message immediately upon connection:
```json
{
  "type": "auth",
  "token": "<jwt_token>"
}
```

2. Server verifies token, registers connection with Connection Manager, marks user `is_online: true`, and responds:
```json
{
  "type": "authenticated",
  "userId": "usr_101",
  "timestamp": "2026-09-28T10:30:00Z"
}
```

3. Heartbeat:
Client sends `{"type": "ping"}` every 25 seconds. Server responds `{"type": "pong"}`.

---

## Client to Server Messages

### 1. Send Message
```json
{
  "type": "message.send",
  "conversationId": "conv_123",
  "content": "Hey, are you going to the hackathon?",
  "messageType": "TEXT"
}
```

### 2. Typing Indicator
```json
{
  "type": "typing.start",
  "conversationId": "conv_123"
}
```

```json
{
  "type": "typing.stop",
  "conversationId": "conv_123"
}
```

### 3. Read Receipt
```json
{
  "type": "message.read",
  "conversationId": "conv_123",
  "messageId": "msg_456"
}
```

### 4. Join Conversation Room
```json
{
  "type": "room.join",
  "conversationId": "conv_123"
}
```

---

## Server to Client Events

### 1. New Message Created
```json
{
  "type": "message.created",
  "message": {
    "id": "msg_456",
    "conversationId": "conv_123",
    "senderId": "usr_101",
    "senderName": "Aarav Shrestha",
    "senderAvatar": "https://images.unsplash.com/photo-1534528741775-53994a69daeb",
    "content": "Hey, are you going to the hackathon?",
    "messageType": "TEXT",
    "status": "SENT",
    "createdAt": "2026-09-28T10:30:00Z"
  }
}
```

### 2. User Typing
```json
{
  "type": "user.typing",
  "conversationId": "conv_123",
  "userId": "usr_202",
  "userName": "Rahul Kumar",
  "isTyping": true
}
```

### 3. User Presence Update
```json
{
  "type": "user.presence",
  "userId": "usr_202",
  "isOnline": true,
  "lastSeen": "2026-09-28T10:35:00Z"
}
```

### 4. Real-Time Notification
```json
{
  "type": "notification.received",
  "notification": {
    "id": "notif_789",
    "category": "EVENT",
    "title": "HackSRM 2026 Registration Confirmed",
    "body": "You are confirmed for HackSRM 2026!",
    "createdAt": "2026-09-28T10:35:00Z"
  }
}
```
