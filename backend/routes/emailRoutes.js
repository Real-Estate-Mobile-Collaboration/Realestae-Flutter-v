const express = require('express');
const router = express.Router();
const { protect } = require('../middleware/auth');
const {
  sendVerificationCode,
  verifyEmail,
  requestPasswordReset,
  resetPassword,
  resendVerificationCode
} = require('../controllers/emailController');

// Email verification routes (require auth)
router.post('/send-verification', protect, sendVerificationCode);
router.post('/verify-email', protect, verifyEmail);
router.post('/resend-verification', protect, resendVerificationCode);

// Password reset routes (no auth required)
router.post('/request-reset', requestPasswordReset);
router.post('/reset-password', resetPassword);

module.exports = router;
