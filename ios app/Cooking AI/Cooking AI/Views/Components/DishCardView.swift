//
//  DishCardView.swift
//  Cooking AI
//

import SwiftUI

struct DishCardView: View {
    let dish: Dish
    @ObservedObject var favouritesManager = FavouritesManager.shared
    @State private var dishImage: UIImage?
    @State private var isLoadingImage = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Image and favourite button
            ZStack(alignment: .topTrailing) {
                if let image = dishImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 220)
                        .clipped()
                } else if isLoadingImage {
                    ZStack {
                        LinearGradient(
                            colors: [Color.gray.opacity(0.1), Color.gray.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        .frame(height: 220)
                        
                        ProgressView()
                            .tint(Color.theme.primary)
                    }
                } else {
                    LinearGradient(
                        colors: [Color.gray.opacity(0.1), Color.gray.opacity(0.2)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .frame(height: 220)
                    .overlay(
                        Image(systemName: "photo")
                            .font(.system(size: 40))
                            .foregroundColor(Color.theme.textTertiary)
                    )
                }
                
                // Favourite button with backdrop
                Button(action: handleToggleFavouriteWithHaptic) {
                    Image(systemName: favouritesManager.isFavourite(dish) ? "heart.fill" : "heart")
                        .font(.system(size: 22))
                        .foregroundColor(favouritesManager.isFavourite(dish) ? Color.theme.favorite : .white)
                        .padding(12)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                        .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
                }
                .padding(12)
                .accessibilityLabel(favouritesManager.isFavourite(dish) ? "Remove from favourites" : "Add to favourites")
            }
            
            VStack(alignment: .leading, spacing: 16) {
                // Dish name
                Text(dish.name)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color.theme.primary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                
                // Time and difficulty with enhanced styling
                HStack(spacing: 12) {
                    InfoPill(icon: "clock.fill", text: dish.timeText)
                    InfoPill(icon: "chart.bar.fill", text: dish.difficultyText)
                }
                
                // Nutrition info with better layout
                VStack(alignment: .leading, spacing: 10) {
                    Text("Nutrition")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color.theme.textSecondary)
                        .textCase(.uppercase)
                        .tracking(0.5)
                    
                    HStack(spacing: 10) {
                        NutritionBadge(label: "Calories", value: String(format: "%.0f", dish.energy_kcal), unit: "kcal")
                        NutritionBadge(label: "Protein", value: String(format: "%.0f", dish.proteins_g), unit: "g")
                        NutritionBadge(label: "Fat", value: String(format: "%.0f", dish.fats_g), unit: "g")
                        NutritionBadge(label: "Carbs", value: String(format: "%.0f", dish.carbs_g), unit: "g")
                    }
                }
                
                Divider()
                    .padding(.vertical, 4)
                
                // Ingredients with better visual hierarchy
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "cart.fill")
                            .font(.system(size: 16))
                            .foregroundColor(Color.theme.primary)
                        Text("Ingredients")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(Color.theme.primary)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(dish.products, id: \.self) { product in
                            HStack(alignment: .top, spacing: 10) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 12))
                                    .foregroundColor(Color.theme.primary.opacity(0.6))
                                    .padding(.top, 2)
                                Text(product)
                                    .font(.system(size: 15))
                                    .foregroundColor(Color.theme.textPrimary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }
                    .padding(.leading, 4)
                }
                
                Divider()
                    .padding(.vertical, 4)
                
                // Recipe with step formatting
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "book.fill")
                            .font(.system(size: 16))
                            .foregroundColor(Color.theme.primary)
                        Text("Instructions")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(Color.theme.primary)
                    }
                    
                    Text(dish.recipe)
                        .font(.system(size: 15))
                        .foregroundColor(Color.theme.textPrimary)
                        .lineSpacing(6)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.leading, 4)
                }
            }
            .padding(20)
        }
        .background(Color.theme.cardBackground)
        .cornerRadius(20)
        .shadow(color: Color.theme.shadowMedium, radius: 12, x: 0, y: 6)
        .onAppear {
            loadDishImage()
        }
    }
    
    private func handleToggleFavourite() {
        favouritesManager.toggleFavourite(dish)
    }
    
    private func handleToggleFavouriteWithHaptic() {
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()
        favouritesManager.toggleFavourite(dish)
    }
    
    private func loadDishImage() {
        isLoadingImage = true
        
        Task {
            do {
                guard let imageId = dish.image_id else {
                    await MainActor.run { isLoadingImage = false }
                    return
                }
                let image = try await APIService.shared.getImage(imageId: imageId)
                await MainActor.run {
                    dishImage = image
                    isLoadingImage = false
                }
            } catch {
                await MainActor.run {
                    isLoadingImage = false
                }
            }
        }
    }
}

// Info pill for time and difficulty
struct InfoPill: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .semibold))
            Text(text)
                .font(.system(size: 13, weight: .medium))
        }
        .foregroundColor(Color.theme.primary)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.theme.primaryLight)
        .cornerRadius(20)
    }
}

// Enhanced nutrition badge
struct NutritionBadge: View {
    let label: String
    let value: String
    let unit: String
    
    var body: some View {
        VStack(spacing: 4) {
            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text(value)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Color.theme.primary)
                Text(unit)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(Color.theme.textSecondary)
            }
            Text(label)
                .font(.system(size: 11))
                .foregroundColor(Color.theme.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(Color.theme.primaryLight)
        .cornerRadius(10)
    }
}
