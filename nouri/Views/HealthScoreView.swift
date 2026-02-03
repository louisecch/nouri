//
//  HealthScoreView.swift
//  nouri
//
//  Created by Chan Ching Hei on 3/2/2026.
//

import SwiftUI

struct HealthScoreView: View {
    @ObservedObject var persistenceManager = MealPersistenceManager.shared
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Daily Score Card
                    ScoreCard(
                        title: "Today's Score",
                        score: persistenceManager.getDailyHealthScore(),
                        icon: "calendar",
                        gradient: dailyGradient
                    )
                    
                    // Weekly Score Card
                    ScoreCard(
                        title: "7-Day Score",
                        score: persistenceManager.getWeeklyHealthScore(),
                        icon: "calendar.badge.clock",
                        gradient: weeklyGradient
                    )
                    
                    // Healthy Score Info
                    HealthyScoreInfoCard()
                    
                    // Today's Meals Breakdown
                    TodayMealsSection()
                    
                    // Health Score Guide
                    HealthScoreGuide()
                }
                .padding()
            }
            .navigationTitle("Health Scores")
            .background(Color(.systemGroupedBackground))
        }
    }
    
    private var dailyGradient: LinearGradient {
        let score = persistenceManager.getDailyHealthScore()
        if score >= 200 {
            return LinearGradient(colors: [.green, .mint], startPoint: .topLeading, endPoint: .bottomTrailing)
        } else if score >= 0 {
            return LinearGradient(colors: [.blue, .cyan], startPoint: .topLeading, endPoint: .bottomTrailing)
        } else {
            return LinearGradient(colors: [.orange, .red], startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }
    
    private var weeklyGradient: LinearGradient {
        let score = persistenceManager.getWeeklyHealthScore()
        if score >= 1000 {
            return LinearGradient(colors: [.green, .mint], startPoint: .topLeading, endPoint: .bottomTrailing)
        } else if score >= 0 {
            return LinearGradient(colors: [.blue, .cyan], startPoint: .topLeading, endPoint: .bottomTrailing)
        } else {
            return LinearGradient(colors: [.orange, .red], startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }
}

struct HealthyScoreInfoCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                Image(systemName: "info.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.blue)
                Text("What's a Healthy Score?")
                    .font(.title3)
                    .fontWeight(.bold)
            }
            
            VStack(alignment: .leading, spacing: 12) {
                Text("A healthy day typically ranges from **200-300 points**, achieved by eating 3-4 nutritious meals.")
                    .font(.subheadline)
                    .fixedSize(horizontal: false, vertical: true)
                
                VStack(alignment: .leading, spacing: 8) {
                    HealthyScoreExampleRow(
                        icon: "sunrise.fill",
                        meal: "Breakfast: Oatmeal + Fruit",
                        points: "~90 pts",
                        color: .green
                    )
                    HealthyScoreExampleRow(
                        icon: "sun.max.fill",
                        meal: "Lunch: Salad + Grilled Chicken",
                        points: "~95 pts",
                        color: .green
                    )
                    HealthyScoreExampleRow(
                        icon: "moon.stars.fill",
                        meal: "Dinner: Salmon + Vegetables",
                        points: "~95 pts",
                        color: .green
                    )
                    
                    Divider()
                        .padding(.vertical, 4)
                    
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                        Text("Daily Total: 280 points")
                            .fontWeight(.semibold)
                    }
                    .font(.subheadline)
                }
                .padding(12)
                .background(Color(.tertiarySystemGroupedBackground))
                .cornerRadius(8)
                
                Text("💡 **Tip:** Balance is key. Even one unhealthy meal won't ruin your day if you make good choices otherwise!")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
}

struct HealthyScoreExampleRow: View {
    let icon: String
    let meal: String
    let points: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.body)
                .foregroundStyle(color)
                .frame(width: 24)
            
            Text(meal)
                .font(.subheadline)
            
            Spacer()
            
            Text(points)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(color)
        }
    }
}

struct ScoreCard: View {
    let title: String
    let score: Int
    let icon: String
    let gradient: LinearGradient
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                Text(title)
                    .font(.headline)
                Spacer()
            }
            .foregroundStyle(.white)
            
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text("\(score)")
                    .font(.system(size: 56, weight: .bold, design: .rounded))
                Text("points")
                    .font(.title3)
                    .fontWeight(.medium)
                Spacer()
            }
            .foregroundStyle(.white)
            
            // Score interpretation
            HStack {
                Text(scoreInterpretation)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Spacer()
            }
            .foregroundStyle(.white.opacity(0.9))
        }
        .padding(20)
        .background(gradient)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
    
    private var scoreInterpretation: String {
        if title.contains("Today") {
            if score >= 200 { return "Excellent nutrition!" }
            else if score >= 100 { return "Good choices!" }
            else if score >= 0 { return "Room for improvement" }
            else { return "Focus on healthier options" }
        } else {
            if score >= 1000 { return "Outstanding week!" }
            else if score >= 500 { return "Good progress!" }
            else if score >= 0 { return "Keep trying!" }
            else { return "Let's improve together" }
        }
    }
}

struct TodayMealsSection: View {
    @ObservedObject var persistenceManager = MealPersistenceManager.shared
    
    var todayMeals: [MealEntry] {
        let calendar = Calendar.current
        return persistenceManager.meals.filter { calendar.isDateInToday($0.date) }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Today's Meals")
                .font(.title2)
                .fontWeight(.bold)
            
            if todayMeals.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "fork.knife.circle")
                        .font(.system(size: 48))
                        .foregroundStyle(.secondary)
                    Text("No meals logged yet today")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 32)
                .background(Color(.secondarySystemGroupedBackground))
                .cornerRadius(12)
            } else {
                VStack(spacing: 8) {
                    ForEach(todayMeals.sorted(by: { $0.mealType.rawValue < $1.mealType.rawValue })) { meal in
                        MealScoreRow(meal: meal)
                    }
                }
                .padding(12)
                .background(Color(.secondarySystemGroupedBackground))
                .cornerRadius(12)
            }
        }
    }
}

struct MealScoreRow: View {
    let meal: MealEntry
    
    var body: some View {
        HStack(spacing: 12) {
            // Meal type icon
            Image(systemName: meal.mealType.icon)
                .font(.title2)
                .foregroundStyle(scoreColor)
                .frame(width: 40)
            
            // Meal info
            VStack(alignment: .leading, spacing: 4) {
                Text(meal.mealType.displayName)
                    .font(.headline)
                
                if let foodName = meal.foodName {
                    Text(foodName)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                } else {
                    Text("Unknown food")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .italic()
                }
            }
            
            Spacer()
            
            // Score
            if let score = meal.healthScore {
                Text("\(score > 0 ? "+" : "")\(score)")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(scoreColor)
            } else {
                Text("–")
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 8)
    }
    
    private var scoreColor: Color {
        guard let score = meal.healthScore else { return .secondary }
        if score >= 70 { return .green }
        else if score >= 40 { return .blue }
        else if score >= 0 { return .orange }
        else { return .red }
    }
}

struct HealthScoreGuide: View {
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button(action: { withAnimation { isExpanded.toggle() } }) {
                HStack {
                    Text("How Scoring Works")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(.primary)
                    Spacer()
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundStyle(.secondary)
                }
            }
            
            if isExpanded {
                VStack(alignment: .leading, spacing: 16) {
                    ScoreRangeRow(
                        emoji: "🥬",
                        category: "Vegetables",
                        range: "85-95 points",
                        color: .green
                    )
                    ScoreRangeRow(
                        emoji: "🍎",
                        category: "Fruits",
                        range: "75-90 points",
                        color: .green
                    )
                    ScoreRangeRow(
                        emoji: "🍗",
                        category: "Proteins",
                        range: "60-85 points",
                        color: .blue
                    )
                    ScoreRangeRow(
                        emoji: "🍚",
                        category: "Grains",
                        range: "50-80 points",
                        color: .blue
                    )
                    ScoreRangeRow(
                        emoji: "☕️",
                        category: "Beverages",
                        range: "20-100 points",
                        color: .cyan
                    )
                    ScoreRangeRow(
                        emoji: "🍕",
                        category: "Fast Food",
                        range: "-35 to -60 points",
                        color: .orange
                    )
                    ScoreRangeRow(
                        emoji: "🍰",
                        category: "Sweets",
                        range: "-40 to -75 points",
                        color: .red
                    )
                    
                    Divider()
                        .padding(.vertical, 4)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Daily Goals")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        HStack {
                            Image(systemName: "star.fill")
                                .foregroundStyle(.green)
                            Text("200+ points: Excellent day!")
                        }
                        .font(.subheadline)
                        
                        HStack {
                            Image(systemName: "star.fill")
                                .foregroundStyle(.blue)
                            Text("100-199 points: Good choices")
                        }
                        .font(.subheadline)
                        
                        HStack {
                            Image(systemName: "star.fill")
                                .foregroundStyle(.orange)
                            Text("0-99 points: Keep improving")
                        }
                        .font(.subheadline)
                    }
                }
                .padding(.top, 8)
            }
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
}

struct ScoreRangeRow: View {
    let emoji: String
    let category: String
    let range: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Text(emoji)
                .font(.title2)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(category)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text(range)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Circle()
                .fill(color)
                .frame(width: 12, height: 12)
        }
    }
}

// MARK: - MealType Extension for Icons

extension MealType {
    var icon: String {
        switch self {
        case .breakfast: return "sunrise.fill"
        case .snackAM: return "cup.and.saucer.fill"
        case .lunch: return "sun.max.fill"
        case .snackPM: return "leaf.fill"
        case .dinner: return "moon.stars.fill"
        case .snackEvening: return "moon.fill"
        }
    }
}

#Preview {
    HealthScoreView()
}
