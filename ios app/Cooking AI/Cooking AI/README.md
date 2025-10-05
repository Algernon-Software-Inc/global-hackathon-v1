# Cooking AI - iOS App

A clean and user-friendly iOS app that helps users discover recipes based on photos of their ingredients.

## Features

### 1. User Preferences (Onboarding)
- **Dietary Restrictions**: Vegetarian, Vegan, Gluten-free, Dairy-free, Lactose-free, Keto, Low-carb, None
- **Cooking Experience**: Beginner, Intermediate, Advanced, Professional
- **Favorite Cuisines**: Italian, Chinese, Japanese, Mexican, Indian, French, Mediterranean, American, Thai
- **Meal Prep Time**: 15-30 minutes, 30-60 minutes, 1-2 hours, 2+ hours

### 2. Main Features
- Take photos or upload images of ingredients
- Get AI-powered recipe suggestions
- View detailed recipe cards with:
  - Recipe image
  - Preparation time
  - Difficulty level (stars)
  - Nutritional information (kcal, protein, fat, carbs)
  - Ingredients list
  - Step-by-step recipe instructions
- Save favorite recipes
- Update preferences anytime

### 3. Navigation
- **Home**: Take photos and view recipe suggestions
- **Favourites**: View saved recipes
- **Settings**: Manage preferences

## Design
- **Color Scheme**: Green (#33994C) and White
- **UI Philosophy**: Clean, minimalist, and user-friendly
- **Accessibility**: Full accessibility support with proper labels and keyboard navigation

## Project Structure

```
Cooking AI/
├── Models/
│   ├── Preferences.swift      # User preferences data model
│   └── Dish.swift              # Recipe/dish data model
├── Services/
│   ├── PreferencesManager.swift   # Manages user preferences storage
│   ├── FavouritesManager.swift    # Manages favorite recipes
│   └── APIService.swift           # Handles API communication
├── Views/
│   ├── Onboarding/
│   │   ├── DietaryRestrictionsView.swift
│   │   ├── CookingExperienceView.swift
│   │   ├── FavoriteCuisinesView.swift
│   │   ├── MealPrepTimeView.swift
│   │   ├── OnboardingCompleteView.swift
│   │   └── OnboardingContainerView.swift
│   ├── Main/
│   │   ├── MainView.swift          # Home screen with camera
│   │   ├── FavouritesView.swift    # Saved recipes
│   │   ├── PreferencesView.swift   # Settings screen
│   │   └── TabNavigationView.swift # Bottom navigation
│   └── Components/
│       ├── SelectionButton.swift   # Reusable selection button
│       ├── DishCardView.swift      # Recipe card component
│       └── ImagePicker.swift       # Camera/photo picker
├── ContentView.swift
└── Cooking_AIApp.swift
```

## Setup Instructions

### 1. API Configuration

Update the `baseURL` in `Services/APIService.swift` with your actual API endpoint:

```swift
private let baseURL = "YOUR_API_BASE_URL"
```

### 2. API Integration

The app expects the following API endpoints:

#### POST `/api/get-dishes`
**Request:**
- `image`: JPEG image file
- `preferences`: JSON object with:
  ```json
  {
    "diets": ["Vegetarian", "Gluten-free"],
    "experience": "Intermediate",
    "favourite": ["Italian", "Mediterranean"],
    "time": ["30-60 minutes"]
  }
  ```

**Response:** Array of dishes:
```json
[
  {
    "name": "Pasta Primavera",
    "products": ["pasta", "vegetables", "olive oil"],
    "recipe": "Step by step instructions...",
    "time_min": 30,
    "difficulty": 2,
    "energy_kcal": 450.5,
    "proteins_g": 12.5,
    "fats_g": 15.0,
    "carbs_g": 60.0,
    "image_id": "dish_image_123"
  }
]
```

#### GET `/api/images/{image_id}`
Returns the dish image as JPEG/PNG.

### 3. Adding App Icons

1. Open the project in Xcode
2. Navigate to `Assets.xcassets/AppIcon`
3. Add your app icons in the following sizes:
   - 1024x1024 (App Store)
   - 180x180 (iPhone 3x)
   - 120x120 (iPhone 2x)
   - 167x167 (iPad Pro)
   - 152x152 (iPad 2x)
   - 76x76 (iPad 1x)
   - 40x40, 58x58, 60x60, 80x80, 87x87, 120x120 (Spotlight & Settings)

Or use a tool like [App Icon Generator](https://appicon.co/) to generate all sizes from your icon.

### 4. Camera Permissions

Add these keys to your `Info.plist`:

```xml
<key>NSCameraUsageDescription</key>
<string>We need access to your camera to take photos of your ingredients.</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>We need access to your photo library to upload ingredient photos.</string>
```

### 5. Build and Run

1. Open the project in Xcode 14.0 or later
2. Select your target device or simulator
3. Build and run (⌘R)

## Requirements

- iOS 15.0+
- Xcode 14.0+
- Swift 5.7+

## Data Storage

- **User Preferences**: Stored locally using UserDefaults
- **Favorites**: Stored locally using UserDefaults
- **Onboarding Status**: Stored locally using UserDefaults

## Future Enhancements

- [ ] Add search functionality
- [ ] Implement recipe categories
- [ ] Add social sharing
- [ ] Support for multiple languages
- [ ] Offline mode with local recipe database
- [ ] Nutritional tracking
- [ ] Shopping list generation

## License

Copyright © 2025 Algernon Software Inc. All rights reserved.

