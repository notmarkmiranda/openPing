import XCTest
@testable import openPing

// Mock URLSession for testing
class MockURLSession: URLSessionProtocol {
    var data: Data?
    var response: URLResponse?
    var error: Error?

    func data(from url: URL) async throws -> (Data, URLResponse) {
        if let error = error {
            throw error
        }
        return (data ?? Data(), response ?? HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!)
    }
}

final class SiteTests: XCTestCase {
    var mockSession: MockURLSession!

    override func setUp() {
        super.setUp()
        mockSession = MockURLSession()
    }

    override func tearDown() {
        mockSession = nil
        super.tearDown()
    }

    func testSiteInitialization() {
        let site = Site(url: "https://example.com", frequency: 30)

        XCTAssertNotNil(site.id)
        XCTAssertEqual(site.url, "https://example.com")
        XCTAssertEqual(site.frequency, 30)
        XCTAssertFalse(site.isSuccess)
        XCTAssertTrue(site.isActive)
        XCTAssertNil(site.lastPingedAt)
    }

    func testStatusColorWhenInactive() {
        let site = Site(url: "https://example.com", frequency: 30, isActive: false)
        XCTAssertEqual(site.statusColor, .yellow)
    }

    func testStatusColorWhenSuccessful() {
        let site = Site(url: "https://example.com", frequency: 30, isSuccess: true)
        XCTAssertEqual(site.statusColor, .green)
    }

    func testStatusColorWhenFailed() {
        let site = Site(url: "https://example.com", frequency: 30, isSuccess: false)
        XCTAssertEqual(site.statusColor, .red)
    }

    func testPingWithSuccessfulResponse() async {
        let url = "https://example.com"
        let site = Site(url: url, frequency: 30, session: mockSession)

        // Setup mock response
        mockSession.response = HTTPURLResponse(
            url: URL(string: url)!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )

        let updatedSite = await site.ping()

        XCTAssertTrue(updatedSite.isSuccess)
        XCTAssertNotNil(updatedSite.lastPingedAt)
    }

    func testPingWithFailedResponse() async {
        let url = "https://example.com"
        let site = Site(url: url, frequency: 30, session: mockSession)

        // Setup mock response
        mockSession.response = HTTPURLResponse(
            url: URL(string: url)!,
            statusCode: 404,
            httpVersion: nil,
            headerFields: nil
        )

        let updatedSite = await site.ping()

        XCTAssertFalse(updatedSite.isSuccess)
        XCTAssertNotNil(updatedSite.lastPingedAt)
    }

    func testPingWithNetworkError() async {
        let url = "https://example.com"
        let site = Site(url: url, frequency: 30, session: mockSession)

        // Setup mock error
        struct NetworkError: Error {}
        mockSession.error = NetworkError()

        let updatedSite = await site.ping()

        XCTAssertFalse(updatedSite.isSuccess)
        XCTAssertNotNil(updatedSite.lastPingedAt)
    }

    func testPingWithInvalidURL() async {
        // Given: A site with an invalid URL and NO mock session
        let site = Site(url: "not a valid url", frequency: 30)

        // When: We ping the site
        let updatedSite = await site.ping()

        // Then: The site should fail
        XCTAssertFalse(updatedSite.isSuccess, "Site with invalid URL should have isSuccess = false")
        XCTAssertNotNil(updatedSite.lastPingedAt, "Site should have a lastPingedAt timestamp")
    }
}
