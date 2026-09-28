const dataRepo = require('../repositories/dataRepository');

class EventController {
  getEvents(req, res) {
    try {
      const { category, filter, page, limit } = req.query;
      const result = dataRepo.getEvents({
        category,
        filter,
        page: page ? parseInt(page) : 1,
        limit: limit ? parseInt(limit) : 20,
        userId: req.user ? req.user.id : null,
      });
      return res.json(result);
    } catch (err) {
      console.error(err);
      return res.status(500).json({ error: 'Failed to get events' });
    }
  }

  getEventById(req, res) {
    try {
      const { id } = req.params;
      const event = dataRepo.getEventById(id, req.user ? req.user.id : null);
      if (!event) {
        return res.status(404).json({ error: 'Event not found' });
      }
      return res.json(event);
    } catch (err) {
      console.error(err);
      return res.status(500).json({ error: 'Failed to get event' });
    }
  }

  createEvent(req, res) {
    try {
      const { title, description, coverImage, location, startTime, endTime, capacity, category, communityId } = req.body;
      if (!title || !description) {
        return res.status(400).json({ error: 'Title and description are required' });
      }
      const event = dataRepo.createEvent(
        { title, description, coverImage, location, startTime, endTime, capacity, category, communityId },
        req.user.id
      );
      return res.status(201).json(event);
    } catch (err) {
      console.error(err);
      return res.status(500).json({ error: 'Failed to create event' });
    }
  }

  register(req, res) {
    try {
      const { id } = req.params;
      const reg = dataRepo.registerForEvent(id, req.user.id);
      const event = dataRepo.getEventById(id, req.user.id);
      
      // Add notification for registration
      dataRepo.createNotification({
        userId: req.user.id,
        category: 'EVENTS',
        title: 'Event Registration Confirmed',
        body: `You are confirmed for "${event ? event.title : 'the event'}".`,
        data: { eventId: id },
      });

      return res.status(200).json(reg);
    } catch (err) {
      console.error(err);
      return res.status(500).json({ error: 'Failed to register for event' });
    }
  }

  cancelRegistration(req, res) {
    try {
      const { id } = req.params;
      const success = dataRepo.cancelEventRegistration(id, req.user.id);
      return res.status(200).json({ success });
    } catch (err) {
      console.error(err);
      return res.status(500).json({ error: 'Failed to cancel registration' });
    }
  }
}

module.exports = new EventController();
