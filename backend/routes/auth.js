const express = require('express');
const router = express.Router();
const authController = require('../controllers/authController');

/**
 * Authentication Routes
 * Handles Google OAuth 2.0 authentication flow
 */

/**
 * @route   GET /api/auth/google
 * @desc    Initiate Google OAuth 2.0 authentication
 * @access  Public
 * @query   format - 'json' to return auth URL as JSON instead of redirect
 */
router.get('/google', authController.initiateAuth);

/**
 * @route   GET /api/auth/google/callback
 * @desc    Handle OAuth callback from Google
 * @access  Public
 * @query   code - Authorization code from Google
 * @query   error - Error from Google OAuth
 * @query   mobile - 'true' to redirect to Flutter app scheme
 */
router.get('/google/callback', authController.handleCallback);

/**
 * @route   GET /api/auth/status
 * @desc    Check current authentication status
 * @access  Public
 */
router.get('/status', authController.checkAuthStatus);

/**
 * @route   POST /api/auth/logout
 * @desc    Logout user and clear stored tokens
 * @access  Public
 */
router.post('/logout', authController.logout);

module.exports = router;
