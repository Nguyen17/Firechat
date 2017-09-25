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
        
        return JSQMessagesAvatarImageFactory.avatarImage(withUserInitials: getInitials(uid: uid), backgroundColor: getColor(uid: uid), textColor: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), font: UIFont.boldSystemFont(ofSize: 20), diameter: 30)
    }
    
    func getColor(uid: String?) -> UIColor {
        var color = #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1)
        if uid != nil {
            if let user = usersDictionary[uid!] as? [String: Any]{
                if let colorComponents = user["color"] as? [CGFloat] {
                    let red = colorComponents[0]
                    let green = colorComponents[1]
                    let blue = colorComponents[2]
                    
                    color = UIColor(displayP3Red: red, green: green, blue: blue, alpha: 1)
                }
            }
        }
        return color
    }
    
    func getInitials(uid: String?) -> String {
        var initials = "A"
        if uid != nil {
            if let user = usersDictionary[uid!] as? [String: Any]{
                if let userName = user["name"] as? String {
                    initials = userName.components(separatedBy: " ").reduce("") { ($0 == "" ? "" : "\($0.characters.first!)") + "\($1.characters.first!)" }
                }
            }
        }
        return initials.uppercased()
    }
    
    let notificationCenter = NotificationCenter.default
    let firebaseManager = FirebaseManager.instance
    
    var channelName: String!
    var messages: [JSQMessage] = []
    var usersDictionary: Dictionary<String, Any> = [:]
    // bool to tell collectionView to scroll to bottom
    var firstLoad = true
    
    lazy var outgoingBubbleImageView: JSQMessagesBubbleImage = self.setupOutgoingBubble()
    lazy var incomingBubbleImageView: JSQMessagesBubbleImage = self.setupIncomingBubble()

    override func viewDidLoad() {
        super.viewDidLoad()
    
        // Used as a default Channel
        navigationItem.title = "Firechat"

        firebaseManager.fetchUsers { (userInfo) in
            self.usersDictionary = userInfo
        }
        
        addObservers()
        setupViews()
    }
    
    
    private func setupViews()
    {
        // Used so that JSQMessagesVC knows who is sending a text
        self.senderId = firebaseManager.currentUser?.uid
        self.senderDisplayName = firebaseManager.currentUser?.email
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
        
        firebaseManager.createListenerUsers { (snapshot) in
            self.usersDictionary = snapshot
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
        self.firstLoad = true
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
                self.firstLoad = true
                self.collectionView.reloadData()
            }
        }
        
        // Empty's the text field when a new channel is selected
        self.inputToolbar.contentView.textView.text = nil
    }
    
    private func scrollToBottom() {
        let lastSectionIndex = (collectionView?.numberOfSections)! - 1
        let lastItemIndex = (collectionView?.numberOfItems(inSection: lastSectionIndex))! - 1
        let indexPath = NSIndexPath(item: lastItemIndex, section: lastSectionIndex)
        collectionView!.scrollToItem(at: indexPath as IndexPath, at: UICollectionViewScrollPosition.bottom, animated: false)
    }
    
    // Posts a message when the send button is pressed
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        guard let uid = firebaseManager.currentUser?.uid else {return}
        firebaseManager.postMessage(channelName: navigationItem.title!, senderID: uid, message: text, date: date.description)
        self.inputToolbar.contentView.textView.text = nil
    }
}
