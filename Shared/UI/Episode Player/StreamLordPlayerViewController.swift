//
//  ViewController.swift
//  StreamKing
//
//  Created by ELLIOTT, Dylan on 5/5/18.
//  Copyright © 2018 Dylan Elliott. All rights reserved.
//

import UIKit
import BrightFutures
import AVKit
import JavaScriptCore

// URL: http://www.streamlord.com/episode-the-magicians-s03e12-18101.html

class StreamLordPlayerViewController: AVPlayerViewController {

	let episode: Episode
	
	let scrobbler: Scrobbler
	let scroblleID: ScrobbleID
	
    
	init(episode: Episode, scrobbler: Scrobbler, scrobbleID: ScrobbleID) {
        self.episode = episode
		self.scrobbler = scrobbler
		self.scroblleID = scrobbleID
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        loadVideo()
    }
    
    private func loadVideo() {
        if let videoURLString = getVideoURL(for: episode.url), let videoURL = URL(string: videoURLString) {
            loadPlayer(withURL: videoURL)
        } else {
            alert(title: "Error", message: "Couldn't load video")
        }
    }
    
    private func loadPlayer(withURL url: URL) {
        DispatchQueue.main.async {
			
            try? AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, with: .mixWithOthers)
            try? AVAudioSession.sharedInstance().setActive(true)
            
            let asset = AVURLAsset(url: url)
            let item = AVPlayerItem(asset: asset)
            let player = SKPlayer(playerItem: item)
			player.delegate = self
			self.player = player
			
			self.player?.play()
        }
    }
    
    let scriptRegex = try! NSRegularExpression(pattern: "\\\"sources\\\": \\[\\{\\\"default\\\": true, \\\"file\\\": eval\\((.+)\\)", options: [])
    let context = JSContext()!
    
    private func getVideoURL(for pageURL: URL) -> String? {
        let html = try! String(contentsOf: pageURL)

        let matches = scriptRegex.matches(in: html, options: [], range: NSRange(location: 0, length: html.count))
        let range = matches.first!.range(at: 1)
        
        let script = "eval(\(html.substring(with: Range(range, in: html)!)))"
        let value = context.evaluateScript(script)
        return value?.toString()
    }
	
	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		self.player = nil
	}
	
	deinit {
		guard let progress = progress else { return }
		scrobbler.episodeDidStop(scroblleID, progress: progress)
	}
}

extension StreamLordPlayerViewController: SKPlayerDelegate {
	var progress: Float? {
		guard let player = player,
			let currentItem = player.currentItem
			else { return nil }
		
		let currentTime = player.currentTime().seconds
		let duration = currentItem.duration.seconds
		return Float(currentTime / duration) * 100.0
	}
	func playerDidPlay() {
		guard let progress = progress else { return }
		scrobbler.episodeDidPlay(scroblleID, progress: progress)
	}
	
	
	func playerDidPause() {
		guard let progress = progress else { return }
		scrobbler.episodeDidPause(scroblleID, progress: progress)
	}
	
	func playerDidStop() {
		guard let progress = progress else { return }
		scrobbler.episodeDidStop(scroblleID, progress: progress)
	}
}

protocol SKPlayerDelegate {
	func playerDidPlay()
	func playerDidPause()
	func playerDidStop()
}

class SKPlayer: AVPlayer {
	
	var delegate: SKPlayerDelegate?
	
	override init() {
		super.init()
		addObserver(self, forKeyPath: "timeControlStatus", options: .new, context: nil)
	}
	
	override init(playerItem item: AVPlayerItem?) {
		super.init(playerItem: item)
	}
	
	override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
		if let object = object as? SKPlayer, object == self, keyPath == "timeControlStatus" {
			switch timeControlStatus {
			case .paused:
				delegate?.playerDidPause()
			case .playing:
				delegate?.playerDidPlay()
			default:
				break
			}
		}
	}
	
	deinit {
		removeObserver(self, forKeyPath: "timeControlStatus")
		delegate?.playerDidStop()
	}
}
