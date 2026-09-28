const dataRepo = require('../repositories/dataRepository');

class ChatController {
  getConversations(req, res) {
    try {
      const convs = dataRepo.getConversations(req.user.id);
      return res.json(convs);
    } catch (err) {
      console.error(err);
      return res.status(500).json({ error: 'Failed to get conversations' });
    }
  }

  getMessages(req, res) {
    try {
      const { id } = req.params;
      const { page, limit } = req.query;
      const messages = dataRepo.getMessages(id, {
        page: page ? parseInt(page) : 1,
        limit: limit ? parseInt(limit) : 50,
      });
      return res.json(messages);
    } catch (err) {
      console.error(err);
      return res.status(500).json({ error: 'Failed to get messages' });
    }
  }

  getOrCreateDirectConversation(req, res) {
    try {
      const { recipientId } = req.body;
      if (!recipientId) {
        return res.status(400).json({ error: 'recipientId is required' });
      }
      const conv = dataRepo.findOrCreateDirectConversation(req.user.id, recipientId);
      return res.json(conv);
    } catch (err) {
      console.error(err);
      return res.status(500).json({ error: 'Failed to initialize conversation' });
    }
  }

  markAsRead(req, res) {
    try {
      const { id } = req.params;
      const count = dataRepo.markMessagesAsRead(id, req.user.id);
      return res.json({ updated: count });
    } catch (err) {
      console.error(err);
      return res.status(500).json({ error: 'Failed to mark messages as read' });
    }
  }
}

module.exports = new ChatController();
