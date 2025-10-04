//
//  ContentView.swift
//  Cooking AI
//
//  Created by Eugene Puntus on 04.10.25.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var preferencesManager = PreferencesManager.shared
    
    var body: some View {
        if preferencesManager.hasCompletedOnboarding {
            TabNavigationView()
        } else {
            OnboardingContainerView()
        }
    }
}

#Preview {
    ContentView()
}
