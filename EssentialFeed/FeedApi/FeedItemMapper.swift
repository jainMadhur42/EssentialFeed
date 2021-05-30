//
//  FeedItemMapper.swift
//  EssentialFeed
//
//  Created by Madhur Jain on 30/05/21.
//

import Foundation

class FeedItemMapper {
	private struct Root: Decodable {
		let items: [item]
		var feed: [FeedItem] {
			items.map({ $0.item })
		}
	}

	private struct item: Decodable {
		public let id: UUID
		public let description: String?
		public let location: String?
		public let image: URL

		var item: FeedItem {
			FeedItem(id: id, description: description, location: location, imageURL: image)
		}
	}
	
	static func map(_ data: Data, from response: HTTPURLResponse) -> RemoteFeedLoader.Result {
		guard response.statusCode == 200,
			  let root = try? JSONDecoder().decode(Root.self, from: data) else {
			return .failure(.invalidData)
		}
		return .success(root.feed)
	}
	
}
