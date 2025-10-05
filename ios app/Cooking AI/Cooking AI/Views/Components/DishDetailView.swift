//
//  DishDetailView.swift
//  Cooking AI
//

import SwiftUI

struct DishDetailView: View {
    let dish: Dish
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            // Background
            Color.theme.background.ignoresSafeArea()
            
            // Content
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    HStack {
                        Text("Recipe Details")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(Color.theme.primary)
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    
                    // Full dish card
                    DishCardView(dish: dish)
                        .padding(.horizontal, 20)
                }
                .padding(.bottom, 40)
            }
            
            // Close button
            Button(action: { dismiss() }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 32))
                    .foregroundColor(Color.theme.textSecondary)
                    .background(
                        Circle()
                            .fill(Color.theme.background)
                            .frame(width: 36, height: 36)
                    )
            }
            .padding(.top, 16)
            .padding(.trailing, 20)
        }
    }
}
