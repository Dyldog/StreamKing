//
//  StreamLordParser.swift
//  StreamKing
//
//  Created by ELLIOTT, Dylan on 5/5/18.
//  Copyright © 2018 Dylan Elliott. All rights reserved.
//

import Foundation
import Kanna

class StreamLordParser {
    static var pageTitleRegex = try! NSRegularExpression(pattern: "Watch ([\\w ]+) \\(", options: [])
    
    static func parseTitle(from html: String) -> String? {
        if let doc = try? HTML(html: html, encoding: .utf8) {
            guard let pageTitle = doc.title else { return nil }
            guard let titleMatch = pageTitleRegex.firstMatch(in: pageTitle, options: [], range: NSRange(location: 0, length: pageTitle.count)) else { return nil }
            
            guard let titleRange = Range(titleMatch.range(at: 1), in: pageTitle) else { return nil }
            let title =  pageTitle.substring(with: titleRange)
            
            return title
        } else {
            return nil
        }
    }
    
    static func parseEpisodes(from html: String) -> [[EpisodeItem]]? {
        guard
            let doc = try? HTML(html: html, encoding: .utf8),
            let seasonWrapper = doc.css("div[id='season-wrapper']").first
        else { return nil }
        
        return seasonWrapper.css("ul").reversed().map { seasonList in
            return seasonList.css("li").reversed().map { (episodeItem) -> EpisodeItem in
                return EpisodeItemMapper.map(node: episodeItem)
            }
        }
    }
}
