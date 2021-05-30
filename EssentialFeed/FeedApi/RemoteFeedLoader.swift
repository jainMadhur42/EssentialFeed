//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Madhur Jain on 29/05/21.
//

import Foundation

public enum HTTPClientResult {
	case success(HTTPURLResponse)
	case fail(Error)
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
	
	public init(url: URL, client: HTTPClient) {
		self.client = client
		self.url = url
	}
	public func load(completion: @escaping (Error) -> Void = {_ in }) {
		client.get(from: url) { result in
			switch result {
			case .success:
				completion(.invalidData)
			case .fail:
				completion(.connectivity)
			}
		
		}
	}
}
