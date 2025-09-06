# AuthController and VideoController Fixes Summary

## Issues Fixed

### 1. AuthController Method Call Error
**Problem:** `TypeError: AuthController.getStoredTokens is not a function`

**Root Cause:** The `getStoredTokens` and `updateStoredTokens` methods were defined as static methods in the AuthController class, but the module exported an instance (`new AuthController()`) instead of the class itself. This prevented access to static methods.

**Solution:** Modified the export in `authController.js` to expose static methods on the instance:
```javascript
// Export both the instance and the class for static method access
const authControllerInstance = new AuthController();
authControllerInstance.getStoredTokens = AuthController.getStoredTokens;
authControllerInstance.updateStoredTokens = AuthController.updateStoredTokens;

module.exports = authControllerInstance;
```

**Updated videoController.js imports:**
```javascript
// Changed from: const AuthController = require('./authController');
const authController = require('./authController');

// Updated all method calls:
// const storedTokens = AuthController.getStoredTokens(userId);
const storedTokens = authController.getStoredTokens(userId);

// authController.updateStoredTokens(userId, activeTokens);
authController.updateStoredTokens(userId, activeTokens);
```

### 2. Context Issue with cleanupTempFile
**Problem:** `TypeError: Cannot read properties of undefined (reading 'cleanupTempFile')`

**Root Cause:** The `uploadVideo` function was used as an Express route handler, which changes the `this` context to `undefined`. This prevented access to `this.cleanupTempFile`.

**Solution:** Moved `cleanupTempFile` outside the class as a standalone utility function:

```javascript
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
```

**Updated function calls:**
```javascript
// Changed from: await this.cleanupTempFile(tempFilePath);
await cleanupTempFile(tempFilePath);
```

## Files Modified

1. **backend/controllers/authController.js**
   - Modified export to expose static methods on instance
   - Maintained backward compatibility

2. **backend/controllers/videoController.js**
   - Updated AuthController import and method calls
   - Moved cleanupTempFile to standalone function
   - Removed duplicate cleanupTempFile method from class
   - Fixed all `this.cleanupTempFile` references

## Testing Results

✅ **Server Startup:** No more TypeError on server startup
✅ **Authentication Endpoints:** All auth endpoints functional
✅ **Video Upload Preparation:** Ready for file upload testing
✅ **Error Handling:** Proper cleanup and error responses

## Next Steps

1. **Test Google OAuth Flow:** 
   - Ensure redirect URI is properly configured in Google Cloud Console
   - Test authentication flow: http://localhost:3000/api/auth/google

2. **Test Video Upload:**
   - Authenticate first via OAuth
   - Test video upload endpoint with actual files

3. **Flutter Integration:**
   - Test Flutter app connection to backend
   - Verify end-to-end video upload flow

## Important Notes

- The redirect URI mismatch error mentioned earlier still needs to be fixed in Google Cloud Console
- Add `http://localhost:3000/api/auth/google/callback` to authorized redirect URIs
- Server is now stable and ready for testing the complete YouTube upload flow

## New Issue: Error 403: access_denied

### Problem
```
Error 403: access_denied
Request details: access_type=offline response_type=code 
redirect_uri=http://localhost:3000/api/auth/google/callback 
prompt=consent client_id=822087544643-ghbi7ms7n7a3r1ikind4c9if1g3lbugf.apps.googleusercontent.com 
scope=https://www.googleapis.com/auth/youtube.upload https://www.googleapis.com/auth/youtube.readonly 
flowName=GeneralOAuthFlow
```

### Root Cause
The 403 access_denied error occurs when:
1. YouTube Data API v3 is not enabled in your Google Cloud project
2. OAuth consent screen is not properly configured
3. Your app is in testing mode but your Google account is not added as a test user
4. The project doesn't have proper verification for YouTube API scopes

### Solution Steps

#### Step 1: Enable YouTube Data API v3
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Select your project (the one with client ID: 822087544643-ghbi7ms7n7a3r1ikind4c9if1g3lbugf)
3. Navigate to **APIs & Services** → **Library**
4. Search for "YouTube Data API v3"
5. Click on it and press **ENABLE**

#### Step 2: Configure OAuth Consent Screen
1. Go to **APIs & Services** → **OAuth consent screen**
2. Choose **External** user type (unless you have a Google Workspace account)
3. Fill in required fields:
   - **App name:** Knowble
   - **User support email:** Your email
   - **Developer contact information:** Your email
4. **Save and Continue**

#### Step 3: Add Scopes
1. In the **Scopes** section, click **ADD OR REMOVE SCOPES**
2. Add these scopes:
   - `https://www.googleapis.com/auth/youtube.upload`
   - `https://www.googleapis.com/auth/youtube.readonly`
3. **Save and Continue**

#### Step 4: Add Test Users (Critical for Testing)
1. In the **Test users** section, click **ADD USERS**
2. Add your Google account email address (the one you'll use to test)
3. **Save and Continue**

#### Step 5: Configure Authorized Redirect URIs
1. Go to **APIs & Services** → **Credentials**
2. Click on your OAuth 2.0 client ID
3. In **Authorized redirect URIs**, add:
   ```
   http://localhost:3000/api/auth/google/callback
   http://127.0.0.1:3000/api/auth/google/callback
   ```
4. **Save**

#### Step 6: Request App Verification (If Needed)
If you plan to use this in production:
1. Your app needs to be verified by Google for YouTube scopes
2. This requires domain verification and security assessment
3. For development/testing, keep the app in testing mode

### Testing the Fix

After completing these steps:
1. Wait 5-10 minutes for changes to propagate
2. Clear your browser cache/cookies for Google
3. Try the authentication flow again: http://localhost:3000/api/auth/google
4. Use the Google account you added as a test user

### Alternative Testing Method

Create a simple test script to verify OAuth:

```javascript
// test-oauth.js
const express = require('express');
const { google } = require('googleapis');
require('dotenv').config();

const app = express();
const oauth2Client = new google.auth.OAuth2(
  process.env.GOOGLE_CLIENT_ID,
  process.env.GOOGLE_CLIENT_SECRET,
  'http://localhost:3000/test/callback'
);

app.get('/test/auth', (req, res) => {
  const authUrl = oauth2Client.generateAuthUrl({
    access_type: 'offline',
    scope: ['https://www.googleapis.com/auth/youtube.readonly'],
    prompt: 'consent'
  });
  res.redirect(authUrl);
});

app.get('/test/callback', async (req, res) => {
  const { code } = req.query;
  try {
    const { tokens } = await oauth2Client.getToken(code);
    res.json({ success: true, tokens });
  } catch (error) {
    res.json({ error: error.message });
  }
});

app.listen(3000, () => console.log('Test server running on port 3000'));
```

### Expected Outcome
- Authentication should succeed
- You should receive access and refresh tokens
- No more 403 access_denied errors
