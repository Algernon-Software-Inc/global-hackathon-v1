//
//  MainView.swift
//  Cooking AI
//

import SwiftUI

struct MainView: View {
    @State private var selectedImage: UIImage?
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
                colors: [Color.white, Color.white]
            , startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 24) {
                    // Branding
                    VStack(spacing: 6) {
                        Text("Cooking AI")
                            .font(.system(size: 34, weight: .bold))
                            .foregroundColor(Color(red: 0.2, green: 0.6, blue: 0.3))
                        Text("Point. Shoot. Cook.")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(.gray)
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

                    // Results
                    if !dishes.isEmpty {
                        VStack(spacing: 16) {
                            ForEach(dishes) { dish in
                                DishCardView(dish: dish)
                                    .padding(.horizontal, 20)
                            }
                            .padding(.bottom, 100)
                        }
                    } else {
                        VStack(spacing: 14) {
                            Image(systemName: "leaf.circle")
                                .font(.system(size: 50, weight: .regular))
                                .foregroundColor(Color(red: 0.2, green: 0.6, blue: 0.3).opacity(0.9))
                            Text("Snap your ingredients to get recipes")
                                .font(.system(size: 16))
                                .foregroundColor(.gray)
                        }
                        .padding(.top, 30)
                    }
                }
                .padding(.bottom, 150)
            }

            // Single primary capture button (centered)
            Button(action: handleOpenSourceSheet) {
                ZStack {
                    Circle()
                        .fill(Color(red: 0.2, green: 0.6, blue: 0.3))
                        .frame(width: 96, height: 96)
                        .shadow(color: Color.black.opacity(0.15), radius: 12, x: 0, y: 8)
                    Image(systemName: "camera.fill")
                        .font(.system(size: 32, weight: .semibold))
                        .foregroundColor(.white)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.bottom, safeBottomInset() + 96)
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
        .overlay(alignment: .center) {
            if isLoading {
                ZStack {
                    Color.black.opacity(0.35).ignoresSafeArea()
                    
                    VStack(spacing: 14) {
                        if let preview = selectedImage {
                            Image(uiImage: preview)
                                .resizable()
                                .scaledToFill()
                                .frame(maxWidth: .infinity)
                                .frame(height: 220)
                                .clipped()
                                .cornerRadius(14)
                                .accessibilityLabel("Selected ingredients image")
                        }
                        
                        LoadingSpinnerView()
                        Text("Analyzing ingredients…")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primary)
                        Text("This may take a few seconds")
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: 340)
                    .padding(18)
                    .background(.ultraThinMaterial)
                    .cornerRadius(18)
                    .shadow(color: Color.black.opacity(0.25), radius: 18, x: 0, y: 10)
                }
                .transition(.opacity)
            }
        }
    }
    
    private func handleOpenSourceSheet() {
        showSourceSheet = true
    }

    private func handleTakePhoto() {
        showCamera = true
    }
    
    private func handleUploadPhoto() {
        showImagePicker = true
    }
    
    private func handleGetRecipes() {
        guard let image = selectedImage else { return }
        
        isLoading = true
        
        Task {
            do {
                let fetchedDishes = try await APIService.shared.getDishes(
                    image: image,
                    preferences: preferencesManager.preferences
                )
                
                await MainActor.run {
                    // Deduplicate by name and show top 1 dish
                    let unique = Array(Dictionary(grouping: fetchedDishes, by: { $0.name }).values.compactMap { $0.first })
                    dishes = unique.prefix(1).map { $0 }
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
