const express = require('express');
const { BookScan } = require('../models');
const { authMiddleware, getLibrarianProfile } = require('../middleware/auth');
const router = express.Router();

router.get('/analytics', authMiddleware, async (req, res) => {
  try {
    const { userId } = req;
    const profile = await getLibrarianProfile(userId);
    if (!profile || !profile.profile) {
      return res.status(403).json({ detail: 'Librarian profile not found.' });
    }
    const schoolId = profile.profile.school;
    const qs = BookScan.find({ school: schoolId });

    const today = new Date();
    today.setHours(0, 0, 0, 0);
    const tomorrow = new Date(today);
    tomorrow.setDate(tomorrow.getDate() + 1);

    const [totalBooks, todayCount, matchedCount, unmatchedCount, byCategory, byGrade, recentScans] = await Promise.all([
      BookScan.countDocuments({ school: schoolId }),
      BookScan.countDocuments({ school: schoolId, scannedAt: { $gte: today, $lt: tomorrow } }),
      BookScan.countDocuments({ school: schoolId, matchedCatalog: true }),
      BookScan.countDocuments({ school: schoolId, matchedCatalog: false }),
      BookScan.aggregate([
        { $match: { school: schoolId } },
        { $group: { _id: { $cond: [{ $eq: ['$category', ''] }, 'Others', '$category'] }, total: { $sum: 1 } } },
        { $sort: { total: -1 } },
      ]),
      BookScan.aggregate([
        { $match: { school: schoolId } },
        { $group: { _id: { $cond: [{ $eq: ['$grade', ''] }, 'Unknown', '$grade'] }, total: { $sum: 1 } } },
        { $sort: { total: -1 } },
      ]),
      BookScan.find({ school: schoolId })
        .populate({ path: 'librarian', populate: { path: 'user', select: 'fullName' } })
        .sort({ scannedAt: -1 })
        .limit(3),
    ]);

    return res.json({
      total_books: totalBooks,
      today: todayCount,
      matched: matchedCount,
      unmatched: unmatchedCount,
      by_category: byCategory.map(c => ({ category: c._id, total: c.total })),
      by_grade: byGrade.map(g => ({ grade: g._id, total: g.total })),
      recent_scans: recentScans.map(s => ({
        id: s._id,
        code: s.code,
        title: s.title,
        author: s.author,
        grade: s.grade,
        category: s.category,
        isbn: s.isbn,
        publisher: s.publisher,
        language: s.language,
        cover_url: s.cover,
        matched_catalog: s.matchedCatalog,
        librarian: s.librarian?.user?.fullName || '',
        scanned_at: s.scannedAt,
      })),
    });
  } catch (err) {
    console.error('Analytics error:', err);
    return res.status(500).json({ detail: 'Could not load analytics' });
  }
});

module.exports = router;
