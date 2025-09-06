const fs = require('fs-extra');
const path = require('path');
const googleConfig = require('../config/googleConfig');
const authController = require('./authController');

/**
 * Utility function to clean up temporary uploaded files
 * @param {string} filePath - Path to temporary file
 */
async function cleanupTempFile(filePath) {
  try {
    if (filePath && await fs.pathExists(filePath)) {
      await fs.remove(filePath);
      console.log('Temporary file cleaned up:', filePath);
    }
  } catch (error) {
    console.error('Error cleaning up temporary file:', error);
  }
}

/**
 * Video Controller
 * Handles YouTube video upload functionality
 */
class VideoController {
  /**
   * Upload video to YouTube
   * Handles file upload, authentication, and YouTube API integration
   */
  async uploadVideo(req, res) {
    let tempFilePath = null;

    try {
      // Check if file was uploaded
      if (!req.file) {
        return res.status(400).json({
          success: false,
          error: 'No video file provided'
        });
      }

      tempFilePath = req.file.path;

      // Get video metadata from request body
      const {
        title = 'Untitled Video',
        description = 'Uploaded via Knowble App',
        tags = 'knowble,education',
        privacy = 'unlisted' // private, public, unlisted
      } = req.body;

      console.log('Starting video upload process...');
      console.log('File:', req.file.filename);
      console.log('Title:', title);

      // Get stored authentication tokens
      const userId = 'default_user'; // In real app, get from session/JWT
      const storedTokens = authController.getStoredTokens(userId);

      if (!storedTokens) {
        return res.status(401).json({
          success: false,
          error: 'Authentication required',
          message: 'Please authenticate with Google first'
        });
      }

      // Check if access token needs refresh
      const needsRefresh = Date.now() >= storedTokens.expires_at;
      let activeTokens = storedTokens;

      if (needsRefresh && storedTokens.refresh_token) {
        console.log('Refreshing access token...');
        try {
          const refreshedTokens = await googleConfig.refreshAccessToken(storedTokens.refresh_token);
          
          // Update stored tokens
          activeTokens = {
            ...storedTokens,
            access_token: refreshedTokens.access_token,
            expires_at: Date.now() + (refreshedTokens.expires_in * 1000)
          };
          
          authController.updateStoredTokens(userId, activeTokens);
          console.log('Access token refreshed successfully');
        } catch (refreshError) {
          console.error('Failed to refresh token:', refreshError);
          return res.status(401).json({
            success: false,
            error: 'Token refresh failed',
            message: 'Please re-authenticate with Google'
          });
        }
      } else if (needsRefresh) {
        return res.status(401).json({
          success: false,
          error: 'Token expired and no refresh token available',
          message: 'Please re-authenticate with Google'
        });
      }

      // Set credentials for YouTube API
      googleConfig.setCredentials({
        access_token: activeTokens.access_token,
        refresh_token: activeTokens.refresh_token
      });

      // Prepare video metadata for YouTube API
      const videoMetadata = {
        snippet: {
          title: title,
          description: description,
          tags: tags.split(',').map(tag => tag.trim()),
          categoryId: '22', // People & Blogs category
          defaultLanguage: 'en',
          defaultAudioLanguage: 'en'
        },
        status: {
          privacyStatus: privacy, // private, public, unlisted
          embeddable: true,
          license: 'youtube',
          selfDeclaredMadeForKids: false
        }
      };

      console.log('Uploading to YouTube...');

      // Upload video to YouTube using resumable upload
      const youtube = googleConfig.getYouTubeClient();
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

      console.log('Video uploaded successfully:', videoId);

      // Clean up temporary file
      await cleanupTempFile(tempFilePath);
      tempFilePath = null;

      // Return success response with video details
      res.json({
        success: true,
        message: 'Video uploaded successfully',
        data: {
          videoId: videoId,
          videoUrl: videoUrl,
          title: videoData.snippet.title,
          description: videoData.snippet.description,
          publishedAt: videoData.snippet.publishedAt,
          privacyStatus: videoData.status.privacyStatus,
          thumbnails: videoData.snippet.thumbnails
        }
      });

    } catch (error) {
      console.error('Error uploading video:', error);

      // Clean up temporary file on error
      if (tempFilePath) {
        await cleanupTempFile(tempFilePath);
      }

      // Handle specific YouTube API errors
      if (error.code === 401) {
        return res.status(401).json({
          success: false,
          error: 'Authentication failed',
          message: 'Please re-authenticate with Google'
        });
      }

      if (error.code === 403) {
        return res.status(403).json({
          success: false,
          error: 'Insufficient permissions',
          message: 'Your Google account does not have permission to upload videos'
        });
      }

      if (error.code === 400) {
        return res.status(400).json({
          success: false,
          error: 'Invalid request',
          message: error.message || 'The video upload request was invalid'
        });
      }

      // Generic error response
      res.status(500).json({
        success: false,
        error: 'Video upload failed',
        details: error.message
      });
    }
  }

  /**
   * Get video upload status and details
   * Check the status of a previously uploaded video
   */
  async getVideoStatus(req, res) {
    try {
      const { videoId } = req.params;

      if (!videoId) {
        return res.status(400).json({
          success: false,
          error: 'Video ID is required'
        });
      }

      // Get stored authentication tokens
      const userId = 'default_user';
      const storedTokens = authController.getStoredTokens(userId);

      if (!storedTokens) {
        return res.status(401).json({
          success: false,
          error: 'Authentication required'
        });
      }

      // Set credentials
      googleConfig.setCredentials({
        access_token: storedTokens.access_token,
        refresh_token: storedTokens.refresh_token
      });

      // Get video details from YouTube API
      const youtube = googleConfig.getYouTubeClient();
      const response = await youtube.videos.list({
        part: ['snippet', 'status', 'statistics'],
        id: [videoId]
      });

      if (response.data.items.length === 0) {
        return res.status(404).json({
          success: false,
          error: 'Video not found'
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
          privacyStatus: video.status.privacyStatus,
          viewCount: video.statistics?.viewCount || '0',
          likeCount: video.statistics?.likeCount || '0',
          thumbnails: video.snippet.thumbnails,
          videoUrl: `https://www.youtube.com/watch?v=${video.id}`
        }
      });

    } catch (error) {
      console.error('Error getting video status:', error);
      res.status(500).json({
        success: false,
        error: 'Failed to get video status',
        details: error.message
      });
    }
  }

  /**
   * Get user's uploaded videos
   * Retrieve list of videos uploaded by the authenticated user
   */
  async getUserVideos(req, res) {
    try {
      // Get stored authentication tokens
      const userId = 'default_user';
      const storedTokens = authController.getStoredTokens(userId);

      if (!storedTokens) {
        return res.status(401).json({
          success: false,
          error: 'Authentication required'
        });
      }

      // Set credentials
      googleConfig.setCredentials({
        access_token: storedTokens.access_token,
        refresh_token: storedTokens.refresh_token
      });

      const youtube = googleConfig.getYouTubeClient();

      // Get user's channel
      const channelResponse = await youtube.channels.list({
        part: ['snippet', 'contentDetails'],
        mine: true
      });

      if (channelResponse.data.items.length === 0) {
        return res.status(404).json({
          success: false,
          error: 'No YouTube channel found for this account'
        });
      }

      const channel = channelResponse.data.items[0];
      const uploadsPlaylistId = channel.contentDetails.relatedPlaylists.uploads;

      // Get videos from uploads playlist
      const videosResponse = await youtube.playlistItems.list({
        part: ['snippet'],
        playlistId: uploadsPlaylistId,
        maxResults: 25
      });

      const videos = videosResponse.data.items.map(item => ({
        videoId: item.snippet.resourceId.videoId,
        title: item.snippet.title,
        description: item.snippet.description,
        publishedAt: item.snippet.publishedAt,
        thumbnails: item.snippet.thumbnails,
        videoUrl: `https://www.youtube.com/watch?v=${item.snippet.resourceId.videoId}`
      }));

      res.json({
        success: true,
        data: {
          channel: {
            id: channel.id,
            title: channel.snippet.title,
            description: channel.snippet.description
          },
          videos: videos,
          totalVideos: videos.length
        }
      });

    } catch (error) {
      console.error('Error getting user videos:', error);
      res.status(500).json({
        success: false,
        error: 'Failed to get user videos',
        details: error.message
      });
    }
  }

}

module.exports = new VideoController();
