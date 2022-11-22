//
//  FeedItem.swift
//  Network-Essentials
//
//  Created by Ivo on 14/11/22.
//

import Foundation

public struct FeedItem: Equatable {
    // TODO: is this correct?
    let id: UUID
    let description: String?
    let location: String?
    let imageURL: URL
    
//    public init(id: UUID,
//                description: String? = nil,
//                location: String? = nil,
//                imageURL: URL) {
//        self.id = id
//        self.description = description
//        self.location = location
//        self.imageURL = imageURL
//    }
}
