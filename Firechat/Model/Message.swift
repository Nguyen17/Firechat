//
//  Message.swift
//  Firechat
//
//  Created by Amanuel Ketebo on 9/19/17.
//  Copyright © 2017 Krevalent. All rights reserved.
//

import Foundation

struct Message {
    var text: String
    var timeStamp: String
    var sender: String
    
    init(text: String, timeStamp: String, sender: String) {
        self.text = text
        self.timeStamp = timeStamp
        self.sender = sender
    }
    
    init(text: String, timeStamp: Date, sender: String) {
        self.text = text
        self.timeStamp = timeStamp.description
        self.sender = sender
    }
}
