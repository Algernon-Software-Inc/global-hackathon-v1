//
//  FavouritesManager.swift
//  Cooking AI
//

import Foundation

class FavouritesManager: ObservableObject {
    static let shared = FavouritesManager()
    
    @Published var favourites: [Dish] = []
    
    private let favouritesKey = "savedFavourites"
    
    private init() {
        loadFavourites()
    }
    
    func loadFavourites() {
        if let data = UserDefaults.standard.data(forKey: favouritesKey),
           let decoded = try? JSONDecoder().decode([Dish].self, from: data) {
            self.favourites = decoded
        }
    }
    
    func saveFavourites() {
        if let encoded = try? JSONEncoder().encode(favourites) {
            UserDefaults.standard.set(encoded, forKey: favouritesKey)
        }
    }
    
    func addToFavourites(_ dish: Dish) {
        if !isFavourite(dish) {
            favourites.append(dish)
            saveFavourites()
        }
    }
    
    func removeFromFavourites(_ dish: Dish) {
        favourites.removeAll { $0.name == dish.name }
        saveFavourites()
    }
    
    func isFavourite(_ dish: Dish) -> Bool {
        favourites.contains { $0.name == dish.name }
    }
    
    func toggleFavourite(_ dish: Dish) {
        if isFavourite(dish) {
            removeFromFavourites(dish)
        } else {
            addToFavourites(dish)
        }
    }
}

