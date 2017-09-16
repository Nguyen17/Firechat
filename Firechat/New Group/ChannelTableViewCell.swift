//
//  ChannelTableViewCell.swift
//  Firechat
//
//  Created by Joshua Ramos on 9/10/17.
//  Copyright © 2017 Krevalent. All rights reserved.
//

import UIKit

class ChannelTableViewCell: UITableViewCell {
    
    static let identifier = "ChannelTableViewCell"

    @IBOutlet weak var channelLabel: UILabel!
    
    func updateView(channel: Channel) {
        channelLabel.text = channel.title
    }

}
