//
//  RemoteFeedLoaderTests.swift
//  Essentials-NetworkTests
//
//  Created by Ivo on 19/11/22.
//

import XCTest

class RemoteFeedLoader {
    func load() {
        HTTPClient.shared.requestedURL = URL(string: "a-url.com")!
    }
}

class HTTPClient {
    static let shared = HTTPClient()
    
    private init() { }
    
    var requestedURL: URL?
}

final class RemoteFeedLoaderTests: XCTestCase {

    func test_init_doesNotRequestDataFromURL() {
        let client = HTTPClient.shared
        _ = RemoteFeedLoader()
        
        XCTAssertNil(client.requestedURL)
    }
    
    func test_load_requestDataFromURL() {
        let client = HTTPClient.shared
        let sut = RemoteFeedLoader()
        
        sut.load()
        
        XCTAssertNotNil(client.requestedURL)
    }
}

// MARK: - Helpers
private extension RemoteFeedLoaderTests {
    func anyURL() -> URL {
        URL(string: "a-url.com")!
    }
}
