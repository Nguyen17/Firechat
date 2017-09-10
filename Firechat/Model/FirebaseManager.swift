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
    
    // MARK: - Saving data methods
    
    func saveGoals(_ goals: [String], completion: ((Error?) -> Void)?)
    {
        guard let currentUser = currentUser else { return }
        
        ref.child("users/\(currentUser.uid)/goals").setValue(goals) { (error, ref) in
            guard let completion = completion else { return }
            
            if let error = error {
                completion(error)
            }
            else {
                completion(nil)
            }
        }
    }
    
    func appendGoal(_ goal: Goal, completion: ((Error?) -> Void)?)
    {
        guard let currentUser = currentUser else { return }
        
        ref.child("users/\(currentUser.uid)/goals").observeSingleEvent(of: .value, with: { [weak self] (snapshot) in
            if var goals = snapshot.value as? [String] {
                goals.append(goal.title)
                self?.saveGoals(goals, completion: completion)
            } else {
                var newArray:[String] = [String]()
                newArray.append(goal.title)
                self?.saveGoals(newArray, completion: completion)
            }
        })
    }
    
    // MARK: - Fetching data methods
    
    func fetchGoals(completion: (([String]?, Error?) -> Void)?)
    {
        guard let currentUser = currentUser else { return }
        
        ref.child("users/\(currentUser.uid)/goals").observeSingleEvent(of: .value, with: { (snapshot) in
            if let goals = snapshot.value as? [String] {
                if let completion = completion {
                    completion(goals, nil)
                }
            }
        }) { (error) in
            if let completion = completion {
                completion(nil, error)
            }
        }
    }
    
    // MARK: - Listener methods
    
    func createListener(completion: (([String]) -> Void)?) {
        if completion != nil {
            if let user = currentUser {
                ref.child("users").child(user.uid).child("goals").observe(.value, with: { (snapshot) in
                    if let goalsArray = snapshot.value as? [String] {
                        completion!(goalsArray)
                    }
                })
            }
        }
    }
}
