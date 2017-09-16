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

    var channelsArray: [String] = []
        
    override func viewDidLoad() {
        super.viewDidLoad()
        self.revealViewController().rearViewRevealWidth = self.view.frame.size.width - 60

        FirebaseManager.instance.fetchChannels { (snapshot, error) in
            if error == nil {
                self.channelsArray = snapshot!
            } else {
                print(error.debugDescription)
            }
        }
        
        channelsTable.dataSource = self
        channelsTable.delegate = self
        
        
    }
    
    @IBAction func logoutButtonPressed(_ sender: Any) {
        FirebaseManager.instance.logout { (error) in
            if error != nil {
                print(error.debugDescription)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return channelsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "ChannelTableViewCell") as? ChannelTableViewCell {
            if !channelsArray.isEmpty {
                let channel = Channel(title: channelsArray[indexPath.row])
                cell.updateView(channel: channel)
                return cell
            } else {
                return ChannelTableViewCell()
            }
        } else {
            return ChannelTableViewCell()
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        <#code#>
    }
}
