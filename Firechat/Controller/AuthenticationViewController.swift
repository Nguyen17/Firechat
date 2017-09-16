//
//  AuthenticationViewController.swift
//  Firechat
//
//  Created by Amanuel Ketebo on 9/10/17.
//  Copyright © 2017 Krevalent. All rights reserved.
//

import UIKit
import FirebaseAuth

class AuthenticationViewController: UIViewController
{
    @IBOutlet weak var errorMessageLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    private var firebaseManager = FirebaseManager.instance
    private let notificationCenter = NotificationCenter.default
    
    var validInput: Bool
    {
        let email = emailTextField.text ?? ""
        let password = passwordTextField.text ?? ""
        
        if email.isEmpty || password.isEmpty
        {
            return false
        }
        else
        {
            return true
        }
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        setupViews()
    }
    
    private func setupViews()
    {
        errorMessageLabel.alpha = 0
    }
    
    @IBAction func login()
    {
        let email = emailTextField.text ?? ""
        let password = passwordTextField.text ?? ""
        
        
        if validInput
        {
            firebaseManager.login(email: email, password: password) { [weak self] (user, error) in
                if let error = error, let authError = AuthErrorCode(rawValue: error._code)
                {
                    self?.showLoginError(authError.description)
                }
                else
                {
                    self?.notificationCenter.post(name: .authStatusChanged, object: nil)
                }
            }
        }
        else
        {
            showLoginError("Invalid input")
        }
    }
    
    private func showLoginError(_ message: String)
    {
        errorMessageLabel.text = message
        errorMessageLabel.fadeIn(duration: 0.2)
    }
    
    private func hideLoginError()
    {
        errorMessageLabel.text = ""
        errorMessageLabel.fadeOut(duration: 0.2)
    }
}

