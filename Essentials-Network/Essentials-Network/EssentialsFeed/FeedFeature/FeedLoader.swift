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

public enum LoadFeedResult<Error: Swift.Error> {
    case success([FeedItem])
    case failure(Error)
}

extension LoadFeedResult: Equatable where Error: Equatable { }

//public typealias LoadFeedResult = Result<[FeedItem], Error>

public protocol FeedLoader {
    associatedtype Error: Swift.Error
    func load(completion: @escaping (LoadFeedResult<Error>) -> Void)
}
