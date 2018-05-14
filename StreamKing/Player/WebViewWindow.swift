//
//  WebViewWindow.swift
//  StreamKing
//
//  Created by ELLIOTT, Dylan on 5/5/18.
//  Copyright © 2018 Dylan Elliott. All rights reserved.
//

import Foundation
import UIKit
import WebKit

enum Result<T> {
    case success(T)
    case failure(Error)
}

enum StreamKingError: Error {
    case wrongContentType(Any)
}

class WebViewController: UIViewController {
    var webView: WKWebView
    
    init() {
        webView = WKWebView()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        self.view = webView
    }
    
    func resetWebView() {
        webView.stopLoading()
        webView = WKWebView()
    }
}

class WebViewWindow: UIWindow {
    let webViewController = WebViewController()
    
    var webView: WKWebView {
        return webViewController.webView
    }
    
    init() {
        super.init(frame: .zero)
        self.rootViewController = webViewController
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    internal func resetWebView() {
        webViewController.resetWebView()
    }
}

class StreamLordEpisodeWindow: WebViewWindow {
    
    private func playMovie(callback: @escaping (Result<String>) -> Void) {
        self.webView.evaluateJavaScript(
            "playMovie();"
        ) { (obj, error) in
            if let error = error {
                callback(.failure(error))
            } else if let value = obj as? String {
                callback(.success(value))
            } else {
                callback(.failure(StreamKingError.wrongContentType(obj as Any)))
            }
        }
    }
    
    private func getVideoSource(callback: @escaping (Result<String>) -> Void) {
        webView.evaluateJavaScript(
            "document.getElementsByTagName('video')[0].src"
        ) { (obj, error) in
            if let error = error {
                callback(.failure(error))
            } else if let urlString = obj as? String {
                callback(.success(urlString))
            } else {
                callback(.failure(StreamKingError.wrongContentType(obj as Any)))
            }
        }
    }
    
    func getVideoURL(forPage pageURL: URL, callback: @escaping ((Result<String>) -> Void)) {
        webView.load(URLRequest(url: pageURL))
        
        DispatchQueue.main.async {
            Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { timer in
                self.getVideoSource(callback: { checkResult in
                    if case .success = checkResult {
                        DispatchQueue.main.async { timer.invalidate() }
                        
                        self.playMovie(callback: { playResult in
                            
                            self.getVideoSource(callback: { result in
                                self.resetWebView()
                                callback(result)
                            })
                        })
                    }
                })
            })
        }
    }
    
}
