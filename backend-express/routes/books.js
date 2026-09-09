const express = require('express');
const { BookCatalog } = require('../models');
const { authMiddleware } = require('../middleware/auth');
const router = express.Router();

router.get('/books/lookup', authMiddleware, async (req, res) => {
  try {
    const code = (req.query.code || '').trim();
    if (!code) {
      return res.status(400).json({ detail: 'code is required' });
    }
    let book = await BookCatalog.findOne({ code: { $regex: new RegExp(`^${code}$`, 'i') } });
    if (!book) {
      book = await BookCatalog.findOne({ isbn: { $regex: new RegExp(`^${code}$`, 'i') } });
    }
    if (!book) {
      return res.json({ matched: false, code });
    }
    return res.json({
      matched: true,
      code,
      title: book.title,
      author: book.author,
      grade: book.grade,
      category: book.category,
      isbn: book.isbn,
      publisher: book.publisher,
      language: book.language,
    });
  } catch (err) {
    console.error('Lookup error:', err);
    return res.status(500).json({ detail: 'Lookup failed' });
  }
});

module.exports = router;
