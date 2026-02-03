//
//  EnvConfig.swift
//  nouri
//
//  Created for environment variable management
//

import Foundation

class EnvConfig {
    static let shared = EnvConfig()
    
    private var config: [String: String] = [:]
    
    private init() {
        loadConfiguration()
    }
    
    private func loadConfiguration() {
        // Priority 1: Try to load from Config.plist (bundled with app)
        if let plistPath = Bundle.main.path(forResource: "Config", ofType: "plist"),
           let plistDict = NSDictionary(contentsOfFile: plistPath) as? [String: Any] {
            print("✅ Loaded configuration from Config.plist")
            for (key, value) in plistDict {
                if let stringValue = value as? String {
                    config[key] = stringValue
                }
            }
            print("📋 Loaded \(config.count) configuration values")
            return
        }
        
        // Priority 2: Try to load from .env file (for local development)
        loadEnvFile()
        
        if config.isEmpty {
            print("ℹ️ No configuration found - using defaults")
        }
    }
    
    private func loadEnvFile() {
        // Try to find .env file in the project directory
        let possiblePaths = [
            Bundle.main.bundlePath + "/.env",
            Bundle.main.bundlePath + "/../../.env",
            FileManager.default.currentDirectoryPath + "/.env"
        ]
        
        var envContent: String?
        var foundPath: String?
        
        for path in possiblePaths {
            if let content = try? String(contentsOfFile: path, encoding: .utf8) {
                envContent = content
                foundPath = path
                break
            }
        }
        
        guard let content = envContent else {
            return
        }
        
        print("✅ Loaded .env file from: \(foundPath ?? "unknown")")
        
        // Parse .env file
        let lines = content.components(separatedBy: .newlines)
        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            
            // Skip comments and empty lines
            if trimmed.isEmpty || trimmed.hasPrefix("#") {
                continue
            }
            
            // Parse KEY=VALUE
            let parts = trimmed.components(separatedBy: "=")
            if parts.count >= 2 {
                let key = parts[0].trimmingCharacters(in: .whitespaces)
                let value = parts[1...].joined(separator: "=").trimmingCharacters(in: .whitespaces)
                config[key] = value
            }
        }
        
        print("📋 Loaded \(config.count) environment variables from .env")
    }
    
    func get(_ key: String, default defaultValue: String = "") -> String {
        return config[key] ?? defaultValue
    }
    
    func has(_ key: String) -> Bool {
        return config[key] != nil
    }
}
