//
//  SiteDataManager.swift
//  openPing
//
//  Created by Mark Miranda on 11/27/24.
//

import Foundation

class SiteDataManager {
  // Singleton instance for global access
  static let shared = SiteDataManager()
  
  // File path for storing sites.json in Documents directory
  private let savePath = FileManager.documentsDirectory.appendingPathComponent("sites.json")
  
  private init() {}
  
  // Load sites from the JSON file
  func loadSites() -> [Site] {
    do {
      let data = try Data(contentsOf: savePath)
      let decodedSites = try JSONDecoder().decode([Site].self, from: data)
      return decodedSites
    } catch {
      print("Failed to load sites: \(error.localizedDescription)")
      return []
    }
  }
  
  // Save sites to the JSON file
  func saveSites(_ sites: [Site]) {
    do {
      let data = try JSONEncoder().encode(sites)
      try data.write(to: savePath, options: [.atomicWrite, .completeFileProtection])
      print("Sites sucessfully saved.")
    } catch {
      print("Failed to save sites: \(error.localizedDescription)")
    }
  }
}

extension FileManager {
  static var documentsDirectory: URL {
    return Self.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
  }
}
