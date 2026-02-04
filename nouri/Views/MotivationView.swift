//
//  MotivationView.swift
//  nouri
//
//  Created by Chan Ching Hei on 17/12/2025.
//

import SwiftUI

// API Service for fetching nutrition facts
class NutritionFactsService: ObservableObject {
    @Published var currentFact: String = ""
    @Published var isLoading: Bool = false
    
    private let apiURL = "https://api.api-ninjas.com/v1/nutrition"
    
    // Fallback facts when API is unavailable
    private let fallbackFacts = [
        "Eating protein with every meal helps maintain stable blood sugar levels and keeps you fuller for longer.",
        "Colorful vegetables contain different phytonutrients - eating a rainbow ensures you get a variety of health benefits.",
        "Fiber helps feed beneficial gut bacteria, which play a crucial role in immunity and mental health.",
        "Healthy fats from sources like avocados, nuts, and olive oil help your body absorb fat-soluble vitamins A, D, E, and K.",
        "Drinking water before meals can help with portion control and improve digestion.",
        "Berries are packed with antioxidants that help protect your cells from damage and may improve brain function.",
        "Eating slowly and mindfully can help you recognize fullness cues and enjoy your food more.",
        "Omega-3 fatty acids found in fatty fish, walnuts, and flax seeds support heart and brain health.",
        "Leafy greens like spinach and kale are rich in vitamin K, which is essential for bone health and blood clotting.",
        "Fermented foods like yogurt, kimchi, and sauerkraut contain probiotics that support digestive health.",
        "Complex carbohydrates provide sustained energy, while simple sugars cause quick spikes and crashes.",
        "Magnesium, found in nuts and seeds, helps with muscle relaxation, sleep quality, and stress management.",
        "Eating breakfast within an hour of waking can help kickstart your metabolism and improve focus.",
        "Dark chocolate (70%+ cacao) contains flavonoids that may improve heart health and mood.",
        "Vitamin D from sunlight and foods like fatty fish helps calcium absorption for stronger bones.",
        "Meal timing matters - eating most of your calories earlier in the day aligns better with your body's natural rhythms.",
        "Herbs and spices like turmeric, ginger, and cinnamon have anti-inflammatory properties.",
        "Iron from plant sources is better absorbed when paired with vitamin C-rich foods like citrus or bell peppers.",
        "Consistent meal times help regulate your body's hunger hormones and improve metabolic health.",
        "Whole grains contain more fiber, vitamins, and minerals than refined grains, supporting long-term health."
    ]
    
    init() {
        fetchRandomFact()
    }
    
    func fetchRandomFact() {
        // Use fallback facts for now (API requires authentication)
        // In production, you would implement proper API calls with your API key
        currentFact = fallbackFacts.randomElement() ?? fallbackFacts[0]
    }
}

struct MotivationView: View {
    @StateObject private var factsService = NutritionFactsService()
    
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
                    
                    // Animated Panda Icon
                    AnimatedPandaView(size: 90)
                        .frame(width: 90, height: 90)
                    
                    // Nutrition Fact
                    VStack(spacing: 16) {
                        if factsService.isLoading {
                            ProgressView()
                                .scaleEffect(1.5)
                        } else {
                            Text(factsService.currentFact)
                                .font(.title3)
                                .fontWeight(.medium)
                                .multilineTextAlignment(.center)
                                .foregroundColor(.primary)
                                .padding(.horizontal, 32)
                                .transition(.opacity)
                        }
                    }
                    .frame(minHeight: 120)
                    
                    // Refresh button
                    Button(action: {
                        withAnimation {
                            factsService.fetchRandomFact()
                        }
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "arrow.clockwise")
                                .rotationEffect(.degrees(factsService.isLoading ? 360 : 0))
                                .animation(factsService.isLoading ? .linear(duration: 1).repeatForever(autoreverses: false) : .default, value: factsService.isLoading)
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
                    .disabled(factsService.isLoading)
                    
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
                // Fetch new fact when view appears
                factsService.fetchRandomFact()
            }
        }
    }
}

#Preview {
    MotivationView()
}

