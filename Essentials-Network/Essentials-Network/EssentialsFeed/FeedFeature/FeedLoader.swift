//
//  FeedLoader.swift
//  Network-Essentials
//
//  Created by Ivo on 14/11/22.
//

import Foundation

public typealias LoadFeedResult = Result<[FeedItem], Error>

public protocol FeedLoader {
    associatedtype Error: Swift.Error
    func load(completion: @escaping (LoadFeedResult) -> Void)
}
