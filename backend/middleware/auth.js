const jwt = require('jsonwebtoken');
const { User, Librarian } = require('../models');

const JWT_SECRET = process.env.JWT_SECRET || 'change-this-secret';

function authMiddleware(req, res, next) {
  const authHeader = req.headers.authorization;
  if (!authHeader || !authHeader.startsWith('Token ')) {
    return res.status(401).json({ detail: 'Authentication required.' });
  }
  const token = authHeader.split(' ')[1];
  try {
    const decoded = jwt.verify(token, JWT_SECRET);
    req.userId = decoded.userId;
    next();
  } catch (err) {
    return res.status(401).json({ detail: 'Invalid or expired token.' });
  }
}

function generateToken(userId) {
  return jwt.sign({ userId }, JWT_SECRET, { expiresIn: '365d' });
}

async function getLibrarianProfile(userId) {
  const user = await User.findById(userId);
  if (!user) return null;
  const profile = await Librarian.findOne({ user: userId }).populate('school');
  return { user, profile };
}

module.exports = { authMiddleware, generateToken, getLibrarianProfile };
