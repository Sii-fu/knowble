const fs = require('fs-extra');

/**
 * Utility Functions
 * Common helper functions used throughout the application
 */

/**
 * Clean up temporary uploaded files
 * @param {string} filePath - Path to temporary file
 * @returns {Promise<void>}
 */
async function cleanupTempFile(filePath) {
  try {
    if (filePath && await fs.pathExists(filePath)) {
      await fs.remove(filePath);
      console.log(`🗑️  Temporary file cleaned up: ${filePath}`);
    }
  } catch (error) {
    console.error(`❌ Error cleaning up temporary file: ${filePath}`, error.message);
  }
}

/**
 * Validate video file properties
 * @param {Object} file - Multer file object
 * @returns {Object} Validation result
 */
function validateVideoFile(file) {
  const MAX_FILE_SIZE = 2 * 1024 * 1024 * 1024; // 2GB
  const ALLOWED_MIME_TYPES = [
    'video/mp4',
    'video/mpeg',
    'video/quicktime',
    'video/x-msvideo',
    'video/x-ms-wmv',
    'video/webm',
    'video/3gpp',
    'video/x-flv',
    'video/x-matroska',
    'application/octet-stream' // Allow generic binary, will check extension
  ];

  const ALLOWED_EXTENSIONS = ['.mp4', '.mpeg', '.mpg', '.mov', '.avi', '.wmv', '.webm', '.3gp', '.flv', '.mkv'];

  if (!file) {
    return {
      valid: false,
      error: 'No video file provided'
    };
  }

  if (file.size > MAX_FILE_SIZE) {
    return {
      valid: false,
      error: `File size too large. Maximum allowed: ${MAX_FILE_SIZE / (1024 * 1024 * 1024)}GB`
    };
  }

  // Get file extension
  const path = require('path');
  const fileExtension = path.extname(file.originalname).toLowerCase();

  // Check MIME type OR file extension
  const isValidMimeType = ALLOWED_MIME_TYPES.includes(file.mimetype);
  const isValidExtension = ALLOWED_EXTENSIONS.includes(fileExtension);

  if (!isValidMimeType && !isValidExtension) {
    return {
      valid: false,
      error: `Unsupported file type: ${file.mimetype} (${fileExtension}). Allowed extensions: ${ALLOWED_EXTENSIONS.join(', ')}`
    };
  }

  // If MIME type is generic but extension is valid, log for debugging
  if (file.mimetype === 'application/octet-stream' && isValidExtension) {
    console.log(`📁 File ${file.originalname} has generic MIME type but valid extension ${fileExtension}`);
  }

  return {
    valid: true,
    file: {
      originalName: file.originalname,
      size: file.size,
      mimeType: file.mimetype,
      path: file.path
    }
  };
}

/**
 * Format file size in human readable format
 * @param {number} bytes - File size in bytes
 * @returns {string} Formatted file size
 */
function formatFileSize(bytes) {
  if (bytes === 0) return '0 Bytes';
  
  const k = 1024;
  const sizes = ['Bytes', 'KB', 'MB', 'GB'];
  const i = Math.floor(Math.log(bytes) / Math.log(k));
  
  return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
}

/**
 * Generate a safe filename from a title
 * @param {string} title - Original title
 * @returns {string} Safe filename
 */
function generateSafeFilename(title) {
  return title
    .replace(/[^a-zA-Z0-9\s-_]/g, '') // Remove special characters
    .replace(/\s+/g, '_') // Replace spaces with underscores
    .substring(0, 100) // Limit length
    .toLowerCase();
}

/**
 * Parse tags from string input
 * @param {string} tagsString - Comma-separated tags
 * @returns {Array<string>} Array of cleaned tags
 */
function parseTags(tagsString) {
  if (!tagsString || typeof tagsString !== 'string') {
    return ['knowble', 'education'];
  }

  return tagsString
    .split(',')
    .map(tag => tag.trim())
    .filter(tag => tag.length > 0)
    .filter(tag => tag.length <= 500) // YouTube tag length limit
    .slice(0, 10); // Limit to 10 tags
}

/**
 * Validate YouTube video metadata
 * @param {Object} metadata - Video metadata
 * @returns {Object} Validated metadata
 */
function validateVideoMetadata(metadata) {
  const {
    title = 'Untitled Video',
    description = 'Uploaded via Knowble App',
    tags = 'knowble,education',
    privacy = 'unlisted'
  } = metadata;

  // Validate privacy setting
  const allowedPrivacy = ['private', 'public', 'unlisted'];
  const validPrivacy = allowedPrivacy.includes(privacy) ? privacy : 'unlisted';

  return {
    title: title.substring(0, 100), // YouTube title limit
    description: description.substring(0, 5000), // YouTube description limit
    tags: parseTags(tags),
    privacy: validPrivacy
  };
}

module.exports = {
  cleanupTempFile,
  validateVideoFile,
  formatFileSize,
  generateSafeFilename,
  parseTags,
  validateVideoMetadata
};
