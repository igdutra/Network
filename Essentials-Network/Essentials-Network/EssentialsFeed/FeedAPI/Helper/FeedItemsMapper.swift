//
//  FeedItemsMapper.swift
//  Essentials-Network
//
//  Created by Ivo on 24/11/22.
//

import Foundation

// 1 - I forgt to make it internal
internal struct FeedItemsMapper {
    
    private struct Feed: Decodable {
        let items: [Item]
        
        var feedItems: [FeedItem] {
            items.map { $0.item }
        }
    }

    /// This is done in order to: the API DETAILS ARE PRIVATE, separated from the FeedLoader protocol
    private struct Item: Decodable {
        let id: UUID
        let description: String?
        let location: String?
        let image: URL
        
        var item: FeedItem {
            FeedItem(id: id, description: description, location: location, imageURL: image)
        }
    }
    
    private static var OK_200: Int { 200 }
    
    // Replace the throw for the already correct result return
    internal static func map(_ data: Data, _ response: HTTPURLResponse) -> RemoteFeedLoader.Result {
        guard response.statusCode == OK_200,
              let feed = try? JSONDecoder().decode(Feed.self, from: data) else {
            return .failure(.invalidData)
        }
        
        return .success(feed.feedItems)
    }
}
