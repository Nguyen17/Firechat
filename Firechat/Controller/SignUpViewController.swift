//
//  SignUpViewController.swift
//  Firechat
//
//  Created by Amanuel Ketebo on 9/19/17.
//  Copyright © 2017 Krevalent. All rights reserved.
//

import UIKit
import FirebaseAuth

class SignUpViewController: UIViewController, AuthenticationInputValidator {
    
    @IBOutlet weak var errorMessageLabel: UILabel!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    let firebaseManager = FirebaseManager()
    let notificationCenter = NotificationCenter.default
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    private func setupViews() {
        errorMessageLabel.alpha = 0
    }
    
    @IBAction func signup() {
        let userName = usernameTextField.text ?? ""
        let email = emailTextField.text ?? ""
        let password = passwordTextField.text ?? ""
    
        
        if validInput(userName, email, password)
        {
            firebaseManager.signup(userName: userName, email: email, password: password) { [weak self] (user, error) in
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
    
    @IBAction func backButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
