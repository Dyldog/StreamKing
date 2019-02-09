//
//  AddShowCoordinator.swift
//  StreamKing
//
//  Created by Dylan Elliott on 9/2/19.
//  Copyright © 2019 Dylan Elliott. All rights reserved.
//

import UIKit

protocol AddShowCoordinatorDelegate {
	func userDidAddShow()
	func userDidCancel()
}

class AddShowCoordinator: Coordinator, URLSelectorViewControllerDelegate {
	
	let streamLordURL = URL(string: "http://www.streamlord.com/")!
	let showManager: ShowManager
	var delegate: AddShowCoordinatorDelegate
	
	init(rootViewController: UIViewController, delegate: AddShowCoordinatorDelegate, showManager: ShowManager) {
		self.delegate = delegate
		self.showManager = showManager
		super.init(rootViewController: rootViewController)
	}
	
	override func show() {
		showStreamLordViewController()
	}
	
	
}

extension AddShowCoordinator {
	private func showStreamLordViewController() {
		#if os(iOS)
		let urlSelectorViewController = UIStoryboard(name: "URLSelector", bundle: .main).instantiateInitialViewController() as! URLSelectorViewController
		urlSelectorViewController.delegate = self
		urlSelectorViewController.webViewURL = streamLordURL
		
		let navigationController = UINavigationController(rootViewController: urlSelectorViewController)
		rootViewController.present(navigationController, animated: true, completion: nil)
		#endif
	}
	
	func userDidCancel(in urlSelectorViewController: URLSelectorViewController) {
		urlSelectorViewController.dismiss(animated: true, completion: nil)
		delegate.userDidCancel()
	}
	
	func userDidSelectURL(url: URL, in urlSelectorViewController: URLSelectorViewController) {
		guard let html = try? String(contentsOf: url) else {
			urlSelectorViewController.alert(title: "Error", message: "Couldn't download HTML")
			return
		}
		guard let showTitle = StreamLordParser.parseTitle(from: html) else {
			urlSelectorViewController.alert(title: "Error", message: "Couldn't parse show title")
			return
		}
		
		showTraktViewController(with: (showTitle, url))
		
	}
}

extension AddShowCoordinator {
	func showTraktViewController(with streamLordData: (title: String, url: URL)) {
		let traktSearchVC = TraktShowSearchViewController(showManager: showManager, searchQuery: streamLordData.title, onSelection: { selectedShow in
			self.showManager.addShow(ShowItem(title: streamLordData.title, streamLordURL: streamLordData.url, traktID: selectedShow.ids))
			self.rootViewController.presentedViewController?.dismiss(animated: true, completion: nil)
			self.delegate.userDidAddShow()
		})
		
		guard let navigationController = rootViewController.presentedViewController as? UINavigationController else { return }
		navigationController.pushViewController(traktSearchVC, animated: true)
	}
}
