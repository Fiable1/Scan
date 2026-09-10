const express = require('express');
const multer = require('multer');
const path = require('path');
const fs = require('fs');
const os = require('os');
const ExcelJS = require('exceljs');
const { BookScan, BookCatalog } = require('../models');
const { authMiddleware, getLibrarianProfile } = require('../middleware/auth');
const router = express.Router();

const uploadDir = path.join(os.tmpdir(), 'covers');
fs.mkdirSync(uploadDir, { recursive: true });

const storage = multer.diskStorage({
  destination: (req, file, cb) => cb(null, uploadDir),
  filename: (req, file, cb) => {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    cb(null, uniqueSuffix + path.extname(file.originalname));
  },
});
const upload = multer({
  storage,
  limits: { fileSize: 10 * 1024 * 1024 },
  fileFilter: (req, file, cb) => {
    const allowed = /jpeg|jpg|png|gif|webp/;
    const ext = allowed.test(path.extname(file.originalname).toLowerCase());
    const mime = allowed.test(file.mimetype);
    cb(null, ext && mime);
  },
});

router.post('/scans', authMiddleware, upload.single('cover'), async (req, res) => {
  try {
    const { userId } = req;
    const profile = await getLibrarianProfile(userId);
    if (!profile || !profile.profile) {
      return res.status(403).json({ detail: 'Librarian profile not found.' });
    }
    const data = req.body;
    const code = (data.code || '').trim();

    let matchedCatalog = false;
    let catalog = await BookCatalog.findOne({ code: { $regex: new RegExp(`^${code}$`, 'i') } });
    if (!catalog) {
      catalog = await BookCatalog.findOne({ isbn: { $regex: new RegExp(`^${code}$`, 'i') } });
    }
    if (catalog) {
      matchedCatalog = true;
      for (const field of ['title', 'author', 'grade', 'category', 'isbn', 'publisher', 'language']) {
        if (!data[field] || data[field].trim() === '') {
          data[field] = catalog[field];
        }
      }
    }

    const scanData = {
      code,
      title: data.title || '',
      author: data.author || '',
      grade: data.grade || '',
      category: data.category || '',
      isbn: data.isbn || '',
      publisher: data.publisher || '',
      language: data.language || '',
      cover: req.file ? `/media/covers/${req.file.filename}` : null,
      matchedCatalog,
      school: profile.profile.school,
      librarian: profile.profile._id,
    };

    const scan = await BookScan.create(scanData);

    return res.status(201).json({
      id: scan._id,
      code: scan.code,
      title: scan.title,
      author: scan.author,
      grade: scan.grade,
      category: scan.category,
      isbn: scan.isbn,
      publisher: scan.publisher,
      language: scan.language,
      cover_url: scan.cover,
      matched_catalog: scan.matchedCatalog,
      school: profile.profile.school.name || profile.profile.school,
      librarian: profile.user.fullName,
      scanned_at: scan.scannedAt,
    });
  } catch (err) {
    console.error('Create scan error:', err);
    return res.status(500).json({ detail: err.message || 'Failed to save scan' });
  }
});

router.get('/scans/list', authMiddleware, async (req, res) => {
  try {
    const { userId } = req;
    const profile = await getLibrarianProfile(userId);
    if (!profile || !profile.profile) {
      return res.status(403).json({ detail: 'Librarian profile not found.' });
    }
    const q = (req.query.q || '').trim();
    let filter = { school: profile.profile.school };
    if (q) {
      filter.$or = [
        { code: { $regex: q, $options: 'i' } },
        { title: { $regex: q, $options: 'i' } },
        { author: { $regex: q, $options: 'i' } },
        { isbn: { $regex: q, $options: 'i' } },
      ];
    }
    const scans = await BookScan.find(filter)
      .populate('school', 'name')
      .populate({ path: 'librarian', populate: { path: 'user', select: 'fullName' } })
      .sort({ scannedAt: -1 });

    return res.json(scans.map(s => ({
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
      school: s.school?.name || '',
      librarian: s.librarian?.user?.fullName || '',
      scanned_at: s.scannedAt,
    })));
  } catch (err) {
    console.error('List scans error:', err);
    return res.status(500).json({ detail: 'Could not load scans' });
  }
});

router.get('/scans/excel', authMiddleware, async (req, res) => {
  try {
    const { userId } = req;
    const profile = await getLibrarianProfile(userId);
    if (!profile || !profile.profile) {
      return res.status(403).json({ detail: 'Librarian profile not found.' });
    }
    const scans = await BookScan.find({ school: profile.profile.school })
      .populate('school', 'name')
      .populate({ path: 'librarian', populate: { path: 'user', select: 'fullName' } })
      .sort({ scannedAt: 1 });

    const workbook = new ExcelJS.Workbook();
    const ws = workbook.addWorksheet('Book Scans');
    ws.columns = [
      { header: 'Title', key: 'title', width: 30 },
      { header: 'Author', key: 'author', width: 25 },
      { header: 'Grade / Level', key: 'grade', width: 18 },
      { header: 'ISBN', key: 'isbn', width: 18 },
      { header: 'Barcode / Code', key: 'code', width: 18 },
      { header: 'Category', key: 'category', width: 18 },
      { header: 'Publisher', key: 'publisher', width: 25 },
      { header: 'Language', key: 'language', width: 15 },
      { header: 'Cover File', key: 'cover', width: 20 },
      { header: 'School', key: 'school', width: 25 },
      { header: 'Librarian', key: 'librarian', width: 25 },
      { header: 'Date Scanned', key: 'dateScanned', width: 15 },
      { header: 'Time Scanned', key: 'timeScanned', width: 15 },
      { header: 'Matched Catalog', key: 'matchedCatalog', width: 18 },
    ];

    for (const scan of scans) {
      const local = new Date(scan.scannedAt);
      ws.addRow({
        title: scan.title,
        author: scan.author,
        grade: scan.grade,
        isbn: scan.isbn,
        code: scan.code,
        category: scan.category,
        publisher: scan.publisher,
        language: scan.language,
        cover: scan.cover || '',
        school: scan.school?.name || '',
        librarian: scan.librarian?.user?.fullName || scan.librarian?.user || '',
        dateScanned: local.toLocaleDateString('en-CA'),
        timeScanned: local.toLocaleTimeString('en-GB'),
        matchedCatalog: scan.matchedCatalog ? 'Yes' : 'No',
      });
    }

    ws.getRow(1).font = { bold: true };
    ws.views = [{ state: 'frozen', ySplit: 1 }];

    const buffer = await workbook.xlsx.writeBuffer();
    const filename = `${(profile.profile.school.name || 'school').replace(/\s+/g, '_')}_book_scans.xlsx`;
    res.setHeader('Content-Type', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
    res.setHeader('Content-Disposition', `attachment; filename="${filename}"`);
    return res.send(buffer);
  } catch (err) {
    console.error('Excel error:', err);
    return res.status(500).json({ detail: 'Failed to generate Excel' });
  }
});

module.exports = router;
