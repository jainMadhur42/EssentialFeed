//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Madhur Jain on 29/05/21.
//

import XCTest

class RemoteFeedLoader {
	let client: HTTPClient
	let url: URL
	
	init(url: URL, client: HTTPClient) {
		self.client = client
		self.url = url
	}
	func load() {
		client.get(from: url)
	}
}

protocol HTTPClient {
	func get(from: URL)
}

class RemoteFeedLoaderTests: XCTestCase {

	
	
	func test_init_doesNotRequestDataFromURL() {
		let (sut, client) = makeSUT()
		XCTAssertNil(client.requestedURL)
	}
	
	func test_load_requestDataFromURL() {
		let url = URL(string: "https://a-madhur.gmail.com")!
		let (sut, client) = makeSUT()
		sut.load()
		XCTAssertEqual(client.requestedURL, url)
	}
	
	// MARK: - Helper
	
	private func makeSUT(url: URL = URL(string: "https://a-madhur.gmail.com")!) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
		let client = HTTPClientSpy()
		let sut = RemoteFeedLoader(url: url, client: client)
		return(sut,client)
	}
	
	class HTTPClientSpy: HTTPClient {
		var requestedURL: URL?
		func get(from url: URL) {
			requestedURL = url
		}
	}
	
}
