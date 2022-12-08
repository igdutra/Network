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
    
    init(session: URLSession = .shared) {
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
    
    func test_getFromURL_deliversError() {
        URLProtocolStub.startInterceptingRequests()
        let anyURl = anyURL()
        let anyError = anyError()
        URLProtocolStub.stub(url: anyURl, error: anyError)
        let exp = expectation(description: "Wait")
        let sut = URLSessionHTTPClient()
        
        sut.get(from: anyURl) { result in
            switch result {
            case .failure(let receivedError as NSError):
                XCTAssertEqual(receivedError.domain, anyError.domain)
                XCTAssertEqual(receivedError.code, anyError.code)
            case .success:
                XCTFail("Expected failure with error \(anyError), got \(result) instead")
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        URLProtocolStub.stopInterceptingRequests()
    }
}

// MARK: - Spy
private extension URLSessionHTTPClientTests {
    class URLProtocolStub: URLProtocol {
        private static var stubs = [URL: Stub]()
        
        struct Stub {
            var error: Error?
        }
        
        static func stub(url: URL, error: Error? = nil) {
            stubs[url] = Stub(error: error)
        }
        
        static func startInterceptingRequests() {
            URLProtocol.registerClass(URLProtocolStub.self)
        }
        
        static func stopInterceptingRequests() {
            URLProtocol.unregisterClass(URLProtocolStub.self)
            stubs = [:]
        }
        
        override class func canInit(with request: URLRequest) -> Bool {
            guard let url = request.url else { return false }
            
            return URLProtocolStub.stubs[url] != nil
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }
        
        // The startLoading() method will be called when we need to do our loading, and is where we’ll return some test data immediately.
        override func startLoading() {
            guard let url = request.url, let stub = URLProtocolStub.stubs[url] else { return }
            
            if let error = stub.error {
                client?.urlProtocol(self, didFailWithError: error)
            }
            
            client?.urlProtocolDidFinishLoading(self)
        }
        
        override func stopLoading() {}
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
