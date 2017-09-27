//
//  SignUpViewController.swift
//  Firechat
//
//  Created by Amanuel Ketebo on 9/19/17.
//  Copyright © 2017 Krevalent. All rights reserved.
//

import UIKit
import FirebaseAuth

public func == (lhs: [CGFloat], rhs: [CGFloat]) -> Bool
{
    guard lhs.count == rhs.count else { return false }
    var i = 0
    while i < lhs.count {
        let lhsCGFloat = lhs[i]
        let rhsCGFloat = rhs[i]
        
        if lhsCGFloat != rhsCGFloat
        {
            return false
        }
        i = i + 1
    }
    
    return true
}

class SignUpViewController: UIViewController, AuthenticationInputValidator {
    
    @IBOutlet weak var errorMessageLabel: UILabel!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var colorsStackView: UIStackView!
    @IBOutlet weak var signUpButton: RoundedButton!
    @IBOutlet weak var firechatLabel: UILabel!
    
    @IBOutlet weak var outerStackView: UIStackView!
    @IBOutlet weak var topStackViewConstraint: NSLayoutConstraint!
    var outerStackViewConstraintSize: CGFloat = 30.0
    
    
    let firebaseManager = FirebaseManager()
    let notificationCenter = NotificationCenter.default
    var colorPick: UIColor?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        
        usernameTextField.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        notificationCenter.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        notificationCenter.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    private func setupViews() {
        errorMessageLabel.alpha = 0
        colorsStackView.subviews.forEach { (colorView) in
            colorView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(pickColor(_:))))
            colorView.layer.shadowRadius = 5
            colorView.layer.shadowColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
            colorView.layer.shadowOpacity = 1
            colorView.layer.shadowOffset = CGSize(width: 1, height: 1)
            
        }
        
        firechatLabel.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        firechatLabel.shadowColor = #colorLiteral(red: 0.5704585314, green: 0.5704723597, blue: 0.5704649091, alpha: 1)
        firechatLabel.shadowOffset = CGSize(width: 1, height: 1)
    }
    
    @objc private func pickColor(_ recognizer: UITapGestureRecognizer)
    {
        guard let associatedView = recognizer.view else { return }
        
        colorPick = associatedView.backgroundColor
        signUpButton.backgroundColor = colorPick
        signUpButton.layer.shadowRadius = 5
        signUpButton.layer.shadowColor = UIColor.black.cgColor
        signUpButton.layer.shadowOpacity = 0.7
        signUpButton.layer.shadowOffset = CGSize(width: 1, height: 1)
        firechatLabel.textColor = colorPick
        unhighlightColors()
    }
    
    private func unhighlightColors()
    {
        colorsStackView.subviews.forEach { (colorView) in
            guard let colorViewComponents = colorView.backgroundColor?.cgColor.components else { return }
            guard let pickedColorComponents = colorPick?.cgColor.components else { return }
            
            if !(colorViewComponents == pickedColorComponents)
            {
                colorView.alpha = 0.2
            }
            else
            {
                colorView.alpha = 1
            }
        }
    }
    
    @IBAction func signup() {
        let userName = usernameTextField.text ?? ""
        let email = emailTextField.text ?? ""
        let password = passwordTextField.text ?? ""
    
        
        if validInput(userName, email, password, colorPick)
        {
            firebaseManager.signup(userName: userName, email: email, password: password, color: colorPick!) { [weak self] (user, error) in
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

extension SignUpViewController: UITextFieldDelegate {
    @objc func keyboardWillShow(notification: NSNotification) {
        if let info = notification.userInfo {
            let rect:CGRect = info["UIKeyboardFrameEndUserInfoKey"] as! CGRect
            
            // Find target Y
            let targetY = view.frame.size.height - rect.height - 20 - signUpButton.frame.size.height
            
            let textFieldY = outerStackView.frame.origin.y + signUpButton.frame.origin.y
            
            let difference = targetY - textFieldY
        
            let targetOffSetForTopConstraint = topStackViewConstraint.constant + difference
            
            self.view.layoutIfNeeded()
            
            UIView.animate(withDuration: 0.25, animations: {
                self.topStackViewConstraint.constant = targetOffSetForTopConstraint
                self.view.layoutIfNeeded()
            })
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        UIView.animate(withDuration: 0.25) {
            self.topStackViewConstraint.constant = self.outerStackViewConstraintSize
            self.view.layoutIfNeeded()
        }
    }
}
