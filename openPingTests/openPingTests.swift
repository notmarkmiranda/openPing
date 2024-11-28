//
//  openPingTests.swift
//  openPingTests
//
//  Created by Mark Miranda on 11/24/24.
//

import Foundation

extension URLSession {
  static func mockSession() -> URLSession {
    let config = URLSessionConfiguration.ephemeral
    config.protocolClasses = [MockURLProtocol.self]
    return URLSession(configuration: config)
  }
}
