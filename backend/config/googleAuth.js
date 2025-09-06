const { google } = require('googleapis');
require('dotenv').config();

/**
 * Google Authentication Helper
 * Manages authentication for a single fixed Google account for YouTube uploads
 * 
 * This module handles:
 * - OAuth2 client setup with stored refresh token
 * - Automatic access token refresh
 * - YouTube API client initialization
 */
class GoogleAuth {
  constructor() {
    // Validate required environment variables
    this.validateEnvironment();
    
    // Initialize OAuth2 client
    this.oauth2Client = new google.auth.OAuth2(
      process.env.GOOGLE_CLIENT_ID,
      process.env.GOOGLE_CLIENT_SECRET,
      process.env.GOOGLE_REDIRECT_URI
    );

    // Set the stored refresh token
    this.oauth2Client.setCredentials({
      refresh_token: process.env.GOOGLE_REFRESH_TOKEN
    });

    // Initialize YouTube API client
    this.youtube = google.youtube({
      version: 'v3',
      auth: this.oauth2Client
    });

    console.log('✅ Google Auth initialized for fixed account');
  }

  /**
   * Validate that all required environment variables are present
   * @throws {Error} If any required environment variable is missing
   */
  validateEnvironment() {
    const required = [
      'GOOGLE_CLIENT_ID',
      'GOOGLE_CLIENT_SECRET', 
      'GOOGLE_REDIRECT_URI',
      'GOOGLE_REFRESH_TOKEN'
    ];

    const missing = required.filter(key => !process.env[key]);
    
    if (missing.length > 0) {
      throw new Error(
        `Missing required environment variables: ${missing.join(', ')}\n` +
        'Please ensure these are set in your .env file:\n' +
        missing.map(key => `${key}=your_${key.toLowerCase()}_here`).join('\n')
      );
    }
  }

  /**
   * Get a fresh access token using the stored refresh token
   * This method automatically handles token refresh and caching
   * 
   * @returns {Promise<string>} Fresh access token
   * @throws {Error} If token refresh fails
   */
  async getFreshAccessToken() {
    try {
      console.log('🔄 Refreshing Google access token...');
      
      // Request fresh access token using refresh token
      const { credentials } = await this.oauth2Client.refreshAccessToken();
      
      // Update the OAuth2 client with new credentials
      this.oauth2Client.setCredentials(credentials);
      
      console.log('✅ Access token refreshed successfully');
      console.log(`🕒 Token expires at: ${new Date(credentials.expiry_date)}`);
      
      return credentials.access_token;
    } catch (error) {
      console.error('❌ Failed to refresh access token:', error.message);
      
      // Provide helpful error messages for common issues
      if (error.message.includes('invalid_grant')) {
        throw new Error(
          'Invalid refresh token. The refresh token may have expired or been revoked. ' +
          'Please re-run the manual OAuth flow to obtain a new refresh token.'
        );
      }
      
      if (error.message.includes('invalid_client')) {
        throw new Error(
          'Invalid client credentials. Please check your GOOGLE_CLIENT_ID and ' +
          'GOOGLE_CLIENT_SECRET in the .env file.'
        );
      }
      
      throw new Error(`Token refresh failed: ${error.message}`);
    }
  }

  /**
   * Get an authenticated YouTube API client
   * Automatically refreshes the access token if needed
   * 
   * @returns {Promise<Object>} YouTube API client instance
   */
  async getYouTubeClient() {
    try {
      // Ensure we have a fresh access token
      await this.getFreshAccessToken();
      
      // Return the authenticated YouTube client
      return this.youtube;
    } catch (error) {
      console.error('❌ Failed to get YouTube client:', error.message);
      throw error;
    }
  }

  /**
   * Test the authentication setup by making a simple API call
   * Useful for verifying the configuration is working
   * 
   * @returns {Promise<Object>} Channel information if successful
   * @throws {Error} If authentication test fails
   */
  async testAuthentication() {
    try {
      console.log('🧪 Testing Google authentication...');
      
      const youtube = await this.getYouTubeClient();
      
      // Make a simple API call to verify authentication
      const response = await youtube.channels.list({
        part: ['snippet'],
        mine: true
      });

      if (response.data.items && response.data.items.length > 0) {
        const channel = response.data.items[0];
        console.log('✅ Authentication test successful');
        console.log(`📺 Connected to channel: ${channel.snippet.title}`);
        console.log(`🆔 Channel ID: ${channel.id}`);
        
        return {
          success: true,
          channel: {
            id: channel.id,
            title: channel.snippet.title,
            description: channel.snippet.description,
            customUrl: channel.snippet.customUrl,
            publishedAt: channel.snippet.publishedAt
          }
        };
      } else {
        throw new Error('No YouTube channel found for the authenticated account');
      }
    } catch (error) {
      console.error('❌ Authentication test failed:', error.message);
      throw new Error(`Authentication test failed: ${error.message}`);
    }
  }

  /**
   * Get OAuth2 client instance for direct use
   * @returns {Object} OAuth2 client
   */
  getOAuth2Client() {
    return this.oauth2Client;
  }
}

// Export a singleton instance
const googleAuth = new GoogleAuth();

module.exports = googleAuth;
