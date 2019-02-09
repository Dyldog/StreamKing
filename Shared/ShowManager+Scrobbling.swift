//
//  ShowManager+Scrobbling.swift
//  StreamKing
//
//  Created by Dylan Elliott on 9/2/19.
//  Copyright © 2019 Dylan Elliott. All rights reserved.
//

import TraktKit

protocol Scrobbler {
	func episodeDidPlay(_ episode: ScrobbleID, progress: Float)
	func episodeDidPause(_ episode: ScrobbleID, progress: Float)
	func episodeDidStop(_ episode: ScrobbleID, progress: Float)
}

typealias ScrobbleID = TraktEpisode

extension Encodable {
	func asDictionary() throws -> [String: Any] {
		let data = try JSONEncoder().encode(self)
		guard let dictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
			throw NSError()
		}
		return dictionary
	}
}

extension ShowManager: Scrobbler {
	func episodeDidPlay(_ episode: ScrobbleID, progress: Float) {
		_ = try? traktContentManager.scrobbleStart(episode: try! episode.asDictionary(), progress: progress, appVersion: 1.0, appBuildDate: Date(), completion: {
			self.handleScrobbleResult($0)
		})
	}
	
	func episodeDidPause(_ episode: ScrobbleID, progress: Float) {
		_ = try? traktContentManager.scrobblePause(episode: try! episode.asDictionary(), progress: progress, appVersion: 1.0, appBuildDate: Date(), completion: {
			self.handleScrobbleResult($0)
		})
	}
	
	func episodeDidStop(_ episode: ScrobbleID, progress: Float) {
		_ = try? traktContentManager.scrobbleStop(episode: try! episode.asDictionary(), progress: progress, appVersion: 1.0, appBuildDate: Date(), completion: {
			self.handleScrobbleResult($0)
		})
	}
	
	private func handleScrobbleResult(_ result: ObjectResultType<ScrobbleResult>) {
		switch result {
		case .error(let error):
			print("SCROBBLE ERROR: \(error.debugDescription)")
		default:
			break
		}
	}
}
