//
//  OnboardingContainerView.swift
//  Cooking AI
//

import SwiftUI

struct OnboardingContainerView: View {
    @State private var currentPage = 0
    
    var body: some View {
        ZStack {
            switch currentPage {
            case 0:
                DietaryRestrictionsView(currentPage: $currentPage)
            case 1:
                CookingExperienceView(currentPage: $currentPage)
            case 2:
                FavoriteCuisinesView(currentPage: $currentPage)
            case 3:
                MealPrepTimeView(currentPage: $currentPage)
            case 4:
                OnboardingCompleteView(currentPage: $currentPage)
            default:
                DietaryRestrictionsView(currentPage: $currentPage)
            }
        }
        .animation(.easeInOut, value: currentPage)
    }
}

