//
//  ShowListViewController.swift
//  StreamKing
//
//  Created by ELLIOTT, Dylan on 5/5/18.
//  Copyright © 2018 Dylan Elliott. All rights reserved.
//

import UIKit

class ShowListViewController: UITableViewController {
    
    let streamLordURL = URL(string: "http://www.streamlord.com/")!
    let showManager = ShowManager()
    var items: [ShowItem] {
        return showManager.shows
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.title = "StreamLord"
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.title = "StreamLord"
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
        #if os(iOS)
        let urlSelectorViewController = UIStoryboard(name: "URLSelector", bundle: .main).instantiateInitialViewController() as! URLSelectorViewController
        urlSelectorViewController.delegate = self
        urlSelectorViewController.webViewURL = streamLordURL
        let navigationController = UINavigationController(rootViewController: urlSelectorViewController)
        self.present(navigationController, animated: true, completion: nil)
        #endif
    }
    
    @IBAction func reloadButtonTapped() {
        showManager.refreshShows()
        tableView.reloadData()
    }
}

#if os(iOS)
extension ShowListViewController: URLSelectorViewControllerDelegate {
    func userDidCancel(in urlSelectorViewController: URLSelectorViewController) {
        urlSelectorViewController.dismiss(animated: true, completion: nil)
    }
    
    func userDidSelectURL(url: URL, in urlSelectorViewController: URLSelectorViewController) {
        urlSelectorViewController.dismiss(animated: true, completion: nil)
        
        guard let html = try? String(contentsOf: url) else {
            alert(title: "Error", message: "Couldn't download HTML")
            return
        }
        guard let showTitle = StreamLordParser.parseTitle(from: html) else {
            alert(title: "Error", message: "Couldn't parse show title")
            return
        }
        
        let newShow = ShowItem(title: showTitle, url: url)
        showManager.addShow(newShow)
        
        self.tableView.reloadData()
    }
}
#endif
