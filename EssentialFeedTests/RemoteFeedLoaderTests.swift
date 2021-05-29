//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Madhur Jain on 29/05/21.
//

import XCTest

class RemoteFeedLoader {
	
	func load() {
		HTTPClient.shared.get(from: URL(string: "https://a-madhur.gmail.com")!)
	}
}

class HTTPClient {
	static var shared = HTTPClient()
	func get(from: URL) { }
	var requestedURL: URL?
}


class HTTPClientSpy: HTTPClient {
	
	override func get(from url: URL) {
		requestedURL = url
	}
}

class RemoteFeedLoaderTests: XCTestCase {
	
	func test_init_doesNotRequestDataFromURL() {
		_ = RemoteFeedLoader()
		let client = HTTPClientSpy()
		HTTPClient.shared = client
		XCTAssertNil(client.requestedURL)
	}
	
	func test_load_requestDataFromURL() {
		let client = HTTPClientSpy()
		HTTPClient.shared = client
		let sut = RemoteFeedLoader()
		sut.load()
		XCTAssertNotNil(client.requestedURL)
	}
	
}
