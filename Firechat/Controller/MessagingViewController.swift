//
//  MessagingViewController.swift
//  Firechat
//
//  Created by Joshua Ramos on 9/10/17.
//  Copyright © 2017 Krevalent. All rights reserved.
//

import UIKit

class MessagingViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // allows the swipe reveal
        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        
        // allows the tap to return
        self.view.addGestureRecognizer(self.revealViewController().tapGestureRecognizer())
    }
}
