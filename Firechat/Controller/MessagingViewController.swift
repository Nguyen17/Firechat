//
//  MessagingViewController.swift
//  Firechat
//
//  Created by Joshua Ramos on 9/10/17.
//  Copyright © 2017 Krevalent. All rights reserved.
//

import UIKit
import JSQMessagesViewController

class MessagingViewController: JSQMessagesViewController {
    let notificationCenter = NotificationCenter.default
    let firebaseManager = FirebaseManager.instance
    
    var channelName: String!
    var messages: [JSQMessage] = []
    
    lazy var outgoingBubbleImageView: JSQMessagesBubbleImage = self.setupOutgoingBubble()
    lazy var incomingBubbleImageView: JSQMessagesBubbleImage = self.setupIncomingBubble()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Used so that JSQMessagesVC knows who is sending a text
        let email = firebaseManager.currentUser?.email
        self.senderId = email!
        self.senderDisplayName = email!

        // Used as a default Channel
        navigationItem.title = "Firechat"
        
        addObservers()
        setupViews()
    }
    
    private func setupViews()
    {
        // allows swiping to reveal the channelsVC
        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        // allows the tap to return
        self.view.addGestureRecognizer(self.revealViewController().tapGestureRecognizer())
        
        collectionView.collectionViewLayout.incomingAvatarViewSize = CGSize()
        collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSize()
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
        firebaseManager.postMessage(channelName: navigationItem.title!, senderName: senderDisplayName, message: text, date: date.description)
        self.inputToolbar.contentView.textView.text = nil
    }
}
