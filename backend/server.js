const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const rateLimit = require('express-rate-limit');
const path = require('path');
require('dotenv').config();

// Import routes
const videoRoutes = require('./routes/videos');

/**
 * Knowble YouTube API Server
 * Node.js backend for handling YouTube video uploads from Flutter app
 * Uses a fixed Google account for all uploads - no per-user authentication required
 */

const app = express();
const PORT = process.env.PORT || 3000;

/**
 * Security middleware
 */
// Basic security headers
app.use(helmet({
  crossOriginEmbedderPolicy: false, // Allow embedding for OAuth redirects
}));

// CORS configuration for Flutter app
app.use(cors({
  origin: [
    'http://localhost:3000',
    'http://127.0.0.1:3000',
    'capacitor://localhost', // For Ionic/Capacitor apps
    'ionic://localhost',     // For Ionic apps
    'http://localhost',      // For local development
    // Add your Flutter app's domain here when deployed
  ],
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization', 'X-Requested-With']
}));

/**
 * Rate limiting
 */
// General rate limiting
const generalLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100, // limit each IP to 100 requests per windowMs
  message: {
    success: false,
    error: 'Too many requests',
    message: 'Please try again later'
  }
});

// Upload rate limiting (more restrictive)
const uploadLimiter = rateLimit({
  windowMs: 60 * 60 * 1000, // 1 hour
  max: 10, // limit each IP to 10 uploads per hour
  message: {
    success: false,
    error: 'Upload limit exceeded',
    message: 'You can upload maximum 10 videos per hour'
  }
});

// Auth rate limiting
const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 20, // limit each IP to 20 auth requests per windowMs
  message: {
    success: false,
    error: 'Too many authentication attempts',
    message: 'Please try again later'
  }
});

/**
 * Middleware
 */
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// Apply rate limiting
app.use('/api/', generalLimiter);
app.use('/api/auth/', authLimiter);
app.use('/api/videos/upload', uploadLimiter);

/**
 * API Routes
 */
app.use('/api/videos', videoRoutes);

/**
 * Health check endpoint
 */
app.get('/health', (req, res) => {
  res.json({
    success: true,
    message: 'Knowble YouTube API Server is running',
    timestamp: new Date().toISOString(),
    version: '1.0.0',
    endpoints: {
      videos: {
        upload: 'POST /api/videos/upload',
        details: 'GET /api/videos/:videoId', 
        testAuth: 'GET /api/videos/test-auth',
        info: 'GET /api/videos/upload/info'
      }
    }
  });
});

/**
 * API documentation endpoint
 */
app.get('/api', (req, res) => {
  res.json({
    name: 'Knowble YouTube API',
    version: '2.0.0',
    description: 'Node.js backend API for YouTube video uploads from Flutter app using fixed Google account',
    documentation: {
      authentication: {
        description: 'Uses a fixed Google account with stored refresh token',
        setup: [
          '1. Complete Google OAuth flow once manually to obtain refresh token',
          '2. Store GOOGLE_REFRESH_TOKEN in .env file',
          '3. All uploads use the configured account automatically'
        ],
        note: 'No per-user authentication required - all videos upload to same YouTube channel'
      },
      videoUpload: {
        description: 'Upload videos directly to the configured YouTube channel',
        requirements: [
          'Video file (max 2GB)',
          'Supported formats: mp4, mpeg, mov, avi, wmv, webm, 3gp, flv, mkv'
        ],
        endpoint: 'POST /api/videos/upload',
        fields: {
          video: 'file (required)',
          title: 'string (optional)',
          description: 'string (optional)',
          tags: 'string (optional, comma-separated)',
          privacy: 'string (optional: private, public, unlisted, default: unlisted)'
        }
      }
    },
    endpoints: '/health for detailed endpoint list'
  });
});

/**
 * 404 handler
 */
app.use('*', (req, res) => {
  res.status(404).json({
    success: false,
    error: 'Endpoint not found',
    message: `${req.method} ${req.originalUrl} is not a valid endpoint`,
    availableEndpoints: '/api for documentation'
  });
});

/**
 * Global error handler
 */
app.use((error, req, res, next) => {
  console.error('Global error handler:', error);

  // Don't expose internal errors in production
  const isDevelopment = process.env.NODE_ENV === 'development';

  res.status(error.status || 500).json({
    success: false,
    error: error.message || 'Internal server error',
    ...(isDevelopment && { stack: error.stack })
  });
});

/**
 * Graceful shutdown handling
 */
process.on('SIGTERM', () => {
  console.log('SIGTERM received, shutting down gracefully...');
  process.exit(0);
});

process.on('SIGINT', () => {
  console.log('SIGINT received, shutting down gracefully...');
  process.exit(0);
});

/**
 * Start server
 */
const server = app.listen(PORT, () => {
  console.log('🚀 Knowble YouTube API Server started');
  console.log(`📡 Server running on port ${PORT}`);
  console.log(`🌐 Base URL: http://localhost:${PORT}`);
  console.log(`📚 API Documentation: http://localhost:${PORT}/api`);
  console.log(`💚 Health Check: http://localhost:${PORT}/health`);
  console.log('');
  console.log('Available endpoints:');
  console.log('  Videos:');
  console.log(`    POST http://localhost:${PORT}/api/videos/upload`);
  console.log(`    GET  http://localhost:${PORT}/api/videos/:videoId`);
  console.log(`    GET  http://localhost:${PORT}/api/videos/test-auth`);
  console.log(`    GET  http://localhost:${PORT}/api/videos/upload/info`);
  console.log('');
  console.log('📋 Make sure to configure your .env file with:');
  console.log('   GOOGLE_CLIENT_ID, GOOGLE_CLIENT_SECRET, GOOGLE_REDIRECT_URI, GOOGLE_REFRESH_TOKEN');
});

// Handle server startup errors
server.on('error', (error) => {
  if (error.code === 'EADDRINUSE') {
    console.error(`❌ Port ${PORT} is already in use`);
    console.error('Please try a different port or stop the existing service');
  } else {
    console.error('❌ Server startup error:', error);
  }
  process.exit(1);
});

module.exports = app;
