const fs = require('fs-extra');
const path = require('path');
const googleAuth = require('../config/googleAuth');
const { 
  cleanupTempFile, 
  validateVideoFile, 
  formatFileSize, 
  validateVideoMetadata 
} = require('../utils/helpers');

/**
 * Video Controller
 * Handles YouTube video upload functionality using a fixed Google account
 * 
 * All videos are uploaded to the configured Google account's YouTube channel.
 * No per-user authentication required - uses stored refresh token.
 */
class VideoController {
  /**
   * Upload video to YouTube using fixed Google account
   * 
   * @route POST /api/videos/upload
   * @access Public (no user auth required)
   * @param {Object} req - Express request object
   * @param {Object} res - Express response object
   */
  async uploadVideo(req, res) {
    let tempFilePath = null;

    try {
      console.log('🎬 Starting video upload process...');

      // Validate uploaded file
      const fileValidation = validateVideoFile(req.file);
      if (!fileValidation.valid) {
        return res.status(400).json({
          success: false,
          error: 'Invalid file',
          message: fileValidation.error
        });
      }

      tempFilePath = req.file.path;
      const fileInfo = fileValidation.file;

      console.log(`📁 File received: ${fileInfo.originalName}`);
      console.log(`📏 File size: ${formatFileSize(fileInfo.size)}`);
      console.log(`🎞️  MIME type: ${fileInfo.mimeType}`);

      // Validate and prepare video metadata
      const validatedMetadata = validateVideoMetadata(req.body);
      console.log(`📝 Video title: ${validatedMetadata.title}`);
      console.log(`🔒 Privacy: ${validatedMetadata.privacy}`);

      // Get authenticated YouTube client using fixed Google account
      console.log('🔐 Authenticating with fixed Google account...');
      const youtube = await googleAuth.getYouTubeClient();

      // Prepare video metadata for YouTube API
      const videoMetadata = {
        snippet: {
          title: validatedMetadata.title,
          description: validatedMetadata.description,
          tags: validatedMetadata.tags,
          categoryId: '22', // People & Blogs category
          defaultLanguage: 'en',
          defaultAudioLanguage: 'en'
        },
        status: {
          privacyStatus: validatedMetadata.privacy,
          embeddable: true,
          license: 'youtube',
          selfDeclaredMadeForKids: false
        }
      };

      console.log('⬆️  Uploading video to YouTube...');

      // Upload video to YouTube using resumable upload
      const uploadResponse = await youtube.videos.insert({
        part: ['snippet', 'status'],
        requestBody: videoMetadata,
        media: {
          body: fs.createReadStream(tempFilePath)
        }
      });

      const videoData = uploadResponse.data;
      const videoId = videoData.id;
      const videoUrl = `https://www.youtube.com/watch?v=${videoId}`;

      console.log(`✅ Video uploaded successfully!`);
      console.log(`🆔 Video ID: ${videoId}`);
      console.log(`🔗 Video URL: ${videoUrl}`);

      // Clean up temporary file
      await cleanupTempFile(tempFilePath);
      tempFilePath = null;

      // Return success response with video details
      res.json({
        success: true,
        message: 'Video uploaded successfully to YouTube',
        data: {
          videoId: videoId,
          videoUrl: videoUrl,
          title: videoData.snippet.title,
          description: videoData.snippet.description,
          publishedAt: videoData.snippet.publishedAt,
          privacyStatus: videoData.status.privacyStatus,
          thumbnails: videoData.snippet.thumbnails || {},
          tags: videoData.snippet.tags || [],
          uploadedAt: new Date().toISOString()
        }
      });

    } catch (error) {
      console.error('❌ Error uploading video:', error.message);

      // Clean up temporary file on error
      if (tempFilePath) {
        await cleanupTempFile(tempFilePath);
      }

      // Handle specific YouTube API errors
      if (error.code === 401 || error.message.includes('invalid_grant')) {
        return res.status(401).json({
          success: false,
          error: 'Authentication failed',
          message: 'Google account authentication failed. Please check the refresh token configuration.',
          details: 'The stored refresh token may have expired or been revoked.'
        });
      }

      if (error.code === 403) {
        return res.status(403).json({
          success: false,
          error: 'Insufficient permissions',
          message: 'The configured Google account does not have permission to upload videos.',
          details: 'Ensure the account has YouTube channel access and proper API permissions.'
        });
      }

      if (error.code === 400) {
        return res.status(400).json({
          success: false,
          error: 'Invalid video data',
          message: error.message || 'The video upload request was invalid',
          details: 'Check video file format, size, and metadata.'
        });
      }

      if (error.code === 409) {
        return res.status(409).json({
          success: false,
          error: 'Upload conflict',
          message: 'Video upload failed due to a conflict.',
          details: 'The video may already exist or there may be a quota issue.'
        });
      }

      // Handle quota exceeded errors
      if (error.message.includes('quota') || error.code === 429) {
        return res.status(429).json({
          success: false,
          error: 'Quota exceeded',
          message: 'YouTube API quota exceeded. Please try again later.',
          details: 'Daily upload quota for the YouTube account has been reached.'
        });
      }

      // Generic error response
      res.status(500).json({
        success: false,
        error: 'Video upload failed',
        message: 'An unexpected error occurred during video upload.',
        details: error.message
      });
    }
  }

  /**
   * Get video details from YouTube
   * 
   * @route GET /api/videos/:videoId
   * @access Public
   * @param {Object} req - Express request object
   * @param {Object} res - Express response object
   */
  async getVideoDetails(req, res) {
    try {
      const { videoId } = req.params;

      if (!videoId) {
        return res.status(400).json({
          success: false,
          error: 'Video ID is required'
        });
      }

      console.log(`🔍 Fetching details for video: ${videoId}`);

      // Get authenticated YouTube client
      const youtube = await googleAuth.getYouTubeClient();

      // Get video details from YouTube API
      const response = await youtube.videos.list({
        part: ['snippet', 'status', 'statistics'],
        id: [videoId]
      });

      if (response.data.items.length === 0) {
        return res.status(404).json({
          success: false,
          error: 'Video not found',
          message: `No video found with ID: ${videoId}`
        });
      }

      const video = response.data.items[0];

      res.json({
        success: true,
        data: {
          videoId: video.id,
          title: video.snippet.title,
          description: video.snippet.description,
          publishedAt: video.snippet.publishedAt,
          channelId: video.snippet.channelId,
          channelTitle: video.snippet.channelTitle,
          privacyStatus: video.status.privacyStatus,
          viewCount: video.statistics?.viewCount || '0',
          likeCount: video.statistics?.likeCount || '0',
          commentCount: video.statistics?.commentCount || '0',
          thumbnails: video.snippet.thumbnails || {},
          tags: video.snippet.tags || [],
          videoUrl: `https://www.youtube.com/watch?v=${video.id}`
        }
      });

    } catch (error) {
      console.error('❌ Error getting video details:', error.message);
      
      if (error.code === 401) {
        return res.status(401).json({
          success: false,
          error: 'Authentication failed',
          message: 'Failed to authenticate with YouTube API'
        });
      }

      res.status(500).json({
        success: false,
        error: 'Failed to get video details',
        message: error.message
      });
    }
  }

  /**
   * Test the Google authentication setup
   * 
   * @route GET /api/videos/test-auth
   * @access Public
   * @param {Object} req - Express request object
   * @param {Object} res - Express response object
   */
  async testAuthentication(req, res) {
    try {
      console.log('🧪 Testing Google authentication...');
      
      const authResult = await googleAuth.testAuthentication();
      
      res.json({
        success: true,
        message: 'Authentication test successful',
        data: authResult
      });

    } catch (error) {
      console.error('❌ Authentication test failed:', error.message);
      
      res.status(500).json({
        success: false,
        error: 'Authentication test failed',
        message: error.message,
        troubleshooting: {
          checkRefreshToken: 'Verify GOOGLE_REFRESH_TOKEN in .env file',
          checkCredentials: 'Verify GOOGLE_CLIENT_ID and GOOGLE_CLIENT_SECRET',
          checkPermissions: 'Ensure the Google account has YouTube access'
        }
      });
    }
  }

  /**
   * Get upload information and requirements
   * 
   * @route GET /api/videos/upload/info
   * @access Public
   * @param {Object} req - Express request object
   * @param {Object} res - Express response object
   */
  async getUploadInfo(req, res) {
    try {
      res.json({
        success: true,
        data: {
          maxFileSize: '2GB',
          supportedFormats: [
            'mp4', 'mpeg', 'mov', 'avi', 'wmv', 
            'webm', '3gp', 'flv', 'mkv'
          ],
          privacyOptions: ['private', 'unlisted', 'public'],
          defaultPrivacy: 'unlisted',
          maxTitleLength: 100,
          maxDescriptionLength: 5000,
          maxTags: 10,
          uploadEndpoint: '/api/videos/upload',
          authenticationRequired: false,
          note: 'All videos are uploaded to the configured YouTube channel'
        }
      });
    } catch (error) {
      res.status(500).json({
        success: false,
        error: 'Failed to get upload info',
        message: error.message
      });
    }
  }
}

module.exports = new VideoController();
