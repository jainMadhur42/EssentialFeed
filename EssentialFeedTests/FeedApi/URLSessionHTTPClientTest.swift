//
//  URLSessionHTTPClientTest.swift
//  EssentialFeedTests
//
//  Created by Madhur Jain on 01/06/21.
//

import XCTest
@testable import EssentialFeed

class URLSessionHTTPClientTest: XCTestCase {

	override func setUp() {
		super.setUp()
		URLProtocolStub.startInterceptingRequest()
	}
	
	override func tearDown() {
		super.tearDown()
		URLProtocolStub.stopInterceptingRequest()
	}
	
	func test_getFromURL_performRequestWithURL() {
		let url = anyURL()
		let exp = expectation(description: "wait for request")
		URLProtocolStub.observeRequests { request in
			XCTAssertEqual(request.url, url)
			XCTAssertEqual(request.httpMethod, "GET")
			exp.fulfill()
		}
		
		makeSut().get(from: anyURL()) { _ in }
		wait(for: [exp], timeout: 1.0)
	}

	func test_getFromURL_failOnRequestError() {
		
		let error = anyError()
		let receivedError = resultErrorFor(data: nil, response: nil, error: error) as NSError?
		
		XCTAssertEqual(receivedError?.domain, error.domain)
		XCTAssertEqual(receivedError?.code, error.code)
	
	}

	func test_getFromURL_failsOnAllInvalidCase() {
	
		XCTAssertNotNil(resultErrorFor(data: nil, response: nil, error: nil))
		XCTAssertNotNil(resultErrorFor(data: nil, response: nonHttpUrlResponse(), error: nil))
		XCTAssertNotNil(resultErrorFor(data: anyData(), response: nil, error: nil))
		XCTAssertNotNil(resultErrorFor(data: anyData(), response: nil, error: anyError()))
		XCTAssertNotNil(resultErrorFor(data: nil, response: nonHttpUrlResponse(), error: anyError()))
		XCTAssertNotNil(resultErrorFor(data: nil, response: anyHTTPURLResponse(), error: anyError()))
		XCTAssertNotNil(resultErrorFor(data: anyData(), response: nonHttpUrlResponse(), error: anyError()))
		XCTAssertNotNil(resultErrorFor(data: anyData(), response: anyHTTPURLResponse(), error: anyError()))
		XCTAssertNotNil(resultErrorFor(data: anyData(), response: nonHttpUrlResponse(), error: nil))
	}
	
	func test_getFromURL_suceedsOnHTTPURLResponseWithData() {
		let data = anyData()
		let response = anyHTTPURLResponse()
		let receivedValues = resultValueFor(data: data, response: response, error: nil)
		
		XCTAssertEqual(receivedValues?.data, data)
		XCTAssertEqual(receivedValues?.response.url, response.url)
		XCTAssertEqual(receivedValues?.response.statusCode, response.statusCode)
	}
	
	func test_getFromURL_suceedsWithEmptyDataInHTTPURLResponseWithNilData() {
		let response = anyHTTPURLResponse()
		let receivedValues = resultValueFor(data: nil, response: response, error: nil)
		let emptyData = Data()
		XCTAssertEqual(receivedValues?.data, emptyData)
		XCTAssertEqual(receivedValues?.response.url, response.url)
		XCTAssertEqual(receivedValues?.response.statusCode, response.statusCode)
	}

	// Mark: Helper Function
	
	private func makeSut(file: StaticString = #file, line: UInt = #line) -> HTTPClient {
		let sut = URLSessionHTTPClient()
		trackForMemoryLeaks(sut, file: file, line: line)
		return sut
	}
	
	private func resultValueFor(data: Data?, response: URLResponse?, error: Error?,
								file: StaticString = #file, line: UInt = #line) -> (data: Data, response: HTTPURLResponse)? {
		let result = resultFor(data: data, response: response, error: error,file: file,line: line)
		switch result {
		case let .success(data, response):
			return (data,response)
		default:
			XCTFail("Expected failure, got \(result) instead", file: file, line: line)
			return nil
		}
	}
	
	private func resultErrorFor(data: Data?, response: URLResponse?, error: Error?,
								file: StaticString = #file, line: UInt = #line) -> Error? {
		let result = resultFor(data: data, response: response, error: error,file: file,line: line)
		
		switch result {
		case let .failure(error):
			return error
		default:
			XCTFail("Expected failure, got \(result) instead", file: file, line: line)
			return nil
		}
		
	}
	
	private func resultFor(data: Data?, response: URLResponse?, error: Error?,
						   file: StaticString = #file, line: UInt = #line) -> HTTPClientResult {
		URLProtocolStub.stub(data: data, response: response, error: error)
		let sut = makeSut(file: file, line: line)
		let exp = expectation(description: "wait for completion")
		
		var receivedResult: HTTPClientResult!
		sut.get(from: anyURL()) { result in
			receivedResult = result
			exp.fulfill()
		}
		wait(for: [exp], timeout: 1.0)
		return receivedResult
	}
	
	private func anyURL() -> URL {
		return URL(string: "http://any-url.com")!
	}
	
	private func anyData() -> Data {
		return Data("".utf8)
	}
	
	private func anyError() -> NSError {
		return NSError(domain: "Any error", code: 1)
	}
	
	private func anyHTTPURLResponse() -> HTTPURLResponse {
		return HTTPURLResponse(url: anyURL(), statusCode: 200, httpVersion: nil, headerFields: nil)!
	}
	
	private func nonHttpUrlResponse() -> URLResponse {
		return URLResponse(url: anyURL(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
	}
	
	private class URLProtocolStub: URLProtocol {
		private static var stub: Stub?
		private static var requestObserver: ((URLRequest) -> Void)?
		
		private struct Stub {
			let data: Data?
			let response: URLResponse?
			let error: Error?
		}
		
		static func stub(data: Data?, response: URLResponse?, error: Error?) {
			stub = Stub(data: data, response: response, error: error)
		}
		
		static func observeRequests(observer: @escaping (URLRequest) -> Void) {
			requestObserver = observer
		}
		
		static func startInterceptingRequest() {
			URLProtocol.registerClass(URLProtocolStub.self)
		}
		
		static func stopInterceptingRequest() {
			URLProtocol.unregisterClass(URLProtocolStub.self)
			stub = nil
			requestObserver = nil
		}
		
		override class func canInit(with request: URLRequest) -> Bool {
			requestObserver?(request)
			return true
		}
		
		override class func canonicalRequest(for request: URLRequest) -> URLRequest {
			return request
		}
		
		override func startLoading() {
			if let data = URLProtocolStub.stub?.data {
				client?.urlProtocol(self, didLoad: data)
			}
			if let response = URLProtocolStub.stub?.response {
				client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
			}
			if let error = URLProtocolStub.stub?.error {
				client?.urlProtocol(self, didFailWithError: error)
			}
			client?.urlProtocolDidFinishLoading(self)
		}
		override func stopLoading() { }
	}

}
