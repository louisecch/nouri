//
//  MotivationView.swift
//  nouri
//
//  Created by Chan Ching Hei on 17/12/2025.
//

import SwiftUI

struct MotivationView: View {
    private let quotes = [
        Quote(text: "Nourishing your body is an act of self-love.", author: "Unknown"),
        Quote(text: "Take care of your body. It's the only place you have to live.", author: "Jim Rohn"),
        Quote(text: "Your body is a temple, but only if you treat it as one.", author: "Astrid Alauda"),
        Quote(text: "The food you eat can be either the safest and most powerful form of medicine or the slowest form of poison.", author: "Ann Wigmore"),
        Quote(text: "Let food be thy medicine and medicine be thy food.", author: "Hippocrates"),
        Quote(text: "Every time you eat is an opportunity to nourish your body.", author: "Unknown"),
        Quote(text: "Small daily improvements are the key to staggering long-term results.", author: "Unknown"),
        Quote(text: "Progress, not perfection.", author: "Unknown"),
        Quote(text: "You don't have to eat less, you just have to eat right.", author: "Unknown"),
        Quote(text: "Health is not about the weight you lose, but the life you gain.", author: "Unknown")
    ]
    
    var dailyQuote: Quote {
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 0
        let index = dayOfYear % quotes.count
        return quotes[index]
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
                    Image(systemName: "heart.circle.fill")
                        .font(.system(size: 80))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.pink, .orange],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    // Quote
                    VStack(spacing: 16) {
                        Text(dailyQuote.text)
                            .font(.title3)
                            .fontWeight(.medium)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.primary)
                            .padding(.horizontal, 32)
                        
                        if let author = dailyQuote.author {
                            Text("— \(author)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    // Daily reminder text
                    VStack(spacing: 8) {
                        Text("Quote of the Day")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text(todayDateString)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    .padding(.bottom, 20)
                }
            }
            .navigationTitle("Motivation")
            #if canImport(UIKit)
            .navigationBarTitleDisplayMode(.inline)
            #endif
        }
    }
    
    private var todayDateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        return formatter.string(from: Date())
    }
}

struct Quote {
    let text: String
    let author: String?
}

#Preview {
    MotivationView()
}

