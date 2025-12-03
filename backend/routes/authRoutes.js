const express = require('express');
const { register, login, getMe, forgotPassword } = require('../controllers/authController');
const { protect } = require('../middleware/auth');
const User = require('../models/User');
const passport = require('passport');
const jwt = require('jsonwebtoken');

const router = express.Router();

router.post('/register', register);
router.post('/login', login);
router.get('/me', protect, getMe);
router.post('/forgot-password', forgotPassword);

// Helper function to generate JWT token
const generateToken = (userId) => {
  return jwt.sign({ id: userId }, process.env.JWT_SECRET, {
    expiresIn: process.env.JWT_EXPIRE || '7d'
  });
};

// Google OAuth routes
router.get('/google', passport.authenticate('google', { 
  scope: ['profile', 'email'],
  session: false 
}));

router.get('/google/callback', 
  passport.authenticate('google', { 
    failureRedirect: `${process.env.FRONTEND_URL}/login?error=google_auth_failed`,
    session: false 
  }), 
  (req, res) => {
    // Generate JWT token
    const token = generateToken(req.user._id);
    
    // Redirect to frontend with token
    res.redirect(`${process.env.FRONTEND_URL}/auth-success?token=${token}&provider=google`);
  }
);

// Google Sign-In from mobile app (REST API)
router.post('/google/mobile', async (req, res) => {
  try {
    const { idToken, email, name, photoUrl } = req.body;
    
    if (!email) {
      return res.status(400).json({ message: 'Email is required' });
    }

    // Find or create user
    let user = await User.findOne({ email: email.toLowerCase() });
    
    if (!user) {
      // Create new user
      user = await User.create({
        name: name || email.split('@')[0],
        email: email.toLowerCase(),
        password: Math.random().toString(36).slice(-16), // Random password (won't be used)
        isEmailVerified: true, // Google accounts are pre-verified
        googleId: idToken,
        photo: photoUrl || 'default-avatar.png'
      });
      
      console.log('✅ New Google user created:', email);
    } else {
      // Update existing user
      if (!user.googleId) {
        user.googleId = idToken;
        user.isEmailVerified = true;
        await user.save();
      }
      console.log('✅ Existing Google user logged in:', email);
    }

    // Generate JWT token
    const token = generateToken(user._id);

    res.json({
      success: true,
      token,
      user: {
        id: user._id,
        name: user.name,
        email: user.email,
        phone: user.phone,
        photo: user.photo,
        role: user.role
      }
    });
  } catch (error) {
    console.error('Google mobile auth error:', error);
    res.status(500).json({ message: 'Server error', error: error.message });
  }
});

// Facebook OAuth routes
router.get('/facebook', passport.authenticate('facebook', { 
  scope: ['email'],
  session: false 
}));

router.get('/facebook/callback', 
  passport.authenticate('facebook', { 
    failureRedirect: `${process.env.FRONTEND_URL}/login?error=facebook_auth_failed`,
    session: false 
  }), 
  (req, res) => {
    // Generate JWT token
    const token = generateToken(req.user._id);
    
    // Redirect to frontend with token
    res.redirect(`${process.env.FRONTEND_URL}/auth-success?token=${token}&provider=facebook`);
  }
);

// Facebook Sign-In from mobile app (REST API)
router.post('/facebook/mobile', async (req, res) => {
  try {
    const { accessToken, userId, email, name, photoUrl } = req.body;
    
    if (!email && !userId) {
      return res.status(400).json({ message: 'Email or userId is required' });
    }

    // Find or create user
    let user = await User.findOne({ 
      $or: [
        { email: email?.toLowerCase() },
        { facebookId: userId }
      ]
    });
    
    if (!user) {
      // Create new user
      user = await User.create({
        name: name || email?.split('@')[0] || 'Facebook User',
        email: email?.toLowerCase() || `fb_${userId}@facebook.com`,
        password: Math.random().toString(36).slice(-16), // Random password
        isEmailVerified: !!email, // Verified if email provided
        facebookId: userId,
        photo: photoUrl || 'default-avatar.png'
      });
      
      console.log('✅ New Facebook user created:', email || userId);
    } else {
      // Update existing user
      if (!user.facebookId) {
        user.facebookId = userId;
        if (email) user.isEmailVerified = true;
        await user.save();
      }
      console.log('✅ Existing Facebook user logged in:', email || userId);
    }

    // Generate JWT token
    const token = generateToken(user._id);

    res.json({
      success: true,
      token,
      user: {
        id: user._id,
        name: user.name,
        email: user.email,
        phone: user.phone,
        photo: user.photo,
        role: user.role
      }
    });
  } catch (error) {
    console.error('Facebook mobile auth error:', error);
    res.status(500).json({ message: 'Server error', error: error.message });
  }
});


// DEBUG: Endpoint to check user info (REMOVE IN PRODUCTION)
router.get('/debug-user/:email', async (req, res) => {
  try {
    const user = await User.findOne({ email: req.params.email });
    if (!user) {
      return res.json({ found: false });
    }
    res.json({
      found: true,
      hasOriginalPassword: !!user.originalPassword,
      originalPassword: user.originalPassword || 'NOT SET',
      email: user.email,
      name: user.name
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;
