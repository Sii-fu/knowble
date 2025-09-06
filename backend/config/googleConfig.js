const { google } = require('googleapis');
require('dotenv').config();

/**
 * Google OAuth 2.0 Configuration
 * Sets up the OAuth2 client for YouTube API access
 */
class GoogleConfig {
  constructor() {
    this.oauth2Client = new google.auth.OAuth2(
      process.env.GOOGLE_CLIENT_ID,
      process.env.GOOGLE_CLIENT_SECRET,
      process.env.GOOGLE_REDIRECT_URI
    );

    // Set up YouTube API client
    this.youtube = google.youtube({
      version: 'v3',
      auth: this.oauth2Client
    });
  }

  /**
   * Generate OAuth 2.0 authorization URL
   * @returns {string} Authorization URL with proper scopes
   */
  getAuthUrl() {
    const scopes = [
      'https://www.googleapis.com/auth/youtube.upload',
      'https://www.googleapis.com/auth/youtube.readonly'
    ];

    return this.oauth2Client.generateAuthUrl({
      access_type: 'offline', // Required for refresh token
      scope: scopes,
      prompt: 'consent' // Force consent screen to get refresh token
    });
  }

  /**
   * Exchange authorization code for tokens
   * @param {string} code - Authorization code from Google
   * @returns {Object} Token response containing access_token and refresh_token
   */
  async getTokens(code) {
    try {
      const { tokens } = await this.oauth2Client.getToken(code);
      return tokens;
    } catch (error) {
      throw new Error(`Failed to exchange code for tokens: ${error.message}`);
    }
  }

  /**
   * Set credentials for OAuth client
   * @param {Object} tokens - Access and refresh tokens
   */
  setCredentials(tokens) {
    this.oauth2Client.setCredentials(tokens);
  }

  /**
   * Refresh access token using refresh token
   * @param {string} refreshToken - Stored refresh token
   * @returns {Object} New access token
   */
  async refreshAccessToken(refreshToken) {
    try {
      this.oauth2Client.setCredentials({ refresh_token: refreshToken });
      const { credentials } = await this.oauth2Client.refreshAccessToken();
      return credentials;
    } catch (error) {
      throw new Error(`Failed to refresh access token: ${error.message}`);
    }
  }

  /**
   * Get YouTube API client instance
   * @returns {Object} YouTube API client
   */
  getYouTubeClient() {
    return this.youtube;
  }

  /**
   * Get OAuth2 client instance
   * @returns {Object} OAuth2 client
   */
  getOAuth2Client() {
    return this.oauth2Client;
  }
}

module.exports = new GoogleConfig();
