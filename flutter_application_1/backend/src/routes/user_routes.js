const express = require('express');
const router = express.Router();
const userController = require('../controllers/user_controller');
const { authMiddleware } = require('../middlewares/auth_middleware');

/**
 * @route   GET /users/unassigned
 * @desc    Get workers not assigned to any site
 * @access  Private
 */
router.get(
    '/unassigned',
    authMiddleware,
    userController.getUnassignedWorkers,
);

/**
 * @route   GET /users/site-coordinators
 * @desc    Get all site coordinators (admin only)
 * @access  Private
 */
router.get(
    '/site-coordinators',
    authMiddleware,
    userController.getSiteCoordinators,
);

/**
 * @route   GET /users/my-site-assignment
 * @desc    Get current user's site assignment
 * @access  Private
 */
router.get(
    '/my-site-assignment',
    authMiddleware,
    userController.getMyCurrentSiteAssignment,
);

module.exports = router;
