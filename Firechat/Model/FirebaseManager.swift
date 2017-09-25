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

struct FirebaseNodes {
    static let channels = "channels"
}

class FirebaseManager {
    static let instance = FirebaseManager()
    let notificationCenter = NotificationCenter.default
    
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
    
    func signup(userName: String, email: String, password: String, color: UIColor, completion: ((User?, Error?) -> Void)?) {
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            guard let completion = completion else { return }
            
            completion(user, error)
            guard let user = user else {return}
            let components = color.cgColor.components!
            let red = components[0]
            let green = components[1]
            let blue = components[2]
  
            if error == nil {
                let userData = ["provider": user.providerID, "email": user.email!, "name": userName, "color": [red, green, blue]] as [String : Any]
                self.postUserInfo(uid: user.uid, userData: userData)
            }
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
        
        notificationCenter.post(name: .authStatusChanged, object: nil)
    }
    
    // MARK: - Fetching and updating channels methods

    func fetchChannels(completion: @escaping (([String]?, Error?) -> Void))
    {
        ref.child(FirebaseNodes.channels).observeSingleEvent(of: .value, with: { (snapshot) in
            if let channel = snapshot.value as? [String] {
                completion(channel, nil)
            }
        }) { (error) in
                completion(nil, error)
        }
    }
    
    func updateChannels(channelArray: [String]) {
        self.ref.child(FirebaseNodes.channels).setValue(channelArray)
    }
    
    // MARK: - Fetching and updating messages
    
    func postMessage(channelName: String, senderID: String, message: String, date: String) {
        ref.child("messages/\(channelName)/").observeSingleEvent(of: .value, with: { [weak self] (snapshot) in
            let message = ["sender": senderID, "message": message, "timeStamp": date] as [String : Any]
            
            if var channelMessages = snapshot.value as? [[String: Any]] {
                channelMessages.append(message)
                self?.ref.child("messages/\(channelName)/").setValue(channelMessages)
            }
            else
            {
                self?.ref.child("messages/\(channelName)/").setValue([message])
            }
        }) { (error) in
            // Handle error
        }
    }
    
    func postUserInfo(uid: String, userData: Dictionary<String, Any>) {
        Database.database().reference().child("users").child(uid).updateChildValues(userData)
    }
    
    func fetchMessages(completion: @escaping (([String: Any]) -> Void)) {
        ref.child("messages").observeSingleEvent(of: .value) { (snapshot) in
            if let messages = snapshot.value as? [String: Any] {
                completion(messages)
            }
        }
    }
    
    func fetchUsers(completion: @escaping (([String: Any]) -> Void)) {
        ref.child("users").observeSingleEvent(of: .value) { (snapshot) in
            if let users = snapshot.value as? [String: Any] {
            completion(users)
            }
        }
    }
    // MARK: - Listening for updates
    func createListener(completion: @escaping (([String: Any]) -> Void)) {
        ref.child("messages").observe(.value, with: { (snapshot) in
            if let messages = snapshot.value as? [String: Any] {
                completion(messages)
            }
        })
    }
    
    func createListenerUsers(completion: @escaping (([String: Any]) -> Void)) {
        ref.child("users").observe(.value, with: { (snapshot) in
            if let messages = snapshot.value as? [String: Any] {
                completion(messages)
            }
        })
    }
}
