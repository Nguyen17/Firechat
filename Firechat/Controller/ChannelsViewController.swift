//
//  ChannelsViewController.swift
//  Firechat
//
//  Created by Joshua Ramos on 9/10/17.
//  Copyright © 2017 Krevalent. All rights reserved.
//

import UIKit


class ChannelsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var channelsTable: UITableView!

    
    
    var refreshControl: UIRefreshControl!
    var channelsArray: [String] = []
    
    let firebaseManager = FirebaseManager.instance
    let notficationCenter = NotificationCenter.default

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    private func setupViews() {
        channelsTable.dataSource = self
        channelsTable.delegate = self
        revealViewController().rearViewRevealWidth = self.view.frame.size.width - 60
        
        fetchChannels()
        
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(refresh(sender:)), for: UIControlEvents.valueChanged)
        channelsTable.addSubview(refreshControl) // not required when using UITableViewController
    }
    
    @objc func refresh(sender:AnyObject) {
        fetchChannels()
    }
    
    @IBAction func logoutButtonPressed(_ sender: Any) {
        firebaseManager.logout { (error) in
            if error != nil {
                print(error.debugDescription)
            }
        }
    }
    
    private func fetchChannels() {
        FirebaseManager.instance.fetchChannels { (snapshot, error) in
            if error != nil {
                print(error.debugDescription)
            } else {
                self.channelsArray = snapshot!
                self.channelsTable.reloadData()
                self.refreshControl.endRefreshing()
            }
        }
    }
    
    // MARK: - Table view data source and delegate methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return channelsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ChannelTableViewCell.identifier) as! ChannelTableViewCell
        
        if !channelsArray.isEmpty {
            let channel = Channel(title: channelsArray[indexPath.row])
            cell.updateView(channel: channel)
            return cell
        } else {
            return ChannelTableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        notficationCenter.post(name: .channelChanged, object: nil, userInfo: ["channelName": channelsArray[indexPath.row]])
        
        if let swRevealController = self.parent as? SWRevealViewController {
            swRevealController.rightRevealToggle(animated: true)
        }
    }
}
