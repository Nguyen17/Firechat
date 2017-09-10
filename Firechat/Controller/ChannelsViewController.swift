//
//  ChannelsViewController.swift
//  Firechat
//
//  Created by Joshua Ramos on 9/10/17.
//  Copyright © 2017 Krevalent. All rights reserved.
//

import UIKit

class ChannelsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.revealViewController().rearViewRevealWidth = self.view.frame.size.width - 60
    }
}
