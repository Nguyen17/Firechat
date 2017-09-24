//
//  MessagesContainerViewController.swift
//  Firechat
//
//  Created by Amanuel Ketebo on 9/24/17.
//  Copyright © 2017 Krevalent. All rights reserved.
//

import UIKit

class MessagesContainerViewController: UIViewController {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var channelTitleLabel: UILabel!
    
    let notificationCenter = NotificationCenter.default

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        addObserver()
    }
    
    private func setupViews() {
        // allows swiping to reveal the channelsVC
        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        // allows the tap to return
        self.view.addGestureRecognizer(self.revealViewController().tapGestureRecognizer())
    }
    
    private func addObserver() {
        notificationCenter.addObserver(self, selector: #selector(addTile(_:)), name: .channelChanged, object: nil)
    }
    
    @objc private func addTile(_ notification: Notification) {
        if let info = notification.userInfo as? [String: String],
            let title = info["channelName"] {
            channelTitleLabel.text = title
        }
    }
}
