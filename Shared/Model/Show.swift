//
//  Show.swift
//  StreamKing
//
//  Created by Dylan Elliott on 9/2/19.
//  Copyright © 2019 Dylan Elliott. All rights reserved.
//

import Foundation

import struct TraktKit.ID

struct Show: Codable {
	var title: String
	var streamLordURL: URL
	var traktID: ID
}
