const prisma = require('../config/db');

/**
 * Get all users (workers and coordinators) assigned to a specific site
 * @param {String} siteId - Site ID
 * @returns {Array} Array of users
 */
const getUsersBySite = async (siteId) => {
    try {
        // Get all user assignments for this site
        const siteAssignments = await prisma.siteUserAssignment.findMany({
            where: {
                site_id: siteId,
            },
            include: {
                user: {
                    select: {
                        id: true,
                        full_name: true,
                        role: true,
                        mobile_number: true,
                    },
                },
            },
        });

        // Extract and format user data - return ALL users (workers + coordinators)
        const users = siteAssignments
            .map((assignment) => ({
                id: assignment.user.id,
                name: assignment.user.full_name,
                role: assignment.user.role,
                mobile_number: assignment.user.mobile_number,
            }));

        return users;
    } catch (error) {
        console.error('Error in getUsersBySite:', error);
        throw error;
    }
};

/**
 * Get all workers who are not assigned to any site
 * @returns {Array} Array of unassigned workers
 */
const getUnassignedWorkers = async () => {
    try {
        // First, get all user IDs that have site assignments
        const assignedUserIds = await prisma.siteUserAssignment.findMany({
            select: {
                user_id: true,
            },
        });

        const assignedIds = assignedUserIds.map(assignment => assignment.user_id);

        // Get all users with role 'worker' who are NOT in the assigned list
        const unassignedWorkers = await prisma.users.findMany({
            where: {
                role: 'worker',
                id: {
                    notIn: assignedIds,
                },
            },
            select: {
                id: true,
                full_name: true,
                mobile_number: true,
                role: true,
            },
            orderBy: {
                full_name: 'asc',
            },
        });

        return unassignedWorkers;
    } catch (error) {
        console.error('Error in getUnassignedWorkers:', error);
        throw error;
    }
};

/**
 * Get all users with role 'site_coordinator'
 * @returns {Array} Array of site coordinators
 */
const getSiteCoordinators = async () => {
    try {
        const coordinators = await prisma.users.findMany({
            where: {
                role: 'site_coordinator',
            },
            select: {
                id: true,
                full_name: true,
                mobile_number: true,
                role: true,
            },
            orderBy: {
                full_name: 'asc',
            },
        });

        return coordinators;
    } catch (error) {
        console.error('Error in getSiteCoordinators:', error);
        throw error;
    }
};

module.exports = {
    getUsersBySite,
    getUnassignedWorkers,
    getSiteCoordinators,
};
