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
        VStack(alignment: .leading, spacing: 15) {
            // Image and favourite button
            ZStack(alignment: .topTrailing) {
                if let image = dishImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 200)
                        .clipped()
                        .cornerRadius(12)
                } else if isLoadingImage {
                    ZStack {
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 200)
                            .cornerRadius(12)
                        
                        ProgressView()
                    }
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 200)
                        .cornerRadius(12)
                }
                
                // Favourite button
                Button(action: handleToggleFavourite) {
                    Image(systemName: favouritesManager.isFavourite(dish) ? "heart.fill" : "heart")
                        .font(.system(size: 24))
                        .foregroundColor(favouritesManager.isFavourite(dish) ? .red : .white)
                        .padding(10)
                        .background(Color.black.opacity(0.3))
                        .clipShape(Circle())
                }
                .padding(10)
            }
            
            // Dish name
            Text(dish.name)
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(Color(red: 0.2, green: 0.6, blue: 0.3))
            
            // Time and difficulty
            HStack(spacing: 20) {
                HStack(spacing: 5) {
                    Image(systemName: "clock")
                        .foregroundColor(.gray)
                    Text("\(dish.time_min) min")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
                
                HStack(spacing: 5) {
                    Text(dish.difficultyStars)
                        .font(.system(size: 14))
                }
            }
            
            // Nutrition info
            HStack(spacing: 15) {
                NutritionBadge(label: "kcal", value: String(format: "%.0f", dish.energy_kcal))
                NutritionBadge(label: "Protein", value: String(format: "%.0fg", dish.proteins_g))
                NutritionBadge(label: "Fat", value: String(format: "%.0fg", dish.fats_g))
                NutritionBadge(label: "Carbs", value: String(format: "%.0fg", dish.carbs_g))
            }
            
            Divider()
            
            // Ingredients
            VStack(alignment: .leading, spacing: 10) {
                Text("Ingredients")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Color(red: 0.2, green: 0.6, blue: 0.3))
                
                ForEach(dish.products, id: \.self) { product in
                    HStack(spacing: 8) {
                        Circle()
                            .fill(Color(red: 0.2, green: 0.6, blue: 0.3))
                            .frame(width: 6, height: 6)
                        Text(product)
                            .font(.system(size: 14))
                            .foregroundColor(.black)
                    }
                }
            }
            
            Divider()
            
            // Recipe
            VStack(alignment: .leading, spacing: 10) {
                Text("Recipe")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Color(red: 0.2, green: 0.6, blue: 0.3))
                
                Text(dish.recipe)
                    .font(.system(size: 14))
                    .foregroundColor(.black)
                    .lineSpacing(5)
            }
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
        .onAppear {
            loadDishImage()
        }
    }
    
    private func handleToggleFavourite() {
        favouritesManager.toggleFavourite(dish)
    }
    
    private func loadDishImage() {
        isLoadingImage = true
        
        Task {
            do {
                let image = try await APIService.shared.getImage(imageId: dish.image_id)
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

struct NutritionBadge: View {
    let label: String
    let value: String
    
    var body: some View {
        VStack(spacing: 5) {
            Text(value)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(Color(red: 0.2, green: 0.6, blue: 0.3))
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(.gray)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(Color(red: 0.2, green: 0.6, blue: 0.3).opacity(0.1))
        .cornerRadius(8)
    }
}
