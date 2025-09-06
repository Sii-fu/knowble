const express = require('express');
const { google } = require('googleapis');
require('dotenv').config();

/**
 * Simple OAuth Test Script
 * Use this to test your Google OAuth setup independently
 */

const app = express();
const PORT = 3001; // Using different port to avoid conflicts

const oauth2Client = new google.auth.OAuth2(
  process.env.GOOGLE_CLIENT_ID,
  process.env.GOOGLE_CLIENT_SECRET,
  `http://localhost:${PORT}/test/callback`
);

// Test with basic scope first
app.get('/test/auth/basic', (req, res) => {
  console.log('Testing basic Google auth...');
  const authUrl = oauth2Client.generateAuthUrl({
    access_type: 'offline',
    scope: ['https://www.googleapis.com/auth/userinfo.profile'],
    prompt: 'consent'
  });
  
  res.send(`
    <h2>🔐 Basic OAuth Test</h2>
    <p>Click the link below to test basic Google authentication:</p>
    <a href="${authUrl}" target="_blank">Authenticate with Google (Basic)</a>
    <br><br>
    <a href="/">← Back to main page</a>
  `);
});

// Test with YouTube scopes
app.get('/test/auth/youtube', (req, res) => {
  console.log('Testing YouTube OAuth...');
  const authUrl = oauth2Client.generateAuthUrl({
    access_type: 'offline',
    scope: [
      'https://www.googleapis.com/auth/youtube.readonly',
      'https://www.googleapis.com/auth/youtube.upload'
    ],
    prompt: 'consent'
  });
  
  res.send(`
    <h2>🎥 YouTube OAuth Test</h2>
    <p>Click the link below to test YouTube API authentication:</p>
    <a href="${authUrl}" target="_blank">Authenticate with Google (YouTube)</a>
    <br><br>
    <a href="/">← Back to main page</a>
  `);
});

// Handle OAuth callback
app.get('/test/callback', async (req, res) => {
  const { code, error } = req.query;
  
  if (error) {
    console.error('OAuth error:', error);
    res.send(`
      <h2>❌ Authentication Failed</h2>
      <p><strong>Error:</strong> ${error}</p>
      <p>This indicates an issue with your Google Cloud Console setup.</p>
      <a href="/">← Try again</a>
    `);
    return;
  }

  if (!code) {
    res.send(`
      <h2>❌ No Authorization Code</h2>
      <p>The authentication flow didn't return an authorization code.</p>
      <a href="/">← Try again</a>
    `);
    return;
  }

  try {
    console.log('Exchanging code for tokens...');
    const { tokens } = await oauth2Client.getToken(code);
    
    // Test API access
    oauth2Client.setCredentials(tokens);
    const oauth2 = google.oauth2({ version: 'v2', auth: oauth2Client });
    const userInfo = await oauth2.userinfo.get();
    
    res.send(`
      <h2>✅ Authentication Successful!</h2>
      <p><strong>Welcome:</strong> ${userInfo.data.name} (${userInfo.data.email})</p>
      <h3>Tokens Received:</h3>
      <pre style="background: #f5f5f5; padding: 10px; border-radius: 5px;">
Access Token: ${tokens.access_token ? 'Yes ✅' : 'No ❌'}
Refresh Token: ${tokens.refresh_token ? 'Yes ✅' : 'No ❌'}
Expires In: ${tokens.expires_in} seconds
Token Type: ${tokens.token_type}
      </pre>
      <a href="/">← Test again</a>
    `);
    
    console.log('✅ OAuth test successful!');
    console.log('User:', userInfo.data.name, userInfo.data.email);
    console.log('Tokens received:', {
      hasAccessToken: !!tokens.access_token,
      hasRefreshToken: !!tokens.refresh_token,
      expiresIn: tokens.expires_in
    });
    
  } catch (error) {
    console.error('Token exchange failed:', error);
    res.send(`
      <h2>❌ Token Exchange Failed</h2>
      <p><strong>Error:</strong> ${error.message}</p>
      <pre style="background: #f5f5f5; padding: 10px; border-radius: 5px;">
${error.stack}
      </pre>
      <a href="/">← Try again</a>
    `);
  }
});

// Main page
app.get('/', (req, res) => {
  res.send(`
    <html>
    <head>
      <title>Google OAuth Test - Knowble</title>
      <style>
        body { font-family: Arial, sans-serif; max-width: 600px; margin: 50px auto; padding: 20px; }
        .button { display: inline-block; padding: 12px 24px; margin: 10px 0; background: #4285f4; color: white; text-decoration: none; border-radius: 5px; }
        .button:hover { background: #3367d6; }
        .info { background: #e3f2fd; padding: 15px; border-radius: 5px; margin: 15px 0; }
        .error { background: #ffebee; padding: 15px; border-radius: 5px; margin: 15px 0; }
      </style>
    </head>
    <body>
      <h1>🔐 Google OAuth Test - Knowble</h1>
      <p>Use this tool to test your Google OAuth setup before using the main application.</p>
      
      <div class="info">
        <h3>📋 Current Configuration:</h3>
        <p><strong>Client ID:</strong> ${process.env.GOOGLE_CLIENT_ID}</p>
        <p><strong>Redirect URI:</strong> http://localhost:${PORT}/test/callback</p>
      </div>
      
      <h3>🧪 Tests Available:</h3>
      <a href="/test/auth/basic" class="button">1. Test Basic Auth</a>
      <p>Tests basic Google authentication with minimal scopes.</p>
      
      <a href="/test/auth/youtube" class="button">2. Test YouTube Auth</a>
      <p>Tests YouTube API authentication with upload/read scopes.</p>
      
      <div class="error">
        <h3>⚠️ Before Testing:</h3>
        <ol>
          <li>Enable YouTube Data API v3 in Google Cloud Console</li>
          <li>Configure OAuth consent screen</li>
          <li>Add your email as a test user</li>
          <li>Add redirect URI: <code>http://localhost:${PORT}/test/callback</code></li>
        </ol>
      </div>
      
      <h3>📚 Troubleshooting:</h3>
      <ul>
        <li><strong>403 access_denied:</strong> Check OAuth consent screen and test users</li>
        <li><strong>redirect_uri_mismatch:</strong> Add redirect URI to Google Cloud Console</li>
        <li><strong>invalid_client:</strong> Check client ID and secret in .env file</li>
      </ul>
    </body>
    </html>
  `);
});

app.listen(PORT, () => {
  console.log('🧪 OAuth Test Server started');
  console.log(`📡 Running on: http://localhost:${PORT}`);
  console.log('🔧 Testing redirect URI: http://localhost:${PORT}/test/callback');
  console.log('');
  console.log('📋 Make sure to add this redirect URI to Google Cloud Console:');
  console.log(`   http://localhost:${PORT}/test/callback`);
  console.log('');
  console.log('🌐 Open: http://localhost:${PORT}');
});
