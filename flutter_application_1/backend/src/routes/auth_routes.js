const express = require('express');
const router = express.Router();
const authController = require('../controllers/auth_controller');
const { authMiddleware } = require('../middlewares/auth_middleware');
const { uploadProfileImage, handleUploadError } = require('../middlewares/upload_middleware');

/**
 * @route   POST /auth/register
 * @desc    Register a new user (for admin)
 * @access  Public
 * @body    { full_name?: string, country_code: string, mobile_number: string, password: string, role?: string, profile_image?: file }
 */
router.post('/register', uploadProfileImage, handleUploadError, authController.register);

/**
 * @route   POST /auth/login
 * @desc    Login with mobile number and password
 * @access  Public
 * @body    { mobile_number: string, password: string, country_code?: string }
 */
router.post('/login', authController.login);

/**
 * @route   GET /auth/me
 * @desc    Get current authenticated user
 * @access  Private
 */
router.get('/me', authMiddleware, (req, res) => {
  const { sendSuccess } = require('../utils/response');
  return sendSuccess(res, { user: req.user }, 'User retrieved successfully');
});

module.exports = router;
