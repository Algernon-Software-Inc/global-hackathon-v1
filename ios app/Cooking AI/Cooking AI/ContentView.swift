//
//  ContentView.swift
//  Cooking AI
//
//  Created by Eugene Puntus on 04.10.25.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var preferencesManager = PreferencesManager.shared
    @State private var showSplash = true
    
    var body: some View {
        ZStack {
            if showSplash {
                SplashScreenView()
                    .transition(.opacity)
            } else {
                if preferencesManager.hasCompletedOnboarding {
                    TabNavigationView()
                } else {
                    OnboardingContainerView()
                }
            }
        }
        .onAppear {
            // Show splash screen for 2 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation(.easeOut(duration: 0.5)) {
                    showSplash = false
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
