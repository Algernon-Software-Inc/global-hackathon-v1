//
//  FavouritesView.swift
//  Cooking AI
//

import SwiftUI

struct FavouritesView: View {
    @ObservedObject var favouritesManager = FavouritesManager.shared
    @State private var searchText = ""
    @State private var isRefreshing = false
    @State private var showEmptyAnimation = false
    @State private var selectedDish: Dish?
    @State private var showDishDetail = false
    
    var filteredFavourites: [Dish] {
        if searchText.isEmpty {
            return favouritesManager.favourites
        } else {
            return favouritesManager.favourites.filter { dish in
                dish.name.localizedCaseInsensitiveContains(searchText) ||
                dish.products.contains { $0.localizedCaseInsensitiveContains(searchText) }
            }
        }
    }
    
    var body: some View {
        ZStack {
            Color.theme.background.ignoresSafeArea()
            
            if favouritesManager.favourites.isEmpty {
                // Enhanced empty state with animations
                VStack(spacing: 28) {
                    // Animated heart icon
                    ZStack {
                        // Pulsing background circle
                        Circle()
                            .fill(Color.theme.primaryLight)
                            .frame(width: 140, height: 140)
                            .scaleEffect(showEmptyAnimation ? 1.1 : 1.0)
                            .opacity(showEmptyAnimation ? 0.3 : 0.6)
                            .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: showEmptyAnimation)
                        
                        // Main heart icon
                    Image(systemName: "heart.slash")
                            .font(.system(size: 70, weight: .light))
                            .foregroundColor(Color.theme.primary.opacity(0.7))
                            .scaleEffect(showEmptyAnimation ? 1.0 : 0.95)
                            .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: showEmptyAnimation)
                    }
                    .padding(.top, 20)
                    
                    VStack(spacing: 12) {
                    Text("No Favourites Yet")
                            .font(.system(size: 26, weight: .bold))
                            .foregroundColor(Color.theme.textPrimary)
                        
                        Text("Start saving recipes you love\nand find them here anytime")
                            .font(.system(size: 16))
                            .foregroundColor(Color.theme.textSecondary)
                            .multilineTextAlignment(.center)
                            .lineSpacing(5)
                    }
                    
                    // Visual hint - example recipe cards
                    VStack(spacing: 12) {
                        HStack(spacing: 12) {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.theme.primaryLight)
                                .frame(width: 100, height: 80)
                                .overlay(
                                    Image(systemName: "fork.knife")
                                        .foregroundColor(Color.theme.primary.opacity(0.4))
                                )
                            
                            VStack(alignment: .leading, spacing: 4) {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.theme.primaryLight)
                                    .frame(width: 140, height: 12)
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.theme.primaryLight)
                                    .frame(width: 100, height: 10)
                            }
                            Spacer()
                        }
                        .padding(12)
                        .background(Color.theme.cardBackground)
                        .cornerRadius(16)
                        .shadow(color: Color.theme.shadowLight, radius: 4, x: 0, y: 2)
                        .opacity(0.5)
                    }
                    .padding(.horizontal, 20)
                    
                    // Action button
                    Button(action: handleGoToMainView) {
                        HStack(spacing: 10) {
                            Image(systemName: "camera.fill")
                                .font(.system(size: 18, weight: .semibold))
                            Text("Discover Recipes")
                                .font(.system(size: 17, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: 280)
                        .padding(.horizontal, 28)
                        .padding(.vertical, 14)
                        .background(
                            LinearGradient(
                                colors: [Color.theme.primary, Color.theme.primaryDark],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(14)
                        .shadow(color: Color.theme.primary.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                    .scaleEffect(showEmptyAnimation ? 1.0 : 0.98)
                    .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: showEmptyAnimation)
                }
                        .padding(.horizontal, 40)
                .onAppear {
                    showEmptyAnimation = true
                }
            } else {
                VStack(spacing: 0) {
                    // Header with count
                    VStack(spacing: 16) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                        Text("My Favourites")
                            .font(.system(size: 32, weight: .bold))
                                    .foregroundColor(Color.theme.primary)
                                
                                Text("\(filteredFavourites.count) \(filteredFavourites.count == 1 ? "recipe" : "recipes")")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(Color.theme.textSecondary)
                            }
                            Spacer()
                        }
                            .padding(.horizontal, 20)
                            .padding(.top, 20)
                        
                        // Search bar
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(Color.theme.textSecondary)
                            
                            TextField("Search recipes or ingredients", text: $searchText)
                                .font(.system(size: 16))
                                .foregroundColor(Color.theme.textPrimary)
                            
                            if !searchText.isEmpty {
                                Button(action: { searchText = "" }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(Color.theme.textSecondary)
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Color.theme.backgroundSecondary)
                        .cornerRadius(12)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 5)
                    }
                    
                    // Favourites list with pull-to-refresh
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(filteredFavourites) { dish in
                                CompactDishCardView(dish: dish)
                                .padding(.horizontal, 20)
                                    .onTapGesture {
                                        handleOpenDishDetail(dish)
                                    }
                                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                        // Delete action
                                        Button(role: .destructive) {
                                            handleDeleteFavourite(dish)
                                        } label: {
                                            Label("Delete", systemImage: "trash.fill")
                                        }
                                        .tint(.red)
                                    }
                                    .swipeActions(edge: .leading, allowsFullSwipe: false) {
                                        // Share action
                                        Button {
                                            handleShareRecipe(dish)
                                        } label: {
                                            Label("Share", systemImage: "square.and.arrow.up.fill")
                                        }
                                        .tint(.blue)
                                        
                                        // Cook now action
                                        Button {
                                            handleCookNow(dish)
                                        } label: {
                                            Label("Cook", systemImage: "flame.fill")
                                        }
                                        .tint(.orange)
                                    }
                            }
                            
                            if filteredFavourites.isEmpty && !searchText.isEmpty {
                                VStack(spacing: 12) {
                                    Image(systemName: "magnifyingglass")
                                        .font(.system(size: 50))
                                        .foregroundColor(Color.theme.textTertiary)
                                    Text("No recipes found")
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundColor(Color.theme.textSecondary)
                                    Text("Try a different search term")
                                        .font(.system(size: 14))
                                        .foregroundColor(Color.theme.textSecondary)
                                }
                                .padding(.top, 60)
                            }
                        }
                        .padding(.top, 20)
                        .padding(.bottom, 100)
                    }
                    .refreshable {
                        await handleRefresh()
                    }
                }
            }
        }
        .sheet(isPresented: $showDishDetail) {
            if let dish = selectedDish {
                DishDetailView(dish: dish)
            }
        }
    }
    
    private func handleOpenDishDetail(_ dish: Dish) {
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()
        
        selectedDish = dish
        showDishDetail = true
    }
    
    private func handleGoToMainView() {
        // This would typically use a navigation coordinator or TabView selection binding
        // For now, user can manually switch tabs
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()
    }
    
    private func handleDeleteFavourite(_ dish: Dish) {
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
        
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            favouritesManager.toggleFavourite(dish)
        }
    }
    
    private func handleShareRecipe(_ dish: Dish) {
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()
        
        // Create share text
        let shareText = """
        \(dish.name)
        
        Time: \(dish.timeText)
        Difficulty: \(dish.difficultyText)
        
        Ingredients:
        \(dish.products.map { "• \($0)" }.joined(separator: "\n"))
        
        Recipe:
        \(dish.recipe)
        """
        
        // Share using UIActivityViewController
        let activityVC = UIActivityViewController(
            activityItems: [shareText],
            applicationActivities: nil
        )
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           let rootVC = window.rootViewController {
            activityVC.popoverPresentationController?.sourceView = window
            activityVC.popoverPresentationController?.sourceRect = CGRect(x: window.bounds.midX, y: window.bounds.midY, width: 0, height: 0)
            activityVC.popoverPresentationController?.permittedArrowDirections = []
            rootVC.present(activityVC, animated: true)
        }
    }
    
    private func handleCookNow(_ dish: Dish) {
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
        
        // Show ingredients checklist or navigate to cooking mode
        // For now, we'll show a simple feedback
        // In a full app, this would open a cooking mode view
        print("🍳 Starting to cook: \(dish.name)")
    }
    
    private func handleRefresh() async {
        isRefreshing = true
        
        // Simulate refresh delay (in real app, this would sync with server)
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        
        isRefreshing = false
    }
}

