//
//  FeedLoader.swift
//  Network-Essentials
//
//  Created by Ivo on 14/11/22.
//

import Foundation

//public enum LoadFeedResult {
//    case success([FeedItem])
//    case error(Error)
//}

public typealias LoadFeedResult = Result<[FeedItem], Error>

public protocol FeedLoader {
    func load(completion: @escaping (LoadFeedResult) -> Void)
}
