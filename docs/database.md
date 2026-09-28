# CampusConnect Database Schema

## Relational Schema

```sql
-- Users
CREATE TABLE users (
  id TEXT PRIMARY KEY,
  email TEXT UNIQUE NOT NULL,
  password_hash TEXT NOT NULL,
  is_online INTEGER DEFAULT 0,
  last_seen TEXT NOT NULL,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL
);

-- Profiles
CREATE TABLE profiles (
  id TEXT PRIMARY KEY,
  user_id TEXT UNIQUE NOT NULL,
  full_name TEXT NOT NULL,
  profile_image TEXT,
  university TEXT NOT NULL,
  department TEXT NOT NULL,
  year TEXT NOT NULL,
  bio TEXT,
  skills TEXT, -- JSON array
  interests TEXT, -- JSON array
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Connections
CREATE TABLE connections (
  id TEXT PRIMARY KEY,
  requester_id TEXT NOT NULL,
  target_id TEXT NOT NULL,
  status TEXT NOT NULL, -- PENDING, ACCEPTED, REJECTED
  created_at TEXT NOT NULL,
  FOREIGN KEY (requester_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (target_id) REFERENCES users(id) ON DELETE CASCADE,
  UNIQUE(requester_id, target_id)
);

-- Communities
CREATE TABLE communities (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  description TEXT NOT NULL,
  cover_image TEXT,
  created_by TEXT NOT NULL,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL,
  FOREIGN KEY (created_by) REFERENCES users(id)
);

-- Community Members
CREATE TABLE community_members (
  id TEXT PRIMARY KEY,
  community_id TEXT NOT NULL,
  user_id TEXT NOT NULL,
  role TEXT DEFAULT 'MEMBER', -- ADMIN, MODERATOR, MEMBER
  joined_at TEXT NOT NULL,
  FOREIGN KEY (community_id) REFERENCES communities(id) ON DELETE CASCADE,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  UNIQUE(community_id, user_id)
);

-- Events
CREATE TABLE events (
  id TEXT PRIMARY KEY,
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  cover_image TEXT,
  location TEXT NOT NULL,
  start_time TEXT NOT NULL,
  end_time TEXT NOT NULL,
  capacity INTEGER DEFAULT 100,
  created_by TEXT NOT NULL,
  community_id TEXT,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL,
  FOREIGN KEY (created_by) REFERENCES users(id),
  FOREIGN KEY (community_id) REFERENCES communities(id) ON DELETE SET NULL
);

-- Event Registrations
CREATE TABLE event_registrations (
  id TEXT PRIMARY KEY,
  event_id TEXT NOT NULL,
  user_id TEXT NOT NULL,
  registered_at TEXT NOT NULL,
  FOREIGN KEY (event_id) REFERENCES events(id) ON DELETE CASCADE,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  UNIQUE(event_id, user_id)
);

-- Conversations
CREATE TABLE conversations (
  id TEXT PRIMARY KEY,
  is_group INTEGER DEFAULT 0,
  title TEXT,
  community_id TEXT,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL,
  FOREIGN KEY (community_id) REFERENCES communities(id) ON DELETE CASCADE
);

-- Conversation Members
CREATE TABLE conversation_members (
  id TEXT PRIMARY KEY,
  conversation_id TEXT NOT NULL,
  user_id TEXT NOT NULL,
  joined_at TEXT NOT NULL,
  FOREIGN KEY (conversation_id) REFERENCES conversations(id) ON DELETE CASCADE,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  UNIQUE(conversation_id, user_id)
);

-- Messages
CREATE TABLE messages (
  id TEXT PRIMARY KEY,
  conversation_id TEXT NOT NULL,
  sender_id TEXT NOT NULL,
  content TEXT NOT NULL,
  message_type TEXT DEFAULT 'TEXT', -- TEXT, IMAGE, FILE, SYSTEM
  status TEXT DEFAULT 'SENT', -- PENDING, SENDING, SENT, DELIVERED, READ
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL,
  FOREIGN KEY (conversation_id) REFERENCES conversations(id) ON DELETE CASCADE,
  FOREIGN KEY (sender_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Notifications
CREATE TABLE notifications (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL,
  category TEXT NOT NULL, -- MESSAGES, CONNECTIONS, EVENTS, COMMUNITIES
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  data TEXT, -- JSON
  is_read INTEGER DEFAULT 0,
  created_at TEXT NOT NULL,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);
```
