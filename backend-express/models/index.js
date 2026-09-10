const mongoose = require('mongoose');

const schoolSchema = new mongoose.Schema({
  name: { type: String, required: true, unique: true },
  district: { type: String, default: '' },
  country: { type: String, default: 'Rwanda' },
  active: { type: Boolean, default: true },
});

const userSchema = new mongoose.Schema({
  email: { type: String, required: true, unique: true, lowercase: true },
  password: { type: String, required: true },
  fullName: { type: String, required: true },
}, { timestamps: true });

const librarianSchema = new mongoose.Schema({
  user: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true, unique: true },
  school: { type: mongoose.Schema.Types.ObjectId, ref: 'School', required: true },
  phone: { type: String, default: '' },
  verified: { type: Boolean, default: true },
});

const bookCatalogSchema = new mongoose.Schema({
  code: { type: String, required: true, unique: true },
  title: { type: String, required: true },
  author: { type: String, default: '' },
  grade: { type: String, default: '' },
  category: { type: String, default: '' },
  isbn: { type: String, default: '' },
  publisher: { type: String, default: '' },
  language: { type: String, default: '' },
});

const bookScanSchema = new mongoose.Schema({
  code: { type: String, required: true, index: true },
  title: { type: String, default: '' },
  author: { type: String, default: '' },
  grade: { type: String, default: '' },
  category: { type: String, default: '' },
  isbn: { type: String, default: '' },
  publisher: { type: String, default: '' },
  language: { type: String, default: '' },
  cover: { type: String, default: null },
  matchedCatalog: { type: Boolean, default: false },
  school: { type: mongoose.Schema.Types.ObjectId, ref: 'School', required: true },
  librarian: { type: mongoose.Schema.Types.ObjectId, ref: 'Librarian', required: true },
  scannedAt: { type: Date, default: Date.now, index: true },
});

const School = mongoose.model('School', schoolSchema);
const User = mongoose.model('User', userSchema);
const Librarian = mongoose.model('Librarian', librarianSchema);
const BookCatalog = mongoose.model('BookCatalog', bookCatalogSchema);
const BookScan = mongoose.model('BookScan', bookScanSchema);

module.exports = { School, User, Librarian, BookCatalog, BookScan };
