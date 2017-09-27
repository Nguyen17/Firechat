//
//  AuthenticationViewController.swift
//  Firechat
//
//  Created by Amanuel Ketebo on 9/10/17.
//  Copyright © 2017 Krevalent. All rights reserved.
//

import UIKit
import FirebaseAuth

protocol AuthenticationInputValidator { }

extension AuthenticationInputValidator {
    func validInput(_ userName: String, _ email: String, _ password: String, _ color: UIColor?) -> Bool {
        if email.isEmpty || password.isEmpty || userName.isEmpty || color == nil {
            return false
        } else {
            return true
        }
    }
    
    func validInput(_ userName: String, _ email: String, _ password: String) -> Bool {
        if email.isEmpty || password.isEmpty || userName.isEmpty {
            return false
        } else {
            return true
        }
    }
    
    func showError(label: UILabel, message: String) {
        label.text = message
        label.fadeIn(duration: 0.2)
    }
    
    func hideError(label: UILabel, message: String) {
        label.text = ""
        label.fadeOut(duration: 0.2)
    }
}

class LoginViewController: UIViewController, AuthenticationInputValidator {
    
    @IBOutlet weak var errorMessageLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var firechatLabel: UILabel!
    
    private var firebaseManager = FirebaseManager.instance
    private let notificationCenter = NotificationCenter.default
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        setupViews()
    }
    
    private func setupViews()
    {
        errorMessageLabel.alpha = 0
        firechatLabel.shadowColor = #colorLiteral(red: 0.5704585314, green: 0.5704723597, blue: 0.5704649091, alpha: 1)
        firechatLabel.shadowOffset = CGSize(width: 1, height: 1)
    }
    
    @IBAction func login()
    {
        let userName = "bypass"
        let email = emailTextField.text ?? ""
        let password = passwordTextField.text ?? ""
        
        
        if validInput(userName, email, password)
        {
            firebaseManager.login(email: email, password: password) { [weak self] (user, error) in
                if let error = error, let authError = AuthErrorCode(rawValue: error._code)
                {
                    guard let errorMessageLabel = self?.errorMessageLabel else { return }
                    self?.showError(label: errorMessageLabel, message: authError.description)
                }
                else
                {
                    self?.notificationCenter.post(name: .authStatusChanged, object: nil)
                }
            }
        }
        else
        {
            showError(label: errorMessageLabel, message: "Invalid input")
        }
    }
}

