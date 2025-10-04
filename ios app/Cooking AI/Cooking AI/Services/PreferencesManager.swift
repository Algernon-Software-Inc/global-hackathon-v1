//
//  PreferencesManager.swift
//  Cooking AI
//

import Foundation

class PreferencesManager: ObservableObject {
    static let shared = PreferencesManager()
    
    @Published var preferences: UserPreferences
    @Published var hasCompletedOnboarding: Bool
    
    private let preferencesKey = "userPreferences"
    private let onboardingKey = "hasCompletedOnboarding"
    
    private init() {
        // Load preferences from UserDefaults
        if let data = UserDefaults.standard.data(forKey: preferencesKey),
           let decoded = try? JSONDecoder().decode(UserPreferences.self, from: data) {
            self.preferences = decoded
        } else {
            self.preferences = UserPreferences()
        }
        
        self.hasCompletedOnboarding = UserDefaults.standard.bool(forKey: onboardingKey)
    }
    
    func savePreferences() {
        if let encoded = try? JSONEncoder().encode(preferences) {
            UserDefaults.standard.set(encoded, forKey: preferencesKey)
        }
    }
    
    func completeOnboarding() {
        hasCompletedOnboarding = true
        UserDefaults.standard.set(true, forKey: onboardingKey)
    }
    
    func resetOnboarding() {
        hasCompletedOnboarding = false
        UserDefaults.standard.set(false, forKey: onboardingKey)
    }
}
