//
//  Message.swift
//  GameOfChat
//
//  Created by Ricardo González Pacheco on 05/04/2020.
//  Copyright © 2020 Ricardo González Pacheco. All rights reserved.
//

import UIKit
import Firebase

class Message: NSObject {
    var message: String?
    var fromId: String?
    var toId: String?
    var timestamp: NSNumber?
    var urlMessageImage: String?
    
    init(dictionary: [String: Any]) {
        self.message = dictionary["message"] as? String
        self.fromId = dictionary["fromId"] as? String
        self.toId = dictionary["toId"] as? String
        self.timestamp = dictionary["timestamp"] as? NSNumber
        self.urlMessageImage = dictionary["url_message_image"] as? String
    }
    
    func chatPartnerId() -> String? {
        return toId == Auth.auth().currentUser?.uid ? fromId : toId
    }
    
}
