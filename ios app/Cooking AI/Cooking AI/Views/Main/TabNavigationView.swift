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
                    icon: "house.fill",
                    label: "Home",
                    isSelected: selectedTab == 0
                ) {
                    selectedTab = 0
                }
                
                TabBarItem(
                    icon: "heart.fill",
                    label: "Favourites",
                    isSelected: selectedTab == 1
                ) {
                    selectedTab = 1
                }
                
                TabBarItem(
                    icon: "gearshape.fill",
                    label: "Settings",
                    isSelected: selectedTab == 2
                ) {
                    selectedTab = 2
                }
            }
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: -5)
            )
            .padding(.horizontal, 20)
            .padding(.bottom, safeBottomInset() + 2)
            .offset(y: 20)
        }
        .ignoresSafeArea(.keyboard)
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
                    .foregroundColor(isSelected ? Color(red: 0.2, green: 0.6, blue: 0.3) : .gray)
                
                Text(label)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(isSelected ? Color(red: 0.2, green: 0.6, blue: 0.3) : .gray)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

private func safeBottomInset() -> CGFloat {
    guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
          let window = windowScene.windows.first else { return 0 }
    return window.safeAreaInsets.bottom
}
