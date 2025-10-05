//
//  SplashScreenView.swift
//  Cooking AI
//

import SwiftUI

struct SplashScreenView: View {
    @State private var isAnimating = false
    @State private var scale: CGFloat = 0.7
    @State private var opacity: Double = 0.0
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.theme.primary.opacity(0.1),
                    Color.theme.background
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // App Icon
                Image("AppIconImage")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 120, height: 120)
                    .cornerRadius(26)
                    .shadow(color: Color.theme.shadowMedium, radius: 20, x: 0, y: 10)
                    .scaleEffect(scale)
                    .opacity(opacity)
                
                // App Name
                Text("Cooking AI")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(Color.theme.primary)
                    .opacity(opacity)
                
                // Loading indicator
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: Color.theme.primary))
                    .scaleEffect(1.2)
                    .opacity(opacity)
                    .padding(.top, 20)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                scale = 1.0
                opacity = 1.0
            }
            
            // Add subtle bounce animation
            withAnimation(
                .easeInOut(duration: 1.0)
                .repeatForever(autoreverses: true)
                .delay(0.8)
            ) {
                isAnimating = true
            }
        }
    }
}

#Preview {
    SplashScreenView()
}
