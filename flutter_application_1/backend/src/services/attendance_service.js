const prisma = require('../config/db');
const path = require('path');

/**
 * Calculate total hours between punch-in and punch-out
 * @param {Date} punchInTime - Punch in time
 * @param {Date} punchOutTime - Punch out time
 * @returns {Number} Total hours (decimal)
 */
const calculateTotalHours = (punchInTime, punchOutTime) => {
  if (!punchInTime || !punchOutTime) {
    return null;
  }

  const diffMs = punchOutTime.getTime() - punchInTime.getTime();
  const diffHours = diffMs / (1000 * 60 * 60); // Convert milliseconds to hours

  return parseFloat(diffHours.toFixed(2));
};

/**
 * Get start of day (00:00:00) for a given date
 * @param {Date} date - Date object
 * @returns {Date} Start of day
 */
const getStartOfDay = (date) => {
  const startOfDay = new Date(date);
  startOfDay.setHours(0, 0, 0, 0);
  return startOfDay;
};

/**
 * Get end of day (23:59:59) for a given date
 * @param {Date} date - Date object
 * @returns {Date} End of day
 */
const getEndOfDay = (date) => {
  const endOfDay = new Date(date);
  endOfDay.setHours(23, 59, 59, 999);
  return endOfDay;
};

/**
 * Punch in - Create or update attendance record
 * @param {String} workerId - Worker/User ID
 * @param {String} siteId - Site ID
 * @param {Number} latitude - Latitude
 * @param {Number} longitude - Longitude
 * @param {String} selfieUrl - Selfie image URL
 * @returns {Object} Attendance record
 */
const punchIn = async (workerId, siteId, latitude, longitude, selfieUrl) => {
  try {
    // Ensure site exists before proceeding to avoid FK violations
    // Skip validation if siteId is null/undefined (for admin users)
    if (siteId) {
      const site = await prisma.site.findUnique({
        where: { id: siteId },
      });

      if (!site) {
        return {
          success: false,
          message: 'Site not found',
        };
      }
    }

    // Get current date (start of day)
    const today = new Date();
    const date = getStartOfDay(today);
    const punchInTime = new Date();

    // Check if attendance record exists for today
    let attendance = await prisma.attendance.findUnique({
      where: {
        worker_id_date: {
          worker_id: workerId,
          date: date,
        },
      },
    });

    if (attendance) {
      // If already punched in, return error
      if (attendance.punch_in_time) {
        return {
          success: false,
          message: 'You have already punched in today',
          attendance: attendance,
        };
      }

      // Update existing record
      attendance = await prisma.attendance.update({
        where: {
          id: attendance.id,
        },
        data: {
          punch_in_time: punchInTime,
          punch_in_latitude: latitude,
          punch_in_longitude: longitude,
          punch_in_selfie_url: selfieUrl,
        },
      });
    } else {
      // Create new attendance record
      attendance = await prisma.attendance.create({
        data: {
          worker_id: workerId,
          site_id: siteId,
          date: date,
          punch_in_time: punchInTime,
          punch_in_latitude: latitude,
          punch_in_longitude: longitude,
          punch_in_selfie_url: selfieUrl,
        },
      });
    }

    return {
      success: true,
      message: 'Punch in successful',
      attendance: attendance,
    };
  } catch (error) {
    console.error('Error in punchIn:', error);
    throw error;
  }
};

/**
 * Punch out - Update attendance record
 * @param {String} workerId - Worker/User ID
 * @param {Number} latitude - Latitude
 * @param {Number} longitude - Longitude
 * @param {String} selfieUrl - Selfie image URL
 * @returns {Object} Attendance record
 */
const punchOut = async (workerId, latitude, longitude, selfieUrl) => {
  try {
    // Get current date (start of day)
    const today = new Date();
    const date = getStartOfDay(today);
    const punchOutTime = new Date();

    // Find today's attendance record
    const attendance = await prisma.attendance.findUnique({
      where: {
        worker_id_date: {
          worker_id: workerId,
          date: date,
        },
      },
    });

    if (!attendance) {
      return {
        success: false,
        message: 'No punch in record found for today. Please punch in first.',
      };
    }

    if (!attendance.punch_in_time) {
      return {
        success: false,
        message: 'No punch in record found for today. Please punch in first.',
      };
    }

    if (attendance.punch_out_time) {
      return {
        success: false,
        message: 'You have already punched out today',
        attendance: attendance,
      };
    }

    // Calculate total hours
    const totalHours = calculateTotalHours(attendance.punch_in_time, punchOutTime);

    // Update attendance record
    const updatedAttendance = await prisma.attendance.update({
      where: {
        id: attendance.id,
      },
      data: {
        punch_out_time: punchOutTime,
        punch_out_latitude: latitude,
        punch_out_longitude: longitude,
        punch_out_selfie_url: selfieUrl,
        total_hours: totalHours,
      },
    });

    return {
      success: true,
      message: 'Punch out successful',
      attendance: updatedAttendance,
    };
  } catch (error) {
    console.error('Error in punchOut:', error);
    throw error;
  }
};

/**
 * Get attendance records for a user within date range
 * @param {String} workerId - Worker/User ID
 * @param {Date} startDate - Start date
 * @param {Date} endDate - End date
 * @returns {Array} Array of attendance records
 */
const getAttendanceRecords = async (workerId, startDate, endDate) => {
  try {
    const start = getStartOfDay(startDate);
    const end = getEndOfDay(endDate);

    const records = await prisma.attendance.findMany({
      where: {
        worker_id: workerId,
        date: {
          gte: start,
          lte: end,
        },
      },
      orderBy: {
        date: 'desc',
      },
    });

    return {
      success: true,
      records: records,
      count: records.length,
    };
  } catch (error) {
    console.error('Error in getAttendanceRecords:', error);
    throw error;
  }
};

/**
 * Get today's punch status for a worker
 * @param {String} workerId
 * @returns {Object} Status info
 */
const getTodayStatus = async (workerId) => {
  try {
    const today = new Date();
    const date = getStartOfDay(today);

    const attendance = await prisma.attendance.findUnique({
      where: {
        worker_id_date: {
          worker_id: workerId,
          date,
        },
      },
    });

    if (!attendance) {
      return {
        success: true,
        status: {
          has_punched_in: false,
          has_punched_out: false,
          punch_in_time: null,
          punch_out_time: null,
        },
      };
    }

    return {
      success: true,
      status: {
        has_punched_in: !!attendance.punch_in_time,
        has_punched_out: !!attendance.punch_out_time,
        punch_in_time: attendance.punch_in_time,
        punch_out_time: attendance.punch_out_time,
      },
    };
  } catch (error) {
    console.error('Error in getTodayStatus:', error);
    throw error;
  }
};

/**
 * Get filtered attendance records
 * @param {String} siteId - Site ID
 * @param {String|Array} workerIds - Worker ID(s) - can be 'all', 'myself', or specific IDs
 * @param {Date} startDate - Start date
 * @param {Date} endDate - End date
 * @param {String} requestingUserId - ID of user making the request
 * @returns {Array} Filtered attendance records
 */
const getFilteredAttendance = async (siteId, workerIds, startDate, endDate, requestingUserId) => {
  try {
    const start = getStartOfDay(startDate);
    const end = getEndOfDay(endDate);

    let whereClause = {
      site_id: siteId,
      date: {
        gte: start,
        lte: end,
      },
    };

    // Handle worker filter
    if (workerIds === 'all') {
      // Get all workers for this site
      const siteAssignments = await prisma.siteUserAssignment.findMany({
        where: { site_id: siteId },
        select: { user_id: true },
      });
      const allWorkerIds = siteAssignments.map(a => a.user_id);
      whereClause.worker_id = { in: allWorkerIds };
    } else if (workerIds === 'myself') {
      // Filter by requesting user
      whereClause.worker_id = requestingUserId;
    } else if (Array.isArray(workerIds)) {
      // Multiple specific workers
      whereClause.worker_id = { in: workerIds };
    } else {
      // Single specific worker
      whereClause.worker_id = workerIds;
    }

    const records = await prisma.attendance.findMany({
      where: whereClause,
      include: {
        worker: {
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
      orderBy: {
        date: 'desc',
      },
    });

    return {
      success: true,
      records: records.map(record => ({
        id: record.id,
        worker_id: record.worker_id,
        worker_name: record.worker?.full_name,
        worker_role: record.worker?.role,
        site_id: record.site_id,
        site_name: record.site?.name,
        site_code: record.site?.code,
        date: record.date,
        punch_in_time: record.punch_in_time,
        punch_in_latitude: record.punch_in_latitude,
        punch_in_longitude: record.punch_in_longitude,
        punch_in_selfie_url: record.punch_in_selfie_url,
        punch_out_time: record.punch_out_time,
        punch_out_latitude: record.punch_out_latitude,
        punch_out_longitude: record.punch_out_longitude,
        punch_out_selfie_url: record.punch_out_selfie_url,
        total_hours: record.total_hours,
        created_at: record.created_at,
        updated_at: record.updated_at,
      })),
      count: records.length,
    };
  } catch (error) {
    console.error('Error in getFilteredAttendance:', error);
    throw error;
  }
};

module.exports = {
  punchIn,
  punchOut,
  getAttendanceRecords,
  getTodayStatus,
  calculateTotalHours,
  getFilteredAttendance,
};
