# OpenAI Vision API Setup Guide

## Overview

Nouri now uses **OpenAI's GPT-4 Vision API** for highly accurate food recognition. This provides much better results than the previous Hugging Face models.

## ✨ Benefits

- **🎯 High Accuracy**: GPT-4 Vision has excellent food recognition capabilities
- **🚀 Fast**: Typically responds in 1-2 seconds
- **🌍 Comprehensive**: Recognizes foods from all cuisines worldwide
- **💬 Context-Aware**: Can identify complex dishes and combinations
- **📱 Always Available**: No model loading delays or deprecation issues

## 💰 Pricing

- **gpt-4o-mini**: ~$0.00015 per image (recommended for most users)
- **gpt-4o**: ~$0.01 per image (best accuracy)

Example: With gpt-4o-mini, 1000 food photos = ~$0.15

## 🔑 Setup Instructions

### Step 1: Get Your OpenAI API Key

1. Go to [OpenAI Platform](https://platform.openai.com/api-keys)
2. Sign up or log in to your account
3. Click "Create new secret key"
4. Give it a name (e.g., "Nouri Food App")
5. Copy the API key (starts with `sk-proj-...`)

⚠️ **Important**: Save your API key immediately - you won't be able to see it again!

### Step 2: Add API Key to the App

1. Open `nouri/Managers/MealPersistenceManager.swift`
2. Find the `APIConfig` struct at the top of the file
3. Replace `YOUR_OPENAI_API_KEY` with your actual API key:

```swift
private struct APIConfig {
    static let openAIAPIKey = "sk-proj-your-actual-key-here"
    static let openAIModel = "gpt-4o-mini"  // or "gpt-4o" for best accuracy
    static let useLocalDetectionOnly = false  // Enable API
}
```

### Step 3: Enable API Mode

Set `useLocalDetectionOnly = false` to use OpenAI Vision instead of local detection.

### Step 4: Test It Out

1. Build and run the app
2. Take a photo of any food
3. Watch the console for:
   ```
   🚀 Sending request to OpenAI Vision API...
   🎯 OpenAI detected: pizza
   ```

## 🔄 Fallback System

If the OpenAI API is unavailable or you haven't added a key, the app automatically falls back to **local Vision framework detection** using:

- Advanced color analysis
- Texture detection
- Shape recognition
- On-device processing

This ensures the app always works, even without an API key!

## 🎛️ Model Options

### gpt-4o-mini (Default - Recommended)
- **Cost**: Very cheap (~$0.00015 per image)
- **Speed**: Fast (1-2 seconds)
- **Accuracy**: Excellent for most foods
- **Best for**: Daily use, budget-conscious users

### gpt-4o (Premium)
- **Cost**: More expensive (~$0.01 per image)
- **Speed**: Fast (1-2 seconds)
- **Accuracy**: Best possible
- **Best for**: Professional use, maximum accuracy needed

To switch models, change `openAIModel` in `APIConfig`:

```swift
static let openAIModel = "gpt-4o"  // Use premium model
```

## 📊 Usage Monitoring

Track your API usage at: https://platform.openai.com/usage

## 🔒 Security Best Practices

1. **Never commit your API key** to version control
2. **Regenerate keys** if accidentally exposed
3. **Set usage limits** in OpenAI dashboard to prevent unexpected charges
4. **Use environment variables** for production apps

## 🆘 Troubleshooting

### "Authentication failed - check API key"
- Verify your API key is correct
- Make sure it starts with `sk-proj-` or `sk-`
- Check that you haven't accidentally added quotes or spaces

### "Rate limit exceeded"
- You've hit your usage limit
- Wait a few minutes or upgrade your OpenAI plan
- App will automatically use local Vision detection

### "Unexpected status code"
- Check your internet connection
- Verify your OpenAI account has credits
- Check OpenAI status page: https://status.openai.com

## 🎯 Expected Accuracy

OpenAI Vision API can accurately identify:

- ✅ Common foods (pizza, burger, salad) - 95%+ accuracy
- ✅ Beverages (coffee, tea, smoothies) - 90%+ accuracy
- ✅ International cuisine - 85%+ accuracy
- ✅ Complex dishes - 80%+ accuracy
- ✅ Plated meals with multiple items - 75%+ accuracy

## 💡 Tips for Best Results

1. **Good lighting**: Take photos in well-lit conditions
2. **Clear view**: Ensure the food is the main subject
3. **Close-up**: Get reasonably close to the food
4. **Minimal clutter**: Reduce background items when possible

## 🔄 Switching Back to Local Detection

If you want to disable OpenAI and use only local Vision detection:

```swift
static let useLocalDetectionOnly = true
```

No API key or internet connection needed!

---

**Need Help?** Check the [API documentation](https://platform.openai.com/docs/guides/vision) or open an issue on GitHub.
