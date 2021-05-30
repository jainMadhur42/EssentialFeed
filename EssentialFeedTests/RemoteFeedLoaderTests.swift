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
		
		expect(sut, toCompleteWithResult: .failure(.connectivity)) {
			let clientError = NSError(domain: "Test", code: 0)
			client.complete(with: clientError)
		}
	}
	
	func test_load_deliversErrorOnNon200HTTPResponse() {
		let (sut, client) = makeSUT()
		
		let samples = [199,201,300,400,500]
		
		samples.enumerated().forEach { index,code in
			expect(sut, toCompleteWithResult: .failure(.invalidData)) {
				let json = makeItemJson([])
				client.complete(withStatusCode: code, data: json, at: index)
			}
		}
	}
	
	func test_load_deliversErrorOn200HTTPResponseWithInvalidJSON(){
		let (sut, client) = makeSUT()
		expect(sut, toCompleteWithResult: .failure(.invalidData)) {
			let invalidJSON = Data("Invalid Json".utf8)
			client.complete(withStatusCode: 200, data: invalidJSON)
		}
	}
	
	func test_loaddeliversNotItemOn200HTTPResponseWithEmptyJSONList() {
		let (sut, client) = makeSUT()
		
		expect(sut, toCompleteWithResult: .success([])) {
			let emptyListJSON = Data("{\"items\": []}".utf8)
			client.complete(withStatusCode: 200, data: emptyListJSON)
		}
	}
	
	func test_loaddeliversNotItemOn200HTTPResponseWithValidJSONList() {
		let (sut, client) = makeSUT()
		
		let item1 = makeItem(id: UUID(),
			imageURL: URL(string: "https://a-madhur.gmail.com")!)
		
		let item2 = makeItem(id: UUID(),
			description: "a Description",
			location: "Test location",
			imageURL: URL(string: "https://a-madhur.gmail.com")!)
		
		let items = [item1.model,item2.model]
		expect(sut, toCompleteWithResult: .success(items)) {
			let json = makeItemJson([item1.json,item2.json])
			client.complete(withStatusCode: 200, data: json)
		}
	}
	
	// MARK: - Helper
	private func makeSUT(url: URL = URL(string: "https://a-madhur.gmail.com")!, file: StaticString = #file, line: UInt = #line) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
		let client = HTTPClientSpy()
		let sut = RemoteFeedLoader(url: url, client: client)
		trackForMemoryLeaks(sut)
		trackForMemoryLeaks(client)
		return(sut,client)
	}
	
	private func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #file, line: UInt = #line) {
		addTeardownBlock { [weak instance] in
			XCTAssertNil(instance, "Instance should have been deallocated. Potential memory leak.",
						 file: file, line: line)
		}
	}
	
	private func makeItem(id: UUID, description: String? = nil, location: String? = nil, imageURL: URL)-> (model: FeedItem, json: [String:Any]) {
		let feedItem = FeedItem(id: id, description: description, location: location, imageURL: imageURL)
		let itemJSON = [
		"id": feedItem.id.uuidString,
		"description": feedItem.description,
		"location": feedItem.location,
		"image": feedItem.imageURL.absoluteString
		].reduce(into: [String: Any]()) { (acc,e) in
			if let value = e.value { acc[e.key] = value}
		}
		return (feedItem, itemJSON)
	}
	
	private func makeItemJson(_ items: [[String: Any]]) -> Data {
		let json = [ "items": items ]
		let data = try! JSONSerialization.data(withJSONObject: json)
		return data
	}
	
	private func expect(_ sut: RemoteFeedLoader, toCompleteWithResult result: RemoteFeedLoader.Result, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
		var capturedResult = [RemoteFeedLoader.Result]()
		sut.load { capturedResult.append($0) }
		action()
		XCTAssertEqual(capturedResult, [result],file: file,line: line)
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
			message[index].completion(.failure(error))
		}
		
		func complete(withStatusCode code: Int, data: Data, at index: Int = 0) {
			let response = HTTPURLResponse(url: requestedURL[index],
				statusCode: code,
				httpVersion: nil,
				headerFields: nil)!
			message[index].completion(.success(data,response))
		}
		
	}
}
