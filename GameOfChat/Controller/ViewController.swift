//
//  ViewController.swift
//  GameOfChat
//
//  Created by Ricardo González Pacheco on 01/04/2020.
//  Copyright © 2020 Ricardo González Pacheco. All rights reserved.
//

import UIKit
import Firebase

class ViewController: UITableViewController {

    override func viewDidLoad() {
        
        if Auth.auth().currentUser?.uid == nil {
            perform(#selector(handleLogout), with: nil, afterDelay: 0)
        }
        
//        let ref = Database.database().reference(fromURL: "https://gameofchat-fe9a7.firebaseio.com/")
//        ref.updateChildValues(["someValue" : "rororor"])
        
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
    }
    
    @objc func handleLogout() {
        
        do {
            try Auth.auth().signOut()
        } catch let error {
            print(error.localizedDescription)
        }
        
        let loginController = LoginController()
        loginController.modalPresentationStyle = .fullScreen
        loginController.modalTransitionStyle = .crossDissolve
        present(loginController, animated: true, completion: nil)
    }


}

