//
//  Preferences.swift
//  Cooking AI
//

import Foundation

struct UserPreferences: Codable {
    var diets: [String]
    var experience: String
    var favourite: [String]
    var time: [String]
    
    init() {
        self.diets = []
        self.experience = ""
        self.favourite = []
        self.time = []
    }
    
    func toAPIFormat() -> [String: Any] {
        return [
            "diets": diets,
            "experience": experience,
            "favourite": favourite,
            "time": time
        ]
    }
}

// Dietary options
enum DietaryRestriction: String, CaseIterable {
    case vegetarian = "Vegetarian"
    case vegan = "Vegan"
    case glutenFree = "Gluten-free"
    case dairyFree = "Dairy-free"
    case lactoseFree = "Lactose-free"
    case keto = "Keto"
    case lowCarb = "Low-carb"
    case none = "None"
}

// Cooking experience levels
enum CookingExperience: String, CaseIterable {
    case beginner = "Beginner"
    case intermediate = "Intermediate"
    case advanced = "Advanced"
    case professional = "Professional"
}

// Favorite cuisines
enum FavoriteCuisine: String, CaseIterable {
    case italian = "Italian"
    case chinese = "Chinese"
    case japanese = "Japanese"
    case mexican = "Mexican"
    case indian = "Indian"
    case french = "French"
    case mediterranean = "Mediterranean"
    case american = "American"
    case thai = "Thai"
}

// Meal prep time
enum MealPrepTime: String, CaseIterable {
    case quick = "15-30 minutes"
    case medium = "30-60 minutes"
    case long = "1-2 hours"
    case veryLong = "2+ hours"
}
