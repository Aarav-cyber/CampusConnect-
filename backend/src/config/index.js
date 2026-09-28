const path = require('path');
require('dotenv').config({ path: path.resolve(__dirname, '../../../.env') });

module.exports = {
  PORT: process.env.PORT || 5000,
  JWT_SECRET: process.env.JWT_SECRET || 'supersecret_campusconnect_jwt_key_2026',
  JWT_EXPIRY: '7d',
};
