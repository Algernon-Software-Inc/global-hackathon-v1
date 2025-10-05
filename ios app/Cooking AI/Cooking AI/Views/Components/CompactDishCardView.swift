//
//  CompactDishCardView.swift
//  Cooking AI
//

import SwiftUI

struct CompactDishCardView: View {
    let dish: Dish
    @ObservedObject var favouritesManager = FavouritesManager.shared
    @State private var dishImage: UIImage?
    @State private var isLoadingImage = false
    
    var body: some View {
        HStack(spacing: 12) {
            // Thumbnail image
            ZStack {
                if let image = dishImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 80, height: 80)
                        .clipped()
                        .cornerRadius(12)
                } else if isLoadingImage {
                    ZStack {
                        LinearGradient(
                            colors: [Color.gray.opacity(0.1), Color.gray.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        .frame(width: 80, height: 80)
                        .cornerRadius(12)
                        
                        ProgressView()
                            .tint(Color.theme.primary)
                    }
                } else {
                    LinearGradient(
                        colors: [Color.gray.opacity(0.1), Color.gray.opacity(0.2)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .frame(width: 80, height: 80)
                    .cornerRadius(12)
                    .overlay(
                        Image(systemName: "photo")
                            .font(.system(size: 24))
                            .foregroundColor(Color.theme.textTertiary)
                    )
                }
            }
            
            // Content
            VStack(alignment: .leading, spacing: 6) {
                // Dish name
                Text(dish.name)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(Color.theme.textPrimary)
                    .lineLimit(2)
                
                // Time and difficulty
                HStack(spacing: 10) {
                    HStack(spacing: 4) {
                        Image(systemName: "clock.fill")
                            .font(.system(size: 11))
                        Text(dish.timeText)
                            .font(.system(size: 13))
                    }
                    .foregroundColor(Color.theme.textSecondary)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "chart.bar.fill")
                            .font(.system(size: 11))
                        Text(dish.difficultyText)
                            .font(.system(size: 13))
                    }
                    .foregroundColor(Color.theme.textSecondary)
                }
                
                // Ingredients summary
                HStack(spacing: 6) {
                    HStack(spacing: 3) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 10))
                            .foregroundColor(Color.theme.success)
                        Text("\(dish.existingProducts.count)/\(dish.products.count)")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(Color.theme.textSecondary)
                    }
                    
                    Text("•")
                        .foregroundColor(Color.theme.textTertiary)
                        .font(.system(size: 10))
                    
                    Text("\(dish.products.count) ingredients")
                        .font(.system(size: 12))
                        .foregroundColor(Color.theme.textSecondary)
                }
            }
            
            Spacer()
            
            // Favorite button
            Button(action: handleToggleFavouriteWithHaptic) {
                Image(systemName: "heart.fill")
                    .font(.system(size: 20))
                    .foregroundColor(Color.theme.favorite)
            }
            .padding(.trailing, 4)
        }
        .padding(12)
        .background(Color.theme.cardBackground)
        .cornerRadius(16)
        .shadow(color: Color.theme.shadowLight, radius: 4, x: 0, y: 2)
        .onAppear {
            loadDishImage()
        }
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
