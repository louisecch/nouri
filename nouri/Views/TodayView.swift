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
    @State private var showEmojiFlood = false
    @State private var emojiType: String = "😐"  // Can be "😐" or "🤨"
    
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
            .overlay(
                EmojiFloodView(isShowing: $showEmojiFlood, emoji: emojiType)
            )
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("NutritionallyOkayDetected"))) { _ in
            triggerEmojiFlood(emoji: "😐")
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("UnhealthyFoodDetected"))) { _ in
            triggerEmojiFlood(emoji: "🤨")
        }
    }
    
    private func triggerEmojiFlood(emoji: String) {
        emojiType = emoji
        showEmojiFlood = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            showEmojiFlood = false
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
    @State private var isHovering = false
    
    var body: some View {
        Button(action: {
            selectedMealType = mealType
        }) {
            VStack(spacing: 0) {
                // Image area
                GeometryReader { geometry in
                    ZStack {
                        if let meal = meal,
                           let imageFileName = meal.imageFileName,
                           let image = persistenceManager.loadImage(fileName: imageFileName) {
                            // Image layer
                            Group {
                                #if canImport(UIKit)
                                Image(uiImage: image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: geometry.size.width, height: geometry.size.height)
                                    .clipped()
                                #elseif canImport(AppKit)
                                Image(nsImage: image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: geometry.size.width, height: geometry.size.height)
                                    .clipped()
                                #endif
                            }
                            .zIndex(0)
                            
                            // Delete button - always visible on iOS, hover on macOS
                            #if canImport(UIKit)
                            VStack {
                                HStack {
                                    Spacer()
                                    Button(action: {
                                        persistenceManager.deleteMeal(meal)
                                    }) {
                                        ZStack {
                                            Circle()
                                                .fill(.ultraThinMaterial)
                                                .frame(width: 28, height: 28)
                                            
                                            Image(systemName: "xmark")
                                                .font(.system(size: 12, weight: .semibold))
                                                .foregroundStyle(.secondary)
                                        }
                                    }
                                    .buttonStyle(.plain)
                                    .padding(8)
                                }
                                Spacer()
                            }
                            .zIndex(1)
                            #elseif canImport(AppKit)
                            if isHovering {
                                VStack {
                                    HStack {
                                        Spacer()
                                        Button(action: {
                                            persistenceManager.deleteMeal(meal)
                                        }) {
                                            ZStack {
                                                Circle()
                                                    .fill(.ultraThinMaterial)
                                                    .frame(width: 28, height: 28)
                                                
                                                Image(systemName: "xmark")
                                                    .font(.system(size: 12, weight: .semibold))
                                                    .foregroundStyle(.secondary)
                                            }
                                        }
                                        .buttonStyle(.plain)
                                        .padding(8)
                                    }
                                    Spacer()
                                }
                                .zIndex(1)
                                .transition(.opacity)
                            }
                            #endif
                        } else {
                            // Placeholder - centered
                            ZStack {
                                Rectangle()
                                    #if canImport(UIKit)
                                    .fill(Color(.systemGray6))
                                    #else
                                    .fill(Color(NSColor.separatorColor))
                                    #endif
                                    .opacity(isHovering ? 0.7 : 1.0)
                                
                                VStack(spacing: 8) {
                                    Image(systemName: "camera.fill")
                                        .font(.system(size: 32))
                                        .foregroundColor(isHovering ? .primary : .secondary)
                                    
                                    Text("Add Photo")
                                        .font(.caption)
                                        .foregroundColor(isHovering ? .primary : .secondary)
                                }
                            }
                            .scaleEffect(isHovering ? 1.02 : 1.0)
                            .animation(.easeInOut(duration: 0.2), value: isHovering)
                        }
                    }
                }
                .frame(height: 140)
                .cornerRadius(12)
                #if canImport(AppKit)
                .onHover { hovering in
                    isHovering = hovering
                }
                #endif
                
                // Meal label and info
                VStack(spacing: 4) {
                    Text(mealType.displayName)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    if let meal = meal {
                        if let foodName = meal.foodName {
                            Text(foodName)
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(.top, 8)
            }
        }
        .buttonStyle(.plain)
    }
}

struct EmojiFloodView: View {
    @Binding var isShowing: Bool
    let emoji: String  // The emoji to display (😐 or 🤨)
    @State private var emojis: [EmojiParticle] = []
    
    var body: some View {
        ZStack {
            if isShowing {
                Color.clear
                    .ignoresSafeArea()
                
                ForEach(emojis) { emojiParticle in
                    Text(emoji)
                        .font(.system(size: emojiParticle.size))
                        .position(x: emojiParticle.x, y: emojiParticle.y)
                        .opacity(emojiParticle.opacity)
                        .animation(.easeOut(duration: emojiParticle.duration), value: emojiParticle.y)
                }
            }
        }
        .allowsHitTesting(false)
        .onChange(of: isShowing) { showing in
            if showing {
                generateEmojis()
            } else {
                emojis.removeAll()
            }
        }
    }
    
    private func generateEmojis() {
        emojis.removeAll()
        
        #if canImport(UIKit)
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        #elseif canImport(AppKit)
        let screenWidth = NSScreen.main?.frame.width ?? 800
        let screenHeight = NSScreen.main?.frame.height ?? 600
        #endif
        
        // Generate 50 emojis
        for i in 0..<50 {
            let randomX = CGFloat.random(in: 0...screenWidth)
            let startY = CGFloat.random(in: -200...(-50))
            let endY = screenHeight + 100
            let size = CGFloat.random(in: 30...80)
            let delay = Double(i) * 0.03
            let duration = Double.random(in: 2.0...3.5)
            
            let emoji = EmojiParticle(
                x: randomX,
                y: startY,
                size: size,
                opacity: 1.0,
                duration: duration
            )
            
            emojis.append(emoji)
            
            // Animate falling
            let emojiID = emoji.id
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                if let index = emojis.firstIndex(where: { $0.id == emojiID }) {
                    emojis[index].y = endY
                    
                    // Fade out near the end
                    DispatchQueue.main.asyncAfter(deadline: .now() + duration * 0.7) {
                        if let fadeIndex = emojis.firstIndex(where: { $0.id == emojiID }) {
                            emojis[fadeIndex].opacity = 0.0
                        }
                    }
                }
            }
        }
    }
}

struct EmojiParticle: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    let size: CGFloat
    var opacity: Double
    let duration: Double
}

#Preview {
    TodayView()
}

