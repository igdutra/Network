//
//  HTTPClient.swift
//  Essentials-Network
//
//  Created by Ivo on 06/12/22.
//

import Foundation

public typealias HTTPClientResult = Result<(Data, HTTPURLResponse), Error>

public protocol HTTPClient {
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void)
}
