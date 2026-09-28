const dataRepo = require('../repositories/dataRepository');

class UserController {
  getAllStudents(req, res) {
    try {
      const { search, department, year, page, limit } = req.query;
      const result = dataRepo.getAllStudents({
        search,
        department,
        year,
        page: page ? parseInt(page) : 1,
        limit: limit ? parseInt(limit) : 20,
        excludeUserId: req.user ? req.user.id : null,
      });
      return res.json(result);
    } catch (err) {
      console.error(err);
      return res.status(500).json({ error: 'Failed to search students' });
    }
  }

  getStudentById(req, res) {
    try {
      const { id } = req.params;
      const profile = dataRepo.findProfileByUserId(id);
      if (!profile) {
        return res.status(404).json({ error: 'Student not found' });
      }
      const user = dataRepo.findUserById(id);
      return res.json({
        ...profile,
        email: user ? user.email : '',
        isOnline: user ? user.isOnline : false,
        lastSeen: user ? user.lastSeen : null,
      });
    } catch (err) {
      console.error(err);
      return res.status(500).json({ error: 'Failed to get student profile' });
    }
  }

  updateProfile(req, res) {
    try {
      const updates = req.body;
      const updated = dataRepo.updateProfile(req.user.id, updates);
      if (!updated) {
        return res.status(404).json({ error: 'Profile not found' });
      }
      return res.json(updated);
    } catch (err) {
      console.error(err);
      return res.status(500).json({ error: 'Failed to update profile' });
    }
  }

  connect(req, res) {
    try {
      const targetId = req.params.id;
      if (targetId === req.user.id) {
        return res.status(400).json({ error: 'Cannot connect with yourself' });
      }
      const conn = dataRepo.createConnection(req.user.id, targetId);
      // Trigger notification for target user
      dataRepo.createNotification({
        userId: targetId,
        category: 'CONNECTIONS',
        title: 'New Connection Request',
        body: `${req.profile.fullName} wants to connect with you.`,
        data: { requesterId: req.user.id },
      });
      return res.status(201).json(conn);
    } catch (err) {
      console.error(err);
      return res.status(500).json({ error: 'Failed to create connection' });
    }
  }

  disconnect(req, res) {
    try {
      const targetId = req.params.id;
      const success = dataRepo.removeConnection(req.user.id, targetId);
      return res.json({ success });
    } catch (err) {
      console.error(err);
      return res.status(500).json({ error: 'Failed to remove connection' });
    }
  }
}

module.exports = new UserController();
