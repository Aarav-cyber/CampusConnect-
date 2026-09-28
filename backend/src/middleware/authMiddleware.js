const jwt = require('jsonwebtoken');
const config = require('../config');
const dataRepo = require('../repositories/dataRepository');

const authMiddleware = (req, res, next) => {
  const authHeader = req.headers.authorization;
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return res.status(401).json({ error: 'Unauthorized: Missing or invalid token' });
  }

  const token = authHeader.split(' ')[1];
  try {
    const decoded = jwt.verify(token, config.JWT_SECRET);
    const user = dataRepo.findUserById(decoded.userId);
    if (!user) {
      return res.status(401).json({ error: 'User no longer exists' });
    }
    req.user = user;
    req.profile = dataRepo.findProfileByUserId(user.id);
    next();
  } catch (err) {
    return res.status(401).json({ error: 'Invalid or expired token' });
  }
};

module.exports = authMiddleware;
