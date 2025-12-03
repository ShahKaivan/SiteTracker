const prisma = require('../config/db');

/**
 * Get sites assigned to a user
 * @param {String} userId - User ID
 * @returns {Array} Array of sites
 */
const getSitesForUser = async (userId) => {
    try {
        // Get all site assignments for this user
        const siteAssignments = await prisma.siteUserAssignment.findMany({
            where: {
                user_id: userId,
            },
            include: {
                site: {
                    select: {
                        id: true,
                        name: true,
                        code: true,
                    },
                },
            },
        });

        // Extract and format site data
        const sites = siteAssignments.map((assignment) => ({
            id: assignment.site.id,
            name: assignment.site.name,
            code: assignment.site.code,
        }));

        return sites;
    } catch (error) {
        console.error('Error in getSitesForUser:', error);
        throw error;
    }
};

/**
 * Assign a worker to a site
 * @param {String} siteId - Site ID
 * @param {String} workerId - Worker/User ID
 * @returns {Object} Created assignment
 */
const assignWorkerToSite = async (siteId, workerId) => {
    try {
        // Check if assignment already exists
        const existingAssignment = await prisma.siteUserAssignment.findFirst({
            where: {
                site_id: siteId,
                user_id: workerId,
            },
        });

        if (existingAssignment) {
            throw new Error('Worker is already assigned to this site');
        }

        // Create new assignment
        const assignment = await prisma.siteUserAssignment.create({
            data: {
                site_id: siteId,
                user_id: workerId,
                assigned_role: 'worker',
            },
            include: {
                user: {
                    select: {
                        id: true,
                        full_name: true,
                        role: true,
                    },
                },
                site: {
                    select: {
                        id: true,
                        name: true,
                        code: true,
                    },
                },
            },
        });

        return assignment;
    } catch (error) {
        console.error('Error in assignWorkerToSite:', error);
        throw error;
    }
};

/**
 * Remove a worker from a site (delete assignment)
 * @param {String} siteId - Site ID
 * @param {String} workerId - Worker/User ID
 * @returns {Object} Deleted assignment
 */
const removeWorkerFromSite = async (siteId, workerId) => {
    try {
        // Find the assignment
        const assignment = await prisma.siteUserAssignment.findFirst({
            where: {
                site_id: siteId,
                user_id: workerId,
            },
        });

        if (!assignment) {
            throw new Error('Worker is not assigned to this site');
        }

        // Delete the assignment
        await prisma.siteUserAssignment.delete({
            where: {
                id: assignment.id,
            },
        });

        return { success: true, message: 'Worker removed from site successfully' };
    } catch (error) {
        console.error('Error in removeWorkerFromSite:', error);
        throw error;
    }
};

/**
 * Get all sites (admin only)
 * @returns {Array} Array of all sites
 */
const getAllSites = async () => {
    try {
        const sites = await prisma.site.findMany({
            select: {
                id: true,
                name: true,
                code: true,
            },
        });

        return sites;
    } catch (error) {
        console.error('Error in getAllSites:', error);
        throw error;
    }
};

/**
 * Create a new site (admin only)
 * @param {Object} siteData - Site data (code, name, address, latitude, longitude)
 * @returns {Object} Created site
 */
const createSite = async (siteData) => {
    try {
        const { code, name, address, latitude, longitude } = siteData;

        // Check if site code already exists
        if (code) {
            const existingSite = await prisma.site.findUnique({
                where: { code },
            });

            if (existingSite) {
                throw new Error('Site code already exists');
            }
        }

        // Create site
        const site = await prisma.site.create({
            data: {
                code: code || null,
                name: name.trim(),
                address: address?.trim() || null,
                latitude: latitude ? parseFloat(latitude) : null,
                longitude: longitude ? parseFloat(longitude) : null,
            },
        });

        return {
            id: site.id,
            code: site.code,
            name: site.name,
            address: site.address,
            latitude: site.latitude,
            longitude: site.longitude,
            created_at: site.created_at,
        };
    } catch (error) {
        console.error('Error in createSite:', error);
        throw error;
    }
};

/**
 * Get all sites that don't have a site coordinator assigned
 * @returns {Array} Array of sites without coordinators
 */
const getSitesWithoutCoordinator = async () => {
    try {
        // Get all sites
        const allSites = await prisma.site.findMany({
            select: {
                id: true,
                name: true,
                code: true,
            },
        });

        // For each site, check if it has a coordinator assigned
        const sitesWithoutCoordinator = [];

        for (const site of allSites) {
            const coordinatorAssignment = await prisma.siteUserAssignment.findFirst({
                where: {
                    site_id: site.id,
                    assigned_role: 'sitecoordinator',
                },
            });

            if (!coordinatorAssignment) {
                sitesWithoutCoordinator.push(site);
            }
        }

        return sitesWithoutCoordinator;
    } catch (error) {
        console.error('Error in getSitesWithoutCoordinator:', error);
        throw error;
    }
};

/**
 * Assign a site coordinator to a site
 * @param {String} siteId - Site ID
 * @param {String} coordinatorId - Coordinator/User ID
 * @returns {Object} Created assignment
 */
const assignCoordinatorToSite = async (siteId, coordinatorId) => {
    try {
        // Check if coordinator is already assigned to this site
        const existingAssignment = await prisma.siteUserAssignment.findFirst({
            where: {
                site_id: siteId,
                user_id: coordinatorId,
            },
        });

        if (existingAssignment) {
            throw new Error('Coordinator is already assigned to this site');
        }

        // Create new assignment
        const assignment = await prisma.siteUserAssignment.create({
            data: {
                site_id: siteId,
                user_id: coordinatorId,
                assigned_role: 'sitecoordinator',
            },
            include: {
                user: {
                    select: {
                        id: true,
                        full_name: true,
                        role: true,
                    },
                },
                site: {
                    select: {
                        id: true,
                        name: true,
                        code: true,
                    },
                },
            },
        });

        return assignment;
    } catch (error) {
        console.error('Error in assignCoordinatorToSite:', error);
        throw error;
    }
};

module.exports = {
    getSitesForUser,
    getAllSites,
    assignWorkerToSite,
    removeWorkerFromSite,
    createSite,
    getSitesWithoutCoordinator,
    assignCoordinatorToSite,
};
