/**
 * OTP Service - Manages temporary OTP storage in memory
 * In production, consider using Redis for distributed systems
 */

// In-memory storage for OTPs
// Structure: { "country_code+mobile_number": { otp: "1234", expiresAt: timestamp, attempts: 0 } }
const otpStore = new Map();

// OTP expiration time (5 minutes)
const OTP_EXPIRY_TIME = 5 * 60 * 1000; // 5 minutes in milliseconds
const MAX_OTP_ATTEMPTS = 3; // Maximum verification attempts

/**
 * Generate a 4-digit OTP
 * @returns {String} 4-digit OTP
 */
const generateOTP = () => {
  return Math.floor(1000 + Math.random() * 9000).toString();
};

/**
 * Store OTP for a mobile number
 * @param {String} countryCode - Country code
 * @param {String} mobileNumber - Mobile number
 * @returns {String} Generated OTP
 */
const storeOTP = (countryCode, mobileNumber) => {
  const key = `${countryCode}${mobileNumber}`;
  const otp = generateOTP();
  const expiresAt = Date.now() + OTP_EXPIRY_TIME;

  otpStore.set(key, {
    otp,
    expiresAt,
    attempts: 0,
  });

  // Clean up expired OTPs periodically
  cleanupExpiredOTPs();

  return otp;
};

/**
 * Verify OTP for a mobile number
 * @param {String} countryCode - Country code
 * @param {String} mobileNumber - Mobile number
 * @param {String} otp - OTP to verify
 * @returns {Object} { valid: boolean, message: string }
 */
const verifyOTP = (countryCode, mobileNumber, otp) => {
  const key = `${countryCode}${mobileNumber}`;
  const storedData = otpStore.get(key);

  if (!storedData) {
    return {
      valid: false,
      message: 'OTP not found. Please request a new OTP.',
    };
  }

  // Check if OTP has expired
  if (Date.now() > storedData.expiresAt) {
    otpStore.delete(key);
    return {
      valid: false,
      message: 'OTP has expired. Please request a new OTP.',
    };
  }

  // Check if maximum attempts exceeded
  if (storedData.attempts >= MAX_OTP_ATTEMPTS) {
    otpStore.delete(key);
    return {
      valid: false,
      message: 'Maximum verification attempts exceeded. Please request a new OTP.',
    };
  }

  // Increment attempts
  storedData.attempts += 1;

  // Verify OTP
  if (storedData.otp === otp) {
    // OTP is valid, remove it from store
    otpStore.delete(key);
    return {
      valid: true,
      message: 'OTP verified successfully',
    };
  } else {
    // Store updated attempts
    otpStore.set(key, storedData);
    return {
      valid: false,
      message: `Invalid OTP. ${MAX_OTP_ATTEMPTS - storedData.attempts} attempts remaining.`,
    };
  }
};

/**
 * Remove OTP for a mobile number (used after successful verification)
 * @param {String} countryCode - Country code
 * @param {String} mobileNumber - Mobile number
 */
const removeOTP = (countryCode, mobileNumber) => {
  const key = `${countryCode}${mobileNumber}`;
  otpStore.delete(key);
};

/**
 * Get OTP for a mobile number (for testing/debugging purposes)
 * @param {String} countryCode - Country code
 * @param {String} mobileNumber - Mobile number
 * @returns {String|null} OTP or null if not found
 */
const getOTP = (countryCode, mobileNumber) => {
  const key = `${countryCode}${mobileNumber}`;
  const storedData = otpStore.get(key);
  
  if (!storedData || Date.now() > storedData.expiresAt) {
    return null;
  }
  
  return storedData.otp;
};

/**
 * Clean up expired OTPs from memory
 */
const cleanupExpiredOTPs = () => {
  const now = Date.now();
  for (const [key, data] of otpStore.entries()) {
    if (now > data.expiresAt) {
      otpStore.delete(key);
    }
  }
};

// Clean up expired OTPs every 10 minutes
setInterval(cleanupExpiredOTPs, 10 * 60 * 1000);

module.exports = {
  generateOTP,
  storeOTP,
  verifyOTP,
  removeOTP,
  getOTP,
};

