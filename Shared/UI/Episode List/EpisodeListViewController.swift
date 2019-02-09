//
//  EpisodeListViewController.swift
//  StreamKing
//
//  Created by ELLIOTT, Dylan on 5/5/18.
//  Copyright © 2018 Dylan Elliott. All rights reserved.
//

import UIKit

class EpisodeListViewController: UITableViewController {
    
    let pageURL: URL
    
    var episodeItems: [[Episode]] = []
    
    init(showItem: Show) {
        self.pageURL = showItem.streamLordURL
        super.init(style: .grouped)
        self.title = showItem.title
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        
        DispatchQueue.main.async {
            let html = try! String(contentsOf: self.pageURL)
            self.episodeItems = StreamLordParser.parseEpisodes(from: html) ?? [] // TODO: Errors
            self.tableView.reloadData()
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return episodeItems.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Season \(section + 1)"
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return episodeItems[section].count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") ?? UITableViewCell(style: .subtitle, reuseIdentifier: "Cell")
        
        let item = episodeItems[indexPath.section][indexPath.row]
        
        cell.textLabel?.text = item.title
        cell.detailTextLabel?.text = "Season \(item.season), Episode \(item.episode)"
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = episodeItems[indexPath.section][indexPath.row]
        let playerViewController = StreamLordPlayerViewController(pageURL: item.url)
        present(playerViewController, animated: true, completion: nil)
    }
}
