//
//  EpisodeItemMapper.swift
//  StreamKing
//
//  Created by Dylan Elliott on 9/2/19.
//  Copyright © 2019 Dylan Elliott. All rights reserved.
//

import Foundation
import Kanna

class EpisodeItemMapper {
	static let urlBase = "http://www.streamlord.com"
	
	static let episodeRegex = try! NSRegularExpression(pattern: "s(\\d{2})e(\\d{2})")
	
	static private func mapEpisodeNum(node: XMLElement) -> (Int, Int) {
		let link = node.css("div[class='playpic']").first!.css("a").first!
		let href = link["href"]!
		
		let result = episodeRegex.firstMatch(in: href, options: [], range: .init(location: 0, length: href.count))!
		
		let seasonNum = Int(href.substring(with: Range(result.range(at: 1), in: href)!))!
		let episodeNum = Int(href.substring(with: Range(result.range(at: 2), in: href)!))!
		
		return (seasonNum, episodeNum)
	}
	
	static private func mapTitle(node: XMLElement) -> String {
		let aTag = node.css("a[class='head']").first!
		let spanText = aTag.css("span").first!.text!
		return aTag.text!.replacingOccurrences(of: spanText, with: "")
	}
	
	static private func mapURL(node: XMLElement) -> URL {
		let link = node.css("div[class='playpic']").first!.css("a").first!
		return URL(string: "\(urlBase)/\(link["href"]!)")!
	}
	
	static func map(node: XMLElement) -> Episode{
		let episodeNum = mapEpisodeNum(node: node)
		
		return Episode(title: mapTitle(node: node), season: episodeNum.0, episode: episodeNum.1, url: mapURL(node: node))
	}
}
