# Cooking AI - Quick Start Guide

## 🚀 What We Built

A complete iOS app with a clean, user-friendly interface that helps users discover recipes based on photos of their ingredients.

### ✅ Completed Features

1. **Full Onboarding Flow** (5 pages)
   - Dietary Restrictions selection
   - Cooking Experience level
   - Favorite Cuisines
   - Meal Prep Time preferences
   - Completion confirmation

2. **Main Application**
   - Home screen with camera/photo upload
   - AI-powered recipe suggestions
   - Detailed recipe cards with nutrition info
   - Favourites management
   - Settings/Preferences management

3. **Navigation**
   - Bottom tab navigation
   - Smooth transitions between screens
   - Persistent state management

4. **Data Management**
   - Local preferences storage
   - Favourites persistence
   - Onboarding state tracking

## 📱 App Flow

```
Launch App
    ↓
First Launch? → YES → Onboarding (5 pages) → Main App
    ↓
    NO
    ↓
Main App (Tab Navigation)
    ├── Home (Take photo → Get recipes)
    ├── Favourites (Saved recipes)
    └── Settings (Edit preferences)
```

## 🎨 Design System

### Colors
- **Primary Green**: RGB(51, 153, 76) / `#33994C`
- **White**: RGB(255, 255, 255) / `#FFFFFF`
- **Gray**: For secondary text

### Typography
- **Headers**: System Bold, 32pt
- **Subheaders**: System Semibold, 20-24pt
- **Body**: System Regular, 14-16pt
- **Small**: System Regular, 12pt

### Components
- Rounded corners (12pt radius)
- Soft shadows
- Green and white color scheme throughout
- Consistent spacing and padding

## 🔧 Next Steps

### 1. Configure API (Required)

Open `Services/APIService.swift` and update:
```swift
private let baseURL = "YOUR_API_BASE_URL"
```

See `API_SETUP.md` for detailed API integration guide.

### 2. Add App Icons

1. Open project in Xcode
2. Go to `Assets.xcassets/AppIcon`
3. Add your `.png` icons in all required sizes
4. Or use https://appicon.co/ to generate all sizes

Required sizes:
- 1024x1024 (App Store)
- 180x180 (iPhone 3x)
- 120x120 (iPhone 2x)
- 167x167 (iPad Pro)
- And more...

### 3. Test on Device/Simulator

1. Open `Cooking AI.xcodeproj` in Xcode
2. Select target device
3. Build and run (⌘R)

### 4. Grant Permissions

When first running the app, grant:
- Camera access (for taking photos)
- Photo library access (for uploading photos)

## 📂 Project Structure

```
Cooking AI/
├── Models/
│   ├── Preferences.swift      # User preferences model
│   └── Dish.swift              # Recipe/dish model
│
├── Services/
│   ├── PreferencesManager.swift   # Preferences storage
│   ├── FavouritesManager.swift    # Favourites storage
│   └── APIService.swift           # API integration
│
├── Views/
│   ├── Onboarding/              # 5 onboarding pages
│   │   ├── DietaryRestrictionsView.swift
│   │   ├── CookingExperienceView.swift
│   │   ├── FavoriteCuisinesView.swift
│   │   ├── MealPrepTimeView.swift
│   │   ├── OnboardingCompleteView.swift
│   │   └── OnboardingContainerView.swift
│   │
│   ├── Main/                    # Main app screens
│   │   ├── MainView.swift
│   │   ├── FavouritesView.swift
│   │   ├── PreferencesView.swift
│   │   └── TabNavigationView.swift
│   │
│   └── Components/              # Reusable components
│       ├── SelectionButton.swift
│       ├── DishCardView.swift
│       └── ImagePicker.swift
│
├── ContentView.swift           # Root view
├── Cooking_AIApp.swift         # App entry point
└── Info.plist                  # Permissions & config
```

## 🧪 Testing the App

### Without API (UI Testing)
1. Run the app
2. Complete onboarding
3. Navigate between tabs
4. Edit preferences
5. Take/upload photos (won't get recipes without API)

### With API (Full Testing)
1. Configure API endpoint
2. Complete onboarding
3. Take photo of ingredients
4. Get recipe suggestions
5. Save to favourites
6. View in favourites tab

## 🎯 Key Features to Test

- [ ] Onboarding flow completion
- [ ] Preferences persistence (close and reopen app)
- [ ] Camera access
- [ ] Photo library access
- [ ] Recipe card display
- [ ] Favourite toggle
- [ ] Navigation between tabs
- [ ] Preferences editing
- [ ] API integration (if configured)

## 🐛 Common Issues & Solutions

### Issue: Camera not working
**Solution:** Check `Info.plist` contains camera permissions

### Issue: Preferences not saving
**Solution:** Ensure `PreferencesManager.shared.savePreferences()` is called after changes

### Issue: API errors
**Solution:** 
1. Verify API URL is correct
2. Check network connection
3. Review API response format
4. See `API_SETUP.md` for debugging

### Issue: App icons not showing
**Solution:** 
1. Ensure all required sizes are added
2. Clean build folder (⌘⇧K)
3. Rebuild project

## 📱 Supported Devices

- **iOS Version:** 15.0+
- **iPhone:** All models
- **iPad:** All models (universal app)

## 🎨 Customization

### Change Primary Color
Search and replace in all files:
```swift
Color(red: 0.2, green: 0.6, blue: 0.3)
```
With your preferred color.

### Modify Preferences Options
Edit enums in `Models/Preferences.swift`:
- `DietaryRestriction`
- `CookingExperience`
- `FavoriteCuisine`
- `MealPrepTime`

## 📚 Additional Resources

- **README.md**: Complete documentation
- **API_SETUP.md**: API integration guide
- **Xcode Documentation**: Press ⌥ while clicking any symbol

## 🚢 Ready to Ship?

Before submitting to App Store:
1. ✅ Add all app icons
2. ✅ Configure API with production URL
3. ✅ Test on physical devices
4. ✅ Add app description and screenshots
5. ✅ Set up App Store Connect account
6. ✅ Create app listing
7. ✅ Submit for review

## 🎉 You're All Set!

The app is fully functional and ready for API integration. Once you connect your API endpoint, users can start getting recipe suggestions!

**Need Help?** Check the documentation files or review the inline code comments.
