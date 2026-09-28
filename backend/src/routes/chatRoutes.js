const express = require('express');
const router = express.Router();
const chatController = require('../controllers/chatController');
const authMiddleware = require('../middleware/authMiddleware');

router.use(authMiddleware);

router.get('/conversations', (req, res) => chatController.getConversations(req, res));
router.get('/conversations/:id/messages', (req, res) => chatController.getMessages(req, res));
router.post('/conversations/direct', (req, res) => chatController.getOrCreateDirectConversation(req, res));
router.post('/conversations/:id/read', (req, res) => chatController.markAsRead(req, res));

module.exports = router;
