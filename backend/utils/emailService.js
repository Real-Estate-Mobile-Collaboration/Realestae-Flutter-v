const nodemailer = require('nodemailer');

// Create reusable transporter
const transporter = nodemailer.createTransport({
  service: 'gmail', // You can use other services like 'hotmail', 'yahoo', etc.
  auth: {
    user: process.env.EMAIL_USER, // Your email
    pass: process.env.EMAIL_PASSWORD // Your email password or app password
  }
});

// Send email verification code
exports.sendVerificationEmail = async (email, userName, verificationCode) => {
  const mailOptions = {
    from: `"${process.env.APP_NAME || 'Real Estate App'}" <${process.env.EMAIL_USER}>`,
    to: email,
    subject: 'Verify Your Email Address',
    html: `
      <!DOCTYPE html>
      <html>
      <head>
        <style>
          body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
          .container { max-width: 600px; margin: 0 auto; padding: 20px; }
          .header { background-color: #2C3E50; color: white; padding: 20px; text-align: center; }
          .content { background-color: #f9f9f9; padding: 30px; }
          .code { background-color: #3498DB; color: white; font-size: 32px; font-weight: bold; 
                  padding: 20px; text-align: center; letter-spacing: 5px; margin: 20px 0; }
          .footer { text-align: center; color: #7f8c8d; padding: 20px; font-size: 12px; }
        </style>
      </head>
      <body>
        <div class="container">
          <div class="header">
            <h1>🏠 Welcome to Real Estate App</h1>
          </div>
          <div class="content">
            <h2>Hello ${userName}!</h2>
            <p>Thank you for registering. Please verify your email address to complete your registration.</p>
            <p>Your verification code is:</p>
            <div class="code">${verificationCode}</div>
            <p>This code will expire in 10 minutes.</p>
            <p>If you didn't create an account, please ignore this email.</p>
          </div>
          <div class="footer">
            <p>&copy; ${new Date().getFullYear()} Real Estate App. All rights reserved.</p>
          </div>
        </div>
      </body>
      </html>
    `
  };

  try {
    await transporter.sendMail(mailOptions);
    return { success: true };
  } catch (error) {
    console.error('Email send error:', error);
    return { success: false, error: error.message };
  }
};

// Send password reset email
exports.sendPasswordResetEmail = async (email, userName, resetToken) => {
  const mailOptions = {
    from: `"${process.env.APP_NAME || 'Real Estate App'}" <${process.env.EMAIL_USER}>`,
    to: email,
    subject: 'Password Reset Request',
    html: `
      <!DOCTYPE html>
      <html>
      <head>
        <style>
          body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
          .container { max-width: 600px; margin: 0 auto; padding: 20px; }
          .header { background-color: #2C3E50; color: white; padding: 20px; text-align: center; }
          .content { background-color: #f9f9f9; padding: 30px; }
          .code { background-color: #E74C3C; color: white; font-size: 24px; font-weight: bold; 
                  padding: 15px; text-align: center; margin: 20px 0; letter-spacing: 3px; }
          .footer { text-align: center; color: #7f8c8d; padding: 20px; font-size: 12px; }
          .warning { color: #F39C12; background-color: #FEF5E7; padding: 10px; border-left: 4px solid #F39C12; }
        </style>
      </head>
      <body>
        <div class="container">
          <div class="header">
            <h1>🔐 Password Reset Request</h1>
          </div>
          <div class="content">
            <h2>Hello ${userName}!</h2>
            <p>We received a request to reset your password. Use the code below to reset your password:</p>
            <div class="code">${resetToken}</div>
            <p>This code will expire in 1 hour.</p>
            <div class="warning">
              <strong>⚠️ Security Notice:</strong> If you didn't request a password reset, please ignore this email 
              and make sure your account is secure.
            </div>
          </div>
          <div class="footer">
            <p>&copy; ${new Date().getFullYear()} Real Estate App. All rights reserved.</p>
          </div>
        </div>
      </body>
      </html>
    `
  };

  try {
    await transporter.sendMail(mailOptions);
    return { success: true };
  } catch (error) {
    console.error('Email send error:', error);
    return { success: false, error: error.message };
  }
};

// Send welcome email after verification
exports.sendWelcomeEmail = async (email, userName) => {
  const mailOptions = {
    from: `"${process.env.APP_NAME || 'Real Estate App'}" <${process.env.EMAIL_USER}>`,
    to: email,
    subject: 'Welcome to Real Estate App!',
    html: `
      <!DOCTYPE html>
      <html>
      <head>
        <style>
          body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
          .container { max-width: 600px; margin: 0 auto; padding: 20px; }
          .header { background-color: #27AE60; color: white; padding: 20px; text-align: center; }
          .content { background-color: #f9f9f9; padding: 30px; }
          .feature { margin: 15px 0; padding: 10px; border-left: 4px solid #3498DB; background: white; }
          .footer { text-align: center; color: #7f8c8d; padding: 20px; font-size: 12px; }
        </style>
      </head>
      <body>
        <div class="container">
          <div class="header">
            <h1>🎉 Welcome to Real Estate App!</h1>
          </div>
          <div class="content">
            <h2>Hello ${userName}!</h2>
            <p>Your email has been verified successfully. You can now enjoy all the features of our platform:</p>
            
            <div class="feature">
              <strong>🏘️ Browse Properties</strong> - Discover thousands of properties for sale and rent
            </div>
            <div class="feature">
              <strong>❤️ Save Favorites</strong> - Keep track of properties you love
            </div>
            <div class="feature">
              <strong>💬 Contact Owners</strong> - Message property owners directly
            </div>
            <div class="feature">
              <strong>📝 List Properties</strong> - Publish your own properties
            </div>
            
            <p>Get started by exploring properties in your area!</p>
          </div>
          <div class="footer">
            <p>&copy; ${new Date().getFullYear()} Real Estate App. All rights reserved.</p>
          </div>
        </div>
      </body>
      </html>
    `
  };

  try {
    await transporter.sendMail(mailOptions);
    return { success: true };
  } catch (error) {
    console.error('Email send error:', error);
    return { success: false, error: error.message };
  }
};

// Send password recovery email (legacy support)
exports.sendTemporaryPassword = async (email, userName, password) => {
  const mailOptions = {
    from: process.env.EMAIL_USER,
    to: email,
    subject: 'Your Password',
    html: `
      <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
        <h2 style="color: #333;">Your Login Password</h2>
        <p>Hello ${userName},</p>
        <p>You requested your password. Here is your login password:</p>
        <div style="background-color: #f5f5f5; padding: 20px; border-radius: 8px; margin: 20px 0; text-align: center;">
          <h1 style="color: #4CAF50; font-size: 32px; margin: 0; letter-spacing: 2px; font-family: monospace;">
            ${password}
          </h1>
        </div>
        <p><strong>Important:</strong></p>
        <ul>
          <li>This is your permanent login password</li>
          <li>Use this password to login to your account</li>
          <li>Keep this password secure and don't share it with anyone</li>
          <li>You can change this password from Settings after logging in</li>
        </ul>
        <p>If you didn't request this, please contact us immediately.</p>
        <hr style="margin: 30px 0; border: none; border-top: 1px solid #ddd;">
        <p style="color: #999; font-size: 12px;">This is an automated email, please do not reply.</p>
      </div>
    `
  };

  try {
    await transporter.sendMail(mailOptions);
    return { success: true };
  } catch (error) {
    console.error('Email send error:', error);
    return { success: false, error: error.message };
  }
};

// Send password change confirmation
exports.sendPasswordChangeConfirmation = async (email, userName) => {
  const mailOptions = {
    from: process.env.EMAIL_USER,
    to: email,
    subject: 'Password Changed Successfully',
    html: `
      <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
        <h2 style="color: #333;">Password Changed</h2>
        <p>Hello ${userName},</p>
        <p>Your password has been changed successfully.</p>
        <p>If you didn't make this change, please contact us immediately.</p>
        <hr style="margin: 30px 0; border: none; border-top: 1px solid #ddd;">
        <p style="color: #999; font-size: 12px;">This is an automated email, please do not reply.</p>
      </div>
    `
  };

  try {
    await transporter.sendMail(mailOptions);
    return { success: true };
  } catch (error) {
    console.error('Email send error:', error);
    return { success: false, error: error.message };
  }
};
