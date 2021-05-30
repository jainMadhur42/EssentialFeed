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
		
		sut.load {_ in }
		sut.load {_ in }
		
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
	
	func test_load_deliversErrorOnNon200HTTPResponse() {
		let (sut, client) = makeSUT()
		
		let samples = [199,201,300,400,500]
		
		samples.enumerated().forEach { index,code in
			var capturedErrors = [RemoteFeedLoader.Error]()
			sut.load { capturedErrors.append($0) }
			
			client.complete(withStatusCode: code, at: index)
			XCTAssertEqual(capturedErrors, [.invalidData])
		}
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
		private var message = [(url: URL, completion:(HTTPClientResult) -> Void)]()
		
		func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
			message.append((url,completion))
		}
		
		func complete(with error: Error, at index: Int = 0) {
			message[index].completion(.fail(error))
		}
		
		func complete(withStatusCode code: Int, at index: Int = 0) {
			let response = HTTPURLResponse(url: requestedURL[index],
				statusCode: code,
				httpVersion: nil,
				headerFields: nil)!
			message[index].completion(.success(response))
		}
		
	}
}
