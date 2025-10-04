//
//  MealPrepTimeView.swift
//  Cooking AI
//

import SwiftUI

struct MealPrepTimeView: View {
    @ObservedObject var preferencesManager = PreferencesManager.shared
    @Binding var currentPage: Int
    
    var body: some View {
        VStack(spacing: 30) {
            // Header
            VStack(spacing: 10) {
                Text("Meal Prep Time")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(Color(red: 0.2, green: 0.6, blue: 0.3))
                
                Text("Select all that apply")
                    .font(.system(size: 16))
                    .foregroundColor(.gray)
            }
            .padding(.top, 60)
            
            // Options
            VStack(spacing: 15) {
                ForEach(MealPrepTime.allCases, id: \.self) { time in
                    SelectionButton(
                        title: time.rawValue,
                        isSelected: preferencesManager.preferences.time.contains(time.rawValue)
                    ) {
                        handleToggleTime(time.rawValue)
                    }
                }
            }
            .padding(.horizontal, 20)
            
            Spacer()
            
            // Progress indicator
            ProgressIndicator(currentPage: 3, totalPages: 5)
            
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
    
    private func handleToggleTime(_ time: String) {
        if let index = preferencesManager.preferences.time.firstIndex(of: time) {
            preferencesManager.preferences.time.remove(at: index)
        } else {
            preferencesManager.preferences.time.append(time)
        }
        preferencesManager.savePreferences()
    }
    
    private func handleBack() {
        currentPage = 2
    }
    
    private func handleNext() {
        currentPage = 4
    }
}
