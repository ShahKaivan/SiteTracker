const authService = require('../services/auth_service');
const { sendSuccess, sendError, sendValidationError } = require('../utils/response');

/**
 * Register a new user
 * POST /auth/register
 * Body: { full_name?: string, country_code: string, mobile_number: string, password: string, role?: string, profile_image?: file }
 */
const register = async (req, res) => {
  try {
    const { full_name, country_code, mobile_number, password, role } = req.body;

    // Validation
    const errors = {};
    if (!country_code) errors.country_code = 'Country code is required';
    if (!mobile_number) errors.mobile_number = 'Mobile number is required';
    if (!password) {
      errors.password = 'Password is required';
    } else if (password.length < 6) {
      errors.password = 'Password must be at least 6 characters long';
    }

    if (Object.keys(errors).length > 0) {
      return sendValidationError(res, errors);
    }

    // Handle profile image if uploaded
    let profile_image_url = null;
    if (req.file) {
      // Construct the URL for the uploaded file
      profile_image_url = `/uploads/${req.file.filename}`;
    }

    // Call service
    const result = await authService.register(
      full_name,
      country_code,
      mobile_number,
      password,
      role,
      profile_image_url
    );

    if (!result.success) {
      return sendError(res, result.message, 400);
    }

    return sendSuccess(res, {
      user: result.user,
    }, result.message);
  } catch (error) {
    console.error('Error in register controller:', error);
    return sendError(res, 'Internal server error', 500);
  }
};

/**
 * Login with mobile number and password
 * POST /auth/login
 * Body: { mobile_number: string, password: string, country_code?: string }
 */
const login = async (req, res) => {
  try {
    const { mobile_number, password, country_code } = req.body;

    // Validation
    const errors = {};
    if (!mobile_number) errors.mobile_number = 'Mobile number is required';
    if (!password) errors.password = 'Password is required';

    if (Object.keys(errors).length > 0) {
      return sendValidationError(res, errors);
    }

    // Call service
    const result = await authService.login(mobile_number, password, country_code);

    if (!result.success) {
      return sendError(res, result.message, 401);
    }

    return sendSuccess(res, {
      token: result.token,
      user: result.user,
    }, result.message);
  } catch (error) {
    console.error('Error in login controller:', error);
    return sendError(res, 'Internal server error', 500);
  }
};

module.exports = {
  register,
  login,
};
