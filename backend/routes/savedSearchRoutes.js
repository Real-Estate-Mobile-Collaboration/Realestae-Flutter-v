const express = require('express');
const router = express.Router();
const { protect } = require('../middleware/auth');
const {
  getSavedSearches,
  createSavedSearch,
  updateSavedSearch,
  deleteSavedSearch,
  getMatchingProperties
} = require('../controllers/savedSearchController');

router.use(protect);

router.route('/')
  .get(getSavedSearches)
  .post(createSavedSearch);

router.route('/:id')
  .put(updateSavedSearch)
  .delete(deleteSavedSearch);

router.get('/:id/properties', getMatchingProperties);

module.exports = router;
