//
//  SettingsView.swift
//  nouri
//
//  Created by Chan Ching Hei on 17/12/2025.
//

import SwiftUI

struct SettingsView: View {
    @StateObject private var persistenceManager = MealPersistenceManager.shared
    @State private var showingClearDataAlert = false
    
    var body: some View {
        NavigationView {
            List {
                // App Info Section
                Section {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Logged Meals")
                        Spacer()
                        Text("\(persistenceManager.meals.count)")
                            .foregroundColor(.secondary)
                    }
                } header: {
                    Text("App Information")
                }
                
                // Data Management Section
                Section {
                    Button(role: .destructive) {
                        showingClearDataAlert = true
                    } label: {
                        HStack {
                            Image(systemName: "trash")
                            Text("Clear All Data")
                        }
                    }
                } header: {
                    Text("Data Management")
                } footer: {
                    Text("This will permanently delete all logged meals and photos.")
                }
                
                // About Section
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("About Nouri")
                            .font(.headline)
                        
                        Text("A simple, mindful way to track your daily meals with photos. Focus on consistency and progress, not perfection.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Settings")
            .alert("Clear All Data", isPresented: $showingClearDataAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Clear", role: .destructive) {
                    clearAllData()
                }
            } message: {
                Text("Are you sure you want to delete all logged meals and photos? This action cannot be undone.")
            }
        }
    }
    
    private func clearAllData() {
        // Delete all meals (which will also delete associated images)
        let allMeals = persistenceManager.meals
        for meal in allMeals {
            persistenceManager.deleteMeal(meal)
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}

