# 🤗 Hugging Face API Setup Guide

## Why We Switched to Hugging Face

✅ **FREE** - No credit card required, ~10,000 requests/month  
✅ **94% Accuracy** - Better than Clarifai on Food-101 dataset  
✅ **Open Source** - Can self-host if needed  
✅ **Fast** - <2 seconds per image  
✅ **Easy** - Simple REST API integration  

## Quick Setup (2 minutes)

### Step 1: Create Account
1. Go to https://huggingface.co/join
2. Sign up with email (no credit card needed!)
3. Verify your email

### Step 2: Get API Token
1. Go to https://huggingface.co/settings/tokens
2. Click **"New token"**
3. Name: `Nouri Food Recognition`
4. Type: **Read**
5. Click **"Generate token"**
6. Copy your token (starts with `hf_...`)

### Step 3: Add to App
1. Open `nouri/Managers/MealPersistenceManager.swift`
2. Find line ~19 (the `APIConfig` struct)
3. Replace this:
   ```swift
   static let huggingFaceAPIKey = "YOUR_HUGGINGFACE_API_KEY"
   ```
   
   With your token:
   ```swift
   static let huggingFaceAPIKey = "hf_YourActualTokenHere..."
   ```

4. Save the file
5. Build and run the app!

## Testing

1. **First Request** - May take 20-30 seconds (model loading)
2. **Subsequent Requests** - Fast! (<2 seconds)
3. Check Xcode console for logs:
   ```
   🌐 Calling Hugging Face API...
   🔑 API Key present: true
   ✅ Using Hugging Face API with key: hf_xxxxx...
   🎯 Top detection: pizza (confidence: 95%)
   ```

## Model Details

**Model:** `BinhQuocNguyen/food-recognition-model`
- 101 food categories (Food-101 dataset)
- EfficientNet-B0 architecture
- 85-94% accuracy
- <2 second inference time
- Trained on 101,000 food images

## Rate Limits

| Tier | Requests/Month | Cost | Speed |
|------|---------------|------|-------|
| Free | ~10,000 | $0 | Fast |
| PRO | Higher | $9/mo | Faster |
| Self-Hosted | Unlimited | $0 | Custom |

For a personal app with 3 meals/day:
- **Free tier = 100+ users!** 🎉

## Common Issues

### "Model is loading"
- First request can take 20-30 seconds
- Model goes to sleep after inactivity
- App automatically uses fallback detection while waiting
- **Solution:** Just wait, or make a test request to wake it up

### "Rate limit exceeded"
- You've hit your monthly limit
- **Solution:** Wait until next month, or upgrade to PRO ($9/month)
- App automatically falls back to color detection

### "Invalid token"
- Token is wrong or has wrong permissions
- **Solution:** Go to https://huggingface.co/settings/tokens
- Make sure token has "Read" permission
- Copy-paste carefully (tokens are long!)

## Advanced: Self-Hosting

Want unlimited requests and complete privacy?

1. Clone the model: `git clone https://huggingface.co/BinhQuocNguyen/food-recognition-model`
2. Run with transformers library:
   ```python
   from transformers import pipeline
   classifier = pipeline("image-classification", 
                        model="BinhQuocNguyen/food-recognition-model")
   result = classifier("food_image.jpg")
   ```
3. Deploy as API endpoint
4. Update `APIConfig.modelID` to your endpoint URL

## Support

- Model page: https://huggingface.co/BinhQuocNguyen/food-recognition-model
- API docs: https://huggingface.co/docs/api-inference
- Need help? Check console logs for detailed error messages

---

**That's it!** 🎉 You now have free, accurate food recognition powered by open source AI.
