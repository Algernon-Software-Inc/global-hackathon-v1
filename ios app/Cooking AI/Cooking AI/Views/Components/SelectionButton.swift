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
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(isSelected ? Color.white.opacity(0.2) : Color(red: 0.2, green: 0.6, blue: 0.3).opacity(0.12))
                        .frame(width: 28, height: 28)
                    Image(systemName: isSelected ? "checkmark" : "plus")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(isSelected ? .white : Color(red: 0.2, green: 0.6, blue: 0.3))
                }
                
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(isSelected ? .white : .black)
                
                Spacer()
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity)
            .background(
                isSelected
                ? Color(red: 0.2, green: 0.6, blue: 0.3)
                : Color.white
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color(red: 0.2, green: 0.6, blue: 0.3).opacity(0.6), lineWidth: isSelected ? 0 : 1.5)
            )
            .cornerRadius(14)
            .shadow(color: isSelected ? Color(red: 0.2, green: 0.6, blue: 0.3).opacity(0.25) : Color.clear, radius: 10, x: 0, y: 6)
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
