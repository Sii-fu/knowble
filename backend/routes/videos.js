const express = require('express');
const multer = require('multer');
const path = require('path');
const fs = require('fs-extra');
const router = express.Router();
const videoController = require('../controllers/videoController');

/**
 * Multer configuration for video file uploads
 * Configures file storage, naming, and validation
 */
const storage = multer.diskStorage({
  destination: async (req, file, cb) => {
    const uploadDir = path.join(__dirname, '../uploads');
    await fs.ensureDir(uploadDir); // Create directory if it doesn't exist
    cb(null, uploadDir);
  },
  filename: (req, file, cb) => {
    // Generate unique filename with timestamp
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    const extension = path.extname(file.originalname);
    cb(null, `video-${uniqueSuffix}${extension}`);
  }
});

/**
 * File filter for video uploads
 * Only allows specific video file types
 */
const fileFilter = (req, file, cb) => {
  // Allowed video MIME types
  const allowedMimeTypes = [
    'video/mp4',
    'video/mpeg',
    'video/quicktime',
    'video/x-msvideo', // .avi
    'video/x-ms-wmv',  // .wmv
    'video/webm',
    'video/3gpp',      // .3gp
    'video/x-flv',     // .flv
    'video/x-matroska', // .mkv
    'application/octet-stream' // Generic binary - we'll validate by extension
  ];

  // Allowed file extensions (more reliable than MIME type detection)
  const allowedExtensions = ['.mp4', '.mpeg', '.mpg', '.mov', '.avi', '.wmv', '.webm', '.3gp', '.flv', '.mkv'];
  
  const fileExtension = path.extname(file.originalname).toLowerCase();
  
  // Check both MIME type and file extension
  if (allowedMimeTypes.includes(file.mimetype) || allowedExtensions.includes(fileExtension)) {
    // For octet-stream, double-check the file extension
    if (file.mimetype === 'application/octet-stream' && !allowedExtensions.includes(fileExtension)) {
      cb(new Error(`Invalid file type: ${file.originalname}. Only video files are allowed.`), false);
    } else {
      cb(null, true);
    }
  } else {
    cb(new Error(`Unsupported file type: ${file.mimetype}. Allowed types: video/mp4, video/mpeg, video/quicktime, video/x-msvideo, video/x-ms-wmv, video/webm, video/3gpp, video/x-flv, video/x-matroska`), false);
  }
};

/**
 * Configure multer with file size limit and filters
 * Maximum file size: 2GB (YouTube's limit is higher, but this is reasonable for mobile uploads)
 */
const upload = multer({
  storage: storage,
  limits: {
    fileSize: 2 * 1024 * 1024 * 1024, // 2GB in bytes
    fieldSize: 10 * 1024 * 1024 // 10MB for text fields
  },
  fileFilter: fileFilter
});

/**
 * Error handling middleware for multer
 */
const handleMulterError = (error, req, res, next) => {
  if (error instanceof multer.MulterError) {
    if (error.code === 'LIMIT_FILE_SIZE') {
      return res.status(400).json({
        success: false,
        error: 'File too large',
        message: 'Video file must be smaller than 2GB'
      });
    }
    
    if (error.code === 'LIMIT_UNEXPECTED_FILE') {
      return res.status(400).json({
        success: false,
        error: 'Unexpected file field',
        message: 'Only one video file is allowed'
      });
    }
  }
  
  if (error.message && error.message.includes('Invalid file type') || error.message.includes('Unsupported file type')) {
    return res.status(400).json({
      success: false,
      error: 'Invalid file type',
      message: error.message,
      details: 'Please select a video file with one of these extensions: .mp4, .mpeg, .mpg, .mov, .avi, .wmv, .webm, .3gp, .flv, .mkv'
    });
  }
  
  // Pass other errors to the next error handler
  next(error);
};

/**
 * Video Routes
 * Handles YouTube video upload and management
 */

/**
 * @route   POST /api/videos/upload
 * @desc    Upload video to YouTube using fixed Google account
 * @access  Public (no authentication required)
 * @body    title - Video title (optional)
 * @body    description - Video description (optional)
 * @body    tags - Comma-separated tags (optional)
 * @body    privacy - Privacy setting: private, public, unlisted (optional, default: unlisted)
 * @file    video - Video file (required)
 */
router.post('/upload', 
  upload.single('video'), // 'video' is the field name for the file
  handleMulterError,
  videoController.uploadVideo
);

/**
 * @route   GET /api/videos/test-auth
 * @desc    Test the Google authentication setup
 * @access  Public
 */
router.get('/test-auth', videoController.testAuthentication);

/**
 * @route   GET /api/videos/upload/info
 * @desc    Get upload requirements and limits
 * @access  Public
 */
router.get('/upload/info', videoController.getUploadInfo);

/**
 * @route   GET /api/videos/:videoId
 * @desc    Get video details from YouTube
 * @access  Public
 * @param   videoId - YouTube video ID
 */
router.get('/:videoId', videoController.getVideoDetails);

module.exports = router;
