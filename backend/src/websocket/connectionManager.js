const WebSocket = require('ws');
const dataRepo = require('../repositories/dataRepository');

class ConnectionManager {
  constructor() {
    // Map of userId -> Set of WebSocket instances (allows multiple device logins)
    this.userSockets = new Map();
    // Map of socket -> userId
    this.socketUserMap = new Map();
    // Map of conversationId -> Set of userIds currently in room
    this.rooms = new Map();
  }

  addConnection(userId, socket) {
    if (!this.userSockets.has(userId)) {
      this.userSockets.set(userId, new Set());
    }
    this.userSockets.get(userId).add(socket);
    this.socketUserMap.set(socket, userId);

    // Update presence to online
    dataRepo.updateUserPresence(userId, true);
    this.broadcastPresence(userId, true);
  }

  removeConnection(socket) {
    const userId = this.socketUserMap.get(socket);
    if (!userId) return;

    this.socketUserMap.delete(socket);
    const userSet = this.userSockets.get(userId);
    if (userSet) {
      userSet.delete(socket);
      if (userSet.size === 0) {
        this.userSockets.delete(userId);
        dataRepo.updateUserPresence(userId, false);
        this.broadcastPresence(userId, false);
      }
    }
  }

  joinRoom(conversationId, userId) {
    if (!this.rooms.has(conversationId)) {
      this.rooms.set(conversationId, new Set());
    }
    this.rooms.get(conversationId).add(userId);
  }

  leaveRoom(conversationId, userId) {
    if (this.rooms.has(conversationId)) {
      this.rooms.get(conversationId).delete(userId);
    }
  }

  sendToUser(userId, payload) {
    const sockets = this.userSockets.get(userId);
    if (!sockets) return false;
    const msg = JSON.stringify(payload);
    sockets.forEach((s) => {
      if (s.readyState === WebSocket.OPEN) {
        s.send(msg);
      }
    });
    return true;
  }

  broadcastToConversation(conversationId, payload, excludeUserId = null) {
    const store = require('../models/store');
    const conversation = store.data.conversations.find((c) => c.id === conversationId);
    if (!conversation) return;

    const msg = JSON.stringify(payload);
    conversation.memberIds.forEach((memberId) => {
      if (excludeUserId && memberId === excludeUserId) return;
      const sockets = this.userSockets.get(memberId);
      if (sockets) {
        sockets.forEach((s) => {
          if (s.readyState === WebSocket.OPEN) {
            s.send(msg);
          }
        });
      }
    });
  }

  broadcastPresence(userId, isOnline) {
    const user = dataRepo.findUserById(userId);
    const payload = JSON.stringify({
      type: 'user.presence',
      userId,
      isOnline,
      lastSeen: user ? user.lastSeen : new Date().toISOString(),
    });

    this.userSockets.forEach((sockets) => {
      sockets.forEach((s) => {
        if (s.readyState === WebSocket.OPEN) {
          s.send(payload);
        }
      });
    });
  }
}

module.exports = new ConnectionManager();
