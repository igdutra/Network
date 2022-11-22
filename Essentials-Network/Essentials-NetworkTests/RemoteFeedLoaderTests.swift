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
        
        sut.load { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_load_requestsDataFromURLTwice() {
        let url = URL(string: "a-different-url.com")!
        let (sut, client) = makeSUT(url: url)
        
        sut.load { _ in }
        sut.load { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    func test_load_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
        
        expect(sut,
               toCompleteWithError: .connectivity,
               when: {
            let clientError = NSError(domain: "Test", code: 0)
            client.complete(with: clientError)
        })
    }
    
    // This was a request in the user story
    func test_load_deliversErrorOnNon200HTTPResponse() {
        let (sut, client) = makeSUT()
        
        let samples = [199, 201, 300, 400, 500]
        
        samples.enumerated().forEach { index, code in
            expect(sut,
                   toCompleteWithError: .invalidData,
                   when: {
                client.complete(withStatusCode: code, at: index)
            })
        }
    }
    
    func test_load_whenHTTPResponseIs200_deliversError() {
        let (sut, client) = makeSUT()
        
        expect(sut,
               toCompleteWithError: .invalidData,
               when: {
            let invalidJSON = invalidJSON()
            client.complete(withStatusCode: 200, data: invalidJSON)
        })
    }
}

// MARK: - Spy
private extension RemoteFeedLoaderTests {
    class HTTPClientSpy: HTTPClient {
        var messages = [(url: URL, completion: (HTTPClientResult) -> Void)]()
        
        // This way you don't break the current tests
        var requestedURLs: [URL] {
            messages.map { $0.url }
        }
        
        func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
            messages.append((url, completion))
        }
        
        func complete(with error: Error, at index: Int = 0) {
            messages[index].completion(.failure(error))
        }
        
        func complete(withStatusCode code: Int,
                      data: Data = Data(),
                      at index: Int = 0) {
            let response = HTTPURLResponse(url: requestedURLs[index],
                                           statusCode: code,
                                           httpVersion: nil,
                                           headerFields: nil)!
            
            messages[index].completion(.success((data, response)))
        }
    }
}

// MARK: - Helpers
private extension RemoteFeedLoaderTests {
    
    // MARK: Factories
    
    func makeSUT(url: URL = URL(string: "a-url.com")!) -> (sut: RemoteFeedLoader,
                                                           client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        return (sut, client)
    }
    
    func expect(_ sut: RemoteFeedLoader,
                toCompleteWithError error: RemoteFeedLoader.Error,
                when action: () -> Void,
                file: StaticString = #filePath, line: UInt = #line) {
        var capturedResults: [RemoteFeedLoader.Result?] = []
        sut.load { capturedErrors.append($0) }
        
        action()
        
        XCTAssertEqual(capturedErrors, [.failure(error)], file: file, line: line)
    }
    
    // MARK: Stubs
    
    // TODO: why you can't use anyURL as default paramether?
    func anyURL() -> URL {
        URL(string: "a-url.com")!
    }
    
    func invalidJSON() -> Data {
        Data("invalid json".utf8)
    }
}
