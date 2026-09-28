const jwt = require('jsonwebtoken');
const config = require('../config');
const dataRepo = require('../repositories/dataRepository');

class AuthController {
  register(req, res) {
    try {
      const { email, password, fullName, department, year, university } = req.body;
      if (!email || !password || !fullName) {
        return res.status(400).json({ error: 'Email, password, and full name are required' });
      }

      const existing = dataRepo.findUserByEmail(email);
      if (existing) {
        return res.status(400).json({ error: 'Email already in use' });
      }

      const { user, profile } = dataRepo.createUser(
        { email, password },
        { fullName, department, year, university }
      );

      const token = jwt.sign({ userId: user.id, email: user.email }, config.JWT_SECRET, {
        expiresIn: config.JWT_EXPIRY,
      });

      return res.status(201).json({
        token,
        user: {
          id: user.id,
          email: user.email,
          profile,
        },
      });
    } catch (err) {
      console.error(err);
      return res.status(500).json({ error: 'Failed to register student' });
    }
  }

  login(req, res) {
    try {
      const { email, password } = req.body;
      if (!email || !password) {
        return res.status(400).json({ error: 'Email and password are required' });
      }

      const user = dataRepo.findUserByEmail(email);
      if (!user || user.password !== password) {
        return res.status(401).json({ error: 'Invalid email or password' });
      }

      const profile = dataRepo.findProfileByUserId(user.id);
      const token = jwt.sign({ userId: user.id, email: user.email }, config.JWT_SECRET, {
        expiresIn: config.JWT_EXPIRY,
      });

      return res.status(200).json({
        token,
        user: {
          id: user.id,
          email: user.email,
          profile,
        },
      });
    } catch (err) {
      console.error(err);
      return res.status(500).json({ error: 'Failed to login' });
    }
  }

  getMe(req, res) {
    return res.json({
      user: {
        id: req.user.id,
        email: req.user.email,
        profile: req.profile,
      },
    });
  }
}

module.exports = new AuthController();
