//
//  PreferencesView.swift
//  Cooking AI
//

import SwiftUI

struct PreferencesView: View {
    @ObservedObject var preferencesManager = PreferencesManager.shared
    @State private var showOnboarding = false
    
    var body: some View {
        ZStack {
            Color.theme.background.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 25) {
                    // Header
                    Text("Preferences")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(Color.theme.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                    
                    // Dietary Restrictions
                    PreferenceSection(
                        title: "Dietary Restrictions",
                        items: preferencesManager.preferences.diets
                    )
                    
                    // Cooking Experience
                    PreferenceSection(
                        title: "Cooking Experience",
                        items: [preferencesManager.preferences.experience]
                    )
                    
                    // Favorite Cuisines
                    PreferenceSection(
                        title: "Favorite Cuisines",
                        items: preferencesManager.preferences.favourite
                    )
                    
                    // Meal Prep Time
                    PreferenceSection(
                        title: "Meal Prep Time",
                        items: preferencesManager.preferences.time
                    )
                    
                    // Edit button
                    Button(action: handleEditPreferencesWithHaptic) {
                        Text("Edit Preferences")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.theme.primary)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    .accessibilityLabel("Edit preferences")
                    .accessibilityHint("Double tap to modify your cooking preferences")
                }
                .padding(.bottom, 100)
            }
        }
        .fullScreenCover(isPresented: $showOnboarding) {
            OnboardingContainerView()
        }
    }
    
    private func handleEditPreferences() {
        showOnboarding = true
    }
    
    private func handleEditPreferencesWithHaptic() {
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()
        showOnboarding = true
    }
}

struct PreferenceSection: View {
    let title: String
    let items: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text(title)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(Color.theme.primary)
            
            if items.isEmpty || (items.count == 1 && items[0].isEmpty) {
                Text("Not set")
                    .font(.system(size: 14))
                    .foregroundColor(Color.theme.textSecondary)
                    .italic()
            } else {
                ForEach(items, id: \.self) { item in
                    HStack(spacing: 10) {
                        Circle()
                            .fill(Color.theme.primary)
                            .frame(width: 8, height: 8)
                        Text(item)
                            .font(.system(size: 16))
                            .foregroundColor(Color.theme.textPrimary)
                    }
                }
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.theme.cardBackground)
        .cornerRadius(12)
        .shadow(color: Color.theme.shadowLight, radius: 5, x: 0, y: 2)
        .padding(.horizontal, 20)
    }
}

