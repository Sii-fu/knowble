# Deployment Guide

This guide covers deploying the YouTube API backend to various platforms.

## 🚀 Quick Deployment Checklist

- [ ] Configure Google OAuth credentials for production domain
- [ ] Set up environment variables on hosting platform
- [ ] Update CORS settings for production Flutter app
- [ ] Configure database for token storage (replace in-memory storage)
- [ ] Set up SSL/HTTPS
- [ ] Configure rate limiting for production traffic
- [ ] Set up monitoring and logging
- [ ] Test all endpoints in production

## 🌐 Platform-Specific Deployment

### Heroku

1. **Install Heroku CLI**
2. **Create Heroku app:**
   ```bash
   heroku create knowble-youtube-api
   ```

3. **Set environment variables:**
   ```bash
   heroku config:set GOOGLE_CLIENT_ID=your_client_id
   heroku config:set GOOGLE_CLIENT_SECRET=your_client_secret
   heroku config:set GOOGLE_REDIRECT_URI=https://your-app.herokuapp.com/api/auth/google/callback
   heroku config:set NODE_ENV=production
   ```

4. **Deploy:**
   ```bash
   git add .
   git commit -m "Deploy YouTube API"
   git push heroku main
   ```

### Railway

1. **Connect GitHub repository to Railway**
2. **Set environment variables in Railway dashboard**
3. **Deploy automatically on git push**

### DigitalOcean App Platform

1. **Create new app from GitHub**
2. **Configure environment variables**
3. **Set build and run commands:**
   - Build: `npm install`
   - Run: `npm start`

### AWS EC2

1. **Launch EC2 instance**
2. **Install Node.js:**
   ```bash
   curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
   sudo apt-get install -y nodejs
   ```

3. **Install PM2:**
   ```bash
   npm install -g pm2
   ```

4. **Deploy and run:**
   ```bash
   git clone your-repo
   cd backend
   npm install
   pm2 start server.js --name youtube-api
   pm2 startup
   pm2 save
   ```

### Google Cloud Platform

1. **Create `app.yaml`:**
   ```yaml
   runtime: nodejs18
   
   env_variables:
     GOOGLE_CLIENT_ID: "your_client_id"
     GOOGLE_CLIENT_SECRET: "your_client_secret"
     GOOGLE_REDIRECT_URI: "https://your-project.appspot.com/api/auth/google/callback"
     NODE_ENV: "production"
   
   automatic_scaling:
     min_instances: 1
     max_instances: 10
   ```

2. **Deploy:**
   ```bash
   gcloud app deploy
   ```

## 🔧 Production Configuration

### Environment Variables

Update `.env` for production:

```env
# Google OAuth 2.0 Configuration
GOOGLE_CLIENT_ID=your_production_client_id
GOOGLE_CLIENT_SECRET=your_production_client_secret
GOOGLE_REDIRECT_URI=https://yourdomain.com/api/auth/google/callback

# Server Configuration
PORT=3000
NODE_ENV=production

# Database (replace in-memory storage)
DATABASE_URL=postgresql://user:password@host:port/database

# Security
JWT_SECRET=your_jwt_secret_for_sessions
CORS_ORIGINS=https://your-flutter-app.com,https://your-web-app.com

# Monitoring
LOG_LEVEL=info
SENTRY_DSN=your_sentry_dsn # Optional error tracking
```

### Database Integration

Replace in-memory token storage with a database:

```javascript
// Example with PostgreSQL
const { Pool } = require('pg');

const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: process.env.NODE_ENV === 'production' ? { rejectUnauthorized: false } : false
});

// Create tokens table
async function createTokensTable() {
  await pool.query(`
    CREATE TABLE IF NOT EXISTS user_tokens (
      user_id VARCHAR(255) PRIMARY KEY,
      access_token TEXT,
      refresh_token TEXT,
      expires_at BIGINT,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    )
  `);
}

// Update AuthController to use database
class AuthController {
  static async storeTokens(userId, tokens) {
    await pool.query(`
      INSERT INTO user_tokens (user_id, access_token, refresh_token, expires_at)
      VALUES ($1, $2, $3, $4)
      ON CONFLICT (user_id) 
      DO UPDATE SET 
        access_token = $2,
        refresh_token = COALESCE($3, user_tokens.refresh_token),
        expires_at = $4,
        updated_at = CURRENT_TIMESTAMP
    `, [userId, tokens.access_token, tokens.refresh_token, tokens.expires_at]);
  }

  static async getStoredTokens(userId) {
    const result = await pool.query(
      'SELECT * FROM user_tokens WHERE user_id = $1',
      [userId]
    );
    return result.rows[0] || null;
  }
}
```

### SSL/HTTPS Configuration

For custom domains, use Let's Encrypt:

```bash
# Install certbot
sudo apt install certbot

# Get SSL certificate
sudo certbot certonly --standalone -d yourdomain.com

# Update server.js for HTTPS
const https = require('https');
const fs = require('fs');

const options = {
  key: fs.readFileSync('/etc/letsencrypt/live/yourdomain.com/privkey.pem'),
  cert: fs.readFileSync('/etc/letsencrypt/live/yourdomain.com/fullchain.pem')
};

https.createServer(options, app).listen(443, () => {
  console.log('HTTPS Server running on port 443');
});
```

## 📊 Monitoring and Logging

### Basic Logging

```javascript
const winston = require('winston');

const logger = winston.createLogger({
  level: process.env.LOG_LEVEL || 'info',
  format: winston.format.combine(
    winston.format.timestamp(),
    winston.format.json()
  ),
  transports: [
    new winston.transports.File({ filename: 'error.log', level: 'error' }),
    new winston.transports.File({ filename: 'combined.log' })
  ]
});

if (process.env.NODE_ENV !== 'production') {
  logger.add(new winston.transports.Console({
    format: winston.format.simple()
  }));
}
```

### Health Check Endpoint

Enhanced health check for monitoring:

```javascript
app.get('/health', async (req, res) => {
  const health = {
    status: 'healthy',
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    memory: process.memoryUsage(),
    version: process.env.npm_package_version || '1.0.0'
  };

  // Check database connection
  try {
    await pool.query('SELECT 1');
    health.database = 'connected';
  } catch (error) {
    health.database = 'disconnected';
    health.status = 'unhealthy';
  }

  // Check Google API
  try {
    // Simple API check
    health.googleApi = 'accessible';
  } catch (error) {
    health.googleApi = 'inaccessible';
    health.status = 'degraded';
  }

  const statusCode = health.status === 'healthy' ? 200 : 503;
  res.status(statusCode).json(health);
});
```

## 🔒 Security Best Practices

### 1. Rate Limiting Configuration

```javascript
// Production rate limiting
const productionLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: process.env.NODE_ENV === 'production' ? 50 : 100,
  message: {
    error: 'Too many requests',
    retryAfter: Math.ceil(15 * 60 * 1000 / 1000) // seconds
  }
});
```

### 2. Input Validation

```javascript
const { body, validationResult } = require('express-validator');

// Validation middleware
const validateVideoUpload = [
  body('title').isLength({ min: 1, max: 100 }).trim().escape(),
  body('description').optional().isLength({ max: 500 }).trim().escape(),
  body('privacy').optional().isIn(['private', 'public', 'unlisted']),
  (req, res, next) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        error: 'Validation failed',
        details: errors.array()
      });
    }
    next();
  }
];

// Use in routes
router.post('/upload', upload.single('video'), validateVideoUpload, videoController.uploadVideo);
```

### 3. CORS Configuration

```javascript
// Production CORS
app.use(cors({
  origin: function (origin, callback) {
    const allowedOrigins = process.env.CORS_ORIGINS?.split(',') || ['http://localhost:3000'];
    if (!origin || allowedOrigins.includes(origin)) {
      callback(null, true);
    } else {
      callback(new Error('Not allowed by CORS'));
    }
  },
  credentials: true
}));
```

## 📱 Flutter App Configuration

Update your Flutter app for production:

```dart
class Config {
  static const bool kDebugMode = bool.fromEnvironment('dart.vm.product') == false;
  
  static const String developmentApiUrl = 'http://localhost:3000/api';
  static const String productionApiUrl = 'https://yourdomain.com/api';
  
  static String get apiUrl => kDebugMode ? developmentApiUrl : productionApiUrl;
}
```

## 🚨 Troubleshooting Production Issues

### Common Issues

1. **OAuth Redirect Mismatch**
   - Ensure Google OAuth redirect URI matches production domain
   - Check HTTPS vs HTTP in redirect URI

2. **CORS Errors**
   - Verify CORS_ORIGINS includes your Flutter app's domain
   - Check preflight OPTIONS requests

3. **File Upload Timeouts**
   - Increase server timeout for large files
   - Consider implementing resumable uploads

4. **Memory Issues**
   - Monitor memory usage during file uploads
   - Implement streaming uploads for large files

5. **Rate Limiting**
   - Monitor rate limit logs
   - Adjust limits based on usage patterns

### Debugging Commands

```bash
# Check logs
heroku logs --tail -a your-app-name

# Check health
curl https://yourdomain.com/health

# Test endpoints
curl -X GET https://yourdomain.com/api/auth/status
```

## 📈 Scaling Considerations

### Load Balancing

For high traffic, consider:
- Multiple server instances
- Load balancer (nginx, AWS ALB)
- Database connection pooling
- Redis for session storage

### File Storage

For production file handling:
- Use cloud storage (AWS S3, Google Cloud Storage)
- Implement direct upload to cloud storage
- Add virus scanning for uploaded files

### Monitoring

- Set up application monitoring (New Relic, DataDog)
- Configure alerts for errors and performance
- Monitor YouTube API quota usage
- Track upload success/failure rates

This deployment guide should help you get your YouTube API backend running in production!
