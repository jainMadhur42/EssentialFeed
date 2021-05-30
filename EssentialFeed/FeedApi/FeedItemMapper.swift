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

	static func map(_ data: Data, _ response: HTTPURLResponse) throws -> [FeedItem] {
		guard response.statusCode == 200 else {
			throw RemoteFeedLoader.Error.invalidData
		}
		let root = try JSONDecoder().decode(Root.self, from: data)
		return root.items.map({ $0.item })
	}
	
}
