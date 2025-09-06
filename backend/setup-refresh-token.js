const express = require('express');
const { google } = require('googleapis');
require('dotenv').config();

/**
 * One-Time OAuth Setup Tool
 * Use this script to obtain a refresh token for the fixed Google account
 * 
 * Run this once to get the GOOGLE_REFRESH_TOKEN for your .env file
 */

const app = express();
const PORT = 3002 ; // Different port to avoid conflicts

console.log('🔐 One-Time OAuth Setup Tool for Fixed Google Account');
console.log('=====================================');

// Validate required environment variables
const required = ['GOOGLE_CLIENT_ID', 'GOOGLE_CLIENT_SECRET', 'GOOGLE_REDIRECT_URI'];
const missing = required.filter(key => !process.env[key]);

if (missing.length > 0) {
  console.error('❌ Missing required environment variables:');
  missing.forEach(key => console.error(`   ${key}`));
  console.error('\nPlease set these in your .env file first.');
  process.exit(1);
}

const oauth2Client = new google.auth.OAuth2(
  process.env.GOOGLE_CLIENT_ID,
  process.env.GOOGLE_CLIENT_SECRET,
  `http://localhost:${PORT}/auth/callback` // Use this port for setup
);

// Main page
app.get('/', (req, res) => {
  res.send(`
    <html>
    <head>
      <title>One-Time OAuth Setup - Knowble</title>
      <style>
        body { font-family: Arial, sans-serif; max-width: 800px; margin: 50px auto; padding: 20px; }
        .button { display: inline-block; padding: 15px 30px; margin: 10px 0; background: #4285f4; color: white; text-decoration: none; border-radius: 5px; font-size: 16px; }
        .button:hover { background: #3367d6; }
        .info { background: #e3f2fd; padding: 20px; border-radius: 5px; margin: 20px 0; }
        .warning { background: #fff3e0; padding: 20px; border-radius: 5px; margin: 20px 0; }
        .success { background: #e8f5e8; padding: 20px; border-radius: 5px; margin: 20px 0; }
        pre { background: #f5f5f5; padding: 15px; border-radius: 5px; overflow-x: auto; }
      </style>
    </head>
    <body>
      <h1>🔐 One-Time OAuth Setup</h1>
      <p>This tool helps you obtain a refresh token for the fixed Google account that will be used for all YouTube uploads.</p>
      
      <div class="warning">
        <h3>⚠️ Important Notes:</h3>
        <ul>
          <li><strong>Use the Google account that owns the YouTube channel</strong> where videos should be uploaded</li>
          <li>This setup only needs to be done once</li>
          <li>The refresh token will be used for all future uploads</li>
          <li>Make sure YouTube Data API v3 is enabled in Google Cloud Console</li>
        </ul>
      </div>
      
      <div class="info">
        <h3>📋 Current Configuration:</h3>
        <p><strong>Client ID:</strong> ${process.env.GOOGLE_CLIENT_ID}</p>
        <p><strong>Setup Redirect URI:</strong> http://localhost:${PORT}/auth/callback</p>
        <p><strong>Note:</strong> This is different from your main app's redirect URI</p>
      </div>
      
      <h3>🚀 Get Your Refresh Token:</h3>
      <a href="/auth/start" class="button">Start OAuth Flow</a>
      
      <div class="info">
        <h3>📝 What happens next:</h3>
        <ol>
          <li>Click "Start OAuth Flow" above</li>
          <li>Sign in with the Google account you want to use for YouTube uploads</li>
          <li>Grant permissions for YouTube upload and read access</li>
          <li>You'll receive a refresh token to add to your .env file</li>
          <li>Copy the refresh token to GOOGLE_REFRESH_TOKEN in your .env file</li>
          <li>Restart your main application</li>
        </ol>
      </div>
      
      <div class="warning">
        <h3>🔧 Before Starting:</h3>
        <p>Make sure to add this redirect URI to your Google Cloud Console:</p>
        <pre>http://localhost:${PORT}/auth/callback</pre>
        <p>Go to: Google Cloud Console → APIs & Services → Credentials → Edit OAuth 2.0 Client → Add redirect URI</p>
      </div>
    </body>
    </html>
  `);
});

// Start OAuth flow
app.get('/auth/start', (req, res) => {
  const authUrl = oauth2Client.generateAuthUrl({
    access_type: 'offline', // Required for refresh token
    scope: [
      'https://www.googleapis.com/auth/youtube.upload',
      'https://www.googleapis.com/auth/youtube.readonly'
    ],
    prompt: 'consent' // Force consent screen to ensure refresh token
  });
  
  console.log('🔄 OAuth flow started');
  res.redirect(authUrl);
});

// Handle OAuth callback
app.get('/auth/callback', async (req, res) => {
  const { code, error } = req.query;
  
  if (error) {
    console.error('❌ OAuth error:', error);
    res.send(`
      <html>
      <head><title>OAuth Error</title></head>
      <body style="font-family: Arial, sans-serif; max-width: 600px; margin: 50px auto; padding: 20px;">
        <h2>❌ OAuth Error</h2>
        <p><strong>Error:</strong> ${error}</p>
        <p>Please check your Google Cloud Console configuration and try again.</p>
        <a href="/">← Back to setup</a>
      </body>
      </html>
    `);
    return;
  }

  if (!code) {
    res.send(`
      <html>
      <head><title>Missing Code</title></head>
      <body style="font-family: Arial, sans-serif; max-width: 600px; margin: 50px auto; padding: 20px;">
        <h2>❌ No Authorization Code</h2>
        <p>The OAuth flow didn't return an authorization code.</p>
        <a href="/">← Try again</a>
      </body>
      </html>
    `);
    return;
  }

  try {
    console.log('🔄 Exchanging code for tokens...');
    const { tokens } = await oauth2Client.getToken(code);
    
    // Test the tokens by making an API call
    oauth2Client.setCredentials(tokens);
    const youtube = google.youtube({ version: 'v3', auth: oauth2Client });
    const channelResponse = await youtube.channels.list({
      part: ['snippet'],
      mine: true
    });

    const channel = channelResponse.data.items[0];
    
    console.log('✅ OAuth setup successful!');
    console.log(`📺 Channel: ${channel.snippet.title}`);
    console.log(`🔑 Refresh token obtained: ${tokens.refresh_token ? 'Yes' : 'No'}`);
    
    res.send(`
      <html>
      <head><title>OAuth Setup Complete</title></head>
      <body style="font-family: Arial, sans-serif; max-width: 800px; margin: 50px auto; padding: 20px;">
        <h2>✅ OAuth Setup Complete!</h2>
        
        <div style="background: #e8f5e8; padding: 20px; border-radius: 5px; margin: 20px 0;">
          <h3>📺 Connected YouTube Channel:</h3>
          <p><strong>Name:</strong> ${channel.snippet.title}</p>
          <p><strong>Description:</strong> ${channel.snippet.description || 'No description'}</p>
          <p><strong>Channel ID:</strong> ${channel.id}</p>
        </div>
        
        <div style="background: #fff3e0; padding: 20px; border-radius: 5px; margin: 20px 0;">
          <h3>🔑 Your Refresh Token:</h3>
          <p><strong>Copy this refresh token to your .env file:</strong></p>
          <pre style="background: #f5f5f5; padding: 15px; border-radius: 5px; word-break: break-all;">
GOOGLE_REFRESH_TOKEN=${tokens.refresh_token || 'NOT_RECEIVED'}
          </pre>
        </div>
        
        <div style="background: #e3f2fd; padding: 20px; border-radius: 5px; margin: 20px 0;">
          <h3>📝 Next Steps:</h3>
          <ol>
            <li>Copy the refresh token above</li>
            <li>Add it to your .env file as GOOGLE_REFRESH_TOKEN</li>
            <li>Restart your main Knowble API server</li>
            <li>Test the setup by visiting /api/videos/test-auth</li>
            <li>You can now close this setup tool</li>
          </ol>
        </div>
        
        ${!tokens.refresh_token ? `
        <div style="background: #ffebee; padding: 20px; border-radius: 5px; margin: 20px 0;">
          <h3>⚠️ No Refresh Token Received</h3>
          <p>This might happen if you've already authorized this app before. Try:</p>
          <ol>
            <li>Go to your Google Account settings</li>
            <li>Remove the Knowble app from authorized apps</li>
            <li>Try the OAuth flow again</li>
          </ol>
        </div>
        ` : ''}
        
        <button onclick="window.close()" style="padding: 12px 24px; background: #4285f4; color: white; border: none; border-radius: 5px; cursor: pointer;">Close Window</button>
      </body>
      </html>
    `);
    
  } catch (error) {
    console.error('❌ Token exchange failed:', error.message);
    res.send(`
      <html>
      <head><title>Token Exchange Failed</title></head>
      <body style="font-family: Arial, sans-serif; max-width: 600px; margin: 50px auto; padding: 20px;">
        <h2>❌ Token Exchange Failed</h2>
        <p><strong>Error:</strong> ${error.message}</p>
        <pre style="background: #f5f5f5; padding: 15px; border-radius: 5px;">
${error.stack}
        </pre>
        <a href="/">← Try again</a>
      </body>
      </html>
    `);
  }
});

app.listen(PORT, () => {
  console.log('🚀 OAuth Setup Tool started');
  console.log(`📡 Running on: http://localhost:${PORT}`);
  console.log('');
  console.log('📋 IMPORTANT: Add this redirect URI to Google Cloud Console:');
  console.log(`   http://localhost:${PORT}/auth/callback`);
  console.log('');
  console.log('🌐 Open: http://localhost:${PORT}');
  console.log('');
  console.log('💡 Use this tool to get your GOOGLE_REFRESH_TOKEN for the .env file');
});
