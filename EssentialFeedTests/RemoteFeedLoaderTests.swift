//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Madhur Jain on 29/05/21.
//

import XCTest
@testable import EssentialFeed

class RemoteFeedLoaderTests: XCTestCase {

	func test_init_doesNotRequestDataFromURL() {
		let (_, client) = makeSUT()
		XCTAssertTrue(client.requestedURL.isEmpty)
	}
	
	func test_load_requestDataFromURL() {
		let url = URL(string: "https://a-madhur.gmail.com")!
		let (sut, client) = makeSUT()
		
		sut.load()
		sut.load()
		
		XCTAssertEqual(client.requestedURL, [url,url])
	}
	
	func test_load_deliversErrorOnClientError() {
		let (sut, client) = makeSUT()
		
		var capturedErrors = [RemoteFeedLoader.Error]()
		sut.load { capturedErrors.append($0) }
		
		let clientError = NSError(domain: "Test", code: 0)
		client.complete(with: clientError)
		
		XCTAssertEqual(capturedErrors, [.connectivity])
	}
	
	// MARK: - Helper
	private func makeSUT(url: URL = URL(string: "https://a-madhur.gmail.com")!) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
		let client = HTTPClientSpy()
		let sut = RemoteFeedLoader(url: url, client: client)
		return(sut,client)
	}
	
	class HTTPClientSpy: HTTPClient {
		var requestedURL: [URL] {
			return message.map { $0.url }
		}
		private var message = [(url: URL, completion:(Error) -> Void)]()
		
		func get(from url: URL, completion: @escaping (Error) -> Void) {
			message.append((url,completion))
		}
		
		func complete(with error: Error, at index: Int = 0) {
			message[index].completion(error)
		}
	}
}
