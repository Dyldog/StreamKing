//
//  ShowManager.swift
//  StreamKing
//
//  Created by ELLIOTT, Dylan on 5/5/18.
//  Copyright © 2018 Dylan Elliott. All rights reserved.
//

import Foundation
import AKTrakt

struct ShowItem: Codable {
    var title: String
    var streamLordURL: URL
	var traktID: TraktIdentifier
}

class ShowManager {
    
    static let showDataKey = "SHOW_DATA"
    
    var keyStore = NSUbiquitousKeyValueStore()
    
    let jsonDecoder = JSONDecoder()
    let jsonEncoder = JSONEncoder()
	
	var traktManager: Trakt
    
    private(set) var shows: [ShowItem]
        
    
	init(trakt: Trakt) {
		traktManager = trakt
		
        keyStore.synchronize()
        shows = []
        loadShowsFromDisk()
    }
    
    private func loadShowsFromDisk() {
        guard let showData = keyStore.data(forKey: ShowManager.showDataKey), let showArray = try? jsonDecoder.decode([ShowItem].self, from: showData) else {
			shows = [.init(title: "The Magicians", streamLordURL: URL(string: "http://www.streamlord.com/watch-tvshow-the-magicians-286.html")!, traktID: 999)]
            saveShowsToDisk()
            return
        }
        
        shows = showArray
    }
    
    private func saveShowsToDisk() {
        let showData = try! jsonEncoder.encode(shows)
        keyStore.set(showData, forKey: ShowManager.showDataKey)
        keyStore.synchronize()
    }
    
    func addShow(_ show: ShowItem) {
        shows.append(show)
        saveShowsToDisk()
    }
    
    func removeShow(withName name: String) {
        guard let showIndex = shows.index(where: { $0.title == name }) else { return }
        shows.remove(at: showIndex)
        saveShowsToDisk()
    }
    
    func refreshShows() {
        keyStore.synchronize()
        loadShowsFromDisk()
    }
}

extension ShowManager {
	var traktIsAuthorised: Bool {
		return traktManager.token != nil
	}
	
	func traktAuthenticationViewController(delegate: TraktAuthViewControllerDelegate) -> TraktAuthenticationViewController {
		return TraktAuthenticationViewController(trakt: traktManager, delegate: delegate)
	}
	
	func searchTrakt(showName: String, completion: @escaping ([TraktShow]?) -> ()) {
		TraktRequestSearch<TraktShow>(query: showName, type: TraktShow.self, year: nil, pagination: nil).request(trakt: traktManager) { (objects, error) in
			
			completion(objects as? [TraktShow])
		}
	}
}
