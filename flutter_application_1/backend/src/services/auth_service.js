const prisma = require('../config/db');
const { generateToken } = require('../config/jwt');
const bcrypt = require('bcrypt');

const VALID_ROLES = ['worker', 'site_coordinator', 'admin'];

const normalizeRole = (role) => {
  if (!role) return 'worker';
  const sanitizedRole = String(role).trim().toLowerCase();
  return VALID_ROLES.includes(sanitizedRole) ? sanitizedRole : 'worker';
};

/**
 * Register a new user (for admin)
 * @param {String} fullName - Full name
 * @param {String} countryCode - Country code
 * @param {String} mobileNumber - Mobile number
 * @param {String} password - Plain text password
 * @param {String} role - User role
 * @param {String} profileImageUrl - Profile image URL
 * @returns {Object} { success: boolean, message: string, user?: Object }
 */
const register = async (fullName, countryCode, mobileNumber, password, role, profileImageUrl = null) => {
  try {
    // Validate inputs
    if (!countryCode || !mobileNumber || !password) {
      return {
        success: false,
        message: 'Country code, mobile number, and password are required',
      };
    }

    // Validate mobile number format
    const mobileRegex = /^\d{10,15}$/;
    if (!mobileRegex.test(mobileNumber)) {
      return {
        success: false,
        message: 'Invalid mobile number format',
      };
    }

    // Validate password strength
    if (password.length < 6) {
      return {
        success: false,
        message: 'Password must be at least 6 characters long',
      };
    }

    // Check if user already exists
    const existingUser = await prisma.users.findUnique({
      where: {
        country_code_mobile_number: {
          country_code: countryCode,
          mobile_number: mobileNumber,
        },
      },
    });

    if (existingUser) {
      return {
        success: false,
        message: 'User with this mobile number already exists',
      };
    }

    // Hash password
    const saltRounds = 10;
    const passwordHash = await bcrypt.hash(password, saltRounds);

    // Create user
    const user = await prisma.users.create({
      data: {
        country_code: countryCode,
        mobile_number: mobileNumber,
        password_hash: passwordHash,
        full_name: fullName || null,
        role: normalizeRole(role),
        profile_image_url: profileImageUrl,
        // is_mobile_verified: false,
      },
    });

    // Remove sensitive data
    const userData = {
      id: user.id,
      mobile_number: user.mobile_number,
      country_code: user.country_code,
      full_name: user.full_name,
      role: normalizeRole(user.role),
      // is_mobile_verified: user.is_mobile_verified,
      profile_image_url: user.profile_image_url,
      created_at: user.created_at,
    };

    return {
      success: true,
      message: 'User registered successfully',
      user: userData,
    };
  } catch (error) {
    console.error('Error in register:', error);
    return {
      success: false,
      message: 'Failed to register user. Please try again.',
    };
  }
};

/**
 * Login with mobile number and password
 * @param {String} countryCode - Country code
 * @param {String} mobileNumber - Mobile number
 * @param {String} password - Plain text password
 * @returns {Object} { success: boolean, message: string, token?: string, user?: Object }
 */
const login = async (mobileNumber, password, countryCode = null) => {
  try {
    // Validate inputs
    if (!mobileNumber || !password) {
      return {
        success: false,
        message: 'Mobile number and password are required',
      };
    }

    // Find user
    let user = null;

    if (countryCode) {
      user = await prisma.users.findUnique({
        where: {
          country_code_mobile_number: {
            country_code: countryCode,
            mobile_number: mobileNumber,
          },
        },
      });
    }

    if (!user) {
      user = await prisma.users.findFirst({
        where: {
          mobile_number: mobileNumber,
        },
      });
    }

    if (!user) {
      return {
        success: false,
        message: 'Invalid mobile number or password',
      };
    }

    // Check if user has a password
    if (!user.password_hash) {
      return {
        success: false,
        message: 'Password not set. Please contact administrator.',
      };
    }

    // Verify password
    const isPasswordValid = await bcrypt.compare(password, user.password_hash);

    if (!isPasswordValid) {
      return {
        success: false,
        message: 'Invalid mobile number or password',
      };
    }

    // Update last login
    const updatedUser = await prisma.users.update({
      where: {
        id: user.id,
      },
      data: {
        last_login_at: new Date(),
      },
    });

    const effectiveRole = normalizeRole(updatedUser.role);

    // Generate JWT token
    const tokenPayload = {
      id: updatedUser.id,
      mobile_number: updatedUser.mobile_number,
      country_code: updatedUser.country_code,
      role: effectiveRole,
    };

    const token = generateToken(tokenPayload);

    // Remove sensitive data from user object
    const userData = {
      id: updatedUser.id,
      mobile_number: updatedUser.mobile_number,
      country_code: updatedUser.country_code,
      full_name: updatedUser.full_name,
      role: effectiveRole,
      is_mobile_verified: updatedUser.is_mobile_verified,
      profile_image_url: updatedUser.profile_image_url,
      created_at: updatedUser.created_at,
      last_login_at: updatedUser.last_login_at,
    };

    return {
      success: true,
      message: 'Login successful',
      token,
      user: userData,
    };
  } catch (error) {
    console.error('Error in login:', error);
    return {
      success: false,
      message: 'Failed to login. Please try again.',
    };
  }
};

module.exports = {
  register,
  login,
};
