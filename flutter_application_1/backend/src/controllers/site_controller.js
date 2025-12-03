const siteService = require('../services/site_service');
const userService = require('../services/user_service');
const { sendSuccess, sendError } = require('../utils/response');

/**
 * GET /sites/my
 * Returns sites assigned to the authenticated user
 */
const getMySites = async (req, res) => {
    try {
        const userId = req.user.id;

        const sites = await siteService.getSitesForUser(userId);

        return sendSuccess(
            res,
            { sites },
            'Sites retrieved successfully',
        );
    } catch (error) {
        console.error('Error in getMySites:', error);
        return sendError(res, 'Failed to fetch sites', 500);
    }
};

/**
 * GET /sites/:id/workers
 * Returns workers assigned to a specific site
 */
const getWorkersBySite = async (req, res) => {
    try {
        const { id } = req.params;

        const workers = await userService.getUsersBySite(id);

        return sendSuccess(
            res,
            { workers },
            'Workers retrieved successfully',
        );
    } catch (error) {
        console.error('Error in getWorkersBySite:', error);
        return sendError(res, 'Failed to fetch workers', 500);
    }
};

/**
 * POST /sites/:id/assign-worker
 * Assign a worker to a specific site
 */
const assignWorkerToSite = async (req, res) => {
    try {
        const { id: siteId } = req.params;
        const { workerId } = req.body;

        if (!workerId) {
            return sendError(res, 'Worker ID is required', 400);
        }

        const assignment = await siteService.assignWorkerToSite(siteId, workerId);

        return sendSuccess(
            res,
            { assignment },
            'Worker assigned to site successfully',
        );
    } catch (error) {
        console.error('Error in assignWorkerToSite:', error);

        if (error.message === 'Worker is already assigned to this site') {
            return sendError(res, error.message, 400);
        }

        return sendError(res, 'Failed to assign worker to site', 500);
    }
};

/**
 * DELETE /sites/:siteId/workers/:workerId
 * Remove a worker from a specific site
 */
const removeWorkerFromSite = async (req, res) => {
    try {
        const { siteId, workerId } = req.params;

        const result = await siteService.removeWorkerFromSite(siteId, workerId);

        return sendSuccess(
            res,
            result,
            'Worker removed from site successfully',
        );
    } catch (error) {
        console.error('Error in removeWorkerFromSite:', error);

        if (error.message === 'Worker is not assigned to this site') {
            return sendError(res, error.message, 404);
        }

        return sendError(res, 'Failed to remove worker from site', 500);
    }
};

/**
 * GET /sites/all
 * Returns all sites (admin only)
 */
const getAllSites = async (req, res) => {
    try {
        const sites = await siteService.getAllSites();

        return sendSuccess(
            res,
            { sites },
            'All sites retrieved successfully',
        );
    } catch (error) {
        console.error('Error in getAllSites:', error);
        return sendError(res, 'Failed to fetch all sites', 500);
    }
};

/**
 * POST /sites/create
 * Create a new site (admin only)
 */
const createSite = async (req, res) => {
    try {
        const { code, name, address, latitude, longitude } = req.body;

        // Validation
        if (!name) {
            return sendError(res, 'Site name is required', 400);
        }

        const siteData = {
            code,
            name,
            address,
            latitude,
            longitude,
        };

        const site = await siteService.createSite(siteData);

        return sendSuccess(
            res,
            { site },
            'Site created successfully',
            201
        );
    } catch (error) {
        console.error('Error in createSite:', error);

        if (error.message === 'Site code already exists') {
            return sendError(res, error.message, 400);
        }

        return sendError(res, 'Failed to create site', 500);
    }
};

/**
 * GET /sites/without-coordinator
 * Returns sites that don't have a site coordinator assigned
 */
const getSitesWithoutCoordinator = async (req, res) => {
    try {
        const sites = await siteService.getSitesWithoutCoordinator();

        return sendSuccess(
            res,
            { sites },
            'Sites without coordinator retrieved successfully',
        );
    } catch (error) {
        console.error('Error in getSitesWithoutCoordinator:', error);
        return sendError(res, 'Failed to fetch sites without coordinator', 500);
    }
};

/**
 * POST /sites/:id/assign-coordinator
 * Assign a site coordinator to a specific site
 */
const assignCoordinatorToSite = async (req, res) => {
    try {
        const { id: siteId } = req.params;
        const { coordinatorId } = req.body;

        if (!coordinatorId) {
            return sendError(res, 'Coordinator ID is required', 400);
        }

        const assignment = await siteService.assignCoordinatorToSite(siteId, coordinatorId);

        return sendSuccess(
            res,
            { assignment },
            'Coordinator assigned to site successfully',
        );
    } catch (error) {
        console.error('Error in assignCoordinatorToSite:', error);

        if (error.message === 'Coordinator is already assigned to this site') {
            return sendError(res, error.message, 400);
        }

        return sendError(res, 'Failed to assign coordinator to site', 500);
    }
};

module.exports = {
    getMySites,
    getAllSites,
    getWorkersBySite,
    assignWorkerToSite,
    removeWorkerFromSite,
    createSite,
    getSitesWithoutCoordinator,
    assignCoordinatorToSite,
};
