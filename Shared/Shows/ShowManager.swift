//
//  ShowManager.swift
//  StreamKing
//
//  Created by ELLIOTT, Dylan on 5/5/18.
//  Copyright © 2018 Dylan Elliott. All rights reserved.
//

import Foundation

import class AKTrakt.Trakt
import class AKTrakt.TraktAuthenticationViewController
import protocol AKTrakt.TraktAuthViewControllerDelegate

import TraktKit

struct ShowItem: Codable {
    var title: String
    var streamLordURL: URL
	var traktID: ID
}

class ShowManager {
    
    static let showDataKey = "SHOW_DATA"
    
    var keyStore = NSUbiquitousKeyValueStore()
    
    let jsonDecoder = JSONDecoder()
    let jsonEncoder = JSONEncoder()
	
	var traktAuthManager: Trakt
	var traktAuthDelegate: TraktAuthViewControllerDelegate?
	var traktContentManager: TraktManager
	
    private(set) var shows: [ShowItem]
        
    
	init(traktAuth: Trakt, traktContent: TraktManager) {
		traktAuthManager = traktAuth
		traktContentManager = traktContent 
		
        keyStore.synchronize()
        shows = []
        loadShowsFromDisk()
		
		if traktIsAuthorised {
			passTraktTokensToContentManager()
		}
    }
    
    private func loadShowsFromDisk() {
        guard let showData = keyStore.data(forKey: ShowManager.showDataKey), let showArray = try? jsonDecoder.decode([ShowItem].self, from: showData) else {
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

extension ShowManager: TraktAuthViewControllerDelegate {
	var traktIsAuthorised: Bool {
		return traktAuthManager.token != nil
	}
	
	func passTraktTokensToContentManager() {
		traktContentManager.refreshToken = traktAuthManager.token?.refreshToken
		traktContentManager.accessToken = traktAuthManager.token?.accessToken
	}
	
	func traktAuthenticationViewController(delegate: TraktAuthViewControllerDelegate) -> TraktAuthenticationViewController {
		traktAuthDelegate = delegate
		return TraktAuthenticationViewController(trakt: traktAuthManager, delegate: delegate)
	}
	
	func searchTrakt(showName: String, completion: @escaping ([TraktShow]?) -> ()) {
		traktContentManager.search(query: showName, types: [.show]) { result in
			switch result {
			case .success(let results):
				completion(results.compactMap { $0.show })
			case .error(_):
				completion(nil)
			}
		}
	}
	
	func TraktAuthViewControllerDidAuthenticate(controller: UIViewController) {
		traktAuthDelegate?.TraktAuthViewControllerDidAuthenticate(controller: controller)
		passTraktTokensToContentManager()
	}

	func TraktAuthViewControllerDidCancel(controller: UIViewController) {
		traktAuthDelegate?.TraktAuthViewControllerDidCancel(controller: controller)
	}
}
