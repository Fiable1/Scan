require('dotenv').config();
const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const path = require('path');

const authRoutes = require('./routes/auth');
const schoolRoutes = require('./routes/schools');
const bookRoutes = require('./routes/books');
const scanRoutes = require('./routes/scans');
const analyticsRoutes = require('./routes/analytics');

const app = express();
const PORT = process.env.PORT || 5000;
const MONGODB_URI = process.env.MONGODB_URI || 'mongodb://localhost:27017/rwanda_school_book_scanner';

app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use('/media', express.static(path.join(__dirname, 'media')));

app.get('/api/', (req, res) => {
  res.json({ name: 'Rwanda School Book Scanner API', status: 'online' });
});

app.use('/api/auth', authRoutes);
app.use('/api', schoolRoutes);
app.use('/api', bookRoutes);
app.use('/api', scanRoutes);
app.use('/api', analyticsRoutes);

mongoose.connect(MONGODB_URI)
  .then(async () => {
    console.log('Connected to MongoDB');
    await seedCatalog();
    app.listen(PORT, () => {
      console.log(`Server running on port ${PORT}`);
    });
  })
  .catch(err => {
    console.error('MongoDB connection error:', err);
    process.exit(1);
  });

async function seedCatalog() {
  const { BookCatalog } = require('./models');
  const count = await BookCatalog.countDocuments();
  if (count > 0) return;
  const catalog = [
    { code: '9780199386429', title: 'New Oxford Primary Mathematics 6', author: 'Various', grade: 'Primary 6', category: 'Mathematics', isbn: '9780199386429', publisher: 'Oxford University Press', language: 'English' },
    { code: '9780582312104', title: 'Longman English Workbook 6', author: 'Pearson', grade: 'Primary 6', category: 'English', isbn: '9780582312104', publisher: 'Pearson', language: 'English' },
    { code: '9780435892258', title: 'Integrated Science Learner Book 6', author: 'REB', grade: 'Primary 6', category: 'Science', isbn: '9780435892258', publisher: 'REB', language: 'English' },
    { code: '9780999577302', title: 'Indimu yose 6', author: 'REB', grade: 'Primary 6', category: 'Kinyarwanda', isbn: '9780999577302', publisher: 'REB', language: 'Kinyarwanda' },
    { code: '9780198390022', title: 'Social Studies Learner Book 6', author: 'Longman', grade: 'Primary 6', category: 'Social Studies', isbn: '9780198390022', publisher: 'Longman', language: 'English' },
    { code: '9780582312098', title: 'New Longman Science for Primary 5', author: 'Longman', grade: 'Primary 5', category: 'Science', isbn: '9780582312098', publisher: 'Longman', language: 'English' },
    { code: '9780199386415', title: 'Oxford English for Primary 4', author: 'Oxford University Press', grade: 'Primary 4', category: 'English', isbn: '9780199386415', publisher: 'Oxford University Press', language: 'English' },
    { code: '9781408846266', title: 'Grade 6 Mathematics Pupils Book', author: 'REB', grade: 'Primary 6', category: 'Mathematics', isbn: '9781408846266', publisher: 'REB', language: 'English' },
  ];
  await BookCatalog.insertMany(catalog);
  console.log(`${catalog.length} catalog entries seeded.`);
}
