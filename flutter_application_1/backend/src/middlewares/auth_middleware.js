const { verifyToken } = require('../config/jwt');
const { sendError } = require('../utils/response');
const prisma = require('../config/db');

/**
 * Authentication middleware to verify JWT token
 * Adds user object to req.user if token is valid
 */
const authMiddleware = async (req, res, next) => {
  try {
    // Get token from Authorization header
    const authHeader = req.headers.authorization;

    if (!authHeader) {
      return sendError(res, 'Authorization header is missing', 401);
    }

    // Extract token from "Bearer <token>"
    const token = authHeader.startsWith('Bearer ')
      ? authHeader.slice(7)
      : authHeader;

    if (!token) {
      return sendError(res, 'Token is missing', 401);
    }

    // Verify token
    let decoded;
    try {
      decoded = verifyToken(token);
    } catch (error) {
      return sendError(res, 'Invalid or expired token', 401);
    }

    // Fetch user from database to ensure user still exists
    const user = await prisma.users.findUnique({
      where: {
        id: decoded.id,
      },
      select: {
        id: true,
        mobile_number: true,
        country_code: true,
        full_name: true,
        role: true,
        // is_mobile_verified: true,
        profile_image_url: true,
        created_at: true,
        last_login_at: true,
      },
    });

    if (!user) {
      return sendError(res, 'User not found', 401);
    }

    // Attach user to request object
    req.user = user;
    req.token = decoded;

    next();
  } catch (error) {
    console.error('Error in auth middleware:', error);
    return sendError(res, 'Authentication failed', 401);
  }
};

/**
 * Optional authentication middleware
 * Doesn't fail if token is missing, but adds user if token is valid
 */
const optionalAuthMiddleware = async (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;

    if (!authHeader) {
      return next();
    }

    const token = authHeader.startsWith('Bearer ')
      ? authHeader.slice(7)
      : authHeader;

    if (!token) {
      return next();
    }

    try {
      const decoded = verifyToken(token);
      const user = await prisma.users.findUnique({
        where: {
          id: decoded.id,
        },
        select: {
          id: true,
          mobile_number: true,
          country_code: true,
          full_name: true,
          role: true,          
          profile_image_url: true,
          created_at: true,
          last_login_at: true,
        },
      });

      if (user) {
        req.user = user;
        req.token = decoded;
      }
    } catch (error) {
      // Ignore token errors for optional auth
    }

    next();
  } catch (error) {
    // Ignore errors for optional auth
    next();
  }
};

module.exports = {
  authMiddleware,
  optionalAuthMiddleware,
};
