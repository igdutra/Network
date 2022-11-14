//
//  FeedLoader.swift
//  Network-Essentials
//
//  Created by Ivo on 14/11/22.
//

import Foundation

enum LoadFeedResult {
    case success([FeedItem])
    case error(Error)
}

protocol FeedLoader {
    func load(completion: @escaping (LoadFeedResult) -> Void)
}
