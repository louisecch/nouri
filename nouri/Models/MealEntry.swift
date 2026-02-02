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
    
    init(id: UUID = UUID(), mealType: MealType, date: Date = Date(), imageFileName: String? = nil) {
        self.id = id
        self.mealType = mealType
        self.date = date
        self.imageFileName = imageFileName
    }
}

