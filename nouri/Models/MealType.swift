//
//  MealType.swift
//  nouri
//
//  Created by Chan Ching Hei on 17/12/2025.
//

import Foundation

enum MealType: String, CaseIterable, Codable {
    case breakfast = "Breakfast"
    case snackAM = "Snack (AM)"
    case lunch = "Lunch"
    case snackPM = "Snack (PM)"
    case dinner = "Dinner"
    case snackEvening = "Snack (Evening)"
    
    var displayName: String {
        self.rawValue
    }
    
    var sortOrder: Int {
        switch self {
        case .breakfast: return 0
        case .snackAM: return 1
        case .lunch: return 2
        case .snackPM: return 3
        case .dinner: return 4
        case .snackEvening: return 5
        }
    }
}


