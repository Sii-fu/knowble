# Gemini API Setup Guide

## 🚀 How to Set Up Gemini API for Your Chatbot

### Step 1: Get Your Gemini API Key

1. Go to [Google AI Studio](https://makersuite.google.com/app/apikey)
2. Sign in with your Google account
3. Click "Create API Key"
4. Copy the generated API key

### Step 2: Add Your API Key

1. Open `lib/core/config/api_config.dart`
2. Replace `YOUR_GEMINI_API_KEY_HERE` with your actual API key:

```dart
class ApiConfig {
  static const String geminiApiKey = 'your-actual-api-key-here';
}
```

### Step 3: Test Your Setup

1. Run the app
2. Navigate to the chatbot page
3. Send a message to test the AI integration

## 🔒 Security Note

- Never commit your API key to version control
- Consider using environment variables for production
- The API key is currently in a config file for development purposes

## 🛠 Features Implemented

- ✅ Real Gemini API integration
- ✅ Educational response generation
- ✅ Context-aware responses based on subject selection
- ✅ Fallback responses if API fails
- ✅ Proper error handling
- ✅ Markdown response formatting

## 📝 Usage

The chatbot now uses Google's Gemini AI to:
- Answer academic questions
- Provide step-by-step explanations
- Generate study materials
- Help with homework and assignments
- Offer subject-specific guidance

## 🔧 Troubleshooting

If you get API errors:
1. Check your API key is correct
2. Ensure you have internet connection
3. Verify your Google AI Studio quota
4. Check the console for detailed error messages

The app will fallback to mock responses if the API fails, so it will always work!
