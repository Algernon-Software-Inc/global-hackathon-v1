//
//  ColorTheme.swift
//  Cooking AI
//

import SwiftUI

extension Color {
    static let theme = ColorTheme()
}

struct ColorTheme {
    // Primary brand color
    let primary = Color(red: 0.2, green: 0.6, blue: 0.3)
    let primaryLight = Color(red: 0.2, green: 0.6, blue: 0.3).opacity(0.1)
    let primaryDark = Color(red: 0.15, green: 0.5, blue: 0.25)
    
    // Neutral colors
    let textPrimary = Color.black
    let textSecondary = Color.gray
    let textTertiary = Color.gray.opacity(0.6)
    
    // Background colors
    let background = Color.white
    let backgroundSecondary = Color.gray.opacity(0.05)
    let cardBackground = Color.white
    
    // Accent colors
    let error = Color.red
    let success = Color.green
    let warning = Color.orange
    let favorite = Color.red
    
    // Shadow
    let shadowLight = Color.black.opacity(0.05)
    let shadowMedium = Color.black.opacity(0.1)
    let shadowDark = Color.black.opacity(0.25)
}
