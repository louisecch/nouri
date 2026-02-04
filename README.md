# Chibo - AI-Powered Meal Tracker

Renamed from Nouri as apparently a dozen others have already GPT-ed this name, I came up with the name non-GPT way.

Drawing from cibo (food in Italian 🇮🇹) and chi, the Chinese idea of life energy (qi / 氣), Chibo believes good food should support a long life without feeling like a sacrifice.

Track your meals with photos and get instant AI-powered nutrition insights. Chibo uses OpenAI Vision to identify your food and calculate health scores, making mindful eating effortless.

## Features

### 📱 Today Tab (Home)

- Displays current day of week and date
- 2-column grid layout with 6 fixed meal categories:
  - Breakfast
  - Snack (AM)
  - Lunch
  - Snack (PM)
  - Dinner
  - Snack (Evening)
- Tap any meal card to add or update a photo from your library
- **🤖 AI Food Recognition** - OpenAI Vision automatically identifies your food
- **📊 Health Scoring** - Instant nutritional insights for each meal
- **🎉 Fun Animations** - Visual feedback based on food healthiness (🤩 healthy, 😐 okay, 🤨 unhealthy)
- Clean, minimal design with photo thumbnails or "Add Photo" placeholders

### 📊 Health Tab

- **Daily Health Score** - See your nutrition score for today
- **7-Day Score** - Track your weekly progress
- **Meal Breakdown** - View scores for each meal logged today
- **Healthy Score Guide** - Understand what daily scores are considered healthy (200-300 points)
- **Example Meal Plans** - See how to achieve healthy daily scores
- Beautiful gradient cards with visual feedback
- Color-coded scores (green = excellent, blue = good, orange/red = needs improvement)

### 💡 Learn Tab

- Daily nutrition facts to inspire healthier choices
- Random facts about food, nutrition, and wellness
- Beautiful gradient design with panda mascot

### ⚙️ Settings Tab

- View app information and meal statistics
- Clear all data option (with confirmation alert)
- About section with app description

## Technical Details

### Architecture

- **SwiftUI** for UI (iOS 16.2+)
- **File-based persistence** for meal data (JSON)
- **Local image storage** in Documents directory
- **Observable pattern** for data management

### Key Components

- `MealType.swift` - Enum defining the 6 meal categories
- `MealEntry.swift` - Model for individual meal entries
- `MealPersistenceManager.swift` - Handles data and image persistence
- `TodayView.swift` - Main meal grid interface
- `HealthScoreView.swift` - Health score tracking and insights
- `MotivationView.swift` - Daily quote display
- `SettingsView.swift` - App settings and data management

### Data Storage

- Meal metadata stored as JSON in Documents directory
- Photos stored as JPEG files in `MealImages` folder
- Images compressed to 80% quality for optimal storage

## Requirements

- **iOS 16.0+** (iPhone & iPad)
- **macOS 12.0+** (Monterey or later) ✅
- Xcode 14.2+
- Swift 5.0+
- **Cross-Platform**: Works on both iOS and macOS!

## AI Food Recognition

The app includes **AI-powered food recognition** with two options:

### Option 1: OpenAI Vision API (Recommended)

- **🎯 Highest Accuracy**: GPT-4 Vision excels at food recognition
- **⚡ Fast**: 1-2 seconds per image
- **🌍 Comprehensive**: Recognizes foods from all cuisines worldwide
- **💰 Low Cost**: ~$0.00015 per image with gpt-4o-mini

**Setup:** See [OPENAI_SETUP.md](OPENAI_SETUP.md) for setup guide.

### Option 2: Local Vision Framework (Free, On-Device)

- **🆓 Completely FREE** - No API needed
- **🔒 100% Private** - All processing on-device
- **🚫 No Internet** - Works offline
- **🧠 Advanced**: Uses Core ML + Vision framework with color, texture, and shape analysis

**Fallback:** App automatically uses local Vision detection if no API key is configured.

## Privacy

The app requests:

- **Photo Library Access**: To select meal photos
- **Camera Access**: To capture new meal photos (ready for future enhancement)

**Data Storage:**

- All meal data stored locally on device
- Photos never leave your device (unless you use OpenAI Vision API)
- When using OpenAI API: Images sent to OpenAI for analysis only (not stored by OpenAI)
- Local Vision mode: 100% on-device, nothing sent to any server
- No cloud sync or tracking

## Building & Running

1. Open `nouri.xcodeproj` in Xcode
2. Select your target device or simulator
3. Build and run (⌘R)

## Design Philosophy

- **Simplicity**: No complex features, just photo logging
- **Mindfulness**: Focus on awareness, not judgment
- **Consistency**: Fixed categories encourage daily tracking
- **Privacy**: All data stays on your device

## Future Enhancements

Potential features for future versions:

- Camera capture directly from the app
- Calendar view to browse past days
- Export functionality
- Meal notes or tags
- Dark mode refinements
- Widget support

## License

Created for personal use. All rights reserved.

---

**App Name**: Chibo  
**Version**: 1.0  
**Bundle ID**: dev.louc.nouri
