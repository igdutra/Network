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
    
    internal static func map(_ data: Data, _ response: HTTPURLResponse) throws -> [FeedItem] {
        guard response.statusCode == OK_200 else {
            throw RemoteFeedLoader.Error.invalidData
        }
        
        let feed = try JSONDecoder().decode(Feed.self, from: data)
        return feed.items.map { $0.item }
    }
}
