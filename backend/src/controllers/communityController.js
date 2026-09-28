const dataRepo = require('../repositories/dataRepository');

class CommunityController {
  getCommunities(req, res) {
    try {
      const { page, limit } = req.query;
      const result = dataRepo.getCommunities({
        page: page ? parseInt(page) : 1,
        limit: limit ? parseInt(limit) : 20,
        userId: req.user ? req.user.id : null,
      });
      return res.json(result);
    } catch (err) {
      console.error(err);
      return res.status(500).json({ error: 'Failed to get communities' });
    }
  }

  getCommunityById(req, res) {
    try {
      const { id } = req.params;
      const community = dataRepo.getCommunityById(id, req.user ? req.user.id : null);
      if (!community) {
        return res.status(404).json({ error: 'Community not found' });
      }
      return res.json(community);
    } catch (err) {
      console.error(err);
      return res.status(500).json({ error: 'Failed to get community' });
    }
  }

  createCommunity(req, res) {
    try {
      const { name, description, coverImage } = req.body;
      if (!name || !description) {
        return res.status(400).json({ error: 'Name and description are required' });
      }
      const community = dataRepo.createCommunity(
        { name, description, coverImage },
        req.user.id
      );
      return res.status(201).json(community);
    } catch (err) {
      console.error(err);
      return res.status(500).json({ error: 'Failed to create community' });
    }
  }

  join(req, res) {
    try {
      const { id } = req.params;
      const member = dataRepo.joinCommunity(id, req.user.id);
      return res.status(200).json(member);
    } catch (err) {
      console.error(err);
      return res.status(500).json({ error: 'Failed to join community' });
    }
  }

  leave(req, res) {
    try {
      const { id } = req.params;
      const success = dataRepo.leaveCommunity(id, req.user.id);
      return res.status(200).json({ success });
    } catch (err) {
      console.error(err);
      return res.status(500).json({ error: 'Failed to leave community' });
    }
  }
}

module.exports = new CommunityController();
