//
//  XCTestCaseMemoryTracking.swift
//  EssentialFeedTests
//
//  Created by Madhur Jain on 01/06/21.
//

import XCTest

extension XCTestCase {
	
	func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #file, line: UInt = #line) {
		addTeardownBlock { [weak instance] in
			XCTAssertNil(instance, "Instance should have been deallocated. Potential memory leak.",
						 file: file, line: line)
		}
	}
}
