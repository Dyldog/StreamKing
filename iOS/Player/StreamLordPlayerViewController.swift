//
//  ViewController.swift
//  StreamKing
//
//  Created by ELLIOTT, Dylan on 5/5/18.
//  Copyright © 2018 Dylan Elliott. All rights reserved.
//

import UIKit
import BrightFutures
import WebKit
import AVKit

// URL: http://www.streamlord.com/episode-the-magicians-s03e12-18101.html

class StreamLordPlayerViewController: AVPlayerViewController {

    let webViewWindow = StreamLordEpisodeWindow()
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
        webViewWindow.getVideoURL(forPage: pageURL, callback: { result in
            guard self.player == nil else { return }
            
            switch result {
            case .success(let value):
                self.loadPlayer(withURL: URL(string: value)!)
            case .failure(let error):
                self.alert(title: "Error", message: error.localizedDescription)
            }
        })
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
}

