# Troubleshooting Guide for Nouri

## Build Issues

### "Failed to build the scheme 'nouri'" Error

If you see this error in Xcode, try these solutions in order:

#### Solution 1: Clean Build Folder
1. In Xcode, go to **Product** → **Clean Build Folder** (⇧⌘K)
2. Try building again (⌘B)

#### Solution 2: Clear Derived Data
1. In Xcode, go to **Xcode** → **Settings** → **Locations**
2. Click the arrow next to **Derived Data** path
3. Find the `nouri-*` folder and delete it
4. Restart Xcode
5. Open the project and build again

#### Solution 3: Reset Package Caches (if applicable)
1. In Xcode, go to **File** → **Packages** → **Reset Package Caches**
2. Wait for it to complete
3. Try building again

#### Solution 4: Check Scheme Settings
1. In Xcode, click the scheme dropdown (near the play button)
2. Select **Edit Scheme...**
3. Make sure "nouri" is selected under **Build** → **Targets**
4. Ensure the target is checked for "Run"

#### Solution 5: Verify Simulator/Device Selection
1. Make sure you have a valid iOS Simulator selected
2. Available simulators:
   - iPhone 14 (iOS 16.2)
   - iPhone 14 Pro (iOS 16.2)
   - iPhone SE (3rd gen) (iOS 16.2)
   - iPad models (iOS 16.2)

#### Solution 6: Command Line Build Test
Open Terminal and run:
```bash
cd /Users/chanchinghei/Desktop/app-dev-repos/nouri
xcodebuild -scheme nouri -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 14' clean build
```

If this succeeds (shows "BUILD SUCCEEDED"), then the issue is with Xcode's cache, not the code.

## Common Issues

### Issue: "No such module 'SwiftUI'"
**Solution**: Make sure your deployment target is iOS 16.2+. Check in:
- Project settings → nouri target → General → Minimum Deployments

### Issue: Photos don't appear after selection
**Cause**: This is normal on first run. The app needs photo library permissions.

**Solution**:
1. When prompted, tap "Allow Access to All Photos" or "Select Photos..."
2. If you denied permission, go to Settings → nouri → Photos and enable access

### Issue: Camera option not working
**Note**: The current implementation only supports photo library selection. Camera capture is prepared for future enhancement but not yet implemented in the UI.

### Issue: App crashes on launch
**Solution**:
1. Check Console for error messages
2. Verify all files are included in the build target
3. Clean build folder and rebuild

## Verification Steps

To verify the project is set up correctly:

1. **Check File Structure**:
```
nouri/
├── Models/
│   ├── MealType.swift
│   └── MealEntry.swift
├── Views/
│   ├── TodayView.swift
│   ├── MotivationView.swift
│   └── SettingsView.swift
├── Managers/
│   └── MealPersistenceManager.swift
├── ContentView.swift
└── nouriApp.swift
```

2. **Verify Build Settings**:
   - iOS Deployment Target: 16.2
   - Swift Language Version: 5.0
   - All Swift files in "Compile Sources" build phase

3. **Test Build from Command Line**:
```bash
cd /Users/chanchinghei/Desktop/app-dev-repos/nouri
xcodebuild -list  # Should show "nouri" scheme
xcodebuild -scheme nouri -sdk iphonesimulator build
```

## Getting Help

If none of these solutions work:

1. Check the specific error message in Xcode's issue navigator (⌘5)
2. Look at the build log: **View** → **Navigators** → **Reports** → select latest build
3. Note any red error messages and their file locations

## Known Limitations

- iOS 16.2+ required (uses SwiftUI features from iOS 16)
- Photos stored locally only (no iCloud sync)
- Camera capture UI not yet implemented (prepared for future)
- No landscape optimizations (portrait primary)

## Success Indicators

The build is successful if:
- ✅ "BUILD SUCCEEDED" appears in Xcode
- ✅ App launches in simulator/device
- ✅ Three tabs appear at bottom
- ✅ Meal grid shows 6 cards in Today tab
- ✅ Tapping a card opens photo picker
- ✅ Selected photos appear in meal cards

## Need More Help?

The project has been verified to build successfully from command line. If Xcode continues to have issues, try:
1. Restart Xcode
2. Restart your Mac
3. Update to latest Xcode version (if possible)
4. Create a new Xcode project and copy the files over


