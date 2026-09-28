const express = require('express');
const router = express.Router();
const communityController = require('../controllers/communityController');
const authMiddleware = require('../middleware/authMiddleware');

router.get('/', (req, res) => communityController.getCommunities(req, res));
router.get('/:id', (req, res) => communityController.getCommunityById(req, res));
router.post('/', authMiddleware, (req, res) => communityController.createCommunity(req, res));
router.post('/:id/join', authMiddleware, (req, res) => communityController.join(req, res));
router.post('/:id/leave', authMiddleware, (req, res) => communityController.leave(req, res));

module.exports = router;
