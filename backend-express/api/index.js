require('dotenv').config();
const app = require('../server');
const connectDB = require('../db');

module.exports = async function handler(req, res) {
  try {
    await connectDB();
  } catch (err) {
    console.error('Database connection failed:', err.message || err);
    return res.status(500).json({ detail: 'Database connection failed', error: err.message });
  }
  return app(req, res);
};