const userService = require('../services/user_service');
const { sendSuccess, sendError } = require('../utils/response');

/**
 * GET /users/unassigned
 * Returns workers who are not assigned to any site
 */
const getUnassignedWorkers = async (req, res) => {
    try {
        const workers = await userService.getUnassignedWorkers();

        return sendSuccess(
            res,
            { workers },
            'Unassigned workers retrieved successfully',
        );
    } catch (error) {
        console.error('Error in getUnassignedWorkers:', error);
        return sendError(res, 'Failed to fetch unassigned workers', 500);
    }
};

/**
 * GET /users/site-coordinators
 * Returns all site coordinators
 */
const getSiteCoordinators = async (req, res) => {
    try {
        const coordinators = await userService.getSiteCoordinators();

        return sendSuccess(
            res,
            { coordinators },
            'Site coordinators retrieved successfully',
        );
    } catch (error) {
        console.error('Error in getSiteCoordinators:', error);
        return sendError(res, 'Failed to fetch site coordinators', 500);
    }
};

/**
 * GET /users/my-site-assignment
 * Returns the current user's site assignment
 */
const getMyCurrentSiteAssignment = async (req, res) => {
    try {
        const userId = req.user.id;

        const assignment = await userService.getMyCurrentSiteAssignment(userId);

        return sendSuccess(
            res,
            { assignment },
            assignment ? 'Site assignment retrieved successfully' : 'No site assignment found',
        );
    } catch (error) {
        console.error('Error in getMyCurrentSiteAssignment:', error);
        return sendError(res, 'Failed to fetch site assignment', 500);
    }
};

module.exports = {
    getUnassignedWorkers,
    getSiteCoordinators,
    getMyCurrentSiteAssignment,
};
