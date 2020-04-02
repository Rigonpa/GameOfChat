//
//  UserCell.swift
//  GameOfChat
//
//  Created by Ricardo González Pacheco on 02/04/2020.
//  Copyright © 2020 Ricardo González Pacheco. All rights reserved.
//

import UIKit

class User: NSObject {
    var email: String?
    var name: String?
    
    init(dictionary: [String: Any]) {
        self.email = dictionary["email"] as? String? ?? ""
        self.name = dictionary["name"] as? String? ?? ""
    }
}
