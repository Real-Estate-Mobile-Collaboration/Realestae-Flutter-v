const express = require('express');
const {
  getUserProfile,
  updateProfile,
  getMyProperties,
  deleteAccount,
  changePassword,
  updateSettings,
  uploadPhoto
} = require('../controllers/userController');
const { protect } = require('../middleware/auth');
const upload = require('../middleware/upload');

const router = express.Router();

router.get('/:id', getUserProfile);
router.post('/upload-photo', protect, upload.single('photo'), uploadPhoto);
router.put('/profile', protect, upload.single('photo'), updateProfile);
router.put('/change-password', protect, changePassword);
router.put('/settings', protect, updateSettings);
router.get('/my-properties', protect, getMyProperties);
router.delete('/account', protect, deleteAccount);

module.exports = router;
