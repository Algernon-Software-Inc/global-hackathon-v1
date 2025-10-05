//
//  TabNavigationView.swift
//  Cooking AI
//

import SwiftUI

struct TabNavigationView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Main content
            TabView(selection: $selectedTab) {
                MainView()
                    .tag(0)
                
                FavouritesView()
                    .tag(1)
                
                PreferencesView()
                    .tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            
            // Custom bottom navigation bar
            HStack(spacing: 0) {
                TabBarItem(
                    icon: "heart.fill",
                    label: "Favourites",
                    isSelected: selectedTab == 1
                ) {
                    handleTabSelection(1)
                }
                
                TabBarItem(
                    icon: "house.fill",
                    label: "Home",
                    isSelected: selectedTab == 0
                ) {
                    handleTabSelection(0)
                }
                
                TabBarItem(
                    icon: "gearshape.fill",
                    label: "Settings",
                    isSelected: selectedTab == 2
                ) {
                    handleTabSelection(2)
                }
            }
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.theme.cardBackground)
                    .shadow(color: Color.theme.shadowMedium, radius: 10, x: 0, y: -5)
            )
            .padding(.horizontal, 20)
            .padding(.bottom, safeBottomInset())
        }
        .ignoresSafeArea(.keyboard)
    }
    
    private func handleTabSelection(_ tab: Int) {
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()
        selectedTab = tab
    }
}

struct TabBarItem: View {
    let icon: String
    let label: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 5) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(isSelected ? Color.theme.primary : Color.theme.textSecondary)
                
                Text(label)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(isSelected ? Color.theme.primary : Color.theme.textSecondary)
            }
            .frame(maxWidth: .infinity)
        }
        .accessibilityLabel("\(label) tab")
        .accessibilityHint(isSelected ? "Currently selected" : "Double tap to switch to \(label)")
    }
}

private func safeBottomInset() -> CGFloat {
    guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
          let window = windowScene.windows.first else { return 0 }
    return window.safeAreaInsets.bottom
}
