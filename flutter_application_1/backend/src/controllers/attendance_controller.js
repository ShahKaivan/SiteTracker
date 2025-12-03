const attendanceService = require('../services/attendance_service');
const { sendSuccess, sendError, sendValidationError } = require('../utils/response');
const path = require('path');

/**
 * Punch in - Create attendance record
 * POST /attendance/punch-in
 * Multipart form data: photo, lat, lng, user_id, site_id
 */
const punchIn = async (req, res) => {
  try {
    const { lat, lng, user_id, site_id } = req.body;
    const file = req.file;

    // Validation
    const errors = {};

    if (!user_id) {
      errors.user_id = 'User ID is required';
    } else if (user_id !== req.user.id) {
      // Security: Ensure user can only punch in for themselves
      return sendError(res, 'You can only punch in for your own account', 403);
    }

    // site_id is optional for admin users
    if (!site_id && req.user.role !== 'admin') {
      errors.site_id = 'Site ID is required';
    }

    if (!lat) {
      errors.lat = 'Latitude is required';
    } else if (isNaN(parseFloat(lat))) {
      errors.lat = 'Latitude must be a valid number';
    }

    if (!lng) {
      errors.lng = 'Longitude is required';
    } else if (isNaN(parseFloat(lng))) {
      errors.lng = 'Longitude must be a valid number';
    }

    if (!file) {
      errors.photo = 'Selfie photo is required';
    }

    if (Object.keys(errors).length > 0) {
      return sendValidationError(res, errors);
    }

    // Validate latitude and longitude ranges
    const latitude = parseFloat(lat);
    const longitude = parseFloat(lng);

    if (latitude < -90 || latitude > 90) {
      return sendValidationError(res, {
        lat: 'Latitude must be between -90 and 90',
      });
    }

    if (longitude < -180 || longitude > 180) {
      return sendValidationError(res, {
        lng: 'Longitude must be between -180 and 180',
      });
    }

    // Generate selfie URL (in production, upload to cloud storage)
    // For now, use relative path
    const selfieUrl = `/uploads/${file.filename}`;

    // In production, you would upload to S3/Cloudinary/etc and get the URL
    // const selfieUrl = await uploadToCloudStorage(file);

    // Call service
    const result = await attendanceService.punchIn(
      user_id,
      site_id,
      latitude,
      longitude,
      selfieUrl
    );

    if (!result.success) {
      return sendError(res, result.message, 400);
    }

    return sendSuccess(res, {
      attendance: result.attendance,
    }, result.message);
  } catch (error) {
    console.error('Error in punchIn controller:', error);
    return sendError(res, 'Internal server error', 500);
  }
};

/**
 * Punch out - Update attendance record
 * POST /attendance/punch-out
 * Multipart form data: photo, lat, lng, user_id
 */
const punchOut = async (req, res) => {
  try {
    const { lat, lng, user_id } = req.body;
    const file = req.file;

    // Validation
    const errors = {};

    if (!user_id) {
      errors.user_id = 'User ID is required';
    } else if (user_id !== req.user.id) {
      // Security: Ensure user can only punch out for themselves
      return sendError(res, 'You can only punch out for your own account', 403);
    }

    if (!lat) {
      errors.lat = 'Latitude is required';
    } else if (isNaN(parseFloat(lat))) {
      errors.lat = 'Latitude must be a valid number';
    }

    if (!lng) {
      errors.lng = 'Longitude is required';
    } else if (isNaN(parseFloat(lng))) {
      errors.lng = 'Longitude must be a valid number';
    }

    if (!file) {
      errors.photo = 'Selfie photo is required';
    }

    if (Object.keys(errors).length > 0) {
      return sendValidationError(res, errors);
    }

    // Validate latitude and longitude ranges
    const latitude = parseFloat(lat);
    const longitude = parseFloat(lng);

    if (latitude < -90 || latitude > 90) {
      return sendValidationError(res, {
        lat: 'Latitude must be between -90 and 90',
      });
    }

    if (longitude < -180 || longitude > 180) {
      return sendValidationError(res, {
        lng: 'Longitude must be between -180 and 180',
      });
    }

    // Generate selfie URL
    const selfieUrl = `/uploads/${file.filename}`;

    // In production, upload to cloud storage
    // const selfieUrl = await uploadToCloudStorage(file);

    // Call service
    const result = await attendanceService.punchOut(
      user_id,
      latitude,
      longitude,
      selfieUrl
    );

    if (!result.success) {
      return sendError(res, result.message, 400);
    }

    return sendSuccess(res, {
      attendance: result.attendance,
    }, result.message);
  } catch (error) {
    console.error('Error in punchOut controller:', error);
    return sendError(res, 'Internal server error', 500);
  }
};

/**
 * Get attendance records for current user
 * GET /attendance/me?start=YYYY-MM-DD&end=YYYY-MM-DD
 */
const getMyAttendance = async (req, res) => {
  try {
    const { start, end } = req.query;
    const userId = req.user.id; // From auth middleware

    // Default to current month if dates not provided
    const today = new Date();
    let startDate, endDate;

    if (start && end) {
      startDate = new Date(start);
      endDate = new Date(end);

      if (isNaN(startDate.getTime())) {
        return sendValidationError(res, {
          start: 'Invalid start date format. Use YYYY-MM-DD',
        });
      }

      if (isNaN(endDate.getTime())) {
        return sendValidationError(res, {
          end: 'Invalid end date format. Use YYYY-MM-DD',
        });
      }

      if (startDate > endDate) {
        return sendValidationError(res, {
          start: 'Start date must be before or equal to end date',
        });
      }
    } else {
      // Default to current month
      startDate = new Date(today.getFullYear(), today.getMonth(), 1);
      endDate = new Date(today.getFullYear(), today.getMonth() + 1, 0);
    }

    // Call service
    const result = await attendanceService.getAttendanceRecords(
      userId,
      startDate,
      endDate
    );

    return sendSuccess(res, {
      records: result.records,
      count: result.count,
      start_date: startDate.toISOString().split('T')[0],
      end_date: endDate.toISOString().split('T')[0],
    }, 'Attendance records retrieved successfully');
  } catch (error) {
    console.error('Error in getMyAttendance controller:', error);
    return sendError(res, 'Internal server error', 500);
  }
};

/**
 * Get today's punch status
 * GET /attendance/status/today
 */
const getTodayStatus = async (req, res) => {
  try {
    const userId = req.user.id;
    const result = await attendanceService.getTodayStatus(userId);

    if (!result.success) {
      return sendError(res, 'Failed to fetch today\'s attendance status', 400);
    }

    return sendSuccess(res, result.status, 'Today\'s attendance status retrieved');
  } catch (error) {
    console.error('Error in getTodayStatus controller:', error);
    return sendError(res, 'Internal server error', 500);
  }
};

/**
 * Get filtered attendance records
 * GET /attendance/filter?siteId=xxx&workerId=xxx&startDate=YYYY-MM-DD&endDate=YYYY-MM-DD
 */
const getFilteredAttendance = async (req, res) => {
  try {
    const { siteId, workerId, startDate: startStr, endDate: endStr } = req.query;
    const requestingUserId = req.user.id;

    // Validation
    if (!siteId) {
      return sendValidationError(res, { siteId: 'Site ID is required' });
    }
    if (!workerId) {
      return sendValidationError(res, { workerId: 'Worker ID is required' });
    }
    if (!startStr || !endStr) {
      return sendValidationError(res, { date: 'Start date and end date are required' });
    }

    const startDate = new Date(startStr);
    const endDate = new Date(endStr);

    if (isNaN(startDate.getTime())) {
      return sendValidationError(res, { startDate: 'Invalid start date format. Use YYYY-MM-DD' });
    }
    if (isNaN(endDate.getTime())) {
      return sendValidationError(res, { endDate: 'Invalid end date format. Use YYYY-MM-DD' });
    }
    if (startDate > endDate) {
      return sendValidationError(res, { startDate: 'Start date must be before or equal to end date' });
    }

    const result = await attendanceService.getFilteredAttendance(
      siteId,
      workerId,
      startDate,
      endDate,
      requestingUserId
    );

    return sendSuccess(res, {
      records: result.records,
      count: result.count,
      start_date: startDate.toISOString().split('T')[0],
      end_date: endDate.toISOString().split('T')[0],
    }, 'Filtered attendance records retrieved successfully');
  } catch (error) {
    console.error('Error in getFilteredAttendance controller:', error);
    return sendError(res, 'Internal server error', 500);
  }
};

module.exports = {
  punchIn,
  punchOut,
  getMyAttendance,
  getTodayStatus,
  getFilteredAttendance,
};
