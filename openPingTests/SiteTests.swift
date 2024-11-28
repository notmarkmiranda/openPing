//
//  SiteTests.swift
//  openPing
//
//  Created by Mark Miranda on 11/27/24.
//

// SiteTests.swift
import XCTest
@testable import openPing

class SiteTests: XCTestCase {
  
  var mockSession: MockURLSessionProtocol!
  var site: Site!
  
  override func setUp() {
    super.setUp()
    mockSession = MockURLSessionProtocol()
  }
  
  override func tearDown() {
    mockSession = nil
    site = nil
    super.tearDown()
  }
  
  // Test successful ping with 200 status code
  func testPingSuccess() async throws {
    // Arrange
    let testURL = "https://google.com"
    site = Site(url: testURL, frequency: 30, session: mockSession)
    
    // Set up mock response
    let url = URL(string: testURL)!
    mockSession.response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)
    mockSession.data = nil // No data needed for ping
    
    // Act
    await site.ping()
    
    // Assert
    XCTAssertTrue(site.isSuccess, "Ping should be successful for status code 200")
    XCTAssertNotNil(site.lastPingedAt, "lastPingedAt should be updated")
  }
  
  // Test failed ping with 500 status code
  func testPingFailureWithServerError() async throws {
    // Arrange
    let testURL = "https://aol.com"
    site = Site(url: testURL, frequency: 60, session: mockSession)
    
    // Set up mock response
    let url = URL(string: testURL)!
    mockSession.response = HTTPURLResponse(url: url, statusCode: 500, httpVersion: nil, headerFields: nil)
    mockSession.data = nil
    
    // Act
    await site.ping()
    
    // Assert
    XCTAssertFalse(site.isSuccess, "Ping should fail for status code 500")
    XCTAssertNotNil(site.lastPingedAt, "lastPingedAt should be updated")
  }
  
  // Test ping with invalid URL
  func testPingWithInvalidURL() async throws {
    // Arrange
    let invalidURL = "ht!tp://invalid-url"
    site = Site(url: invalidURL, frequency: 45, session: mockSession)
    
    // No need to set mockSession as the URL is invalid and no request is made
    
    // Act
    await site.ping()
    
    // Assert
    XCTAssertFalse(site.isSuccess, "Ping should fail for an invalid URL")
    XCTAssertNotNil(site.lastPingedAt, "lastPingedAt should be updated")
  }
  
  // Test ping with network error
  func testPingWithNetworkError() async throws {
    // Arrange
    let testURL = "https://example.com"
    site = Site(url: testURL, frequency: 30, session: mockSession)
    
    // Set up mock error
    let networkError = NSError(domain: "NetworkError", code: -1009, userInfo: nil) // e.g., no internet connection
    mockSession.error = networkError
    
    // Act
    await site.ping()
    
    // Assert
    XCTAssertFalse(site.isSuccess, "Ping should fail due to network error")
    XCTAssertNotNil(site.lastPingedAt, "lastPingedAt should be updated")
  }
}
