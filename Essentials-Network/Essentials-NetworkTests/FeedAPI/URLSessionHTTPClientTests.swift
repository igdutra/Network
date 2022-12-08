//
//  URLSessionHTTPClientTests.swift
//  Essentials-NetworkTests
//
//  Created by Ivo on 08/12/22.
//

import XCTest
import Essentials_Network

class URLSessionHTTPClient {
    var session: URLSession
    
    init(session: URLSession) {
        self.session = session
    }
    
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
        session.dataTask(with: url) { _, _, error in
            if let error = error {
                completion(.failure(error))
            }
        }.resume()
    }
}

final class URLSessionHTTPClientTests: XCTestCase {
    
    func test_getFromURL_resumesDataTaskWithURL() {
        let anyURl = anyURL()
        let session = URLSessionSpy()
        let dataTaskSpy = URLSessionDataTaskSpy()
        session.stub(url: anyURl, task: dataTaskSpy)
        let sut = URLSessionHTTPClient(session: session)
        
        sut.get(from: anyURl) { _ in }
        
        XCTAssertEqual(dataTaskSpy.messages, [.resume])
    }
    
    func test_getFromURL_deliversError() {
        let anyURl = anyURL()
        let session = URLSessionSpy()
        let anyError = anyError()
        session.stub(url: anyURl, error: anyError)
        let exp = expectation(description: "Wait")
        let sut = URLSessionHTTPClient(session: session)
        
        sut.get(from: anyURl) { result in
            switch result {
            case .failure(let receivedError as NSError):
                XCTAssertEqual(receivedError, anyError)
            case .success:
                XCTFail("Expected failure with error \(anyError), got \(result) instead")
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
}

// MARK: - Spy
private extension URLSessionHTTPClientTests {
    class URLSessionSpy: URLSession {
        private var stubs = [URL: Stub]()
        
        struct Stub {
            var task: URLSessionDataTask
            var error: Error?
        }
        
        func stub(url: URL, task: URLSessionDataTask = FakeURLSessionDataTask(), error: Error? = nil) {
            stubs[url] = Stub(task: task, error: error)
        }
        
        override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
            guard let stub = stubs[url] else {
                fatalError("Where is the Stub")
            }

            completionHandler(nil, nil, stub.error)
            return stub.task
        }
    }
    
    // Mocking classes you don't own...
    class FakeURLSessionDataTask: URLSessionDataTask {
        override func resume() { }
    }
    
    class URLSessionDataTaskSpy: URLSessionDataTask {
        enum Method {
            case resume
        }
        
        var messages: [Method] = []
        
        override func resume() {
            messages.append(.resume)
        }
    }
}

// MARK: - Helpers
private extension URLSessionHTTPClientTests {
    
    // MARK: Stubs
    // TODO: why you can't use anyURL as default paramether?
    func anyURL(_ differentText: String = "a-url") -> URL {
        URL(string: differentText + ".com")!
    }
    
    func anyError() -> NSError {
        NSError(domain: "any error", code: 1)
    }
}
