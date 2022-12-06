//
//  RemoteFeedLoader.swift
//  Essentials-Network
//
//  Created by Ivo on 21/11/22.
//

import Foundation

public final class RemoteFeedLoader {
    private let client: HTTPClient
    private let url: URL
    
    public enum Error: Swift.Error {
       case connectivity
       case invalidData
    }
    
    public typealias Result = Swift.Result<[FeedItem], RemoteFeedLoader.Error>
    
    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    // MARK: - Methods
    
    public func load(completion: @escaping (Result) -> Void) {
        client.get(from: url) { result in
            switch result {
            case .success((let data, let response)):
                completion(FeedItemsMapper.map(data, response))
            case .failure:
                completion(.failure(.connectivity))
            }
        }
    }
}
