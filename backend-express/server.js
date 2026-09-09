require('dotenv').config();
const express = require('express');
const cors = require('cors');
const path = require('path');
const os = require('os');

const authRoutes = require('./routes/auth');
const schoolRoutes = require('./routes/schools');
const bookRoutes = require('./routes/books');
const scanRoutes = require('./routes/scans');
const analyticsRoutes = require('./routes/analytics');

const app = express();
const PORT = process.env.PORT || 5000;

app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Best-effort serving of uploaded covers from the ephemeral temp dir.
app.use('/media/covers', express.static(path.join(os.tmpdir(), 'covers')));
app.use('/media', express.static(path.join(__dirname, 'media')));

app.get('/api/', (req, res) => {
  res.json({ name: 'Rwanda School Book Scanner API', status: 'online' });
});

app.use('/api/auth', authRoutes);
app.use('/api', schoolRoutes);
app.use('/api', bookRoutes);
app.use('/api', scanRoutes);
app.use('/api', analyticsRoutes);

if (require.main === module) {
  const connectDB = require('./db');
  connectDB()
    .then(() => {
      app.listen(PORT, () => {
        console.log(`Server running on port ${PORT}`);
      });
    })
    .catch(err => {
      console.error('MongoDB connection error:', err);
      process.exit(1);
    });
}

module.exports = app;