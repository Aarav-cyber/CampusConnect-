const express = require('express');
const router = express.Router();
const userController = require('../controllers/userController');
const authMiddleware = require('../middleware/authMiddleware');

router.get('/', (req, res) => userController.getAllStudents(req, res));
router.get('/:id', (req, res) => userController.getStudentById(req, res));
router.put('/profile', authMiddleware, (req, res) => userController.updateProfile(req, res));
router.post('/:id/connect', authMiddleware, (req, res) => userController.connect(req, res));
router.delete('/:id/connect', authMiddleware, (req, res) => userController.disconnect(req, res));

module.exports = router;
