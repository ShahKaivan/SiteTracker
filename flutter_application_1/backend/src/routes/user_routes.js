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

module.exports = router;
