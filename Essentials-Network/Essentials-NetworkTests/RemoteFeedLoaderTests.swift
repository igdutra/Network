//
//  RemoteFeedLoaderTests.swift
//  Essentials-NetworkTests
//
//  Created by Ivo on 19/11/22.
//

import XCTest

class RemoteFeedLoader {}

class HTTPClient {
    var requestedURL: URL?
}

final class RemoteFeedLoaderTests: XCTestCase {

    func test_init_doesNotRequestDataFromURL() {
        let client = HTTPClient()
        _ = RemoteFeedLoader()
        
        XCTAssertNil(client.requestedURL)
    }
}
