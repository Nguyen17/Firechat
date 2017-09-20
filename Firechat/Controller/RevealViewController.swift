//
//  RevealViewController.swift
//  Firechat
//
//  Created by Amanuel Ketebo on 9/19/17.
//  Copyright © 2017 Krevalent. All rights reserved.
//

import Foundation

class RevealViewController: SWRevealViewController {
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
    }
}

extension RevealViewController: SWRevealViewControllerDelegate {
    func revealController(_ revealController: SWRevealViewController!, willMoveTo position: FrontViewPosition) {
        if let navVC = self.frontViewController as? UINavigationController,
            let messagesVC = navVC.viewControllers.first as? MessagingViewController
        {
            messagesVC.keyboardController.textView.resignFirstResponder()
        }
    }
}
