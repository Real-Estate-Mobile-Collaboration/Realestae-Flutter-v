const express = require('express');
const router = express.Router();
const { getListingAnalytics, getPropertyAnalytics } = require('../controllers/analyticsController');
const { protect } = require('../middleware/auth');

router.get('/listings', protect, getListingAnalytics);
router.get('/property/:id', protect, getPropertyAnalytics);

module.exports = router;
