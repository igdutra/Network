//
//  URLSessionHTTPClientTests.swift
//  Essentials-NetworkTests
//
//  Created by Ivo on 08/12/22.
//

import XCTest
import Essentials_Network

class URLSessionHTTPClient: HTTPClient {
    var session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    struct UnexpectedValuesRepresentation: Error { }
    
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
        session.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
            } else if let data = data, let response = response as? HTTPURLResponse {
                completion(.success((data, response)))
            }else {
                completion(.failure(UnexpectedValuesRepresentation()))
            }
        }.resume()
    }
}

final class URLSessionHTTPClientTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        URLProtocolStub.startInterceptingRequests()
    }
    
    override func tearDown() {
        URLProtocolStub.stopInterceptingRequests()
        super.tearDown()
    }
    
    func test_getFromURL_performsGETRequestWithURL() {
        let anyURL = anyURL()
        let sut = makeSUT()
        
        let exp = expectation(description: "Wait for request")
        
        URLProtocolStub.observeRequests { request in
            XCTAssertEqual(request.url, anyURL)
            XCTAssertEqual(request.httpMethod, "GET")
            exp.fulfill()
        }
        
        sut.get(from: anyURL) { _ in }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_getFromURL_failsOnRequestError() {
        let requestError = anyNSError()
        
        let receivedError = resultErrorFor(data: nil, response: nil, error: requestError) as? NSError
        
        XCTAssertEqual(receivedError?.domain, requestError.domain)
        XCTAssertEqual(receivedError?.code, requestError.code)
    }
    
    func test_getFromURL_failsOnAllInvalidRepresentationCases() {
        XCTAssertNotNil(resultErrorFor(data: nil, response: nil, error: nil))
        XCTAssertNotNil(resultErrorFor(data: nil, response: nonHTTPURLResponse(), error: nil))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nil, error: nil))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nil, error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: nil, response: nonHTTPURLResponse(), error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: nil, response: anyHTTPURLResponse(), error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nonHTTPURLResponse(), error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: anyHTTPURLResponse(), error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nonHTTPURLResponse(), error: nil))
    }
    
    // MARK: Happy Path
    func test_getFromURL_succeedsOnHTTPURLResponseWithData() {
        let data = anyData()
        let response = anyHTTPURLResponse()
        
        let receivedValues = resultValuesFor(data: data, response: response)
        
        XCTAssertEqual(receivedValues?.data, data)
        XCTAssertEqual(receivedValues?.response?.url, response.url)
        XCTAssertEqual(receivedValues?.response?.statusCode, response.statusCode)
    }
    
    // This was made out of a validation of the framework, and it demostrated how the framework was replacing the nil Data with a actually valid Empty representation from Data
    // And this is a valid scenario, 304, etc.
    func test_getFromURL_succeedsWithEmptyDataOnHTTPURLResponseWithNilData() {
        let response = anyHTTPURLResponse()
        let emptyData = Data()
        
        let receivedValues = resultValuesFor(data: nil, response: response)
        
        XCTAssertEqual(receivedValues?.data, emptyData)
        XCTAssertEqual(receivedValues?.response?.url, response.url)
        XCTAssertEqual(receivedValues?.response?.statusCode, response.statusCode)
    }
}

// MARK: - Spy
private extension URLSessionHTTPClientTests {
    class URLProtocolStub: URLProtocol {
        private static var requestObserver: ((URLRequest) -> Void)?
        private static var stub: Stub?
        
        struct Stub {
            var data: Data?
            var response: URLResponse?
            var error: Error?
        }
        
        static func stub(data: Data?, response: URLResponse?, error: Error? = nil) {
            stub = Stub(data: data, response: response, error: error)
        }
        
        static func observeRequests(observer: @escaping (URLRequest) -> Void) {
            requestObserver = observer
        }
        
        static func startInterceptingRequests() {
            URLProtocol.registerClass(URLProtocolStub.self)
        }
        
        static func stopInterceptingRequests() {
            URLProtocol.unregisterClass(URLProtocolStub.self)
            stub = nil
            requestObserver = nil
        }
        
        // MARK: Abstract Class Methods
        
        override class func canInit(with request: URLRequest) -> Bool {
            requestObserver?(request)
            return true
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }
        
        // The startLoading() method will be called when we need to do our loading, and is where we’ll return some test data immediately.
        override func startLoading() {
            if let data = URLProtocolStub.stub?.data {
                client?.urlProtocol(self, didLoad: data)
            }
            
            if let response = URLProtocolStub.stub?.response {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            
            if let error = URLProtocolStub.stub?.error {
                client?.urlProtocol(self, didFailWithError: error)
            }
            
            client?.urlProtocolDidFinishLoading(self)
        }
        
        override func stopLoading() {}
    }
}

// MARK: - Helpers
private extension URLSessionHTTPClientTests {
    
    // MARK: Factories
    func makeSUT(file: StaticString = #file, line: UInt = #line) -> HTTPClient {
        let sut = URLSessionHTTPClient()
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
    
    // MARK: Stubs
    // TODO: why you can't use anyURL as default paramether?
    func anyURL(_ differentText: String = "a-url") -> URL {
        URL(string: differentText + ".com")!
    }
    
    func anyNSError() -> NSError {
        NSError(domain: "any error", code: 1)
    }
    
    func anyData() -> Data {
        return Data("any data".utf8)
    }
    
    func anyHTTPURLResponse() -> HTTPURLResponse {
        return HTTPURLResponse(url: anyURL(), statusCode: 200, httpVersion: nil, headerFields: nil)!
    }
    
    func nonHTTPURLResponse() -> URLResponse {
        return URLResponse(url: anyURL(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
    }
    
    // MARK: Helpers
    
    /*
     So First there was only one helper, resultErrorFor
     then there was the resultValues for
     
     then saw the duplication code between the helpers, and then refactored it to use just one thing.
     */
    
    func resultValuesFor(data: Data?, response: URLResponse?, error: Error? = nil, file: StaticString = #file, line: UInt = #line) -> (data: Data, response: HTTPURLResponse?)? {
        let result = resultFor(data: data, response: response, error: error)
        
        switch result {
        case .success((let data, let response)):
            return (data, response)
        default:
            XCTFail("Expected success, got \(String(describing: result)) instead", file: file, line: line)
            return nil
        }
    }
    
    func resultErrorFor(data: Data?, response: URLResponse?, error: Error? = nil, file: StaticString = #file, line: UInt = #line) -> Error? {
        let result = resultFor(data: data, response: response, error: error)
        
        switch result {
        case .failure(let error):
            return error
        default:
            XCTFail("Expected failure, got \(String(describing: result)) instead", file: file, line: line)
            return nil
        }
    }
    
    func resultFor(data: Data?, response: URLResponse?, error: Error?, file: StaticString = #file, line: UInt = #line) -> HTTPClientResult? {
        URLProtocolStub.stub(data: data, response: response, error: error)
        
        let sut = makeSUT(file: file, line: line)
        
        let exp = expectation(description: "Wait")
        
        var receivedResult: HTTPClientResult?
        
        sut.get(from: anyURL()) { result in
            switch result {
            case .failure(let error):
                receivedResult = .failure(error)
            case .success((let data, let response)):
                receivedResult = .success((data, response))
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        return receivedResult
    }
}
