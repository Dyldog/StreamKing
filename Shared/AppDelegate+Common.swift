//
//  AppDelegate.swift
//  StreamKing
//
//  Created by Dylan Elliott on 9/2/19.
//  Copyright © 2019 Dylan Elliott. All rights reserved.
//

import Foundation

import AVKit
import AKTrakt
import class TraktKit.TraktManager

extension AppDelegate {
	func setupContext() {
		if let navigationController = window?.rootViewController as? UINavigationController, let showListViewController = navigationController.viewControllers[0] as? ShowListViewController {
			
			let traktContentManager = TraktManager()
			traktContentManager.set(clientID: Secrets.clientId, clientSecret: Secrets.clientSecret, redirectURI: Secrets.redirectURI)
			
			showListViewController.showManager = ShowManager(
				traktAuth: Trakt(
					clientId: Secrets.clientId,
					clientSecret: Secrets.clientSecret,
					applicationId: Secrets.applicationId),
				traktContent: traktContentManager
			)
			showListViewController.addShowCoordinator = AddShowCoordinator(
				rootViewController: showListViewController,
				delegate: showListViewController, showManager:
				showListViewController.showManager
			)
		}
	}
}
