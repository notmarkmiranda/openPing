//
//  MockURLProtocol.swift
//  openPing
//
//  Created by Mark Miranda on 11/27/24.
//

import Foundation

class MockURLProtocol: URLProtocol {
  // This closure will be used to return mock responses
  static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data?))?
  
  override class func canInit(with request: URLRequest) -> Bool {
    // Handle all types of requests
    return true
  }
  
  override class func canonicalRequest(for request: URLRequest) -> URLRequest {
    return request
  }
  
  override func startLoading() {
    guard let handler = MockURLProtocol.requestHandler else {
      fatalError("Handler is unavailable.")
    }
    
    do {
      // Call the handler to get the mock response and data
      let (response, data) = try handler(request)
      
      // Send the mock response
      client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
      
      // Send the mock data if available
      if let data = data {
        client?.urlProtocol(self, didLoad: data)
      }
      
      // Notify that the request has finished loading
      client?.urlProtocolDidFinishLoading(self)
    } catch {
      // Notify of the failure
      client?.urlProtocol(self, didFailWithError: error)
    }
  }
  
  override func stopLoading() {
    // Required method; no implementation needed for this mock
  }
}
