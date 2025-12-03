const User = require('../models/User');
const crypto = require('crypto');
const { sendVerificationEmail, sendPasswordResetEmail, sendWelcomeEmail } = require('../utils/emailService');

// Send verification code
exports.sendVerificationCode = async (req, res) => {
  try {
    const user = await User.findById(req.user.id);

    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    if (user.isEmailVerified) {
      return res.status(400).json({ message: 'Email already verified' });
    }

    // Generate 6-digit code
    const verificationCode = Math.floor(100000 + Math.random() * 900000).toString();

    // Hash the code before saving
    const hashedCode = crypto.createHash('sha256').update(verificationCode).digest('hex');

    user.emailVerificationCode = hashedCode;
    user.emailVerificationExpire = Date.now() + 10 * 60 * 1000; // 10 minutes
    await user.save();

    // Send email
    const emailResult = await sendVerificationEmail(user.email, user.name, verificationCode);

    if (!emailResult.success) {
      return res.status(500).json({ 
        message: 'Failed to send verification email',
        error: emailResult.error 
      });
    }

    res.json({
      success: true,
      message: 'Verification code sent to your email'
    });
  } catch (error) {
    console.error('Send verification code error:', error);
    res.status(500).json({ message: 'Server error', error: error.message });
  }
};

// Verify email with code
exports.verifyEmail = async (req, res) => {
  try {
    const { code } = req.body;

    if (!code) {
      return res.status(400).json({ message: 'Please provide verification code' });
    }

    const user = await User.findById(req.user.id);

    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    if (user.isEmailVerified) {
      return res.status(400).json({ message: 'Email already verified' });
    }

    // Hash the provided code
    const hashedCode = crypto.createHash('sha256').update(code).digest('hex');

    // Check if code matches and is not expired
    if (user.emailVerificationCode !== hashedCode) {
      return res.status(400).json({ message: 'Invalid verification code' });
    }

    if (user.emailVerificationExpire < Date.now()) {
      return res.status(400).json({ message: 'Verification code has expired' });
    }

    // Verify email
    user.isEmailVerified = true;
    user.emailVerificationCode = undefined;
    user.emailVerificationExpire = undefined;
    await user.save();

    // Send welcome email
    await sendWelcomeEmail(user.email, user.name);

    res.json({
      success: true,
      message: 'Email verified successfully',
      user: {
        id: user._id,
        name: user.name,
        email: user.email,
        isEmailVerified: user.isEmailVerified
      }
    });
  } catch (error) {
    console.error('Verify email error:', error);
    res.status(500).json({ message: 'Server error', error: error.message });
  }
};

// Request password reset
exports.requestPasswordReset = async (req, res) => {
  try {
    const { email } = req.body;

    console.log('📧 Password reset request for:', email);

    if (!email) {
      return res.status(400).json({ message: 'Please provide email address' });
    }

    const user = await User.findOne({ email: email.toLowerCase() });

    if (!user) {
      console.log('⚠️  User not found for email:', email);
      // Don't reveal if user exists or not
      return res.json({
        success: true,
        message: 'If an account exists with that email, a password reset code has been sent'
      });
    }

    // Generate 6-digit reset code
    const resetCode = Math.floor(100000 + Math.random() * 900000).toString();
    console.log('🔑 Generated reset code:', resetCode, 'for user:', user.name);

    // Hash the code before saving
    const hashedCode = crypto.createHash('sha256').update(resetCode).digest('hex');

    user.resetPasswordToken = hashedCode;
    user.resetPasswordExpire = Date.now() + 60 * 60 * 1000; // 1 hour
    await user.save();

    console.log('💾 Reset code saved to database');

    // Send email
    console.log('📮 Sending password reset email to:', user.email);
    const emailResult = await sendPasswordResetEmail(user.email, user.name, resetCode);

    if (!emailResult.success) {
      console.error('❌ Failed to send email:', emailResult.error);
      return res.status(500).json({ 
        message: 'Failed to send reset email',
        error: emailResult.error 
      });
    }

    console.log('✅ Password reset email sent successfully to:', user.email);

    res.json({
      success: true,
      message: 'Password reset code sent to your email'
    });
  } catch (error) {
    console.error('Request password reset error:', error);
    res.status(500).json({ message: 'Server error', error: error.message });
  }
};

// Reset password with code
exports.resetPassword = async (req, res) => {
  try {
    const { email, code, newPassword } = req.body;

    if (!email || !code || !newPassword) {
      return res.status(400).json({ message: 'Please provide email, code, and new password' });
    }

    console.log('🔐 Reset password attempt for:', email);
    console.log('📝 Code provided:', code);

    if (newPassword.length < 6) {
      return res.status(400).json({ message: 'Password must be at least 6 characters' });
    }

    const user = await User.findOne({ email: email.toLowerCase() }).select('+password');

    if (!user) {
      console.log('❌ User not found for email:', email);
      return res.status(404).json({ message: 'Invalid reset code or email' });
    }

    // Hash the provided code
    const hashedCode = crypto.createHash('sha256').update(code).digest('hex');

    // Check if code matches and is not expired
    if (user.resetPasswordToken !== hashedCode) {
      console.log('❌ Invalid reset code for user:', user.name);
      return res.status(400).json({ message: 'Invalid reset code' });
    }

    if (user.resetPasswordExpire < Date.now()) {
      console.log('⏰ Reset code expired for user:', user.name);
      return res.status(400).json({ message: 'Reset code has expired' });
    }

    console.log('✅ Reset code validated for user:', user.name);

    // Update password
    user.password = newPassword;
    user.resetPasswordToken = undefined;
    user.resetPasswordExpire = undefined;
    await user.save();

    console.log('✅ Password reset successfully for user:', user.name);

    res.json({
      success: true,
      message: 'Password reset successfully. You can now login with your new password'
    });
  } catch (error) {
    console.error('Reset password error:', error);
    res.status(500).json({ message: 'Server error', error: error.message });
  }
};

// Resend verification code
exports.resendVerificationCode = async (req, res) => {
  try {
    const user = await User.findById(req.user.id);

    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    if (user.isEmailVerified) {
      return res.status(400).json({ message: 'Email already verified' });
    }

    // Check if too soon to resend (rate limiting)
    if (user.emailVerificationExpire && user.emailVerificationExpire > Date.now()) {
      const remainingTime = Math.ceil((user.emailVerificationExpire - Date.now()) / 1000 / 60);
      return res.status(429).json({ 
        message: `Please wait ${remainingTime} minutes before requesting a new code` 
      });
    }

    // Generate new code
    const verificationCode = Math.floor(100000 + Math.random() * 900000).toString();
    const hashedCode = crypto.createHash('sha256').update(verificationCode).digest('hex');

    user.emailVerificationCode = hashedCode;
    user.emailVerificationExpire = Date.now() + 10 * 60 * 1000;
    await user.save();

    // Send email
    const emailResult = await sendVerificationEmail(user.email, user.name, verificationCode);

    if (!emailResult.success) {
      return res.status(500).json({ 
        message: 'Failed to send verification email',
        error: emailResult.error 
      });
    }

    res.json({
      success: true,
      message: 'New verification code sent to your email'
    });
  } catch (error) {
    console.error('Resend verification code error:', error);
    res.status(500).json({ message: 'Server error', error: error.message });
  }
};
