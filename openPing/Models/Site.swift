//
//  Site.swift
//  openPing
//
//  Created by Mark Miranda on 11/27/24.
//

import Foundation
import SwiftUI

// MARK: URLSessionProtocol Definition

protocol URLSessionProtocol {
  func data(from url: URL) async throws -> (Data, URLResponse)
}

extension URLSession: URLSessionProtocol {}

// MARK: Site Struct

struct Site: Identifiable, Hashable, Codable {
  let id: UUID
  let url: String
  let frequency: Int
  var isSuccess: Bool
  var isActive: Bool
  var lastPingedAt: Date?
  
  private var session: URLSessionProtocol
  
  enum CodingKeys: String, CodingKey {
    case id, url, frequency, isSuccess, isActive, lastPingedAt
  }
  
  init(id: UUID = UUID(),
       url: String,
       frequency: Int,
       isSuccess: Bool = false,
       isActive: Bool = true,
       lastPingedAt: Date? = nil,
       session: URLSessionProtocol = URLSession.shared) {
    self.id = id
    self.url = url
    self.frequency = frequency
    self.isSuccess = isSuccess
    self.isActive = isActive
    self.lastPingedAt = lastPingedAt
    self.session = session
  }
  
  //Custom decoder
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    id = try container.decode(UUID.self, forKey: .id)
    url = try container.decode(String.self, forKey: .url)
    frequency = try container.decode(Int.self, forKey: .frequency)
    isSuccess = try container.decode(Bool.self, forKey: .isSuccess)
    isActive = try container.decode(Bool.self, forKey: .isActive)
    lastPingedAt = try container.decodeIfPresent(Date.self, forKey: .lastPingedAt)
    session = URLSession.shared
  }
  
  //Custom encoder
  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(id, forKey: .id)
    try container.encode(url, forKey: .url)
    try container.encode(frequency, forKey: .frequency)
    try container.encode(isSuccess, forKey: .isSuccess)
    try container.encode(isActive, forKey: .isActive)
    try container.encodeIfPresent(lastPingedAt, forKey: .lastPingedAt)
  }
  
  // MARK: - Equatable Conformance
  static func == (lhs: Site, rhs: Site) -> Bool {
    return lhs.id == rhs.id &&
           lhs.url == rhs.url &&
           lhs.frequency == rhs.frequency &&
           lhs.isSuccess == rhs.isSuccess &&
           lhs.isActive == rhs.isActive &&
           lhs.lastPingedAt == rhs.lastPingedAt
  }
  
  // MARK: - Hashable Conformance
  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
    hasher.combine(url)
    hasher.combine(frequency)
    hasher.combine(isSuccess)
    hasher.combine(isActive)
    hasher.combine(lastPingedAt)
  }
  
  // MARK: - Ping Method

  func ping() async -> Site {
    var updatedSite = self
    guard let url = URL(string: self.url) else {
      updatedSite.isSuccess = false
      updatedSite.lastPingedAt = Date()
      return updatedSite
    }
    
    do {
      let(_, response) = try await session.data(from: url)
      
      if let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) {
        updatedSite.isSuccess = true
      } else {
        updatedSite.isSuccess = false
      }
    } catch {
      updatedSite.isSuccess = false
    }
    
    updatedSite.lastPingedAt = Date()
    return updatedSite
  }
}

extension Site {
  var statusColor: Color {
    if !isActive {
      return .yellow
    }
    return isSuccess ? .green : .red
  }
}
