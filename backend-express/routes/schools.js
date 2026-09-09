const express = require('express');
const { School } = require('../models');
const router = express.Router();

const RWANDAN_DISTRICTS = [
  'Gasabo', 'Kicukiro', 'Nyarugenge', 'Rwamagana', 'Muhanga',
  'Huye', 'Nyamagabe', 'Gisagara', 'Nyagatare', 'Gatsibo',
  'Kayonza', 'Kirehe', 'Ngoma', 'Bugesera', 'Nyanza',
  'Nyaruguru', 'Ruhango', 'Kamonyi', 'Musanze', 'Burera',
  'Gakenke', 'Gicumbi', 'Rulindo', 'Karongi', 'Ngororero',
  'Nyabihu', 'Rubavu', 'Rusizi', 'Nyamasheke',
];

router.get('/schools', async (req, res) => {
  try {
    const schools = await School.find({ active: true, country: { $regex: /^rwanda$/i } }).sort({ name: 1 });
    return res.json(schools.map(s => ({ id: s._id, name: s.name, district: s.district })));
  } catch (err) {
    return res.status(500).json({ detail: 'Could not load schools' });
  }
});

router.get('/districts', async (req, res) => {
  try {
    const dbDistricts = await School.find({ country: { $regex: /^rwanda$/i } }).distinct('district');
    const all = new Set([...RWANDAN_DISTRICTS, ...dbDistricts.filter(d => d)]);
    return res.json([...all].sort());
  } catch (err) {
    return res.status(500).json({ detail: 'Could not load districts' });
  }
});

module.exports = router;
