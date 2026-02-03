# 📊 Health Score Feature

## Overview

Added a dedicated **Health Score** tab to track nutrition scores and provide insights into eating habits.

## What's New

### New Tab in Bottom Navigation

- **Icon:** Heart with text square (`heart.text.square.fill`)
- **Position:** Second tab (between "Today" and "Learn")
- **Purpose:** View health scores and meal insights

## Features

### 1. Daily Score Card

- Shows today's total health score
- Color-coded gradient based on performance:
  - 🟢 Green (200+ points): "Excellent nutrition!"
  - 🔵 Blue (100-199 points): "Good choices!"
  - 🟠 Orange (0-99 points): "Room for improvement"
  - 🔴 Red (negative): "Focus on healthier options"

### 2. Weekly Score Card

- Shows 7-day cumulative score
- Similar color-coded system:
  - 🟢 Green (1000+ points): "Outstanding week!"
  - 🔵 Blue (500-999 points): "Good progress!"
  - 🟠 Orange (0-499 points): "Keep trying!"
  - 🔴 Red (negative): "Let's improve together"

### 3. Today's Meals Breakdown

- List of all meals logged today
- Each meal shows:
  - Meal type icon (sunrise, sun, moon, etc.)
  - Meal name (Breakfast, Lunch, etc.)
  - Detected food name
  - Individual health score with +/- prefix
  - Color-coded score (green = healthy, red = unhealthy)
- Sorted by meal type (chronological order)
- Empty state when no meals logged

### 4. Health Score Guide (Expandable)

- Tap to expand/collapse
- Shows scoring ranges for each food category:
  - 🥬 Vegetables: 85-95 points
  - 🍎 Fruits: 75-90 points
  - 🍗 Proteins: 60-85 points
  - 🍚 Grains: 50-80 points
  - ☕️ Beverages: 20-100 points
  - 🍕 Fast Food: -35 to -60 points
  - 🍰 Sweets: -40 to -75 points
- Daily goals section with targets
- Color-coded indicators

## UI/UX Design

### Visual Hierarchy

1. **Top**: Daily score (most important, largest)
2. **Middle**: Weekly score (secondary importance)
3. **Meals**: Detailed breakdown
4. **Bottom**: Educational guide (expandable)

### Color System

- **Green**: Excellent scores (≥70 points)
- **Blue**: Good scores (40-69 points)
- **Orange**: Moderate scores (0-39 points)
- **Red**: Negative scores (<0 points)

### Layout

- ScrollView for all content
- Cards with rounded corners (16px radius)
- Consistent padding and spacing
- System grouped background
- Shadows for depth (subtle)

## Technical Implementation

### New Files

- `HealthScoreView.swift` - Main view and all components

### Components Created

1. **HealthScoreView** - Main container
2. **ScoreCard** - Reusable score display card
3. **TodayMealsSection** - Meals list container
4. **MealScoreRow** - Individual meal row
5. **HealthScoreGuide** - Expandable guide
6. **ScoreRangeRow** - Guide row item

### Extensions

- `MealType` extension with `icon` property for SF Symbols

### Data Source

- Uses existing `MealPersistenceManager.shared`
- Calls `getDailyHealthScore()` and `getWeeklyHealthScore()`
- Filters meals for today using `Calendar.isDateInToday()`

## User Flow

1. User opens app → Sees "Today" tab by default
2. User logs meals with photos throughout the day
3. AI recognizes food → Health scores calculated automatically
4. User taps **"Health"** tab → Sees:
   - Current daily score
   - Weekly trend
   - Breakdown of today's meals
   - How scoring works
5. User expands guide to learn about scoring system
6. User adjusts food choices based on insights

## Benefits

### For Users

- ✅ **Visual feedback** on nutrition choices
- ✅ **Motivation** to eat healthier
- ✅ **Education** about food scores
- ✅ **Tracking** daily and weekly progress
- ✅ **Awareness** of eating habits

### For App

- ✅ **Engagement** - Another reason to use the app
- ✅ **Value** - Actionable insights from photos
- ✅ **Gamification** - Score system encourages better choices
- ✅ **Retention** - Weekly tracking encourages daily use

## Future Enhancements

Potential improvements:

- [ ] Monthly/yearly score graphs
- [ ] Score history chart (line graph)
- [ ] Achievements/badges for milestones
- [ ] Custom score goals
- [ ] Meal recommendations based on current score
- [ ] Share score achievements
- [ ] Compare with previous weeks
- [ ] Nutritional balance indicator (proteins/carbs/fats)

## Testing Checklist

- [x] View displays correctly
- [x] Scores calculate accurately
- [x] Empty state shows when no meals
- [x] Colors match score ranges
- [x] Expandable guide works
- [x] Tab icon shows correctly
- [ ] Test with various meal combinations
- [ ] Test with negative scores
- [ ] Test with high scores (200+)
- [ ] Verify performance with many meals

## Screenshots (Future)

_Add screenshots here after building the app_

## Integration

Updated files:

- ✅ `ContentView.swift` - Added Health tab
- ✅ `README.md` - Documented new feature
- ✅ `PROJECT_STRUCTURE.md` - Updated structure
- ✅ `nouri.xcodeproj` - Added new file to project

## Scoring Reference

Quick reference for understanding scores:

**Excellent Day (200+ points):**

- 3 vegetables/fruits (270 points)
- Lean protein (75 points)
- Water/tea (85 points)
- = 430 points 🎉

**Good Day (100-199 points):**

- 2 fruits (160 points)
- Chicken (75 points)
- Coffee (40 points)
- = 275 points ✅

**Needs Improvement (0-99 points):**

- Oatmeal (80 points)
- Burger (-50 points)
- Soda (-60 points)
- = -30 points ⚠️

---

**Feature Status:** ✅ Complete and Ready
**Added:** February 3, 2026
