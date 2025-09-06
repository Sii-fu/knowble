const googleConfig = require('../config/googleConfig');

/**
 * In-memory token storage (replace with database in production)
 * In a real application, store tokens securely in a database
 */
let userTokens = {};

/**
 * Authentication Controller
 * Handles Google OAuth 2.0 authentication flow
 */
class AuthController {
  /**
   * Initiate Google OAuth 2.0 authentication
   * Generates authorization URL and redirects user to Google consent screen
   */
  async initiateAuth(req, res) {
    try {
      const authUrl = googleConfig.getAuthUrl();
      
      // For Flutter app integration, you might want to return JSON instead of redirect
      if (req.query.format === 'json') {
        return res.json({
          success: true,
          authUrl: authUrl,
          message: 'Open this URL in browser to authenticate'
        });
      }

      // Redirect to Google OAuth consent screen
      res.redirect(authUrl);
    } catch (error) {
      console.error('Error initiating auth:', error);
      res.status(500).json({
        success: false,
        error: 'Failed to initiate authentication',
        details: error.message
      });
    }
  }

  /**
   * Handle OAuth callback from Google
   * Exchange authorization code for access and refresh tokens
   */
  async handleCallback(req, res) {
    try {
      const { code, error } = req.query;

      if (error) {
        console.error('OAuth error:', error);
        return res.status(400).json({
          success: false,
          error: 'Authentication failed',
          details: error
        });
      }

      if (!code) {
        return res.status(400).json({
          success: false,
          error: 'Authorization code not provided'
        });
      }

      // Exchange code for tokens
      const tokens = await googleConfig.getTokens(code);
      
      if (!tokens.refresh_token) {
        console.warn('No refresh token received. User may have already granted access.');
      }

      // Store tokens (in production, use database with user association)
      const userId = 'default_user'; // In real app, get from session/JWT
      userTokens[userId] = {
        access_token: tokens.access_token,
        refresh_token: tokens.refresh_token || userTokens[userId]?.refresh_token,
        expires_at: Date.now() + (tokens.expires_in * 1000),
        created_at: new Date().toISOString()
      };

      console.log('Tokens stored successfully for user:', userId);

      // For Flutter app, you might want to redirect to custom scheme
      const flutterScheme = process.env.FLUTTER_APP_SCHEME;
      if (flutterScheme && req.query.mobile === 'true') {
        return res.redirect(`${flutterScheme}?success=true&message=Authentication successful`);
      }

      // Return success response
      res.json({
        success: true,
        message: 'Authentication successful! You can now upload videos.',
        hasRefreshToken: !!tokens.refresh_token
      });

    } catch (error) {
      console.error('Error in OAuth callback:', error);
      res.status(500).json({
        success: false,
        error: 'Failed to complete authentication',
        details: error.message
      });
    }
  }

  /**
   * Check authentication status
   * Verify if user has valid tokens
   */
  async checkAuthStatus(req, res) {
    try {
      const userId = 'default_user'; // In real app, get from session/JWT
      const tokens = userTokens[userId];

      if (!tokens) {
        return res.json({
          authenticated: false,
          message: 'No authentication found'
        });
      }

      // Check if access token is expired
      const isExpired = Date.now() >= tokens.expires_at;
      
      res.json({
        authenticated: true,
        hasRefreshToken: !!tokens.refresh_token,
        accessTokenExpired: isExpired,
        authenticatedAt: tokens.created_at
      });

    } catch (error) {
      console.error('Error checking auth status:', error);
      res.status(500).json({
        success: false,
        error: 'Failed to check authentication status',
        details: error.message
      });
    }
  }

  /**
   * Logout user by clearing stored tokens
   */
  async logout(req, res) {
    try {
      const userId = 'default_user'; // In real app, get from session/JWT
      delete userTokens[userId];

      res.json({
        success: true,
        message: 'Logged out successfully'
      });

    } catch (error) {
      console.error('Error during logout:', error);
      res.status(500).json({
        success: false,
        error: 'Failed to logout',
        details: error.message
      });
    }
  }

  /**
   * Get stored tokens for a user (internal use)
   * @param {string} userId - User identifier
   * @returns {Object|null} User tokens or null if not found
   */
  static getStoredTokens(userId = 'default_user') {
    return userTokens[userId] || null;
  }

  /**
   * Update stored tokens (internal use)
   * @param {string} userId - User identifier
   * @param {Object} tokens - Updated tokens
   */
  static updateStoredTokens(userId = 'default_user', tokens) {
    if (userTokens[userId]) {
      userTokens[userId] = { ...userTokens[userId], ...tokens };
    }
  }
}

// Export both the instance and the class for static method access
const authControllerInstance = new AuthController();
authControllerInstance.getStoredTokens = AuthController.getStoredTokens;
authControllerInstance.updateStoredTokens = AuthController.updateStoredTokens;

module.exports = authControllerInstance;
