const express = require('express');
const router = express.Router();
const siteController = require('../controllers/site_controller');
const { authMiddleware } = require('../middlewares/auth_middleware');

/**
 * @route   GET /sites/all
 * @desc    Get all sites (admin only)
 * @access  Private
 */
router.get(
    '/all',
    authMiddleware,
    siteController.getAllSites,
);

/**
 * @route   GET /sites/my
 * @desc    Get sites assigned to the authenticated user
 * @access  Private
 */
router.get(
    '/my',
    authMiddleware,
    siteController.getMySites,
);

/**
 * @route   GET /sites/:id/workers
 * @desc    Get workers assigned to a specific site
 * @access  Private
 */
router.get(
    '/:id/workers',
    authMiddleware,
    siteController.getWorkersBySite,
);

/**
 * @route   POST /sites/:id/assign-worker
 * @desc    Assign a worker to a specific site
 * @access  Private
 */
router.post(
    '/:id/assign-worker',
    authMiddleware,
    siteController.assignWorkerToSite,
);

/**
 * @route   DELETE /sites/:siteId/workers/:workerId
 * @desc    Remove a worker from a specific site
 * @access  Private
 */
router.delete(
    '/:siteId/workers/:workerId',
    authMiddleware,
    siteController.removeWorkerFromSite,
);

/**
 * @route   POST /sites/create
 * @desc    Create a new site (admin only)
 * @access  Private
 */
router.post(
    '/create',
    authMiddleware,
    siteController.createSite,
);

/**
 * @route   GET /sites/without-coordinator
 * @desc    Get sites without a site coordinator assigned (admin only)
 * @access  Private
 */
router.get(
    '/without-coordinator',
    authMiddleware,
    siteController.getSitesWithoutCoordinator,
);

/**
 * @route   POST /sites/:id/assign-coordinator
 * @desc    Assign a site coordinator to a specific site (admin only)
 * @access  Private
 */
router.post(
    '/:id/assign-coordinator',
    authMiddleware,
    siteController.assignCoordinatorToSite,
);

module.exports = router;
