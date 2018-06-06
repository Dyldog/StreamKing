//
//  ShowManager.swift
//  StreamKing
//
//  Created by ELLIOTT, Dylan on 5/5/18.
//  Copyright © 2018 Dylan Elliott. All rights reserved.
//

import Foundation
import Disk

struct ShowItem: Codable {
    var title: String
    var url: URL
}

class ShowManager {
    var shows: [ShowItem] {
        didSet {
            saveShowsToDisk()
        }
    }
    
    init() {
        shows = []
        loadShowsFromDisk()
    }
    
    private func loadShowsFromDisk() {
        if let loadedShows = try? Disk.retrieve("shows.json", from: .applicationSupport, as: [ShowItem].self) {
            shows = loadedShows
        } else {
            shows = [
                .init(title: "The Magicians", url: URL(string: "http://www.streamlord.com/watch-tvshow-the-magicians-286.html")!)
            ]
        }
    }
    
    private func saveShowsToDisk() {
        try? Disk.save(shows, to: .applicationSupport, as: "shows.json")
    }
}
