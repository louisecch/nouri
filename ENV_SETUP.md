# Environment Configuration Setup

## Overview

Your OpenAI API key is now stored securely in configuration files that are **excluded from git** to prevent accidental exposure.

## 🔐 Security Setup Complete

✅ API key moved to `Config.plist` and `.env`  
✅ Config files added to `.gitignore`  
✅ Template files created for other developers

## 📁 Files Created

### Configuration Files (NOT committed to git)
- `.env` - Environment variables (text format)
- `nouri/Config.plist` - Configuration (plist format, preferred)

### Template Files (safe to commit)
- `.env.example` - Template for .env file
- `nouri/Config.plist.example` - Template for Config.plist

### Code Files
- `nouri/Helpers/EnvConfig.swift` - Reads configuration from plist or .env

## 🎯 How It Works

The app reads configuration in this order:

1. **Config.plist** (bundled with app) ← Current source
2. **.env** file (fallback for local development)
3. **Default values** (if neither found)

## 🛠️ Adding Config.plist to Xcode

The `Config.plist` and `EnvConfig.swift` files need to be added to your Xcode project:

### Step 1: Add Config.plist
1. Open `nouri.xcodeproj` in Xcode
2. Right-click on the `nouri` folder in the Project Navigator
3. Select "Add Files to 'nouri'..."
4. Navigate to `nouri/Config.plist`
5. Check ✅ "Copy items if needed"
6. Check ✅ Target: nouri
7. Click "Add"

### Step 2: Add EnvConfig.swift
1. Right-click on the `Helpers` folder in Xcode
2. Select "Add Files to 'nouri'..."
3. Navigate to `nouri/Helpers/EnvConfig.swift`
4. Check ✅ "Copy items if needed"
5. Check ✅ Target: nouri
6. Click "Add"

### Step 3: Verify
Build the project. You should see:
```
✅ Loaded configuration from Config.plist
📋 Loaded 2 configuration values
```

## 🔄 For Other Developers

When someone clones your repository:

1. Copy the example file:
   ```bash
   cp nouri/Config.plist.example nouri/Config.plist
   ```

2. Edit `nouri/Config.plist` and add their API key

3. Add the file to Xcode (steps above)

## 🔒 Security Best Practices

✅ **Config.plist is in .gitignore** - Won't be committed  
✅ **API key is separate from code** - Easy to rotate  
✅ **Template files provided** - Other devs know what to do  
✅ **Fallback to .env** - Works for command-line builds too

## ⚠️ Important

**Never commit these files:**
- `Config.plist`
- `.env`

**Safe to commit:**
- `Config.plist.example`
- `.env.example`
- `EnvConfig.swift`
- `.gitignore`

## 🧪 Testing

To verify your setup:

1. Build and run the app
2. Upload a food photo
3. Check Xcode console for:
   ```
   ✅ Loaded configuration from Config.plist
   ✅ OpenAI API key loaded from .env file
   🚀 Sending request to OpenAI Vision API...
   ```

## 🔄 Rotating Your API Key

If you need to change your API key:

1. Get new key from https://platform.openai.com/api-keys
2. Edit `nouri/Config.plist`
3. Update the `OPENAI_API_KEY` value
4. Rebuild the app

No code changes needed!

## 💡 Alternative: Using .env Only

If you prefer not to use plist files:

1. The app will automatically fall back to reading `.env`
2. Make sure `.env` is in the project root
3. Format: `OPENAI_API_KEY=your-key-here`

---

**Questions?** Check [OPENAI_SETUP.md](OPENAI_SETUP.md) for more details.
