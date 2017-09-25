//
//  MessagingViewController.swift
//  Firechat
//
//  Created by Joshua Ramos on 9/10/17.
//  Copyright © 2017 Krevalent. All rights reserved.
//

import UIKit
import JSQMessagesViewController
extension String {
    public var first: String {
        return String(self[startIndex])
    }
}

class MessagingViewController: JSQMessagesViewController, JSQMessageAvatarImageDataSource  {
    var initialsForMessage: String = "A"
    
    func avatarImage() -> UIImage! {
        return getAvatar(uid: nil).avatarImage
    }
    
    func avatarHighlightedImage() -> UIImage! {
        return getAvatar(uid: nil).avatarHighlightedImage
    }
    
    func avatarPlaceholderImage() -> UIImage! {
        
        return getAvatar(uid: nil).avatarPlaceholderImage
    }
    
    func getAvatar(uid: String?) -> JSQMessagesAvatarImage {
        
        return JSQMessagesAvatarImageFactory.avatarImage(withUserInitials: getInitials(uid: uid), backgroundColor: #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1), textColor: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), font: UIFont.boldSystemFont(ofSize: 25), diameter: 30)
    }
    
    func getInitials(uid: String?) -> String {
        var initials = "A"
        if uid == nil {
            return initials
        } else {
            for user in usersArray {
                if let tempCheckUIDCheck = user["uid"] as? String {
                    if tempCheckUIDCheck == uid {
                        if let theName = user["name"] as? String {
                            initials = theName.components(separatedBy: " ").reduce("") { ($0 == "" ? "" : "\($0.characters.first!)") + "\($1.characters.first!)" }
                        }
                    }
                }
            }
        }
        return initials
    }
    
    let notificationCenter = NotificationCenter.default
    let firebaseManager = FirebaseManager.instance
    
    var channelName: String!
    var messages: [JSQMessage] = []
    var usersArray: [[String: Any]] = []
    
    
    lazy var outgoingBubbleImageView: JSQMessagesBubbleImage = self.setupOutgoingBubble()
    lazy var incomingBubbleImageView: JSQMessagesBubbleImage = self.setupIncomingBubble()

    override func viewDidLoad() {
        super.viewDidLoad()
    
        // Used as a default Channel
        navigationItem.title = "Firechat"
        
        firebaseManager.fetchUsers { (userInfo) in
            self.usersArray = userInfo
        }
        
        addObservers()
        setupViews()
        
    }
    
    private func setupViews()
    {
        // allows swiping to reveal the channelsVC
        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        // allows the tap to return
        self.view.addGestureRecognizer(self.revealViewController().tapGestureRecognizer())
    
        // Used so that JSQMessagesVC knows who is sending a text
        self.senderId = firebaseManager.currentUser?.uid
        self.senderDisplayName = firebaseManager.currentUser?.email
        
//        collectionView.collectionViewLayout.incomingAvatarViewSize = CGSize()
//        collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSize()
    }
    
    
    private func addObservers() {
        // Checks if a different channel has been selected
        notificationCenter.addObserver(self, selector: #selector(updateMessages(_:)), name: .channelChanged, object: nil)
        
        // Checks if there has been a change in the messages child on the data base
        firebaseManager.createListener { (snapshot) in
            if let recievedMessages = snapshot[self.navigationItem.title!] as? [[String: Any]] {
                // Handle the recieved messages
                self.parseMessages(recievedMessages)
            } else {
                // Empty array if no messages recieved
                self.messages = []
                self.collectionView.reloadData()
            }
        }
    }
    
    // Function to take recieved data and place them into the JSQMessagesVC
    private func parseMessages(_ recievedMessages: [[String: Any]]) {
        // Empty's the messages
        self.messages = []
        
        // Adds each message into the array
        for texts in recievedMessages {
            self.messages.append(JSQMessage(senderId: texts["sender"] as! String, displayName: texts["sender"] as! String, text: texts["message"] as! String))
        }
        
        // Reloads entire view with the recieved messages
        self.collectionView.reloadData()
    }
    
    // Updates the view controlled when a new channel is selected
    @objc private func updateMessages(_ notification: Notification) {
        guard let channelDictionary = notification.userInfo as? [String: String] else { return }
        
        // Checks for the new channel name
        if let channelName = channelDictionary["channelName"]
        {
            navigationItem.title = channelName
            self.channelName = channelName
        }
        
        // Requests for the new messages in a specific channel
        firebaseManager.fetchMessages { (snapshot) in
            if let recievedMessages = snapshot[self.navigationItem.title!] as? [[String: Any]] {
                self.parseMessages(recievedMessages)
            } else {
                self.messages = []
                self.collectionView.reloadData()
            }
        }
        
        // Empty's the text field when a new channel is selected
        self.inputToolbar.contentView.textView.text = nil
    }
    
    
    // Posts a message when the send button is pressed
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        guard let uid = firebaseManager.currentUser?.uid else {return}
        firebaseManager.postMessage(channelName: navigationItem.title!, senderID: uid, message: text, date: date.description)
        self.inputToolbar.contentView.textView.text = nil
    }
}
