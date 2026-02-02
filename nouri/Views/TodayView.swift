//
//  TodayView.swift
//  nouri
//
//  Created by Chan Ching Hei on 17/12/2025.
//

import SwiftUI

struct TodayView: View {
    @StateObject private var persistenceManager = MealPersistenceManager.shared
    @State private var selectedMealType: MealType?
    @State private var showingImagePicker = false
    @State private var selectedImage: PlatformImage?
    
    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header with day and date
                    VStack(alignment: .leading, spacing: 4) {
                        Text(currentDayOfWeek)
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text(currentDate)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                    
                    // Meal Grid
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(MealType.allCases.sorted(by: { $0.sortOrder < $1.sortOrder }), id: \.self) { mealType in
                            MealCardView(
                                mealType: mealType,
                                meal: persistenceManager.getMeal(for: mealType, on: Date()),
                                selectedMealType: $selectedMealType
                            )
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom, 20)
            }
            .navigationTitle("Today")
            #if canImport(UIKit)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(selectedImage: $selectedImage, isPresented: $showingImagePicker)
                    .padding()
            }
            .onChange(of: selectedImage) { newImage in
                if let image = newImage, let mealType = selectedMealType {
                    if let existingMeal = persistenceManager.getMeal(for: mealType, on: Date()) {
                        persistenceManager.updateMeal(existingMeal, with: image)
                    } else {
                        persistenceManager.addMeal(mealType: mealType, date: Date(), image: image)
                    }
                    
                    selectedImage = nil
                    selectedMealType = nil
                }
            }
            .onChange(of: selectedMealType) { newMealType in
                if newMealType != nil {
                    showingImagePicker = true
                }
            }
        }
    }
    
    private var currentDayOfWeek: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter.string(from: Date())
    }
    
    private var currentDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy"
        return formatter.string(from: Date())
    }
}

struct MealCardView: View {
    let mealType: MealType
    let meal: MealEntry?
    @Binding var selectedMealType: MealType?
    
    @StateObject private var persistenceManager = MealPersistenceManager.shared
    
    var body: some View {
        Button(action: {
            selectedMealType = mealType
        }) {
            VStack(spacing: 0) {
                // Image area
                ZStack {
                    if let meal = meal,
                       let imageFileName = meal.imageFileName,
                       let image = persistenceManager.loadImage(fileName: imageFileName) {
                        #if canImport(UIKit)
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 140)
                            .clipped()
                        #elseif canImport(AppKit)
                        Image(nsImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 140)
                            .clipped()
                        #endif
                    } else {
                        // Placeholder
                        ZStack {
                            Rectangle()
                                #if canImport(UIKit)
                                .fill(Color(.systemGray6))
                                #else
                                .fill(Color(NSColor.separatorColor))
                                #endif
                                .frame(height: 140)
                            
                            VStack(spacing: 8) {
                                Image(systemName: "camera.fill")
                                    .font(.system(size: 32))
                                    .foregroundColor(.secondary)
                                
                                Text("Add Photo")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                .frame(height: 140)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                
                // Meal label
                Text(mealType.displayName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                    .padding(.top, 8)
            }
        }
        .buttonStyle(.plain)
    }
}

struct TodayView_Previews: PreviewProvider {
    static var previews: some View {
        TodayView()
    }
}

