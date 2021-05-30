//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Madhur Jain on 29/05/21.
//

import Foundation

public enum LoadFeedResult<Error: Swift.Error> {
	case sucess([FeedItem])
	case failure(Error)
}

extension LoadFeedResult: Equatable where Error: Equatable {}

protocol FeedLoader {
	associatedtype Error: Swift.Error
	func load(completion: @escaping (LoadFeedResult<Error>)-> Void)
}
