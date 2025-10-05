//
//  OnboardingCompleteView.swift
//  Cooking AI
//

import SwiftUI

struct OnboardingCompleteView: View {
    @ObservedObject var preferencesManager = PreferencesManager.shared
    @Binding var currentPage: Int
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // Success icon
            ZStack {
                Circle()
                    .fill(Color(red: 0.2, green: 0.6, blue: 0.3).opacity(0.1))
                    .frame(width: 120, height: 120)
                
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(Color(red: 0.2, green: 0.6, blue: 0.3))
            }
            
            // Header
            VStack(spacing: 10) {
                Text("All Set!")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(Color(red: 0.2, green: 0.6, blue: 0.3))
                
                Text("Your preferences have been saved")
                    .font(.system(size: 16))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
            
            // Progress indicator
            ProgressIndicator(currentPage: 4, totalPages: 5)
            
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
                
                Button(action: handleComplete) {
                    Text("Get Started")
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
    
    private func handleBack() {
        currentPage = 3
    }
    
    private func handleComplete() {
        preferencesManager.completeOnboarding()
    }
}

