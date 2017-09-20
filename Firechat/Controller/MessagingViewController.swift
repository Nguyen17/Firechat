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
    var channelName: String!
    let notificationCenter = NotificationCenter.default
    
    var messages: [JSQMessage] = []
    
    lazy var outgoingBubbleImageView: JSQMessagesBubbleImage = self.setupOutgoingBubble()
    lazy var incomingBubbleImageView: JSQMessagesBubbleImage = self.setupIncomingBubble()
    
    let firebaseManager = FirebaseManager.instance

    override func viewDidLoad() {
        super.viewDidLoad()
        let email = firebaseManager.currentUser?.email
        self.senderId = email!
        self.senderDisplayName = email!
        addObservers()
        setupViews()
        navigationItem.title = "Firechat"
        
        firebaseManager.createListener { (snapshot) in
            if let recievedMessages = snapshot[self.navigationItem.title!] as? [[String: Any]] {
                self.parseMessages(recievedMessages)
            } else {
                self.messages = []
                self.collectionView.reloadData()
            }
        }
    }
    
    private func parseMessages(_ recievedMessages: [[String: Any]]) {
        self.messages = []
        for texts in recievedMessages {
            self.messages.append(JSQMessage(senderId: texts["sender"] as! String, displayName: texts["sender"] as! String, text: texts["message"] as! String))
        }
        self.collectionView.reloadData()
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return messages[indexPath.row]
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }

    private func addObservers() {
        notificationCenter.addObserver(self, selector: #selector(updateMessages(_:)), name: .channelChanged, object: nil)
    }
    
    @objc private func updateMessages(_ notification: Notification) {
        guard let channelDictionary = notification.userInfo as? [String: String] else { return }
        
        if let channelName = channelDictionary["channelName"]
        {
            navigationItem.title = channelName
            self.channelName = channelName
        }
        
        firebaseManager.fetchMessages { (snapshot) in
            if let recievedMessages = snapshot[self.navigationItem.title!] as? [[String: Any]] {
                self.parseMessages(recievedMessages)
            } else {
                self.messages = []
                self.collectionView.reloadData()
            }
        }
        
        self.inputToolbar.contentView.textView.text = ""
    }
    
    private func setupViews()
    {
        // allows the swipe reveal
        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        // allows the tap to return
        self.view.addGestureRecognizer(self.revealViewController().tapGestureRecognizer())

        collectionView.collectionViewLayout.incomingAvatarViewSize = CGSize()
        collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSize()
    }

    private func setupOutgoingBubble() -> JSQMessagesBubbleImage {
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        return bubbleImageFactory!.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleBlue())
    }

    private func setupIncomingBubble() -> JSQMessagesBubbleImage {
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        return bubbleImageFactory!.incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
    }

    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = messages[indexPath.row]

        if message.senderId == self.senderId {
            return outgoingBubbleImageView
        } else {
            return incomingBubbleImageView
        }
    }

    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        let message = messages[indexPath.item]

        if message.senderId == senderId {
            cell.textView?.textColor = UIColor.white
        } else {
            cell.textView?.textColor = UIColor.black
        }
        return cell
    }
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        firebaseManager.postMessage(channelName: navigationItem.title!, senderName: senderDisplayName, message: text, date: date.description)
        self.inputToolbar.contentView.textView.text = ""
    }
}
