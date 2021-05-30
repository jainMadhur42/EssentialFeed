//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Madhur Jain on 29/05/21.
//

import Foundation


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
				do {
				let item = try FeedItemMapper.map(data, response)
					completion(.success(item))
				} catch {
					completion(.failure(.invalidData))
				}
			case .failure:
				completion(.failure(.connectivity))
			}
		}
	}
	
	private func map(_ data: Data, from response: HTTPURLResponse) -> Result {
		do {
		let item = try FeedItemMapper.map(data, response)
			return .success(item)
		} catch {
			return .failure(.invalidData)
		}
	}
}

