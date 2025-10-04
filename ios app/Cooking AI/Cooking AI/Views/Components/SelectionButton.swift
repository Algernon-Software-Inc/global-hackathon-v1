//
//  SelectionButton.swift
//  Cooking AI
//

import SwiftUI

struct SelectionButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(isSelected ? .white : Color(red: 0.2, green: 0.6, blue: 0.3))
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundColor(.white)
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(isSelected ? Color(red: 0.2, green: 0.6, blue: 0.3) : Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(red: 0.2, green: 0.6, blue: 0.3), lineWidth: 2)
            )
            .cornerRadius(12)
        }
    }
}

struct ProgressIndicator: View {
    let currentPage: Int
    let totalPages: Int
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<totalPages, id: \.self) { index in
                Circle()
                    .fill(index <= currentPage ? Color(red: 0.2, green: 0.6, blue: 0.3) : Color.gray.opacity(0.3))
                    .frame(width: 8, height: 8)
            }
        }
        .padding(.vertical, 10)
    }
}
