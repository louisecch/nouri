# Nouri - Project Structure

## File Organization

```
nouri/
├── nouriApp.swift              # App entry point
├── ContentView.swift            # Main tab view container
│
├── Models/
│   ├── MealType.swift          # Enum: 6 meal categories
│   └── MealEntry.swift         # Data model for meal entries
│
├── Views/
│   ├── TodayView.swift         # Home screen with meal grid
│   ├── MotivationView.swift   # Daily quote display
│   └── SettingsView.swift     # App settings
│
├── Managers/
│   └── MealPersistenceManager.swift  # Data & image persistence
│
└── Assets.xcassets/            # App icons and colors
```

## Code Structure

### Models (2 files)
**MealType.swift**
- Defines 6 fixed meal categories
- Provides display names and sort order
- Codable for persistence

**MealEntry.swift**
- Represents a single logged meal
- Contains: ID, meal type, date, image filename
- Codable for JSON storage

### Managers (1 file)
**MealPersistenceManager.swift**
- Singleton pattern (`shared`)
- Observable object for SwiftUI
- Handles:
  - JSON-based meal data storage
  - JPEG image file storage
  - CRUD operations for meals
  - File system management

### Views (3 files)
**TodayView.swift**
- Navigation stack with "Today" title
- Header showing day of week and date
- 2-column LazyVGrid with 6 meal cards
- PhotosPicker integration
- Real-time meal updates via persistence manager

**MotivationView.swift**
- 10 curated wellness quotes
- Daily rotation based on day of year
- Gradient background
- Heart icon with SF Symbols
- Centered, readable typography

**SettingsView.swift**
- List-based layout
- App info section (version, meal count)
- Data management (clear all data)
- About section with app description
- Destructive action with confirmation alert

### Main Container
**ContentView.swift**
- TabView with 3 tabs
- SF Symbols for tab icons
- State management for selected tab

**nouriApp.swift**
- @main entry point
- WindowGroup with ContentView

## Data Flow

1. **User Action** → Taps meal card in TodayView
2. **PhotosPicker** → User selects image
3. **TodayView** → Calls persistence manager
4. **MealPersistenceManager** → Saves image & metadata
5. **@Published** → SwiftUI updates UI automatically

## Storage Locations

- **Meal Data**: `Documents/meals.json`
- **Images**: `Documents/MealImages/*.jpg`
- Compression: 80% JPEG quality
- Local only, no cloud sync

## Key Design Patterns

1. **Singleton**: MealPersistenceManager.shared
2. **Observable Object**: SwiftUI reactive updates
3. **File-based persistence**: Simple, reliable storage
4. **Enum-driven UI**: MealType defines all categories
5. **Lazy loading**: LazyVGrid for performance

## SwiftUI Features Used

- NavigationStack
- TabView
- LazyVGrid
- @State and @StateObject
- @Published properties
- Sheet presentation
- Alert dialogs
- SF Symbols
- UIViewControllerRepresentable (ImagePicker)

## Apple HIG Compliance

✓ Native iOS navigation patterns  
✓ Tab bar navigation  
✓ SF Symbols throughout  
✓ System fonts and spacing  
✓ Destructive action colors  
✓ Confirmation alerts for destructive actions  
✓ Accessibility-ready structure  
✓ Standard list layouts  

## Privacy Compliance

- NSCameraUsageDescription: Camera access reason
- NSPhotoLibraryUsageDescription: Photo library access reason
- Both configured in build settings

## Build Configuration

- Target: iOS 16.2+
- Swift: 5.0
- Deployment: iPhone & iPad
- Orientation: Portrait (primary)
- Bundle ID: dev.louc.nouri


