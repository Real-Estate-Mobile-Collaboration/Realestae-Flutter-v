const express = require('express');
const {
  getReviews,
  addReview,
  updateReview,
  deleteReview,
  getMyReviews
} = require('../controllers/reviewController');
const { protect } = require('../middleware/auth');

const router = express.Router();

router.get('/:propertyId', getReviews);
router.post('/:propertyId', protect, addReview);
router.put('/:id', protect, updateReview);
router.delete('/:id', protect, deleteReview);
router.get('/user/me', protect, getMyReviews);

module.exports = router;
