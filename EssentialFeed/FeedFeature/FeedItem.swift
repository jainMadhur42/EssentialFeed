//
//  FeedItem.swift
//  EssentialFeed
//
//  Created by Madhur Jain on 29/05/21.
//

import Foundation

public struct FeedItem: Equatable {
	let id: UUID
	let description: String?
	let location: String?
	let url: URL
}
