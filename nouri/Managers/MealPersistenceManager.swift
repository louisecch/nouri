//
//  MealPersistenceManager.swift
//  nouri
//
//  Created by Chan Ching Hei on 17/12/2025.
//

import Foundation

class MealPersistenceManager: ObservableObject {
    static let shared = MealPersistenceManager()
    
    @Published var meals: [MealEntry] = []
    
    private let mealsFileName = "meals.json"
    private let imagesDirectory = "MealImages"
    
    private var documentsDirectory: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    private var mealsFileURL: URL {
        documentsDirectory.appendingPathComponent(mealsFileName)
    }
    
    private var imagesDirectoryURL: URL {
        documentsDirectory.appendingPathComponent(imagesDirectory)
    }
    
    init() {
        createImagesDirectoryIfNeeded()
        loadMeals()
    }
    
    // MARK: - Directory Management
    
    private func createImagesDirectoryIfNeeded() {
        if !FileManager.default.fileExists(atPath: imagesDirectoryURL.path) {
            try? FileManager.default.createDirectory(at: imagesDirectoryURL, withIntermediateDirectories: true)
        }
    }
    
    // MARK: - Load & Save Meals
    
    func loadMeals() {
        guard FileManager.default.fileExists(atPath: mealsFileURL.path) else {
            meals = []
            return
        }
        
        do {
            let data = try Data(contentsOf: mealsFileURL)
            meals = try JSONDecoder().decode([MealEntry].self, from: data)
        } catch {
            print("Error loading meals: \(error)")
            meals = []
        }
    }
    
    private func saveMeals() {
        do {
            let data = try JSONEncoder().encode(meals)
            try data.write(to: mealsFileURL)
            objectWillChange.send()
        } catch {
            print("Error saving meals: \(error)")
        }
    }
    
    // MARK: - Meal Operations
    
    func addMeal(mealType: MealType, date: Date, image: PlatformImage) {
        let imageFileName = "\(UUID().uuidString).jpg"
        
        // Save image
        if saveImage(image, fileName: imageFileName) {
            let newMeal = MealEntry(mealType: mealType, date: date, imageFileName: imageFileName)
            meals.append(newMeal)
            saveMeals()
            print("✅ Added meal: \(mealType.displayName) with image: \(imageFileName)")
        } else {
            print("❌ Failed to save image for meal: \(mealType.displayName)")
        }
    }
    
    func updateMeal(_ meal: MealEntry, with image: PlatformImage) {
        // Delete old image if exists
        if let oldImageFileName = meal.imageFileName {
            deleteImage(fileName: oldImageFileName)
        }
        
        // Save new image
        let imageFileName = "\(UUID().uuidString).jpg"
        if saveImage(image, fileName: imageFileName) {
            // Remove old meal
            meals.removeAll { $0.id == meal.id }
            
            // Add updated meal
            let updatedMeal = MealEntry(id: meal.id, mealType: meal.mealType, date: meal.date, imageFileName: imageFileName)
            meals.append(updatedMeal)
            saveMeals()
            print("✅ Updated meal: \(meal.mealType.displayName) with new image: \(imageFileName)")
        } else {
            print("❌ Failed to save new image for meal: \(meal.mealType.displayName)")
        }
    }
    
    func deleteMeal(_ meal: MealEntry) {
        if let imageFileName = meal.imageFileName {
            deleteImage(fileName: imageFileName)
        }
        meals.removeAll { $0.id == meal.id }
        saveMeals()
    }
    
    func getMeal(for mealType: MealType, on date: Date) -> MealEntry? {
        let calendar = Calendar.current
        return meals.first { meal in
            meal.mealType == mealType &&
            calendar.isDate(meal.date, inSameDayAs: date)
        }
    }
    
    // MARK: - Image Operations
    
    private func saveImage(_ image: PlatformImage, fileName: String) -> Bool {
        print("📸 Attempting to save image: \(fileName)")
        print("   Image size: \(image.size)")
        
        guard let data = image.jpegData(compressionQuality: 0.8) else {
            print("❌ Failed to convert image to JPEG data")
            return false
        }
        
        print("   JPEG data size: \(data.count) bytes")
        
        let fileURL = imagesDirectoryURL.appendingPathComponent(fileName)
        print("   Saving to: \(fileURL.path)")
        
        do {
            try data.write(to: fileURL)
            print("✅ Successfully saved image to disk")
            return true
        } catch {
            print("❌ Error writing image to disk: \(error)")
            return false
        }
    }
    
    func loadImage(fileName: String) -> PlatformImage? {
        let fileURL = imagesDirectoryURL.appendingPathComponent(fileName)
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            print("⚠️ Image file not found: \(fileName)")
            return nil
        }
        
        #if canImport(UIKit)
        guard let data = try? Data(contentsOf: fileURL) else {
            print("❌ Failed to load image data: \(fileName)")
            return nil
        }
        guard let image = PlatformImage(data: data) else {
            print("❌ Failed to create UIImage from data: \(fileName)")
            return nil
        }
        print("✅ Loaded image: \(fileName)")
        return image
        #elseif canImport(AppKit)
        guard let image = PlatformImage(contentsOf: fileURL) else {
            print("❌ Failed to load NSImage: \(fileName)")
            return nil
        }
        print("✅ Loaded image: \(fileName)")
        return image
        #endif
    }
    
    private func deleteImage(fileName: String) {
        let fileURL = imagesDirectoryURL.appendingPathComponent(fileName)
        try? FileManager.default.removeItem(at: fileURL)
    }
}

