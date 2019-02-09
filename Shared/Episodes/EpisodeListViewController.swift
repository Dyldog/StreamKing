//
//  EpisodeListViewController.swift
//  StreamKing
//
//  Created by ELLIOTT, Dylan on 5/5/18.
//  Copyright © 2018 Dylan Elliott. All rights reserved.
//

import UIKit
import Kanna

struct EpisodeItem {
    let title: String
    let season: Int
    let episode: Int
    let url: URL
}

class EpisodeItemMapper {
    static let urlBase = "http://www.streamlord.com"
    
    static let episodeRegex = try! NSRegularExpression(pattern: "s(\\d{2})e(\\d{2})")
    
    static private func mapEpisodeNum(node: XMLElement) -> (Int, Int) {
        let link = node.css("div[class='playpic']").first!.css("a").first!
        let href = link["href"]!
        
        let result = episodeRegex.firstMatch(in: href, options: [], range: .init(location: 0, length: href.count))!
        
        let seasonNum = Int(href.substring(with: Range(result.range(at: 1), in: href)!))!
        let episodeNum = Int(href.substring(with: Range(result.range(at: 2), in: href)!))!
        
        return (seasonNum, episodeNum)
    }
    
    static private func mapTitle(node: XMLElement) -> String {
        let aTag = node.css("a[class='head']").first!
        let spanText = aTag.css("span").first!.text!
        return aTag.text!.replacingOccurrences(of: spanText, with: "")
    }
    
    static private func mapURL(node: XMLElement) -> URL {
        let link = node.css("div[class='playpic']").first!.css("a").first!
        return URL(string: "\(urlBase)/\(link["href"]!)")!
    }
    
    static func map(node: XMLElement) -> EpisodeItem{
        let episodeNum = mapEpisodeNum(node: node)
        
        return EpisodeItem(title: mapTitle(node: node), season: episodeNum.0, episode: episodeNum.1, url: mapURL(node: node))
    }
}

class EpisodeListViewController: UITableViewController {
    
    let pageURL: URL
    
    var episodeItems: [[EpisodeItem]] = []
    
    init(showItem: ShowItem) {
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
