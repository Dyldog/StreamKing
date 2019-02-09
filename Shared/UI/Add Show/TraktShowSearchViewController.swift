//
//  TraktShowSearchViewController.swift
//  StreamKing
//
//  Created by Dylan Elliott on 9/2/19.
//  Copyright © 2019 Dylan Elliott. All rights reserved.
//

import UIKit
import TraktKit

class TraktShowSearchViewController: UITableViewController {
	let showManager: ShowManager
	let searchQuery: String
	
	var searchResults: [TraktShow]?
	
	var onSelection: ((TraktShow) -> Void)
	
	init(showManager: ShowManager, searchQuery: String, onSelection: @escaping ((TraktShow) -> Void)) {
		self.showManager = showManager
		self.searchQuery = searchQuery
		self.onSelection = onSelection
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		loadSearchResults()
	}
	
	private func loadSearchResults() {
		showManager.searchTrakt(showName: searchQuery) { results in
			self.searchResults = results
			
			DispatchQueue.main.async {
				if self.searchResults == nil {
					let alert = UIAlertController(title: "Error", message: "Search results could not be loaded", preferredStyle: .alert)
					alert.addAction(UIAlertAction(title: "Retry", style: .default, handler:
						{ _ in self.loadSearchResults() }
					))
					alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
				} else {
					self.tableView.reloadData()
				}
			}
		}
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return searchResults?.count ?? 0
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "cell") ?? UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
		cell.detailTextLabel?.numberOfLines = 0
		return cell
	}
	
	override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		let show = searchResults![indexPath.row]
		
		cell.textLabel?.text = show.title
		cell.detailTextLabel?.text = show.overview
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		onSelection(searchResults![indexPath.row])
		tableView.deselectRow(at: indexPath, animated: true)
	}
}
