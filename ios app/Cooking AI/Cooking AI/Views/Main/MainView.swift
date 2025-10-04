//
//  MainView.swift
//  Cooking AI
//

import SwiftUI

struct MainView: View {
    @State private var selectedImage: UIImage?
    @State private var showImagePicker = false
    @State private var showCamera = false
    @State private var dishes: [Dish] = []
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    @ObservedObject var preferencesManager = PreferencesManager.shared
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    VStack(spacing: 10) {
                        Text("Cooking AI")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(Color(red: 0.2, green: 0.6, blue: 0.3))
                        
                        Text("Take a photo of your ingredients")
                            .font(.system(size: 16))
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 20)
                    
                    // Camera buttons
                    HStack(spacing: 15) {
                        Button(action: handleTakePhoto) {
                            VStack(spacing: 10) {
                                Image(systemName: "camera.fill")
                                    .font(.system(size: 40))
                                Text("Take Photo")
                                    .font(.system(size: 14, weight: .medium))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 30)
                            .background(Color(red: 0.2, green: 0.6, blue: 0.3))
                            .cornerRadius(12)
                        }
                        
                        Button(action: handleUploadPhoto) {
                            VStack(spacing: 10) {
                                Image(systemName: "photo.fill")
                                    .font(.system(size: 40))
                                Text("Upload Photo")
                                    .font(.system(size: 14, weight: .medium))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 30)
                            .background(Color(red: 0.2, green: 0.6, blue: 0.3))
                            .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // Selected image preview
                    if let image = selectedImage {
                        VStack(spacing: 15) {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 200)
                                .cornerRadius(12)
                            
                            Button(action: handleGetRecipes) {
                                Text("Get Recipe Suggestions")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color(red: 0.2, green: 0.6, blue: 0.3))
                                    .cornerRadius(12)
                            }
                            .disabled(isLoading)
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    // Loading indicator
                    if isLoading {
                        ProgressView()
                            .scaleEffect(1.5)
                            .padding()
                    }
                    
                    // Dishes list
                    if !dishes.isEmpty {
                        VStack(spacing: 20) {
                            Text("Suggested Recipes")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(Color(red: 0.2, green: 0.6, blue: 0.3))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 20)
                            
                            ForEach(dishes) { dish in
                                DishCardView(dish: dish)
                                    .padding(.horizontal, 20)
                            }
                        }
                    }
                }
                .padding(.bottom, 100)
            }
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(image: $selectedImage, sourceType: .photoLibrary)
        }
        .sheet(isPresented: $showCamera) {
            ImagePicker(image: $selectedImage, sourceType: .camera)
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
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
        
        isLoading = true
        
        Task {
            do {
                let fetchedDishes = try await APIService.shared.getDishes(
                    image: image,
                    preferences: preferencesManager.preferences
                )
                
                await MainActor.run {
                    dishes = fetchedDishes
                    isLoading = false
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
