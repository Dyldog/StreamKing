//
//  ShowListViewController.swift
//  StreamKing
//
//  Created by ELLIOTT, Dylan on 5/5/18.
//  Copyright © 2018 Dylan Elliott. All rights reserved.
//

import UIKit
import AKTrakt

class ShowListViewController: UITableViewController {
	
	var showManager: ShowManager!
	var addShowCoordinator: AddShowCoordinator!
	
    var items: [ShowItem] {
        return showManager?.shows ?? []
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.title = "StreamLord"
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.title = "StreamLord"
    }
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
	}
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") ?? UITableViewCell(style: .subtitle, reuseIdentifier: "Cell")
        
        let item = items[indexPath.row]
        
        cell.textLabel?.text = item.title
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let show = showManager.shows[indexPath.row]
            showManager.removeShow(withName: show.title)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = items[indexPath.row]
        let showViewController = EpisodeListViewController(showItem: item)
        navigationController?.pushViewController(showViewController, animated: true)
    }
    
    @IBAction func addButtonTapped() {
        addShowCoordinator.show()
    }
    
    @IBAction func reloadButtonTapped() {
        showManager.refreshShows()
        tableView.reloadData()
    }
}

extension ShowListViewController: TraktAuthViewControllerDelegate {
	
	func showAuthIfNecessary() {
		if showManager.traktIsAuthorised == false {
			let authViewController = showManager.traktAuthenticationViewController(delegate: self)
			present(authViewController, animated: true, completion: nil)
		}
	}
	
	func TraktAuthViewControllerDidAuthenticate(controller: UIViewController) {
		showAuthIfNecessary()
	}
	
	func TraktAuthViewControllerDidCancel(controller: UIViewController) {
		let alert = UIAlertController(title: "No Trakt", message: "Your viewing activity will not be tracked on Trakt. To reattempt Trakt authentication, relaunch the app.", preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
	}
}

extension ShowListViewController: AddShowCoordinatorDelegate {
	func userDidAddShow() {
		tableView.reloadData()
	}
	
	func userDidCancel() { }
	
	
}
