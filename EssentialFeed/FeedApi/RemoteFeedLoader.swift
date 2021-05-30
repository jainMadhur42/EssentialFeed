//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Madhur Jain on 29/05/21.
//

import Foundation

public enum HTTPClientResult {
	case success(Data, HTTPURLResponse)
	case failure(Error)
}

public protocol HTTPClient {
	func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void)
}

public final class RemoteFeedLoader {
	private let client: HTTPClient
	private let url: URL
	
	public enum Error: Swift.Error {
		case connectivity
		case invalidData
	}
	
	public enum Result: Equatable {
		case success([FeedItem])
		case failure(Error)
	}
	
	public init(url: URL, client: HTTPClient) {
		self.client = client
		self.url = url
	}
	public func load(completion: @escaping (Result) -> Void = {_ in }) {
		client.get(from: url) { result in
			switch result {
			case let .success(data, response):
				if response.statusCode == 200 , let root = try? JSONDecoder().decode(Root.self, from: data) {
					completion(.success(root.items.map(
						{ $0.item }))
					)
				} else {
					completion(.failure(.invalidData))
				}
			case .failure:
				completion(.failure(.connectivity))
			}
		
		}
	}
}

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
