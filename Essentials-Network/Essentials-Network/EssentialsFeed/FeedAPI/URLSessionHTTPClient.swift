//
//  URLSessionHTTPClient.swift
//  Essentials-Network
//
//  Created by Ivo on 12/12/22.
//

import Foundation

public class URLSessionHTTPClient: HTTPClient {
    private var session: URLSession
    
    public init(session: URLSession = .shared) {
        self.session = session
    }
    
    public func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
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

// MARK: - Extension
private extension URLSessionHTTPClient {
    struct UnexpectedValuesRepresentation: Error { }
}
