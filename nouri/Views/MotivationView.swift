//
//  MotivationView.swift
//  nouri
//
//  Created by Chan Ching Hei on 17/12/2025.
//

import SwiftUI

struct MotivationView: View {
    @State private var currentFact: NutritionFact
    
    private let nutritionFacts = [
        NutritionFact(text: "Eating protein with every meal helps maintain stable blood sugar levels and keeps you fuller for longer."),
        NutritionFact(text: "Colorful vegetables contain different phytonutrients - eating a rainbow ensures you get a variety of health benefits."),
        NutritionFact(text: "Fiber helps feed beneficial gut bacteria, which play a crucial role in immunity and mental health."),
        NutritionFact(text: "Healthy fats from sources like avocados, nuts, and olive oil help your body absorb fat-soluble vitamins A, D, E, and K."),
        NutritionFact(text: "Drinking water before meals can help with portion control and improve digestion."),
        NutritionFact(text: "Berries are packed with antioxidants that help protect your cells from damage and may improve brain function."),
        NutritionFact(text: "Eating slowly and mindfully can help you recognize fullness cues and enjoy your food more."),
        NutritionFact(text: "Omega-3 fatty acids found in fatty fish, walnuts, and flax seeds support heart and brain health."),
        NutritionFact(text: "Leafy greens like spinach and kale are rich in vitamin K, which is essential for bone health and blood clotting."),
        NutritionFact(text: "Fermented foods like yogurt, kimchi, and sauerkraut contain probiotics that support digestive health."),
        NutritionFact(text: "Complex carbohydrates provide sustained energy, while simple sugars cause quick spikes and crashes."),
        NutritionFact(text: "Magnesium, found in nuts and seeds, helps with muscle relaxation, sleep quality, and stress management."),
        NutritionFact(text: "Eating breakfast within an hour of waking can help kickstart your metabolism and improve focus."),
        NutritionFact(text: "Dark chocolate (70%+ cacao) contains flavonoids that may improve heart health and mood."),
        NutritionFact(text: "Vitamin D from sunlight and foods like fatty fish helps calcium absorption for stronger bones."),
        NutritionFact(text: "Meal timing matters - eating most of your calories earlier in the day aligns better with your body's natural rhythms."),
        NutritionFact(text: "Herbs and spices like turmeric, ginger, and cinnamon have anti-inflammatory properties."),
        NutritionFact(text: "Iron from plant sources is better absorbed when paired with vitamin C-rich foods like citrus or bell peppers."),
        NutritionFact(text: "Consistent meal times help regulate your body's hunger hormones and improve metabolic health."),
        NutritionFact(text: "Whole grains contain more fiber, vitamins, and minerals than refined grains, supporting long-term health.")
    ]
    
    init() {
        _currentFact = State(initialValue: NutritionFact.random(from: nutritionFacts))
    }
    
    private func refreshFact() {
        currentFact = NutritionFact.random(from: nutritionFacts)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Subtle gradient background
                #if canImport(UIKit)
                LinearGradient(
                    colors: [
                        Color(platformColor: .systemBackground),
                        Color(platformColor: .systemGray6).opacity(0.3)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                #else
                LinearGradient(
                    colors: [
                        Color(NSColor.windowBackgroundColor),
                        Color.gray.opacity(0.2)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                #endif
                
                VStack(spacing: 32) {
                    Spacer()
                    
                    // Icon
                    Image(systemName: "lightbulb.circle.fill")
                        .font(.system(size: 80))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.green, .blue],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    // Nutrition Fact
                    VStack(spacing: 16) {
                        Text(currentFact.text)
                            .font(.title3)
                            .fontWeight(.medium)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.primary)
                            .padding(.horizontal, 32)
                    }
                    
                    // Refresh button
                    Button(action: refreshFact) {
                        HStack(spacing: 8) {
                            Image(systemName: "arrow.clockwise")
                            Text("New Fact")
                        }
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.blue)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(.ultraThinMaterial)
                        .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                    
                    Spacer()
                    
                    // Label
                    VStack(spacing: 8) {
                        Text("Nutrition Fact")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("Tap to learn more")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    .padding(.bottom, 20)
                }
            }
            .navigationTitle("Nutrition Facts")
            #if canImport(UIKit)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .onAppear {
                // Refresh fact when view appears
                refreshFact()
            }
        }
    }
}

struct NutritionFact {
    let text: String
    
    static func random(from facts: [NutritionFact]) -> NutritionFact {
        facts.randomElement() ?? NutritionFact(text: "Eating a balanced diet supports your overall health and wellbeing.")
    }
}

#Preview {
    MotivationView()
}

