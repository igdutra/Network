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
               toCompleteWithResut: .failure(.connectivity),
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
                   toCompleteWithResut: .failure(.invalidData),
                   when: {
                client.complete(withStatusCode: code, at: index)
            })
        }
    }
    
    func test_load_whenHTTPResponseIs200_deliversError() {
        let (sut, client) = makeSUT()
        
        expect(sut,
               toCompleteWithResut: .failure(.invalidData),
               when: {
            let invalidJSON = invalidJSON()
            client.complete(withStatusCode: 200, data: invalidJSON)
        })
    }
    
    func test_load_Success_whenHTTPResponseIs200AndEmptyJson() {
        let (sut, client) = makeSUT()
        
        expect(sut,
               toCompleteWithResut: .success([]),
               when: {
            let emptyJSON = emptyItemsJSON()
            client.complete(withStatusCode: 200, data: emptyJSON)
        })
    }
    
    func test_load_whenHTTPResponseIs200_deliversItemsArray() {
        let (sut, client) = makeSUT()
        
        let item1 = FeedItem(id: UUID(),
                            description: "A description",
                            location: "A location",
                            imageURL: anyURL())
        
        let item2 = FeedItem(id: UUID(),
                            imageURL: anyURL("anotherURL"))
        
        let item1JSON = [
            "id": item1.id.uuidString,
            "description": item1.description,
            "location": item1.location,
            "image": item1.imageURL.absoluteString
        ]
        
        let item2JSON = [
            "id": item2.id.uuidString,
            "image": item2.imageURL.absoluteString
        ]
        
        let finalJSON = [
            "items": [item1JSON, item2JSON]
        ]
        
        expect(sut,
               toCompleteWithResut: .success([item1, item2]),
               when: {
            let json = try! JSONSerialization.data(withJSONObject: finalJSON)
            client.complete(withStatusCode: 200, data: json)
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
                toCompleteWithResut result: RemoteFeedLoader.Result,
                when action: () -> Void,
                file: StaticString = #filePath, line: UInt = #line) {
        var capturedResults: [RemoteFeedLoader.Result?] = []
        sut.load { capturedResults.append($0) }
        
        action()
        
        XCTAssertEqual(capturedResults, [result], file: file, line: line)
    }
    
    // MARK: Stubs
    
    // TODO: why you can't use anyURL as default paramether?
    func anyURL(_ differentText: String = "a-url") -> URL {
        URL(string: differentText + ".com")!
    }
    
    func invalidJSON() -> Data {
        Data("invalid json".utf8)
    }
    
    func emptyItemsJSON() -> Data {
        Data("{\"items\": []}".utf8)
    }
}
