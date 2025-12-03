const announcementService = require('../services/announcement_service');
const { sendSuccess, sendError } = require('../utils/response');

/**
 * GET /announcements/my-sites
 * Returns announcements relevant to the authenticated worker.
 */
const getMySitesAnnouncements = async (req, res) => {
  try {
    // When worker/site relationships exist, we can filter by req.user.id.
    const announcements = await announcementService.getAnnouncementsForUser(req.user.id, req.user.role);

    return sendSuccess(
      res,
      { announcements },
      'Announcements retrieved successfully',
    );
  } catch (error) {
    console.error('Error in getMySitesAnnouncements:', error);
    return sendError(res, 'Failed to fetch announcements', 500);
  }
};

/**
 * POST /announcements/create
 * Create a new announcement (coordinator only)
 */
const createAnnouncement = async (req, res) => {
  try {
    const { siteId, title, message, priority, expiryDate } = req.body;
    const userId = req.user.id;

    // Validation
    if (!siteId || !title || !message || !priority) {
      return sendError(res, 'Missing required fields: siteId, title, message, priority', 400);
    }

    // Create announcement
    const announcement = await announcementService.createAnnouncement({
      siteId,
      title,
      message,
      priority,
      expiryDate,
      createdBy: userId,
    });

    return sendSuccess(
      res,
      { announcement },
      'Announcement created successfully',
      201
    );
  } catch (error) {
    console.error('Error in createAnnouncement:', error);
    return sendError(res, error.message || 'Failed to create announcement', 500);
  }
};

/**
 * GET /announcements/my
 * Get announcements created by the authenticated coordinator
 */
const getMyAnnouncements = async (req, res) => {
  try {
    const userId = req.user.id;
    const { siteId } = req.query;

    const announcements = await announcementService.getMyAnnouncements(userId, siteId);

    return sendSuccess(
      res,
      { announcements },
      'Announcements retrieved successfully'
    );
  } catch (error) {
    console.error('Error in getMyAnnouncements:', error);
    return sendError(res, 'Failed to fetch announcements', 500);
  }
};

/**
 * PATCH /announcements/:id/deactivate
 * Deactivate an announcement
 */
const deactivateAnnouncement = async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user.id;

    const announcement = await announcementService.deactivateAnnouncement(id, userId);

    return sendSuccess(
      res,
      { announcement },
      'Announcement deactivated successfully'
    );
  } catch (error) {
    console.error('Error in deactivateAnnouncement:', error);
    return sendError(res, error.message || 'Failed to deactivate announcement', 500);
  }
};

module.exports = {
  getMySitesAnnouncements,
  createAnnouncement,
  getMyAnnouncements,
  deactivateAnnouncement,
};
