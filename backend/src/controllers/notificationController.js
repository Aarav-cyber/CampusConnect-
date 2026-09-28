const dataRepo = require('../repositories/dataRepository');

class NotificationController {
  getNotifications(req, res) {
    try {
      const list = dataRepo.getNotifications(req.user.id);
      return res.json(list);
    } catch (err) {
      console.error(err);
      return res.status(500).json({ error: 'Failed to get notifications' });
    }
  }

  markRead(req, res) {
    try {
      const { id } = req.params;
      const notif = dataRepo.markNotificationAsRead(id, req.user.id);
      if (!notif) {
        return res.status(404).json({ error: 'Notification not found' });
      }
      return res.json(notif);
    } catch (err) {
      console.error(err);
      return res.status(500).json({ error: 'Failed to update notification' });
    }
  }
}

module.exports = new NotificationController();
