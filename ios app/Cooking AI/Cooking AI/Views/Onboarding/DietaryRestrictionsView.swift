//
//  DietaryRestrictionsView.swift
//  Cooking AI
//

import SwiftUI

struct DietaryRestrictionsView: View {
    @ObservedObject var preferencesManager = PreferencesManager.shared
    @Binding var currentPage: Int
    
    var body: some View {
        VStack(spacing: 30) {
            // Header
            VStack(spacing: 10) {
                Text("Dietary Restrictions")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(Color(red: 0.2, green: 0.6, blue: 0.3))
                
                Text("Select all that apply")
                    .font(.system(size: 16))
                    .foregroundColor(.gray)
            }
            .padding(.top, 60)
            
            // Options
            ScrollView {
                VStack(spacing: 15) {
                    ForEach(DietaryRestriction.allCases, id: \.self) { diet in
                        SelectionButton(
                            title: diet.rawValue,
                            isSelected: preferencesManager.preferences.diets.contains(diet.rawValue)
                        ) {
                            handleToggleDiet(diet.rawValue)
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
            
            Spacer()
            
            // Progress indicator
            ProgressIndicator(currentPage: 0, totalPages: 5)
            
            // Next button
            Button(action: handleNext) {
                Text("Next")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(red: 0.2, green: 0.6, blue: 0.3))
                    .cornerRadius(12)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 30)
        }
        .background(Color.white.ignoresSafeArea())
    }
    
    private func handleToggleDiet(_ diet: String) {
        if let index = preferencesManager.preferences.diets.firstIndex(of: diet) {
            preferencesManager.preferences.diets.remove(at: index)
        } else {
            preferencesManager.preferences.diets.append(diet)
        }
        preferencesManager.savePreferences()
    }
    
    private func handleNext() {
        currentPage = 1
    }
}
