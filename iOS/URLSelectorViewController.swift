//
//  URLSelectorViewController.swift
//  StreamKing
//
//  Created by ELLIOTT, Dylan on 5/5/18.
//  Copyright © 2018 Dylan Elliott. All rights reserved.
//

import UIKit
import WebKit

protocol URLSelectorViewControllerDelegate: class {
    func userDidCancel(in urlSelectorViewController: URLSelectorViewController)
    func userDidSelectURL(url: URL, in urlSelectorViewController: URLSelectorViewController)
}

class URLSelectorViewController: UIViewController {
    @IBOutlet private weak var webView: WKWebView! {
        didSet {
            guard let webViewURL = webViewURL else { return }
            webView?.load(URLRequest(url: webViewURL))
        }
    }
    
    weak var delegate: URLSelectorViewControllerDelegate?
    
    override func viewDidLoad() {
//        self.navigationItem.prompt = "Travel to a TV sho"
    }
    var webViewURL: URL? {
        didSet {
            guard let webViewURL = webViewURL else { return }
            webView?.load(URLRequest(url: webViewURL))
        }
    }
    
    @IBAction func cancelButtonTapped() {
        delegate?.userDidCancel(in: self)
    }
    
    @IBAction func doneButtonTapped() {
        guard let url = webView.url else { return }
        
        delegate?.userDidSelectURL(url: url, in: self)
    }
    
    @IBAction func backButtonTapped() {
        webView.goBack()
    }
    
    @IBAction func forwardButtonTapped() {
        webView.goForward()
    }
}
