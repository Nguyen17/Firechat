//
//  FirebaseManager.swift
//  GoalSetter
//
//  Created by Amanuel Ketebo on 9/3/17.
//  Copyright © 2017 Krevalent. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseDatabase

enum FirebaseLogoutError {
    case unableToSignOut
}

class FirebaseManager {
    
    static let instance = FirebaseManager()

    private var ref: DatabaseReference {
        return Database.database().reference()
    }
    
    var currentUser: User? {
        return Auth.auth().currentUser
    }
    
    // MARK: - Authentication methods
    
    func login(email: String, password: String, completion: ((User?, Error?) -> Void)?)
    {
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            guard let completion = completion else { return }
            completion(user, error)
        }
    }
    
    func logout(completion: (FirebaseLogoutError?) -> Void) {
        do {
            try Auth.auth().signOut()
            completion(nil)
        }
        catch {
            completion(FirebaseLogoutError.unableToSignOut)
        }
    }
}
