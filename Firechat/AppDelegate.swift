//
//  AppDelegate.swift
//  Firechat
//
//  Created by Joshua Ramos on 9/10/17.
//  Copyright © 2017 Krevalent. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

extension NSNotification.Name {
    static let authStatusChanged = NSNotification.Name("AuthStatusChanged")
    static let channelChanged = NSNotification.Name("ChannelChanged")
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    let firebaseManager = FirebaseManager.instance
    let notificationCenter = NotificationCenter.default
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        setupObservers()
        setupRootVC()
        
        return true
    }
    
    private func setupObservers() {
        notificationCenter.addObserver(self, selector: #selector(setupRootVC), name: .authStatusChanged, object: nil)
    }
    
    @objc private func setupRootVC() {
        var rootVC: UIViewController!
        
        if let _ = Auth.auth().currentUser {
            let revealVC = UIStoryboard.main.instantiateInitialViewController() as! RevealViewController
            
            rootVC = revealVC
        } else {
            let loginVC = UIStoryboard.authentication.instantiateInitialViewController() as! LoginViewController
            
            rootVC = loginVC
        }
        
        window?.rootViewController?.dismiss(animated: true, completion: nil)
        window?.rootViewController = rootVC
        window?.makeKeyAndVisible()
    }
    
    
}

