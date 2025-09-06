# Knowble YouTube API Backend v2.0

A Node.js backend service that handles YouTube video uploads for the Knowble Flutter app using a **fixed Google account**. All videos are uploaded to a single YouTube channel without requiring per-user authentication.

## 🔧 Configuration Overview

This backend uses a **single Google account** with a stored refresh token to upload all videos to one YouTube channel. This simplifies the authentication flow and ensures all content goes to a centralized location.

### Architecture Benefits:
- ✅ No per-user OAuth required
- ✅ Centralized content management  
- ✅ Simplified authentication flow
- ✅ Production-ready with proper error handling
- ✅ Automatic token refresh

## 📋 Prerequisites

1. **Google Cloud Project** with YouTube Data API v3 enabled
2. **OAuth 2.0 credentials** (Client ID and Secret)
3. **YouTube channel** for the Google account that will receive uploads
4. **Node.js** 14+ and npm

## 🚀 Quick Setup

### 1. Install Dependencies

```bash
cd backend
npm install
```

### 2. Configure Environment Variables

Update `.env` with your Google OAuth credentials:

```env
# Google OAuth 2.0 Configuration for Fixed Account
GOOGLE_CLIENT_ID=your_client_id_here
GOOGLE_CLIENT_SECRET=your_client_secret_here
GOOGLE_REDIRECT_URI=http://localhost:3000/api/auth/google/callback

# Google Refresh Token for Fixed Account (REQUIRED)
GOOGLE_REFRESH_TOKEN=your_refresh_token_here

# Server Configuration
PORT=3000
NODE_ENV=development
```

### 3. Obtain Refresh Token (One-Time Setup)

**Important:** You need to run this setup once to get the refresh token.

#### Step 3a: Add Setup Redirect URI to Google Cloud Console

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Navigate to **APIs & Services** → **Credentials**
3. Edit your OAuth 2.0 client
4. Add this redirect URI: `http://localhost:3002/auth/callback`

#### Step 3b: Run the Setup Tool

```bash
node setup-refresh-token.js
```

1. Open http://localhost:3002 in your browser
2. Click "Start OAuth Flow"
3. **Sign in with the Google account that owns the YouTube channel** where videos should be uploaded
4. Grant permissions for YouTube upload and read access
5. Copy the refresh token provided
6. Add it to your `.env` file as `GOOGLE_REFRESH_TOKEN`

### 4. Start the Server

```bash
node server.js
```

The server will start on http://localhost:3000 with these endpoints:
- `POST /api/videos/upload` - Upload video to YouTube
- `GET /api/videos/:videoId` - Get video details
- `GET /api/videos/test-auth` - Test authentication setup
- `GET /api/videos/upload/info` - Get upload requirements

## 📁 Project Structure

```
backend/
├── server.js                 # Main Express server
├── config/
│   └── googleAuth.js         # Google authentication manager
├── controllers/
│   └── videoController.js    # Video upload logic
├── routes/
│   └── videos.js            # Video API routes
├── utils/
│   └── helpers.js           # Utility functions
├── uploads/                 # Temporary file storage
├── setup-refresh-token.js   # One-time OAuth setup tool
├── .env                     # Environment configuration
└── package.json
```

## 🎬 API Endpoints

### Upload Video
```http
POST /api/videos/upload
Content-Type: multipart/form-data

Body:
- video: File (required) - Video file up to 2GB
- title: String (optional) - Video title
- description: String (optional) - Video description  
- tags: String (optional) - Comma-separated tags
- privacy: String (optional) - "private", "public", or "unlisted" (default)
```

**Response:**
```json
{
  "success": true,
  "message": "Video uploaded successfully to YouTube",
  "data": {
    "videoId": "abc123",
    "videoUrl": "https://www.youtube.com/watch?v=abc123",
    "title": "My Video",
    "description": "Video description",
    "publishedAt": "2023-01-01T12:00:00Z",
    "privacyStatus": "unlisted",
    "thumbnails": {...},
    "tags": ["tag1", "tag2"]
  }
}
```

### Get Video Details
```http
GET /api/videos/:videoId
```

### Test Authentication
```http
GET /api/videos/test-auth
```

### Get Upload Info
```http
GET /api/videos/upload/info
```

## 🔐 Authentication Flow

Unlike traditional OAuth flows, this backend uses a **fixed Google account**:

1. **One-time setup**: Run `setup-refresh-token.js` to obtain refresh token
2. **Stored credentials**: Refresh token stored in `.env` file
3. **Automatic refresh**: Access tokens refreshed automatically as needed
4. **No user auth**: Flutter app uploads directly without user authentication

### Security Notes:
- ✅ Refresh token never exposed to frontend
- ✅ Access tokens auto-refresh server-side
- ✅ All uploads go to controlled YouTube channel
- ✅ No user credentials stored or transmitted

## 🛠️ Troubleshooting

### Common Issues:

#### 1. "Authentication failed" Error
- **Cause**: Invalid or expired refresh token
- **Solution**: Re-run `setup-refresh-token.js` to get a new refresh token

#### 2. "Insufficient permissions" Error  
- **Cause**: Google account doesn't have YouTube channel access
- **Solution**: Ensure the Google account has a YouTube channel and proper permissions

#### 3. "Quota exceeded" Error
- **Cause**: YouTube API quota limit reached
- **Solution**: Wait 24 hours for quota reset or request quota increase

#### 4. "Invalid file type" Error
- **Cause**: Unsupported video format
- **Solution**: Use supported formats: mp4, mpeg, mov, avi, wmv, webm, 3gp, flv, mkv

### Testing Authentication:

```bash
# Test if authentication is working
curl http://localhost:3000/api/videos/test-auth
```

### Debug Mode:

Set `NODE_ENV=development` in `.env` for detailed error messages.

## 📦 Dependencies

- **express**: Web framework
- **googleapis**: Google APIs client
- **multer**: File upload handling
- **cors**: Cross-origin requests
- **helmet**: Security headers
- **express-rate-limit**: Rate limiting
- **fs-extra**: Enhanced file system operations

## 🚦 Production Deployment

1. **Environment**: Set `NODE_ENV=production`
2. **Security**: Use HTTPS and secure headers
3. **Storage**: Configure persistent storage for uploads directory
4. **Monitoring**: Add logging and monitoring
5. **Scaling**: Consider load balancing for multiple instances

---

## 📞 Support

For issues or questions:
1. Check the troubleshooting section above
2. Verify Google Cloud Console configuration
3. Test authentication using `/api/videos/test-auth`
4. Check server logs for detailed error messages
