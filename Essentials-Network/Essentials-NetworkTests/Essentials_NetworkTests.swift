//
//  Essentials_NetworkTests.swift
//  Essentials-NetworkTests
//
//  Created by Ivo on 14/11/22.
//

import XCTest
import Essentials_Network

final class Essentials_NetworkTests: XCTestCase {

    // Simple test to configure CI
    func test_publicStruct() {
        let item = FeedItem(id: UUID(), imageURL: anyURL())
        
        XCTAssertEqual(anyURL(), item.imageURL)
    }
    
    // MARK: - Helpers
    
    func anyURL() -> URL {
        URL(string: "any-url.com")!
    }
}
