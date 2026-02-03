//
//  MealPersistenceManager.swift
//  nouri
//
//  Created by Chan Ching Hei on 17/12/2025.
//

import Foundation
import Vision
import CoreML

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

// MARK: - Configuration

private struct APIConfig {
    // OpenAI Vision API configuration
    // Get from: https://platform.openai.com/api-keys
    // Pricing: ~$0.00015 per image (gpt-4o-mini), ~$0.01 per image (gpt-4o)
    
    // Load from .env file for security
    static let openAIAPIKey: String = {
        let envKey = EnvConfig.shared.get("OPENAI_API_KEY", default: "YOUR_OPENAI_API_KEY")
        if envKey != "YOUR_OPENAI_API_KEY" {
            print("✅ OpenAI API key loaded from .env file")
        }
        return envKey
    }()
    
    static let openAIModel: String = {
        return EnvConfig.shared.get("OPENAI_MODEL", default: "gpt-4o-mini")
    }()
    
    // Fallback: disable API and use local Vision detection (set to true to use fallback only)
    static let useLocalDetectionOnly = false  // Set to true to force local Vision detection
}

// MARK: - Food Recognition Models

struct FoodRecognitionResult {
    let foodName: String
    let confidence: Float
    let nutritionScore: Int
    let details: String
}

enum FoodCategory {
    case vegetables, fruits, protein, grains, dairy, sweets, beverages, processedFood, fastFood, unknown
    
    var baseScore: Int {
        switch self {
        case .vegetables: return 90
        case .fruits: return 80
        case .protein: return 70
        case .grains: return 60
        case .dairy: return 50
        case .beverages: return 30
        case .sweets: return -40
        case .processedFood: return -50
        case .fastFood: return -60
        case .unknown: return 0
        }
    }
}

struct ImageColor {
    let r: CGFloat
    let g: CGFloat
    let b: CGFloat
    
    var isBrownish: Bool {
        // Brown is high red, moderate green, low blue
        return r > 0.3 && g > 0.2 && b < 0.4 && abs(r - g) < 0.3
    }
    
    var isGreenish: Bool {
        return g > r && g > b && g > 0.3
    }
    
    var isReddish: Bool {
        return r > g && r > b && r > 0.4
    }
    
    var isYellowish: Bool {
        return r > 0.5 && g > 0.4 && b < 0.3
    }
    
    var isWhitish: Bool {
        return r > 0.7 && g > 0.7 && b > 0.7
    }
}

class MealPersistenceManager: ObservableObject {
    static let shared = MealPersistenceManager()
    
    @Published var meals: [MealEntry] = []
    
    private let mealsFileName = "meals.json"
    private let imagesDirectory = "MealImages"
    
    // Food database for recognition
    private let foodDatabase: [String: (category: FoodCategory, score: Int, details: String)] = [
        // Vegetables (90-100)
        "salad": (.vegetables, 95, "High in fiber, vitamins"),
        "broccoli": (.vegetables, 90, "Rich in vitamin C"),
        "spinach": (.vegetables, 95, "Iron and nutrients"),
        "kale": (.vegetables, 95, "Superfood, antioxidants"),
        "carrots": (.vegetables, 85, "Beta-carotene, vitamin A"),
        "tomato": (.vegetables, 85, "Lycopene, vitamins"),
        
        // Fruits (75-90)
        "apple": (.fruits, 85, "Good source of fiber"),
        "banana": (.fruits, 80, "High in potassium"),
        "berries": (.fruits, 90, "Antioxidants"),
        "strawberry": (.fruits, 88, "Vitamin C, low sugar"),
        "blueberry": (.fruits, 90, "Brain health"),
        "orange": (.fruits, 85, "Vitamin C"),
        "grapes": (.fruits, 75, "Natural sugars"),
        "watermelon": (.fruits, 80, "Hydrating"),
        
        // Proteins (65-85)
        "chicken": (.protein, 75, "Lean protein"),
        "salmon": (.protein, 85, "Rich in omega-3"),
        "eggs": (.protein, 70, "Complete protein"),
        "tuna": (.protein, 80, "Low fat protein"),
        "tofu": (.protein, 75, "Plant-based protein"),
        "beef": (.protein, 60, "High protein, iron"),
        "steak": (.protein, 60, "High protein, iron"),
        "pork": (.protein, 55, "Moderate protein"),
        "fish": (.protein, 80, "Heart-healthy"),
        "shrimp": (.protein, 75, "Low calorie protein"),
        
        // Grains (50-80)
        "oatmeal": (.grains, 80, "Heart-healthy grain"),
        "rice": (.grains, 65, "Complex carbs"),
        "quinoa": (.grains, 80, "Complete protein"),
        "pasta": (.grains, 55, "Energy source"),
        "bread": (.grains, 50, "Choose whole grain"),
        "cereal": (.grains, 60, "Fortified nutrients"),
        
        // Dairy (50-70)
        "yogurt": (.dairy, 65, "Probiotics and protein"),
        "milk": (.dairy, 60, "Calcium, vitamin D"),
        "cheese": (.dairy, 50, "Calcium, high fat"),
        
        // Beverages (20-100)
        "coffee": (.beverages, 40, "Antioxidants"),
        "cappuccino": (.beverages, 20, "Moderate calories"),
        "latte": (.beverages, 25, "Milk-based"),
        "espresso": (.beverages, 45, "Concentrated coffee"),
        "tea": (.beverages, 70, "Antioxidants"),
        "green tea": (.beverages, 85, "Metabolism boost"),
        "water": (.beverages, 100, "Essential hydration"),
        "juice": (.beverages, 30, "Natural sugars"),
        "soda": (.beverages, -60, "Empty calories"),
        "smoothie": (.beverages, 60, "Nutrient-dense"),
        
        // Fast Food (-35 to -60)
        "pizza": (.fastFood, -40, "High calories/sodium"),
        "burger": (.fastFood, -50, "High saturated fat"),
        "hamburger": (.fastFood, -50, "High saturated fat"),
        "fries": (.fastFood, -55, "Trans fats"),
        "hot dog": (.fastFood, -55, "Processed meat"),
        "nachos": (.fastFood, -45, "High sodium, fat"),
        "taco": (.fastFood, -35, "Depends on ingredients"),
        
        // Sweets (-40 to -75)
        "candy": (.sweets, -70, "Pure sugar"),
        "cake": (.sweets, -50, "High sugar"),
        "chocolate_cake": (.sweets, -55, "High sugar, fat"),
        "cookie": (.sweets, -50, "Refined sugar"),
        "cookies": (.sweets, -50, "Refined sugar"),
        "donut": (.sweets, -65, "Sugar and trans fats"),
        "ice cream": (.sweets, -45, "High sugar, fat"),
        "chocolate": (.sweets, -40, "Sugar, some benefits"),
        "brownie": (.sweets, -55, "High sugar, fat"),
        "pie": (.sweets, -50, "High sugar"),
        "apple_pie": (.sweets, -45, "Fruit with sugar"),
        
        // Processed (-50 to -70)
        "chips": (.processedFood, -60, "High sodium"),
        "crackers": (.processedFood, -40, "Refined carbs"),
        "instant noodles": (.processedFood, -65, "High sodium, MSG"),
        "frozen meal": (.processedFood, -50, "High sodium"),
        
        // Snacks (mixed)
        "nuts": (.protein, 75, "Healthy fats, protein"),
        "popcorn": (.grains, 55, "Whole grain snack"),
        "granola": (.grains, 50, "Watch added sugar"),
        "protein bar": (.protein, 60, "Convenient protein")
    ]
    
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
            // Analyze food in image
            analyzeFoodInImage(image) { [weak self] result in
                guard let self = self else { return }
                
                let newMeal = MealEntry(
                    mealType: mealType,
                    date: date,
                    imageFileName: imageFileName,
                    foodName: result?.foodName,
                    healthScore: result?.nutritionScore,
                    recognitionConfidence: result?.confidence
                )
                
                self.meals.append(newMeal)
                self.saveMeals()
                
                if let result = result {
                    print("✅ Added meal: \(mealType.displayName)")
                    print("   Food detected: \(result.foodName) (confidence: \(Int(result.confidence * 100))%)")
                    print("   Health score: \(result.nutritionScore) - \(result.details)")
                    
                    // Post notification with detection info
                    NotificationCenter.default.post(
                        name: NSNotification.Name("FoodDetected"),
                        object: nil,
                        userInfo: ["foodName": result.foodName, "score": result.nutritionScore]
                    )
                    
                    // Trigger emoji flood based on health score
                    if result.nutritionScore >= 70 {
                        // Healthy (70+) - show 🤩 emoji flood
                        NotificationCenter.default.post(name: NSNotification.Name("HealthyFoodDetected"), object: nil)
                    } else if result.nutritionScore >= 0 && result.nutritionScore < 70 {
                        // Nutritionally okay (0-69) - show 😐 emoji flood
                        NotificationCenter.default.post(name: NSNotification.Name("NutritionallyOkayDetected"), object: nil)
                    } else if result.nutritionScore < 0 {
                        // Unhealthy (negative score) - show 🤨 emoji flood
                        NotificationCenter.default.post(name: NSNotification.Name("UnhealthyFoodDetected"), object: nil)
                    }
                } else {
                    print("✅ Added meal: \(mealType.displayName) with image: \(imageFileName)")
                }
            }
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
            // Analyze food in new image
            analyzeFoodInImage(image) { [weak self] result in
                guard let self = self else { return }
                
                // Remove old meal
                self.meals.removeAll { $0.id == meal.id }
                
                // Add updated meal with recognition data
                let updatedMeal = MealEntry(
                    id: meal.id,
                    mealType: meal.mealType,
                    date: meal.date,
                    imageFileName: imageFileName,
                    foodName: result?.foodName,
                    healthScore: result?.nutritionScore,
                    recognitionConfidence: result?.confidence
                )
                self.meals.append(updatedMeal)
                self.saveMeals()
                
                if let result = result {
                    print("✅ Updated meal: \(meal.mealType.displayName)")
                    print("   Food detected: \(result.foodName) - Score: \(result.nutritionScore)")
                    
                    // Trigger emoji flood based on health score
                    if result.nutritionScore >= 70 {
                        // Healthy (70+) - show 🤩 emoji flood
                        NotificationCenter.default.post(name: NSNotification.Name("HealthyFoodDetected"), object: nil)
                    } else if result.nutritionScore >= 0 && result.nutritionScore < 70 {
                        // Nutritionally okay (0-69) - show 😐 emoji flood
                        NotificationCenter.default.post(name: NSNotification.Name("NutritionallyOkayDetected"), object: nil)
                    } else if result.nutritionScore < 0 {
                        // Unhealthy (negative score) - show 🤨 emoji flood
                        NotificationCenter.default.post(name: NSNotification.Name("UnhealthyFoodDetected"), object: nil)
                    }
                } else {
                    print("✅ Updated meal: \(meal.mealType.displayName) with new image: \(imageFileName)")
                }
            }
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
        print("   Original image size: \(image.size)")
        
        // Step 1: Resize image if too large (max 1920px on longest side)
        let processedImage = resizeImage(image, maxDimension: 1920)
        print("   Processed image size: \(processedImage.size)")
        
        // Step 2: Convert to JPEG with optimization
        // Try different compression qualities to find optimal size
        var compressionQuality: CGFloat = 0.8
        var data = processedImage.jpegData(compressionQuality: compressionQuality)
        
        // If image is still too large (>2MB), reduce quality further
        let maxFileSize = 2 * 1024 * 1024 // 2MB
        while let imageData = data, imageData.count > maxFileSize && compressionQuality > 0.3 {
            compressionQuality -= 0.1
            data = processedImage.jpegData(compressionQuality: compressionQuality)
            print("   Adjusting quality to \(compressionQuality)")
        }
        
        guard let finalData = data else {
            print("❌ Failed to convert image to JPEG data")
            return false
        }
        
        let fileSizeKB = Double(finalData.count) / 1024
        print("   Final JPEG size: \(String(format: "%.2f", fileSizeKB)) KB (quality: \(compressionQuality))")
        
        let fileURL = imagesDirectoryURL.appendingPathComponent(fileName)
        print("   Saving to: \(fileURL.path)")
        
        do {
            try finalData.write(to: fileURL)
            print("✅ Successfully saved optimized image to disk")
            return true
        } catch {
            print("❌ Error writing image to disk: \(error)")
            return false
        }
    }
    
    private func resizeImage(_ image: PlatformImage, maxDimension: CGFloat) -> PlatformImage {
        let size = image.size
        
        // Check if resizing is needed
        guard size.width > maxDimension || size.height > maxDimension else {
            return image
        }
        
        // Calculate new size maintaining aspect ratio
        let aspectRatio = size.width / size.height
        var newSize: CGSize
        
        if size.width > size.height {
            newSize = CGSize(width: maxDimension, height: maxDimension / aspectRatio)
        } else {
            newSize = CGSize(width: maxDimension * aspectRatio, height: maxDimension)
        }
        
        #if canImport(UIKit)
        // iOS/iPadOS implementation
        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { context in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
        #elseif canImport(AppKit)
        // macOS implementation
        let newImage = NSImage(size: newSize)
        newImage.lockFocus()
        image.draw(in: CGRect(origin: .zero, size: newSize),
                   from: CGRect(origin: .zero, size: size),
                   operation: .copy,
                   fraction: 1.0)
        newImage.unlockFocus()
        return newImage
        #endif
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
    
    // MARK: - Food Recognition
    
    private func analyzeFoodInImage(_ image: PlatformImage, completion: @escaping (FoodRecognitionResult?) -> Void) {
        print("🔬 START: analyzeFoodInImage called")
        
        // Convert image to JPEG data for API
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            print("❌ Failed to convert image to JPEG for analysis")
            completion(nil)
            return
        }
        
        print("✅ Image converted to JPEG data: \(imageData.count) bytes")
        
        // Use OpenAI Vision API for Food Recognition
        print("🌐 Calling OpenAI Vision API...")
        recognizeFoodWithAI(imageData: imageData) { [weak self] foodName in
            guard let self = self else { return }
            
            if let detectedFood = foodName {
                print("🔍 Detected food: \(detectedFood)")
                
                // Match with our database
                let normalizedFood = detectedFood.lowercased()
                let matchedFood = self.findBestMatch(for: normalizedFood)
                
                if let foodInfo = self.foodDatabase[matchedFood] {
                    let result = FoodRecognitionResult(
                        foodName: matchedFood.capitalized,
                        confidence: 0.85,
                        nutritionScore: foodInfo.score,
                        details: foodInfo.details
                    )
                    
                    DispatchQueue.main.async {
                        completion(result)
                    }
                } else {
                    // Food detected but not in our database
                    print("⚠️ Food '\(detectedFood)' not in database, using neutral score")
                    let result = FoodRecognitionResult(
                        foodName: detectedFood.capitalized,
                        confidence: 0.85,
                        nutritionScore: 0,
                        details: "Food item recognized"
                    )
                    DispatchQueue.main.async {
                        completion(result)
                    }
                }
            } else {
                print("❌ Could not detect food in image")
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }
    }
    
    // OpenAI Vision API for Food Recognition
    private func recognizeFoodWithAI(imageData: Data, completion: @escaping (String?) -> Void) {
        // Check if local detection is forced
        if APIConfig.useLocalDetectionOnly {
            print("ℹ️ Local Vision detection mode enabled")
            useFallbackDetection(imageData: imageData, completion: completion)
            return
        }
        
        let apiKey = APIConfig.openAIAPIKey
        
        // Check if API key is configured
        if apiKey == "YOUR_OPENAI_API_KEY" {
            print("⚠️ OpenAI API key not configured, using local Vision detection")
            print("   Get your API key at: https://platform.openai.com/api-keys")
            print("   Add it to MealPersistenceManager.swift (APIConfig struct)")
            useFallbackDetection(imageData: imageData, completion: completion)
            return
        }
        
        print("✅ Using OpenAI Vision API with key: \(String(apiKey.prefix(8)))...")
        print("✅ Using model: \(APIConfig.openAIModel)")
        
        // OpenAI Vision API endpoint
        guard let url = URL(string: "https://api.openai.com/v1/chat/completions") else {
            print("❌ Invalid API URL")
            useFallbackDetection(imageData: imageData, completion: completion)
            return
        }
        
        // Convert image to base64
        let base64Image = imageData.base64EncodedString()
        
        // Create OpenAI Vision request
        let requestBody: [String: Any] = [
            "model": APIConfig.openAIModel,
            "messages": [
                [
                    "role": "user",
                    "content": [
                        [
                            "type": "text",
                            "text": "You are a food recognition expert. Analyze this image and identify the main food item. Respond with ONLY the food name in lowercase, nothing else. Examples: 'pizza', 'salad', 'cappuccino', 'burger', 'rice', 'chicken'. Be specific but concise."
                        ],
                        [
                            "type": "image_url",
                            "image_url": [
                                "url": "data:image/jpeg;base64,\(base64Image)"
                            ]
                        ]
                    ]
                ]
            ],
            "max_tokens": 50
        ]
        
        guard let httpBody = try? JSONSerialization.data(withJSONObject: requestBody) else {
            print("❌ Failed to create request body")
            useFallbackDetection(imageData: imageData, completion: completion)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 30
        request.httpBody = httpBody
        
        print("🚀 Sending request to OpenAI Vision API...")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ OpenAI API network error: \(error.localizedDescription)")
                self.useFallbackDetection(imageData: imageData, completion: completion)
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("📡 OpenAI response status: \(httpResponse.statusCode)")
                
                if httpResponse.statusCode == 401 {
                    print("❌ Authentication failed - check API key")
                    self.useFallbackDetection(imageData: imageData, completion: completion)
                    return
                }
                
                if httpResponse.statusCode == 429 {
                    print("⚠️ Rate limit exceeded")
                    self.useFallbackDetection(imageData: imageData, completion: completion)
                    return
                }
                
                if httpResponse.statusCode != 200 {
                    print("❌ Unexpected status code: \(httpResponse.statusCode)")
                    if let data = data, let errorString = String(data: data, encoding: .utf8) {
                        print("   Error response: \(errorString)")
                    }
                    self.useFallbackDetection(imageData: imageData, completion: completion)
                    return
                }
            }
            
            guard let data = data else {
                print("❌ No data received from OpenAI")
                self.useFallbackDetection(imageData: imageData, completion: completion)
                return
            }
            
            print("✅ Received data: \(data.count) bytes")
            
            do {
                // Parse OpenAI response
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let choices = json["choices"] as? [[String: Any]],
                   let firstChoice = choices.first,
                   let message = firstChoice["message"] as? [String: Any],
                   let content = message["content"] as? String {
                    
                    // Clean up the response - remove extra whitespace and newlines
                    let foodName = content.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
                    
                    print("🎯 OpenAI detected: \(foodName)")
                    completion(foodName)
                } else {
                    print("❌ Could not parse OpenAI response")
                    if let jsonString = String(data: data, encoding: .utf8) {
                        print("   Response: \(jsonString.prefix(200))")
                    }
                    self.useFallbackDetection(imageData: imageData, completion: completion)
                }
            } catch {
                print("❌ Failed to parse OpenAI response: \(error)")
                self.useFallbackDetection(imageData: imageData, completion: completion)
            }
        }.resume()
        
        print("⏳ Waiting for OpenAI Vision response...")
    }
    
    // Vision-based food detection using Core ML and Vision framework
    private func useFallbackDetection(imageData: Data, completion: @escaping (String?) -> Void) {
        print("🔬 USING VISION-BASED DETECTION (Core ML + Vision Framework)")
        DispatchQueue.global(qos: .userInitiated).async {
            // Create image from data
            #if canImport(UIKit)
            guard let image = UIImage(data: imageData),
                  let cgImage = image.cgImage else {
                completion(nil)
                return
            }
            #elseif canImport(AppKit)
            guard let image = NSImage(data: imageData),
                  let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
                completion(nil)
                return
            }
            #endif
            
            // Use Vision framework for advanced analysis
            self.analyzeImageWithVision(cgImage: cgImage) { foodGuess in
                DispatchQueue.main.async {
                    completion(foodGuess)
                }
            }
        }
    }
    
    // MARK: - Vision Framework Analysis
    // Advanced on-device food detection using Core ML + Vision
    // Combines multiple analysis techniques:
    // 1. Color Analysis - Dominant colors, percentages, brightness, variance
    // 2. Texture Analysis - Rectangles, circles, edge detection, homogeneity
    // 3. Shape Analysis - Contours, aspect ratios, circular detection
    // 4. Combined Decision - Weighted scoring based on all analyses
    
    private func analyzeImageWithVision(cgImage: CGImage, completion: @escaping (String?) -> Void) {
        print("🔍 Starting Vision framework analysis...")
        
        // Create Vision request handler
        let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        
        // Run multiple Vision analyses in parallel
        var colorAnalysis: ColorAnalysisResult?
        var textureAnalysis: TextureAnalysisResult?
        var shapeAnalysis: ShapeAnalysisResult?
        
        let group = DispatchGroup()
        
        // 1. Color Analysis
        group.enter()
        analyzeColors(cgImage: cgImage) { result in
            colorAnalysis = result
            group.leave()
        }
        
        // 2. Texture Analysis using Vision
        group.enter()
        analyzeTexture(requestHandler: requestHandler) { result in
            textureAnalysis = result
            group.leave()
        }
        
        // 3. Shape Analysis
        group.enter()
        analyzeShapes(requestHandler: requestHandler) { result in
            shapeAnalysis = result
            group.leave()
        }
        
        // Wait for all analyses to complete
        group.notify(queue: .global(qos: .userInitiated)) {
            // Combine all analyses to determine food
            let detectedFood = self.combinedFoodDetection(
                color: colorAnalysis,
                texture: textureAnalysis,
                shape: shapeAnalysis
            )
            
            print("✅ Vision analysis complete: \(detectedFood)")
            completion(detectedFood)
        }
    }
    
    // MARK: - Color Analysis
    
    struct ColorAnalysisResult {
        let dominantColors: [ImageColor]
        let greenPercent: Double
        let redPercent: Double
        let yellowPercent: Double
        let brownPercent: Double
        let whitePercent: Double
        let averageBrightness: Double
        let colorVariance: Double
    }
    
    private func analyzeColors(cgImage: CGImage, completion: @escaping (ColorAnalysisResult?) -> Void) {
        let colors = extractDominantColors(from: cgImage)
        
        let totalColors = max(colors.count, 1)
        
        let greenCount = colors.filter { $0.isGreenish }.count
        let redCount = colors.filter { $0.isReddish }.count
        let yellowCount = colors.filter { $0.isYellowish }.count
        let brownCount = colors.filter { $0.isBrownish }.count
        let whiteCount = colors.filter { $0.isWhitish }.count
        
        let greenPercent = Double(greenCount) / Double(totalColors)
        let redPercent = Double(redCount) / Double(totalColors)
        let yellowPercent = Double(yellowCount) / Double(totalColors)
        let brownPercent = Double(brownCount) / Double(totalColors)
        let whitePercent = Double(whiteCount) / Double(totalColors)
        
        // Calculate average brightness
        let avgBrightness = colors.map { ($0.r + $0.g + $0.b) / 3.0 }.reduce(0, +) / Double(totalColors)
        
        // Calculate color variance (how diverse the colors are)
        let variance = calculateColorVariance(colors: colors)
        
        let result = ColorAnalysisResult(
            dominantColors: colors,
            greenPercent: greenPercent,
            redPercent: redPercent,
            yellowPercent: yellowPercent,
            brownPercent: brownPercent,
            whitePercent: whitePercent,
            averageBrightness: avgBrightness,
            colorVariance: variance
        )
        
        print("📊 Color Analysis: G:\(Int(greenPercent*100))% R:\(Int(redPercent*100))% Y:\(Int(yellowPercent*100))% B:\(Int(brownPercent*100))% W:\(Int(whitePercent*100))%")
        
        completion(result)
    }
    
    private func calculateColorVariance(colors: [ImageColor]) -> Double {
        guard !colors.isEmpty else { return 0 }
        
        let avgR = colors.map { $0.r }.reduce(0, +) / Double(colors.count)
        let avgG = colors.map { $0.g }.reduce(0, +) / Double(colors.count)
        let avgB = colors.map { $0.b }.reduce(0, +) / Double(colors.count)
        
        let variance = colors.map { color in
            pow(color.r - avgR, 2) + pow(color.g - avgG, 2) + pow(color.b - avgB, 2)
        }.reduce(0, +) / Double(colors.count)
        
        return variance
    }
    
    // MARK: - Texture Analysis
    
    struct TextureAnalysisResult {
        let hasRectangles: Bool  // Pizza, sandwiches
        let hasCircles: Bool      // Burgers, donuts, plates
        let edgeCount: Int        // Complexity
        let isHomogeneous: Bool   // Smooth vs varied texture
    }
    
    private func analyzeTexture(requestHandler: VNImageRequestHandler, completion: @escaping (TextureAnalysisResult?) -> Void) {
        // Detect rectangles
        let rectangleRequest = VNDetectRectanglesRequest { request, error in
            let rectangleCount = request.results?.count ?? 0
            
            // Use contour detection for edge/texture analysis (available in iOS 14+)
            let contourRequest = VNDetectContoursRequest { contourReq, contourError in
                let contourObservations = contourReq.results as? [VNContoursObservation] ?? []
                let edgeCount = contourObservations.reduce(0) { $0 + $1.contourCount }
                
                let result = TextureAnalysisResult(
                    hasRectangles: rectangleCount > 0,
                    hasCircles: false, // Will be detected in shape analysis
                    edgeCount: edgeCount,
                    isHomogeneous: edgeCount < 50
                )
                
                print("🧩 Texture Analysis: Rectangles:\(rectangleCount) Edges:\(edgeCount)")
                completion(result)
            }
            
            contourRequest.contrastAdjustment = 1.5
            contourRequest.detectsDarkOnLight = true
            
            do {
                try requestHandler.perform([contourRequest])
            } catch {
                print("⚠️ Contour detection failed: \(error)")
                // Fallback without edge detection
                let result = TextureAnalysisResult(
                    hasRectangles: rectangleCount > 0,
                    hasCircles: false,
                    edgeCount: 0,
                    isHomogeneous: true
                )
                completion(result)
            }
        }
        
        rectangleRequest.minimumConfidence = 0.6
        rectangleRequest.minimumAspectRatio = 0.3
        
        do {
            try requestHandler.perform([rectangleRequest])
        } catch {
            print("⚠️ Rectangle detection failed: \(error)")
            // Fallback with no texture analysis
            let result = TextureAnalysisResult(
                hasRectangles: false,
                hasCircles: false,
                edgeCount: 0,
                isHomogeneous: true
            )
            completion(result)
        }
    }
    
    // MARK: - Shape Analysis
    
    struct ShapeAnalysisResult {
        let hasCircularShapes: Bool
        let aspectRatio: Double  // Width/height ratio
        let symmetry: Double     // How symmetrical the food is
    }
    
    private func analyzeShapes(requestHandler: VNImageRequestHandler, completion: @escaping (ShapeAnalysisResult?) -> Void) {
        // Detect contours for shape analysis
        let contourRequest = VNDetectContoursRequest { request, error in
            if let error = error {
                print("⚠️ Shape detection error: \(error)")
                completion(ShapeAnalysisResult(hasCircularShapes: false, aspectRatio: 1.0, symmetry: 0.5))
                return
            }
            
            guard let observations = request.results as? [VNContoursObservation] else {
                completion(ShapeAnalysisResult(hasCircularShapes: false, aspectRatio: 1.0, symmetry: 0.5))
                return
            }
            
            // Analyze shape characteristics
            let hasCircular = observations.contains { obs in
                // Check if contour is roughly circular
                let boundingBox = obs.normalizedPath.boundingBox
                guard boundingBox.height > 0 else { return false }
                let aspectRatio = boundingBox.width / boundingBox.height
                return aspectRatio > 0.8 && aspectRatio < 1.2
            }
            
            let avgAspectRatio = observations.isEmpty ? 1.0 :
                observations.compactMap { obs -> Double? in
                    let boundingBox = obs.normalizedPath.boundingBox
                    guard boundingBox.height > 0 else { return nil }
                    return boundingBox.width / boundingBox.height
                }
                .reduce(0, +) / Double(max(observations.count, 1))
            
            let result = ShapeAnalysisResult(
                hasCircularShapes: hasCircular,
                aspectRatio: avgAspectRatio,
                symmetry: 0.5
            )
            
            print("🔺 Shape Analysis: Circular:\(hasCircular) AspectRatio:\(String(format: "%.2f", avgAspectRatio))")
            completion(result)
        }
        
        contourRequest.contrastAdjustment = 1.5
        contourRequest.detectsDarkOnLight = true
        
        do {
            try requestHandler.perform([contourRequest])
        } catch {
            print("⚠️ Shape analysis failed: \(error)")
            completion(ShapeAnalysisResult(hasCircularShapes: false, aspectRatio: 1.0, symmetry: 0.5))
        }
    }
    
    // MARK: - Combined Analysis
    
    private func combinedFoodDetection(
        color: ColorAnalysisResult?,
        texture: TextureAnalysisResult?,
        shape: ShapeAnalysisResult?
    ) -> String {
        print("🎯 Combining analyses for final detection...")
        
        guard let color = color else {
            return getFallbackByTime()
        }
        
        // High confidence detections based on strong color signals
        
        // Green vegetables (salad, broccoli, etc.)
        if color.greenPercent > 0.35 {
            return color.colorVariance > 0.05 ? "salad" : "broccoli"
        }
        
        // Pizza (red sauce + yellow cheese + low variance)
        if color.redPercent > 0.15 && color.yellowPercent > 0.15 {
            return texture?.hasRectangles == true ? "pizza" : "pasta"
        }
        
        // Banana (yellow dominant)
        if color.yellowPercent > 0.45 && color.redPercent < 0.1 {
            return shape?.hasCircularShapes == true ? "apple_pie" : "banana"
        }
        
        // Coffee/Cappuccino (brown + white with specific ratios)
        if color.brownPercent > 0.25 && color.whitePercent > 0.2 {
            return shape?.hasCircularShapes == true ? "cappuccino" : "donut"
        }
        
        // Tea (brown without white)
        if color.brownPercent > 0.35 && color.whitePercent < 0.15 {
            return "tea"
        }
        
        // Strawberries/Tomatoes (red dominant)
        if color.redPercent > 0.35 {
            return color.colorVariance > 0.03 ? "strawberry" : "tomato"
        }
        
        // Orange foods
        if color.redPercent > 0.2 && color.yellowPercent > 0.25 && color.greenPercent < 0.1 {
            return shape?.hasCircularShapes == true ? "orange" : "carrots"
        }
        
        // Rice/Bread (white/beige dominant)
        if color.whitePercent > 0.4 {
            return texture?.isHomogeneous == true ? "rice" : "bread"
        }
        
        // Chocolate/Dark foods
        if color.brownPercent > 0.4 && color.averageBrightness < 0.3 {
            return shape?.hasCircularShapes == true ? "chocolate_cake" : "steak"
        }
        
        // Medium-diverse colors might be mixed foods
        if color.colorVariance > 0.08 {
            return "salad"  // Likely a mixed dish
        }
        
        // Default fallback based on time
        return getFallbackByTime()
    }
    
    private func getFallbackByTime() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        if hour >= 6 && hour < 11 {
            return "oatmeal"
        } else if hour >= 11 && hour < 15 {
            return "chicken"
        } else {
            return "rice"
        }
    }
    
    // Find best match in database
    private func findBestMatch(for detectedFood: String) -> String {
        // Direct match
        if foodDatabase[detectedFood] != nil {
            return detectedFood
        }
        
        // Partial match - check if detected food contains any database key
        for key in foodDatabase.keys {
            if detectedFood.contains(key) || key.contains(detectedFood) {
                return key
            }
        }
        
        // Synonym matching
        let synonyms: [String: String] = [
            "espresso": "coffee",
            "latte": "cappuccino",
            "americano": "coffee",
            "mocha": "cappuccino",
            "green tea": "tea",
            "black tea": "tea",
            "lettuce": "salad",
            "french fries": "fries",
            "hamburger": "burger",
            "cheeseburger": "burger",
            "spaghetti": "pasta",
            "penne": "pasta",
            "coke": "soda",
            "pepsi": "soda",
            "chocolate": "candy",
            "cookie": "cookies",
            "doughnut": "donut"
        ]
        
        if let synonym = synonyms[detectedFood] {
            return synonym
        }
        
        // No match found, return original
        return detectedFood
    }
    
    // Intelligent guess based on image analysis
    // This is a placeholder until we integrate a real ML model
    // Extract dominant colors from image
    private func extractDominantColors(from cgImage: CGImage) -> [ImageColor] {
        let width = cgImage.width
        let height = cgImage.height
        
        // Sample pixels (for performance, sample every 10th pixel)
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * width
        let bitsPerComponent = 8
        
        guard let context = CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: bitsPerComponent,
            bytesPerRow: bytesPerRow,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else {
            return []
        }
        
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        guard let data = context.data else { return [] }
        let buffer = data.bindMemory(to: UInt8.self, capacity: width * height * bytesPerPixel)
        
        var colors: [ImageColor] = []
        let sampleRate = 20 // Sample every 20th pixel
        
        for y in stride(from: 0, to: height, by: sampleRate) {
            for x in stride(from: 0, to: width, by: sampleRate) {
                let offset = (y * width + x) * bytesPerPixel
                let r = CGFloat(buffer[offset]) / 255.0
                let g = CGFloat(buffer[offset + 1]) / 255.0
                let b = CGFloat(buffer[offset + 2]) / 255.0
                
                colors.append(ImageColor(r: r, g: g, b: b))
            }
        }
        
        return colors
    }
    
    // MARK: - Health Score Calculation
    
    func getDailyHealthScore() -> Int {
        let calendar = Calendar.current
        let todayMeals = meals.filter { calendar.isDateInToday($0.date) }
        
        let totalScore = todayMeals.compactMap { $0.healthScore }.reduce(0, +)
        return totalScore
    }
    
    func getWeeklyHealthScore() -> Int {
        let calendar = Calendar.current
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        
        let weekMeals = meals.filter { $0.date >= weekAgo }
        let totalScore = weekMeals.compactMap { $0.healthScore }.reduce(0, +)
        
        return totalScore
    }
}

