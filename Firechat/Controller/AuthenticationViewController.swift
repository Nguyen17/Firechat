//
//  AuthenticationViewController.swift
//  Firechat
//
//  Created by Amanuel Ketebo on 9/10/17.
//  Copyright © 2017 Krevalent. All rights reserved.
//

import UIKit

class AuthenticationViewController: UIViewController {
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    let firebaseManager = FirebaseManager.instance
    let notifcationCenter = NotificationCenter.default
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func login() {
        let email = emailTextField.text!
        let password = passwordTextField.text!
        
        firebaseManager.login(email: email, password: password) { [weak self] (user, error) in
            if error != nil {
                print(error?.localizedDescription)
            } else {
                self?.notifcationCenter.post(name: .authStatusChanged, object: nil)
            }
        }
    }
}
