const prisma = require('../config/db');

const PRIORITY_ORDER = {
  high: 0,
  medium: 1,
  low: 2,
};

/**
 * Fetch announcements for the user's sites.
 * Workers see announcements from their assigned sites.
 * Coordinators see announcements from their assigned sites.
 * Admins see announcements created by any admin.
 */
const getAnnouncementsForUser = async (userId, userRole) => {
  const now = new Date();

  try {
    let whereClause = {
      is_active: true,
      AND: [
        {
          OR: [
            { expiry_date: null },
            { expiry_date: { gte: now } },
          ],
        },
      ],
    };

    if (userRole === 'admin') {
      // Admins see all announcements created by any admin (global or site-specific)
      // We find all users with role 'admin' first to get their IDs, or we can filter by creator.role if we join.
      // Since we can't easily join on creator role in a simple where clause without relation filtering (which Prisma supports),
      // let's use relation filtering.
      whereClause.creator = {
        role: 'admin',
      };
    } else {
      // Workers and Coordinators logic
      // Get all sites assigned to this user
      const userSiteAssignments = await prisma.siteUserAssignment.findMany({
        where: {
          user_id: userId,
        },
        select: {
          site_id: true,
        },
      });

      // Extract site IDs
      const siteIds = userSiteAssignments.map(assignment => assignment.site_id);

      // If user has no site assignments, they only see global announcements (if any)
      // But typically workers should be assigned.

      whereClause.OR = [
        { site_id: { in: siteIds } }, // Site specific
        { site_id: null }, // Global
      ];
    }

    // Fetch active announcements based on the constructed where clause
    const announcements = await prisma.announcement.findMany({
      where: whereClause,
      include: {
        site: {
          select: {
            id: true,
            name: true,
            code: true,
          },
        },
        creator: {
          select: {
            role: true,
            full_name: true
          }
        }
      },
      orderBy: [
        { created_at: 'desc' },
      ],
    });

    // Sort in-memory to respect priority order then recency
    announcements.sort((a, b) => {
      const aPriority = PRIORITY_ORDER[a.priority?.toLowerCase()] ?? 99;
      const bPriority = PRIORITY_ORDER[b.priority?.toLowerCase()] ?? 99;
      if (aPriority !== bPriority) {
        return aPriority - bPriority;
      }
      return new Date(b.created_at) - new Date(a.created_at);
    });

    return announcements.map((announcement) => ({
      id: announcement.id,
      site_id: announcement.site_id,
      site_name: announcement.site?.name ?? null,
      title: announcement.title,
      message: announcement.message,
      priority: announcement.priority,
      created_at: announcement.created_at,
      updated_at: announcement.updated_at,
      expiry_date: announcement.expiry_date,
      is_active: announcement.is_active,
      creator_role: announcement.creator?.role,
      creator_name: announcement.creator?.full_name
    }));
  } catch (error) {
    console.error('Error in getAnnouncementsForUser:', error);
    throw error;
  }
};

/**
 * Create a new announcement
 */
const createAnnouncement = async ({ siteId, title, message, priority, expiryDate, createdBy }) => {
  try {
    // Validate priority
    const validPriorities = ['low', 'medium', 'high'];
    if (!validPriorities.includes(priority.toLowerCase())) {
      throw new Error('Invalid priority. Must be low, medium, or high');
    }

    // Create announcement
    const announcement = await prisma.announcement.create({
      data: {
        site_id: siteId === 'all' ? null : siteId,
        title: title.trim(),
        message: message.trim(),
        priority: priority.toLowerCase(),
        expiry_date: expiryDate ? new Date(expiryDate) : null,
        is_active: true,
        created_by: createdBy,
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

    return {
      id: announcement.id,
      site_id: announcement.site_id,
      site_name: announcement.site?.name ?? null,
      title: announcement.title,
      message: announcement.message,
      priority: announcement.priority,
      created_at: announcement.created_at,
      updated_at: announcement.updated_at,
      expiry_date: announcement.expiry_date,
      is_active: announcement.is_active,
      created_by: announcement.created_by,
    };
  } catch (error) {
    console.error('Error in createAnnouncement service:', error);
    throw error;
  }
};

/**
 * Get announcements created by a specific coordinator
 * Optionally filter by site
 */
const getMyAnnouncements = async (userId, siteId = null) => {
  try {
    const where = {
      created_by: userId,
    };

    // Add site filter if provided
    if (siteId) {
      if (siteId === 'all') {
        where.site_id = null;
      } else {
        where.site_id = siteId;
      }
    }

    const announcements = await prisma.announcement.findMany({
      where,
      include: {
        site: {
          select: {
            id: true,
            name: true,
            code: true,
          },
        },
      },
      orderBy: [
        { created_at: 'desc' },
      ],
    });

    return announcements.map((announcement) => {
      const now = new Date();
      const isExpired = announcement.expiry_date && new Date(announcement.expiry_date) < now;

      return {
        id: announcement.id,
        site_id: announcement.site_id,
        site_name: announcement.site?.name ?? null,
        site_code: announcement.site?.code ?? null,
        title: announcement.title,
        message: announcement.message,
        priority: announcement.priority,
        created_at: announcement.created_at,
        updated_at: announcement.updated_at,
        expiry_date: announcement.expiry_date,
        is_active: announcement.is_active,
        is_expired: isExpired,
        created_by: announcement.created_by,
      };
    });
  } catch (error) {
    console.error('Error in getMyAnnouncements service:', error);
    throw error;
  }
};

/**
 * Deactivate an announcement
 * Only the creator can deactivate
 */
const deactivateAnnouncement = async (announcementId, userId) => {
  try {
    // First check if announcement exists and user is the creator
    const announcement = await prisma.announcement.findUnique({
      where: { id: announcementId },
    });

    if (!announcement) {
      throw new Error('Announcement not found');
    }

    if (announcement.created_by !== userId) {
      throw new Error('You are not authorized to deactivate this announcement');
    }

    // Deactivate the announcement
    const updated = await prisma.announcement.update({
      where: { id: announcementId },
      data: {
        is_active: false,
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

    return {
      id: updated.id,
      site_id: updated.site_id,
      site_name: updated.site?.name ?? null,
      title: updated.title,
      message: updated.message,
      priority: updated.priority,
      created_at: updated.created_at,
      updated_at: updated.updated_at,
      expiry_date: updated.expiry_date,
      is_active: updated.is_active,
    };
  } catch (error) {
    console.error('Error in deactivateAnnouncement service:', error);
    throw error;
  }
};

module.exports = {
  getAnnouncementsForUser,
  createAnnouncement,
  getMyAnnouncements,
  deactivateAnnouncement,
};
