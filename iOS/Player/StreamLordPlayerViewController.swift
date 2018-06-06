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

    let pageURL: URL
    
    init(pageURL: URL) {
        self.pageURL = pageURL
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
        if let videoURLString = getVideoURL(for: pageURL), let videoURL = URL(string: videoURLString) {
            loadPlayer(withURL: videoURL)
        } else {
            alert(title: "Error", message: "Couldn't load video")
        }
    }
    
    private func loadPlayer(withURL url: URL) {
        DispatchQueue.main.async {
            try? AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try? AVAudioSession.sharedInstance().setActive(true)
            
            let asset = AVURLAsset(url: url)
            let item = AVPlayerItem(asset: asset)
            let player = AVPlayer(playerItem: item)
            player.play()
            
            self.player = player
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
}

