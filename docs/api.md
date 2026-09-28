# CampusConnect REST API Documentation

Base URL: `http://localhost:5000/api`

All protected endpoints require the following header:
```http
Authorization: Bearer <jwt_token>
```

---

## 1. Authentication Endpoints

### Register User
- **POST** `/auth/register`
- **Body:**
  ```json
  {
    "email": "aarav@university.edu",
    "password": "Password123!",
    "fullName": "Aarav Shrestha",
    "department": "Computer Science",
    "year": "3rd Year",
    "university": "SRM University-AP"
  }
  ```
- **Response (201):**
  ```json
  {
    "token": "jwt_token_string",
    "user": {
      "id": "usr_101",
      "email": "aarav@university.edu",
      "profile": {
        "fullName": "Aarav Shrestha",
        "department": "Computer Science",
        "year": "3rd Year",
        "university": "SRM University-AP"
      }
    }
  }
  ```

### Login User
- **POST** `/auth/login`
- **Body:**
  ```json
  {
    "email": "aarav@university.edu",
    "password": "Password123!"
  }
  ```
- **Response (200):** Token and user profile details.

---

## 2. Students & Profile Endpoints

### Get Current User Profile
- **GET** `/users/me`

### Update Profile
- **PUT** `/users/me`
- **Body:**
  ```json
  {
    "bio": "Building Flutter apps and AI systems.",
    "skills": ["Flutter", "Dart", "Python", "Machine Learning"],
    "interests": ["AI", "Open Source", "Robotics"],
    "avatarUrl": "https://images.unsplash.com/photo-1534528741775-53994a69daeb"
  }
  ```

### Discover / Search Students
- **GET** `/users?search=Machine%20Learning&department=Computer%20Science&year=3rd%20Year&page=1&limit=20`

### Get Student Details
- **GET** `/users/:id`

### Connect With Student
- **POST** `/users/:id/connect`

### Remove Connection
- **DELETE** `/users/:id/connect`

---

## 3. Communities Endpoints

### List Communities
- **GET** `/communities?page=1&limit=20`

### Get Community Details
- **GET** `/communities/:id`

### Create Community
- **POST** `/communities`
- **Body:**
  ```json
  {
    "name": "Flutter Developers",
    "description": "Cross-platform mobile and web developers hub.",
    "coverImage": "https://images.unsplash.com/photo-1551288049-bebda4e38f71"
  }
  ```

### Join Community
- **POST** `/communities/:id/join`

### Leave Community
- **POST** `/communities/:id/leave`

---

## 4. Events Endpoints

### List Events
- **GET** `/events?filter=upcoming&category=Technology&page=1&limit=20`

### Get Event Details
- **GET** `/events/:id`

### Create Event
- **POST** `/events`
- **Body:**
  ```json
  {
    "title": "HackSRM 2026",
    "description": "Annual 36-hour flagship campus hackathon.",
    "coverImage": "https://images.unsplash.com/photo-1504384308090-c894fdcc538d",
    "location": "SRM University-AP Auditorium",
    "startTime": "2026-10-20T09:00:00Z",
    "endTime": "2026-10-21T21:00:00Z",
    "capacity": 300,
    "communityId": "comm_1"
  }
  ```

### Register for Event
- **POST** `/events/:id/register`

### Cancel Event Registration
- **DELETE** `/events/:id/register`

---

## 5. Conversations & Messages Endpoints

### List Conversations
- **GET** `/conversations`

### Get Conversation Messages (Paginated)
- **GET** `/conversations/:id/messages?page=1&limit=30`

### Create or Get Direct Conversation
- **POST** `/conversations/direct`
- **Body:**
  ```json
  {
    "recipientId": "usr_202"
  }
  ```

---

## 6. Notifications Endpoints

### Get Notifications
- **GET** `/notifications`

### Mark Notification as Read
- **PUT** `/notifications/:id/read`
