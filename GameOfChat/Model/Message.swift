//
//  Message.swift
//  GameOfChat
//
//  Created by Ricardo González Pacheco on 05/04/2020.
//  Copyright © 2020 Ricardo González Pacheco. All rights reserved.
//

import UIKit

class Message: NSObject {
    var message: String?
    var fromId: String?
    var toId: String?
    var timestamp: NSNumber?
    
    init(dictionary: [String: Any]) {
        self.message = dictionary["message"] as? String
        self.fromId = dictionary["fromId"] as? String
        self.toId = dictionary["toId"] as? String
        self.timestamp = dictionary["timestamp"] as? NSNumber
    }
    
}
