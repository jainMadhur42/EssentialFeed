//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Madhur Jain on 29/05/21.
//

import Foundation

public enum LoadFeedResult {
	case sucess([FeedItem])
	case failure(Error)
}

protocol FeedLoader {
	
	func load(completion: @escaping (LoadFeedResult)-> Void)
}
