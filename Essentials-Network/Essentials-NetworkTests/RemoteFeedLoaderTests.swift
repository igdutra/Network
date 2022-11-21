//
//  RemoteFeedLoaderTests.swift
//  Essentials-NetworkTests
//
//  Created by Ivo on 19/11/22.
//

import XCTest
import Essentials_Network

final class RemoteFeedLoaderTests: XCTestCase {

    func test_init_doesNotRequestDataFromURL() {
        let (_, client) = makeSUT()
        
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_load_requestsDataFromURL() {
        let url = URL(string: "a-different-url.com")!
        let (sut, client) = makeSUT(url: url)
        
        sut.load()
        
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_load_requestsDataFromURLTwice() {
        let url = URL(string: "a-different-url.com")!
        let (sut, client) = makeSUT(url: url)
        
        sut.load()
        sut.load()
        
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    func test_load_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
        var capturedErrors: [RemoteFeedLoader.Error?] = []
        
        sut.load { capturedErrors.append($0) }
        
        let clientError = NSError(domain: "Test", code: 0)
        client.complitions[0](clientError)
        
        XCTAssertEqual(capturedErrors, [.connectivity])
    }
}

// MARK: - Helpers
private extension RemoteFeedLoaderTests {
    
    // MARK: Spy
    
    class HTTPClientSpy: HTTPClient {
        var requestedURLs = [URL]()
        var error: Error?
        var complitions = [(Error) -> Void]()
        
        func get(from url: URL) {
            requestedURLs.append(url)
        }
        
        func get(from url: URL, completion: @escaping (Error) -> Void) {
            complitions.append(completion)
            requestedURLs.append(url)
        }
    }
    
    // MARK: Factories
    
    func makeSUT(url: URL = URL(string: "a-url.com")!) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        return (sut, client)
    }
    
    // TODO: why you can't use anyURL as default paramether?
    func anyURL() -> URL {
        URL(string: "a-url.com")!
    }
}
