//
//  MealEntry.swift
//  nouri
//
//  Created by Chan Ching Hei on 17/12/2025.
//

import Foundation

struct MealEntry: Identifiable, Codable {
    let id: UUID
    let mealType: MealType
    let date: Date
    let imageFileName: String?
    let foodName: String?
    let healthScore: Int?  // -100 to +100
    let recognitionConfidence: Float?
    
    init(id: UUID = UUID(), 
         mealType: MealType, 
         date: Date = Date(), 
         imageFileName: String? = nil,
         foodName: String? = nil,
         healthScore: Int? = nil,
         recognitionConfidence: Float? = nil) {
        self.id = id
        self.mealType = mealType
        self.date = date
        self.imageFileName = imageFileName
        self.foodName = foodName
        self.healthScore = healthScore
        self.recognitionConfidence = recognitionConfidence
    }
    
    var healthScoreColor: String {
        guard let score = healthScore else { return "gray" }
        
        if score >= 70 {
            return "green"  // Very healthy
        } else if score >= 40 {
            return "blue"   // Moderately healthy
        } else if score >= 0 {
            return "yellow" // Neutral
        } else if score >= -40 {
            return "orange" // Less healthy
        } else {
            return "red"    // Unhealthy
        }
    }
    
    var healthScoreEmoji: String {
        guard let score = healthScore else { return "❓" }
        
        if score >= 70 {
            return "🌟"  // Excellent
        } else if score >= 40 {
            return "✅"  // Good
        } else if score >= 0 {
            return "⚖️"  // Neutral
        } else if score >= -40 {
            return "⚠️"  // Caution
        } else {
            return "❌"  // Avoid
        }
    }
}

