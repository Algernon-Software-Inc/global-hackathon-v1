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
    let image_id: String?

    enum CodingKeys: String, CodingKey {
        case name, products, recipe, time_min, difficulty
        case energy_kcal, proteins_g, fats_g, carbs_g, image_id
        case time, timeMin, difficulty_level, kcal, energy
        case protein, proteins, fat, carbs
        case imageId
    }

    // Lenient decoding to handle partial/mismatched server payloads
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        self.name = (try? c.decode(String.self, forKey: .name)) ?? "Dish"
        self.products = (try? c.decode([String].self, forKey: .products)) ?? []
        self.recipe = (try? c.decode(String.self, forKey: .recipe)) ?? ""

        func decodeInt(_ keys: [CodingKeys], default def: Int) -> Int {
            for k in keys {
                if let v = try? c.decode(Int.self, forKey: k) { return v }
                if let s = try? c.decode(String.self, forKey: k), let v = Int(s) { return v }
                if let d = try? c.decode(Double.self, forKey: k) { return Int(d) }
            }
            return def
        }
        func decodeDouble(_ keys: [CodingKeys], default def: Double) -> Double {
            for k in keys {
                if let v = try? c.decode(Double.self, forKey: k) { return v }
                if let i = try? c.decode(Int.self, forKey: k) { return Double(i) }
                if let s = try? c.decode(String.self, forKey: k), let v = Double(s) { return v }
            }
            return def
        }

        self.time_min = decodeInt([.time_min, .time, .timeMin], default: 0)
        self.difficulty = decodeInt([.difficulty, .difficulty_level], default: 0)
        self.energy_kcal = decodeDouble([.energy_kcal, .kcal, .energy], default: 0)
        self.proteins_g = decodeDouble([.proteins_g, .protein, .proteins], default: 0)
        self.fats_g = decodeDouble([.fats_g, .fat], default: 0)
        self.carbs_g = decodeDouble([.carbs_g, .carbs], default: 0)
        self.image_id = (try? c.decode(String.self, forKey: .image_id)) ?? (try? c.decode(String.self, forKey: .imageId))
    }

    // For displaying difficulty as stars
    var difficultyStars: String {
        String(repeating: "⭐️", count: max(0, min(difficulty, 5)))
    }
    
    // For displaying difficulty as text
    var difficultyText: String {
        switch difficulty {
        case 1:
            return "Very Easy"
        case 2:
            return "Easy"
        case 3:
            return "Medium"
        case 4:
            return "Hard"
        case 5:
            return "Very Hard"
        default:
            return "Easy"
        }
    }
    
    // For displaying time with fallback
    var timeText: String {
        if time_min > 0 {
            return "\(time_min) min"
        } else {
            return "30 min" // Default fallback
        }
    }

    // Encodable conformance (canonical keys)
    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(name, forKey: .name)
        try c.encode(products, forKey: .products)
        try c.encode(recipe, forKey: .recipe)
        try c.encode(time_min, forKey: .time_min)
        try c.encode(difficulty, forKey: .difficulty)
        try c.encode(energy_kcal, forKey: .energy_kcal)
        try c.encode(proteins_g, forKey: .proteins_g)
        try c.encode(fats_g, forKey: .fats_g)
        try c.encode(carbs_g, forKey: .carbs_g)
        try c.encodeIfPresent(image_id, forKey: .image_id)
    }
}
