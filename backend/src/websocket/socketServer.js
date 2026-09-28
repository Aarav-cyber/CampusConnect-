const WebSocket = require('ws');
const jwt = require('jsonwebtoken');
const config = require('../config');
const dataRepo = require('../repositories/dataRepository');
const connectionManager = require('./connectionManager');

function setupWebSocketServer(httpServer) {
  const wss = new WebSocket.Server({ server: httpServer, path: '/ws' });

  wss.on('connection', (ws, req) => {
    let authenticatedUserId = null;

    // Check query params token if present (e.g. ws://localhost:5000/ws?token=xyz)
    const url = new URL(req.url, 'http://localhost');
    const tokenQuery = url.searchParams.get('token');
    if (tokenQuery) {
      try {
        const decoded = jwt.verify(tokenQuery, config.JWT_SECRET);
        authenticatedUserId = decoded.userId;
        connectionManager.addConnection(authenticatedUserId, ws);
        ws.send(
          JSON.stringify({
            type: 'authenticated',
            userId: authenticatedUserId,
            timestamp: new Date().toISOString(),
          })
        );
      } catch (err) {
        console.warn('WS auth token failed on query', err.message);
      }
    }

    ws.on('message', (messageRaw) => {
      try {
        const data = JSON.parse(messageRaw);

        // 1. Auth message
        if (data.type === 'auth') {
          try {
            const decoded = jwt.verify(data.token, config.JWT_SECRET);
            authenticatedUserId = decoded.userId;
            connectionManager.addConnection(authenticatedUserId, ws);
            ws.send(
              JSON.stringify({
                type: 'authenticated',
                userId: authenticatedUserId,
                timestamp: new Date().toISOString(),
              })
            );
          } catch (e) {
            ws.send(JSON.stringify({ type: 'error', message: 'Authentication failed' }));
          }
          return;
        }

        // Heartbeat
        if (data.type === 'ping') {
          ws.send(JSON.stringify({ type: 'pong' }));
          return;
        }

        if (!authenticatedUserId) {
          ws.send(JSON.stringify({ type: 'error', message: 'Unauthorized WebSocket action' }));
          return;
        }

        // 2. Room Join
        if (data.type === 'room.join' && data.conversationId) {
          connectionManager.joinRoom(data.conversationId, authenticatedUserId);
          return;
        }

        // 3. Send Message
        if (data.type === 'message.send') {
          const { conversationId, content, messageType } = data;
          if (!conversationId || !content) return;

          const createdMsg = dataRepo.createMessage({
            conversationId,
            senderId: authenticatedUserId,
            content,
            messageType: messageType || 'TEXT',
          });

          const senderProfile = dataRepo.findProfileByUserId(authenticatedUserId);

          const eventPayload = {
            type: 'message.created',
            message: {
              ...createdMsg,
              senderName: senderProfile ? senderProfile.fullName : 'Student',
              senderAvatar: senderProfile ? senderProfile.profileImage : null,
            },
          };

          // Broadcast to all conversation members (including sender for sync)
          connectionManager.broadcastToConversation(conversationId, eventPayload);
          return;
        }

        // 4. Typing indicator
        if (data.type === 'typing.start' || data.type === 'typing.stop') {
          const { conversationId } = data;
          const senderProfile = dataRepo.findProfileByUserId(authenticatedUserId);
          const isTyping = data.type === 'typing.start';

          connectionManager.broadcastToConversation(
            conversationId,
            {
              type: 'user.typing',
              conversationId,
              userId: authenticatedUserId,
              userName: senderProfile ? senderProfile.fullName : 'Student',
              isTyping,
            },
            authenticatedUserId // exclude sender
          );
          return;
        }

        // 5. Read receipt
        if (data.type === 'message.read') {
          const { conversationId } = data;
          dataRepo.markMessagesAsRead(conversationId, authenticatedUserId);
          connectionManager.broadcastToConversation(
            conversationId,
            {
              type: 'message.read',
              conversationId,
              userId: authenticatedUserId,
            },
            authenticatedUserId
          );
          return;
        }
      } catch (err) {
        console.error('WebSocket message processing error', err);
      }
    });

    ws.on('close', () => {
      connectionManager.removeConnection(ws);
    });

    ws.on('error', (err) => {
      console.error('WebSocket client error', err);
      connectionManager.removeConnection(ws);
    });
  });

  return wss;
}

module.exports = { setupWebSocketServer };
