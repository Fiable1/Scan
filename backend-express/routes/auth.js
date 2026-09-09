const express = require('express');
const bcrypt = require('bcryptjs');
const { User, Librarian, School } = require('../models');
const { generateToken } = require('../middleware/auth');
const router = express.Router();

router.post('/register', async (req, res) => {
  try {
    const { full_name, email, phone, password, district, school_name } = req.body;
    if (!full_name || !email || !password || !school_name) {
      return res.status(400).json({ detail: 'full_name, email, password, and school_name are required.' });
    }
    const existing = await User.findOne({ email: email.toLowerCase() });
    if (existing) {
      return res.status(400).json({ detail: { email: 'Already registered.' } });
    }
    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(password, salt);
    const user = await User.create({
      email: email.toLowerCase(),
      password: hashedPassword,
      fullName: full_name,
    });
    let school = await School.findOne({ name: school_name.trim() });
    if (!school) {
      school = await School.create({
        name: school_name.trim(),
        district: (district || '').trim(),
        country: 'Rwanda',
        active: true,
      });
    }
    const librarian = await Librarian.create({
      user: user._id,
      school: school._id,
      phone: phone || '',
    });
    const token = generateToken(user._id);
    return res.status(201).json({
      token,
      librarian: user.fullName,
      school: school.name,
      district: school.district,
    });
  } catch (err) {
    console.error('Register error:', err);
    return res.status(500).json({ detail: 'Server error during registration.' });
  }
});

router.post('/login', async (req, res) => {
  try {
    const { email, password } = req.body;
    if (!email || !password) {
      return res.status(400).json({ detail: 'Email and password are required.' });
    }
    const user = await User.findOne({ email: email.toLowerCase() });
    if (!user) {
      return res.status(400).json({ detail: 'Invalid email or password.' });
    }
    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      return res.status(400).json({ detail: 'Invalid email or password.' });
    }
    const profile = await Librarian.findOne({ user: user._id }).populate('school');
    if (!profile) {
      return res.status(403).json({ detail: 'This account is not a registered librarian.' });
    }
    const token = generateToken(user._id);
    return res.json({
      token,
      librarian: user.fullName,
      school: profile.school.name,
    });
  } catch (err) {
    console.error('Login error:', err);
    return res.status(500).json({ detail: 'Server error during login.' });
  }
});

router.post('/logout', async (req, res) => {
  return res.status(204).send();
});

module.exports = router;
