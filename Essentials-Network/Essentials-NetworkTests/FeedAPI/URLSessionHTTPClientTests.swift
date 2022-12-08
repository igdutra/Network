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
        session.dataTask(with: url) { _, _, _ in }.resume()
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
}

// MARK: - Spy
private extension URLSessionHTTPClientTests {
    class URLSessionSpy: URLSession {
        private var stubs = [URL: URLSessionDataTask]()
        
        func stub(url: URL, task: URLSessionDataTask) {
            stubs[url] = task
        }
        
        override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
            return stubs[url] ?? FakeURLSessionDataTask()
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
}
