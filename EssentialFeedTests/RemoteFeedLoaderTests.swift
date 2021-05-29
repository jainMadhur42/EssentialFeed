//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Madhur Jain on 29/05/21.
//

import XCTest

class RemoteFeedLoader {
	
	func load() {
		HTTPClient.shared.requestedURL = URL(string: "https://a-madhur.gmail.com")
	}
}

class HTTPClient {
	static let shared = HTTPClient()
	private init() {}
	var requestedURL: URL?
}

class RemoteFeedLoaderTests: XCTestCase {
	
	func test_init_doesNotRequestDataFromURL() {
		_ = RemoteFeedLoader()
		let client = HTTPClient.shared
		XCTAssertNil(client.requestedURL)
	}
	
	func test_load_requestDataFromURL() {
		let client = HTTPClient.shared
		let sut = RemoteFeedLoader()
		sut.load()
		XCTAssertNotNil(client.requestedURL)
	}
	
}
