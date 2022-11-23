//
//  RemoteFeedLoader.swift
//  Essentials-Network
//
//  Created by Ivo on 21/11/22.
//

import Foundation

public typealias HTTPClientResult = Result<(Data, HTTPURLResponse), Error>

public protocol HTTPClient {
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void)
}

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
            case .success((let data, _)):
                if let feed = try? JSONDecoder().decode(Feed.self, from: data) {
                    completion(.success(feed.items))
                } else {
                    completion(.failure(.invalidData))
                }
            case .failure:
                completion(.failure(.connectivity))
            }
        }
    }
}

private struct Feed: Decodable {
    let items: [FeedItem]
}
