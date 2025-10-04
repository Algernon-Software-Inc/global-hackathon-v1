//
//  FavouritesView.swift
//  Cooking AI
//

import SwiftUI

struct FavouritesView: View {
    @ObservedObject var favouritesManager = FavouritesManager.shared
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            if favouritesManager.favourites.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "heart.slash")
                        .font(.system(size: 80))
                        .foregroundColor(Color.gray.opacity(0.5))
                    
                    Text("No Favourites Yet")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.gray)
                    
                    Text("Save your favorite recipes to see them here")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
            } else {
                ScrollView {
                    VStack(spacing: 20) {
                        // Header
                        Text("My Favourites")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(Color(red: 0.2, green: 0.6, blue: 0.3))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 20)
                            .padding(.top, 20)
                        
                        // Favourites list
                        ForEach(favouritesManager.favourites) { dish in
                            DishCardView(dish: dish)
                                .padding(.horizontal, 20)
                        }
                    }
                    .padding(.bottom, 100)
                }
            }
        }
    }
}
