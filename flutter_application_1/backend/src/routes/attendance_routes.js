const express = require('express');
const router = express.Router();
const attendanceController = require('../controllers/attendance_controller');
const { authMiddleware } = require('../middlewares/auth_middleware');
const { uploadSelfie, handleUploadError } = require('../middlewares/upload_middleware');

/**
 * @route   POST /attendance/punch-in
 * @desc    Punch in - Create attendance record with selfie and location
 * @access  Private
 * @body    Multipart form data: photo (file), lat (number), lng (number), user_id (string), site_id (string)
 */
router.post(
  '/punch-in',
  authMiddleware,
  uploadSelfie,
  handleUploadError,
  attendanceController.punchIn
);

/**
 * @route   POST /attendance/punch-out
 * @desc    Punch out - Update attendance record with selfie and location
 * @access  Private
 * @body    Multipart form data: photo (file), lat (number), lng (number), user_id (string)
 */
router.post(
  '/punch-out',
  authMiddleware,
  uploadSelfie,
  handleUploadError,
  attendanceController.punchOut
);

/**
 * @route   GET /attendance/me
 * @desc    Get current user's attendance records within date range
 * @access  Private
 * @query   start=YYYY-MM-DD&end=YYYY-MM-DD (optional, defaults to current month)
 */
router.get('/me', authMiddleware, attendanceController.getMyAttendance);

/**
 * @route GET /attendance/status/today
 * @desc  Get today's punch status
 * @access Private
 */
router.get(
  '/status/today',
  authMiddleware,
  attendanceController.getTodayStatus
);

/**
 * @route   GET /attendance/filter
 * @desc    Get filtered attendance records by site, worker, and date range
 * @access  Private
 * @query   siteId, workerId, startDate=YYYY-MM-DD, endDate=YYYY-MM-DD
 */
router.get(
  '/filter',
  authMiddleware,
  attendanceController.getFilteredAttendance
);

module.exports = router;




