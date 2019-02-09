//
//  ShowManager+Episodes.swift
//  StreamKing
//
//  Created by Dylan Elliott on 9/2/19.
//  Copyright © 2019 Dylan Elliott. All rights reserved.
//

import Foundation

protocol EpisodeProvider {
	func getEpisodeScrobbleID(show: Show, number: (Int, Int), completion: @escaping ((ScrobbleID?) -> ()))
}

extension ShowManager: EpisodeProvider {
	
	func getEpisodeScrobbleID(show: Show, number: (Int, Int), completion: @escaping ((ScrobbleID?) -> ())) {
		traktContentManager.getEpisodeSummary(
			showID: show.traktID.trakt,
			seasonNumber: number.0 as NSNumber,
			episodeNumber: number.1 as NSNumber,
			extended: []
		) { result in
			switch result {
			case .success(let episode):
				completion(episode)
			case .error(let error):
				print("GET EPISODE ERROR: \(error.debugDescription)")
				completion(nil)
			}
			
		}
	}
}
