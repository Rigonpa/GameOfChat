//
//  ViewController.swift
//  GameOfChat
//
//  Created by Ricardo González Pacheco on 01/04/2020.
//  Copyright © 2020 Ricardo González Pacheco. All rights reserved.
//

import UIKit
import Firebase

class MessageController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "square.and.pencil"), style: .plain, target: self, action: #selector(handleNewMessage))

        isUserLoggedIn()
        
    }
    
    @objc func handleNewMessage() {
        let newMessageController = NewMessageController()
        present(UINavigationController(rootViewController: newMessageController), animated: true, completion: nil)
    }
    
    func isUserLoggedIn() {
        if Auth.auth().currentUser?.uid == nil {
            perform(#selector(handleLogout), with: nil, afterDelay: 0)
        } else {
            let uid = Auth.auth().currentUser?.uid
            Database.database().reference().child("users").child(uid!).observeSingleEvent(of: .value, with: {[weak self] (snapshot) in
                guard let self = self else { return }
                
                if let dictionary = snapshot.value as? [String: AnyObject] {
                    self.title = dictionary["name"] as? String
                }
                
            }, withCancel: nil)
        }
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

