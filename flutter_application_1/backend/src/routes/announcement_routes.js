const express = require('express');
const router = express.Router();
const announcementController = require('../controllers/announcement_controller');
const { authMiddleware } = require('../middlewares/auth_middleware');

/**
 * @route   GET /announcements/my-sites
 * @desc    Get announcements for the worker's sites
 * @access  Private
 */
router.get(
  '/my-sites',
  authMiddleware,
  announcementController.getMySitesAnnouncements,
);

/**
 * @route   POST /announcements/create
 * @desc    Create new announcement (coordinator only)
 * @access  Private
 */
router.post(
  '/create',
  authMiddleware,
  announcementController.createAnnouncement,
);

/**
 * @route   GET /announcements/my
 * @desc    Get announcements created by coordinator
 * @access  Private
 */
router.get(
  '/my',
  authMiddleware,
  announcementController.getMyAnnouncements,
);

/**
 * @route   PATCH /announcements/:id/deactivate
 * @desc    Deactivate an announcement
 * @access  Private
 */
router.patch(
  '/:id/deactivate',
  authMiddleware,
  announcementController.deactivateAnnouncement,
);

module.exports = router;



