const express = require('express');
const router = express.Router();
const eventController = require('../controllers/eventController');
const authMiddleware = require('../middleware/authMiddleware');

router.get('/', (req, res) => eventController.getEvents(req, res));
router.get('/:id', (req, res) => eventController.getEventById(req, res));
router.post('/', authMiddleware, (req, res) => eventController.createEvent(req, res));
router.post('/:id/register', authMiddleware, (req, res) => eventController.register(req, res));
router.delete('/:id/register', authMiddleware, (req, res) => eventController.cancelRegistration(req, res));

module.exports = router;
