//
//  Dish.swift
//  Cooking AI
//

import Foundation

struct Dish: Codable, Identifiable {
    let id = UUID()
    let name: String
    let products: [String]
    let recipe: String
    let time_min: Int
    let difficulty: Int
    let energy_kcal: Double
    let proteins_g: Double
    let fats_g: Double
    let carbs_g: Double
    let image_id: String
    
    enum CodingKeys: String, CodingKey {
        case name, products, recipe, time_min, difficulty
        case energy_kcal, proteins_g, fats_g, carbs_g, image_id
    }
    
    // For displaying difficulty as stars
    var difficultyStars: String {
        String(repeating: "⭐️", count: min(difficulty, 5))
    }
}
