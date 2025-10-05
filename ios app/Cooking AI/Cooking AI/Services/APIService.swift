//
//  APIService.swift
//  Cooking AI
//

import Foundation
import UIKit

class APIService {
    static let shared = APIService()
    
    // Update this with your actual API base URL
    private let baseURL = "http://65.21.9.14:1212"
    
    private init() {}
    
    func getDishes(image: UIImage, preferences: UserPreferences) async throws -> [Dish] {
        // Try multiple encodings to match backend expectations
        // 1) multipart: image + preferences (application/json)
        // 2) multipart: image + preferences (text/plain JSON string)
        // 3) multipart: image + data (application/json)
        // 4) pure JSON: { image_base64, preferences }
        enum Attempt: String { case mpImagePrefsJson = "multipart:image+preferences(json)", mpImagePrefsText = "multipart:image+preferences(text)", mpImageDataJson = "multipart:image+data(json)", jsonBase64 = "json:base64+preferences" }
        let attempts: [(Attempt, RequestBuilder)] = [
            (.mpImagePrefsJson, buildMultipart(imageField: "image", prefsField: "preferences", prefsAsTextPlain: false)),
            (.mpImagePrefsText, buildMultipart(imageField: "image", prefsField: "preferences", prefsAsTextPlain: true)),
            (.mpImageDataJson, buildMultipart(imageField: "image", prefsField: "data", prefsAsTextPlain: false)),
            (.jsonBase64, buildJSONBase64())
        ]
        var lastError: Error = APIError.invalidResponse
        for (label, makeRequest) in attempts {
            do {
                #if DEBUG
                print("[API] ▶️ Sending request: variant=\(label.rawValue) url=\(baseURL)/api/get-dishes/ at=\(Date())")
                #endif
                let (data, response) = try await makeRequest(image, preferences)
                guard let httpResponse = response as? HTTPURLResponse else {
                    lastError = APIError.invalidResponse
                    continue
                }
                guard (200...299).contains(httpResponse.statusCode) else {
                    #if DEBUG
                    let s = String(data: data, encoding: .utf8) ?? "<non-utf8>"
                    print("[API] ❌ HTTP error variant=\(label.rawValue) status=\(httpResponse.statusCode) bytes=\(data.count) body=\(s)")
                    #endif
                    lastError = APIError.server(status: httpResponse.statusCode, body: String((String(data: data, encoding: .utf8) ?? "").prefix(500)))
                    continue
                }
                do {
                    let dishes = try decodeDishes(data)
                    #if DEBUG
                    let raw = String(data: data, encoding: .utf8) ?? "<non-utf8>"
                    print("[API] ✅ Success variant=\(label.rawValue) status=\(httpResponse.statusCode) bytes=\(data.count) count=\(dishes.count) at=\(Date()) raw=\(raw)")
                    #endif
                    return dishes
                } catch {
                    #if DEBUG
                    let s = String(data: data, encoding: .utf8) ?? "<non-utf8>"
                    print("[API] ⚠️ Decode failed variant=\(label.rawValue) error=\(error) bytes=\(data.count) body=\(s)")
                    #endif
                    lastError = APIError.decodingError
                    continue
                }
            } catch {
                #if DEBUG
                print("[API] 🛑 Network error variant=\(label.rawValue) error=\(error)")
                #endif
                lastError = APIError.network(error)
                continue
            }
        }
        throw lastError
    }

    // MARK: - Builders
    private typealias RequestBuilder = (_ image: UIImage, _ prefs: UserPreferences) async throws -> (Data, URLResponse)

    private func buildMultipart(imageField: String, prefsField: String, prefsAsTextPlain: Bool) -> RequestBuilder {
        return { image, prefs in
            guard let url = URL(string: "\(self.baseURL)/api/get-dishes/") else { throw APIError.invalidURL }
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.timeoutInterval = 60
            request.setValue("application/json", forHTTPHeaderField: "Accept")

            let boundary = UUID().uuidString
            request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

            var body = Data()
            // image part
            if let imageData = image.jpegData(compressionQuality: 0.7) {
                body.append("--\(boundary)\r\n".data(using: .utf8)!)
                body.append("Content-Disposition: form-data; name=\"\(imageField)\"; filename=\"photo.jpg\"\r\n".data(using: .utf8)!)
                body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
                body.append(imageData)
                body.append("\r\n".data(using: .utf8)!)
            }
            // preferences part
            let prefsObject = prefs.toAPIFormat()
            let prefsData = try JSONSerialization.data(withJSONObject: prefsObject, options: [])
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(prefsField)\"\r\n".data(using: .utf8)!)
            if prefsAsTextPlain {
                body.append("Content-Type: text/plain; charset=utf-8\r\n\r\n".data(using: .utf8)!)
                if let s = String(data: prefsData, encoding: .utf8)?.data(using: .utf8) {
                    body.append(s)
                }
            } else {
                body.append("Content-Type: application/json\r\n\r\n".data(using: .utf8)!)
                body.append(prefsData)
            }
            body.append("\r\n".data(using: .utf8)!)
            body.append("--\(boundary)--\r\n".data(using: .utf8)!)

            request.httpBody = body
            return try await URLSession.shared.data(for: request)
        }
    }

    private func buildJSONBase64() -> RequestBuilder {
        return { image, prefs in
            guard let url = URL(string: "\(self.baseURL)/api/get-dishes/") else { throw APIError.invalidURL }
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            request.timeoutInterval = 60

            let imageData = image.jpegData(compressionQuality: 0.7) ?? Data()
            let base64 = imageData.base64EncodedString()
            let payload: [String: Any] = [
                "image_base64": base64,
                "preferences": prefs.toAPIFormat()
            ]
            request.httpBody = try JSONSerialization.data(withJSONObject: payload, options: [])
            return try await URLSession.shared.data(for: request)
        }
    }

    // MARK: - Decoding helpers
    private func decodeDishes(_ data: Data) throws -> [Dish] {
        let decoder = JSONDecoder()
        // 1) direct array
        if let arr = try? decoder.decode([Dish].self, from: data) { return arr }
        // 2) { dishes: [...] }
        struct DishesWrap: Decodable { let dishes: [Dish]? }
        if let wrap = try? decoder.decode(DishesWrap.self, from: data), let arr = wrap.dishes { return arr }
        // 3) common wrappers { status: ok, dishes: [...] }
        struct CommonWrap: Decodable { let status: String?; let dishes: [Dish]?; let data: [Dish]?; let results: [Dish]? }
        if let cw = try? decoder.decode(CommonWrap.self, from: data) {
            if let arr = cw.dishes { return arr }
            if let arr = cw.data { return arr }
            if let arr = cw.results { return arr }
        }
        throw APIError.decodingError
    }
    
    func getImage(imageId: String) async throws -> UIImage {
        // Django often requires trailing slash; add it here
        guard let url = URL(string: "\(baseURL)/api/images/\(imageId).png") else {
            throw APIError.invalidURL
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        // Some servers reject specific Accept values. Prefer */* or omit entirely.
        request.setValue("*/*", forHTTPHeaderField: "Accept")

        var (data, response) = try await URLSession.shared.data(for: request)
        if let http = response as? HTTPURLResponse, http.statusCode == 406 {
            // Retry once without Accept header
            request.setValue(nil, forHTTPHeaderField: "Accept")
            (data, response) = try await URLSession.shared.data(for: request)
        }

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            #if DEBUG
            let s = String(data: data, encoding: .utf8) ?? "<non-utf8> or binary>"
            print("[API] ❌ Image fetch failed id=\(imageId) status=\((response as? HTTPURLResponse)?.statusCode ?? -1) body=\(s)")
            #endif
            throw APIError.invalidResponse
        }

        #if DEBUG
        if let http = response as? HTTPURLResponse {
            let ctype = http.allHeaderFields["Content-Type"] as? String ?? http.allHeaderFields["content-type"] as? String ?? "?"
            print("[API] 📷 Image content-type=\(ctype) size=\(data.count)")
        }
        #endif

        guard let image = UIImage(data: data) else {
            #if DEBUG
            print("[API] ⚠️ Image bytes could not be decoded id=\(imageId) size=\(data.count)")
            #endif
            throw APIError.decodingError
        }

        return image
    }
}

enum APIError: Error {
    case invalidURL
    case invalidResponse
    case decodingError
    case server(status: Int, body: String)
    case network(Error)
}
