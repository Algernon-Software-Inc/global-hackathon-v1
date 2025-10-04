//
//  CookingExperienceView.swift
//  Cooking AI
//

import SwiftUI

struct CookingExperienceView: View {
    @ObservedObject var preferencesManager = PreferencesManager.shared
    @Binding var currentPage: Int
    
    var body: some View {
        VStack(spacing: 30) {
            // Header
            VStack(spacing: 10) {
                Text("Cooking Experience")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(Color(red: 0.2, green: 0.6, blue: 0.3))
                
                Text("Select your level")
                    .font(.system(size: 16))
                    .foregroundColor(.gray)
            }
            .padding(.top, 60)
            
            // Options
            VStack(spacing: 15) {
                ForEach(CookingExperience.allCases, id: \.self) { experience in
                    SelectionButton(
                        title: experience.rawValue,
                        isSelected: preferencesManager.preferences.experience == experience.rawValue
                    ) {
                        handleSelectExperience(experience.rawValue)
                    }
                }
            }
            .padding(.horizontal, 20)
            
            Spacer()
            
            // Progress indicator
            ProgressIndicator(currentPage: 1, totalPages: 5)
            
            // Navigation buttons
            HStack(spacing: 15) {
                Button(action: handleBack) {
                    Text("Back")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(Color(red: 0.2, green: 0.6, blue: 0.3))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(red: 0.2, green: 0.6, blue: 0.3), lineWidth: 2)
                        )
                }
                
                Button(action: handleNext) {
                    Text("Next")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(red: 0.2, green: 0.6, blue: 0.3))
                        .cornerRadius(12)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 30)
        }
        .background(Color.white.ignoresSafeArea())
    }
    
    private func handleSelectExperience(_ experience: String) {
        preferencesManager.preferences.experience = experience
        preferencesManager.savePreferences()
    }
    
    private func handleBack() {
        currentPage = 0
    }
    
    private func handleNext() {
        currentPage = 2
    }
}
