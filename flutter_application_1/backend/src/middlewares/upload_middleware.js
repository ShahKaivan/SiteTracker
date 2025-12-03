const multer = require('multer');
const path = require('path');
const fs = require('fs');

// Create uploads directory if it doesn't exist
const uploadsDir = path.join(__dirname, '../../uploads');
if (!fs.existsSync(uploadsDir)) {
  fs.mkdirSync(uploadsDir, { recursive: true });
}

// Configure storage
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, uploadsDir);
  },
  filename: (req, file, cb) => {
    // Generate unique filename: timestamp-random-originalname
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    const ext = path.extname(file.originalname);
    cb(null, `selfie-${uniqueSuffix}${ext}`);
  },
});

// File filter - only allow images (JPEG, PNG, WebP)
const fileFilter = (req, file, cb) => {
  // Normalize values
  const mimetype = (file.mimetype || '').toLowerCase();
  const ext = path.extname(file.originalname || '').toLowerCase();

  const allowedMimes = ['image/jpeg', 'image/jpg', 'image/png', 'image/webp'];
  const allowedExts = ['.jpg', '.jpeg', '.png', '.webp'];

  // Primary check: trusted image MIME types
  const isAllowedMime = allowedMimes.includes(mimetype);

  // Fallback: some clients (or platforms) send application/octet-stream or empty mimetype.
  // In that case, trust the file extension if it matches an allowed image type.
  const isOctetStream = mimetype === 'application/octet-stream' || mimetype === '';
  const isAllowedExt = allowedExts.includes(ext);

  if (isAllowedMime || (isOctetStream && isAllowedExt)) {
    return cb(null, true);
  }

  return cb(
    new Error('Invalid file type. Only JPEG, PNG, and WebP images are allowed.'),
    false
  );
};

// Configure multer
const upload = multer({
  storage: storage,
  fileFilter: fileFilter,
  limits: {
    fileSize: 5 * 1024 * 1024, // 5MB max file size
  },
});

/**
 * Middleware for handling single file upload (selfie)
 */
const uploadSelfie = upload.single('photo');

/**
 * Middleware for handling profile image upload (registration)
 */
const uploadProfileImage = upload.single('profile_image');

/**
 * Error handler for multer errors
 */
const handleUploadError = (err, req, res, next) => {
  if (err instanceof multer.MulterError) {
    if (err.code === 'LIMIT_FILE_SIZE') {
      return res.status(400).json({
        success: false,
        message: 'File size too large. Maximum size is 5MB.',
      });
    }
    return res.status(400).json({
      success: false,
      message: err.message,
    });
  }

  if (err) {
    return res.status(400).json({
      success: false,
      message: err.message,
    });
  }

  next();
};

module.exports = {
  uploadSelfie,
  uploadProfileImage,
  handleUploadError,
};

