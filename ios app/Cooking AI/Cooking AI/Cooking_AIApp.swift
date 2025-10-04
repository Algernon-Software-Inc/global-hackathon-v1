//
//  Cooking_AIApp.swift
//  Cooking AI
//
//  Created by Eugene Puntus on 04.10.25.
//

import SwiftUI

@main
struct Cooking_AIApp: App {
    init() {
        // Initialize managers
        _ = PreferencesManager.shared
        _ = FavouritesManager.shared
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
