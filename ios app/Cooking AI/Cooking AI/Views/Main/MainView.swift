//
//  MainView.swift
//  Cooking AI
//

import SwiftUI

struct MainView: View {
    @State private var selectedImage: UIImage?
    @State private var lastUsedImage: UIImage?
    @State private var showImagePicker = false
    @State private var showCamera = false
    @State private var showSourceSheet = false
    @State private var dishes: [Dish] = []
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    @ObservedObject var preferencesManager = PreferencesManager.shared
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Background
            LinearGradient(
                colors: [Color.theme.background, Color.theme.background]
            , startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 24) {
                    // Branding
                    VStack(spacing: 6) {
                        Text("Cooking AI")
                            .font(.system(size: 34, weight: .bold))
                            .foregroundColor(Color.theme.primary)
                        Text("Point. Shoot. Cook.")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(Color.theme.textSecondary)
                    }
                    .padding(.top, 28)

                    // Preview of last selected image (optional)
                    if let image = selectedImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(height: 220)
                            .frame(maxWidth: .infinity)
                            .clipped()
                            .cornerRadius(16)
                            .padding(.horizontal, 20)
                    }

                    // Loading state
                    if isLoading {
                        VStack(spacing: 20) {
                            LoadingSpinnerView()
                            
                            VStack(spacing: 8) {
                                Text("Analyzing ingredients…")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(Color.theme.textPrimary)
                                Text("Finding the perfect recipes for you")
                                    .font(.system(size: 14))
                                    .foregroundColor(Color.theme.textSecondary)
                            }
                        }
                        .padding(.top, 60)
                        .padding(.horizontal, 40)
                    }
                    
                    // Results
                    if !dishes.isEmpty {
                        VStack(spacing: 16) {
                            ForEach(dishes) { dish in
                                DishCardView(dish: dish)
                                    .padding(.horizontal, 20)
                            }
                            .padding(.bottom, 50)
                        }
                    }
                    
                    // Empty state with guidance and integrated button
                    if !isLoading && dishes.isEmpty {
                        VStack(spacing: 32) {
                            Image(systemName: "camera.viewfinder")
                                .font(.system(size: 70, weight: .light))
                                .foregroundColor(Color.theme.primary.opacity(0.6))
                            
                            VStack(spacing: 8) {
                                Text("Ready to Cook?")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(Color.theme.textPrimary)
                                
                                Text("Capture your ingredients and\nwe'll suggest delicious recipes")
                                    .font(.system(size: 16))
                                    .foregroundColor(Color.theme.textSecondary)
                                    .multilineTextAlignment(.center)
                                    .lineSpacing(4)
                            }
                            
                            // Integrated capture button
                            Button(action: handleOpenSourceSheetWithHaptic) {
                                HStack(spacing: 12) {
                                    Image(systemName: "camera.fill")
                                        .font(.system(size: 20, weight: .semibold))
                                    Text("Capture Ingredients")
                                        .font(.system(size: 18, weight: .semibold))
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal, 32)
                                .padding(.vertical, 16)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color.theme.primary)
                                        .shadow(color: Color.theme.shadowMedium, radius: 8, x: 0, y: 4)
                                )
                            }
                            .accessibilityLabel("Capture ingredients")
                            .accessibilityHint("Double tap to take a photo or choose from library")
                        }
                        .padding(.top, 60)
                        .padding(.horizontal, 40)
                    }
                }
                .padding(.bottom, 150)
            }
        }
        .overlay(alignment: .bottom) {
            if !dishes.isEmpty {
                ZStack {
                    // Main capture button (centered)
                    Button(action: handleOpenSourceSheetWithHaptic) {
                        ZStack {
                            Circle()
                                .fill(Color.theme.primary)
                                .frame(width: 84, height: 84)
                                .shadow(color: Color.theme.shadowMedium, radius: 12, x: 0, y: 8)
                            Image(systemName: "camera.fill")
                                .font(.system(size: 26, weight: .semibold))
                                .foregroundColor(.white)
                        }
                    }
                    .accessibilityLabel("Capture ingredients")
                    .accessibilityHint("Double tap to take a photo or choose from library")
                    
                    // Regenerate button (positioned to the left of center)
                    HStack {
                        Button(action: handleRegenerateWithHaptic) {
                            ZStack {
                                Circle()
                                    .fill(Color.theme.cardBackground)
                                    .frame(width: 60, height: 60)
                                    .shadow(color: Color.theme.shadowMedium, radius: 8, x: 0, y: 4)
                                Circle()
                                    .stroke(Color.theme.primary, lineWidth: 2)
                                    .frame(width: 60, height: 60)
                                Image(systemName: "arrow.clockwise")
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundColor(Color.theme.primary)
                            }
                        }
                        .offset(x: 58)
                        .accessibilityLabel("Regenerate recipes")
                        .accessibilityHint("Double tap to regenerate recipes with the same ingredients")
                        Spacer()
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.bottom, safeBottomInset() + 88)
            }
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(image: $selectedImage, sourceType: .photoLibrary)
        }
        .sheet(isPresented: $showCamera) {
            ImagePicker(image: $selectedImage, sourceType: .camera)
        }
        .confirmationDialog("Select Source", isPresented: $showSourceSheet, titleVisibility: .visible) {
            Button("Take Photo") { handleTakePhoto() }
            Button("Choose from Library") { handleUploadPhoto() }
            Button("Cancel", role: .cancel) { }
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
        .onChange(of: selectedImage) { newImage in
            guard newImage != nil else { return }
            handleGetRecipes()
        }
    }
    
    private func handleOpenSourceSheet() {
        showSourceSheet = true
    }
    
    private func handleOpenSourceSheetWithHaptic() {
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
        showSourceSheet = true
    }
    
    private func handleRegenerateWithHaptic() {
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()
        
        // Regenerate recipes by resending the last API request
        guard let lastImage = lastUsedImage else {
            errorMessage = "No previous image to regenerate from"
            showError = true
            return
        }
        
        isLoading = true
        
        Task {
            do {
                let fetchedDishes = try await APIService.shared.getDishes(
                    image: lastImage,
                    preferences: preferencesManager.preferences
                )
                
                await MainActor.run {
                    dishes = fetchedDishes
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = "Failed to regenerate recipes. Please try again."
                    showError = true
                }
            }
        }
    }

    private func handleTakePhoto() {
        showCamera = true
    }
    
    private func handleUploadPhoto() {
        showImagePicker = true
    }
    
    private func handleGetRecipes() {
        guard let image = selectedImage else { return }
        
        // Store the image for regeneration
        lastUsedImage = image
        
        isLoading = true
        
        Task {
            do {
                let fetchedDishes = try await APIService.shared.getDishes(
                    image: image,
                    preferences: preferencesManager.preferences
                )
                
                await MainActor.run {
                    // Show all dishes returned by the API in original order
                    dishes = fetchedDishes
                    isLoading = false
                    // Remove preview image after successful fetch
                    selectedImage = nil
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = "Failed to fetch recipes. Please try again."
                    showError = true
                }
            }
        }
    }
}

private func safeBottomInset() -> CGFloat {
    guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
          let window = windowScene.windows.first else { return 0 }
    return window.safeAreaInsets.bottom
}

private struct LoadingSpinnerView: View {
    @State private var animate = false
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.white.opacity(0.15), lineWidth: 6)
                .frame(width: 42, height: 42)
            Circle()
                .trim(from: 0, to: 0.65)
                .stroke(Color(red: 0.2, green: 0.6, blue: 0.3), style: StrokeStyle(lineWidth: 6, lineCap: .round))
                .frame(width: 42, height: 42)
                .rotationEffect(.degrees(animate ? 360 : 0))
                .animation(.linear(duration: 0.8).repeatForever(autoreverses: false), value: animate)
        }
        .onAppear { animate = true }
        .accessibilityLabel("Loading")
    }
}
