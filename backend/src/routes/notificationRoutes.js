const express = require('express');
const router = express.Router();
const notificationController = require('../controllers/notificationController');
const authMiddleware = require('../middleware/authMiddleware');

router.use(authMiddleware);

router.get('/', (req, res) => notificationController.getNotifications(req, res));
router.put('/:id/read', (req, res) => notificationController.markRead(req, res));

module.exports = router;
