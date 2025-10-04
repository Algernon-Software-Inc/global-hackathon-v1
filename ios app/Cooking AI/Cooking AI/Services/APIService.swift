//
//  APIService.swift
//  Cooking AI
//

import Foundation
import UIKit

class APIService {
    static let shared = APIService()
    
    // Update this with your actual API base URL
    private let baseURL = "YOUR_API_BASE_URL"
    
    private init() {}
    
    func getDishes(image: UIImage, preferences: UserPreferences) async throws -> [Dish] {
        guard let url = URL(string: "\(baseURL)/api/get-dishes") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // Create multipart form data
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        
        // Add image
        if let imageData = image.jpegData(compressionQuality: 0.8) {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"image\"; filename=\"photo.jpg\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
            body.append(imageData)
            body.append("\r\n".data(using: .utf8)!)
        }
        
        // Add preferences as JSON
        let preferencesJSON = preferences.toAPIFormat()
        if let jsonData = try? JSONSerialization.data(withJSONObject: preferencesJSON) {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"preferences\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: application/json\r\n\r\n".data(using: .utf8)!)
            body.append(jsonData)
            body.append("\r\n".data(using: .utf8)!)
        }
        
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw APIError.invalidResponse
        }
        
        let dishes = try JSONDecoder().decode([Dish].self, from: data)
        return dishes
    }
    
    func getImage(imageId: String) async throws -> UIImage {
        guard let url = URL(string: "\(baseURL)/api/images/\(imageId)") else {
            throw APIError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200,
              let image = UIImage(data: data) else {
            throw APIError.invalidResponse
        }
        
        return image
    }
}

enum APIError: Error {
    case invalidURL
    case invalidResponse
    case decodingError
}
