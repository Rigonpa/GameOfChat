//
//  ViewController.swift
//  GameOfChat
//
//  Created by Ricardo González Pacheco on 01/04/2020.
//  Copyright © 2020 Ricardo González Pacheco. All rights reserved.
//

import UIKit
import Firebase

class MessagesController: UITableViewController {
    
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
        newMessageController.modalTransitionStyle = .coverVertical
        present(UINavigationController(rootViewController: newMessageController), animated: true, completion: nil)
    }
    
    func isUserLoggedIn() {
        if Auth.auth().currentUser?.uid == nil {
            perform(#selector(handleLogout), with: nil, afterDelay: 0)
        } else {
            self.fetchUserAndSetupNavBarTitle()
        }
    }
    
    func fetchUserAndSetupNavBarTitle() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: {[weak self] (snapshot) in
            guard let self = self else { return }
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let user = User(dictionary: dictionary)
                self.fetchUserAndNameNavTabBar(user: user)
//                self.title = dictionary["name"] as? String
            }
            
        }, withCancel: nil)
    }
    
    func fetchUserAndNameNavTabBar(user: User) {
        
        let titleView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 40))
//        titleView.backgroundColor = .red
        self.navigationItem.titleView = titleView
        
        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        titleView.addSubview(contentView)
        NSLayoutConstraint.activate([
            contentView.centerXAnchor.constraint(equalTo: titleView.centerXAnchor),
            contentView.centerYAnchor.constraint(equalTo: titleView.centerYAnchor)
        ])
        
        let profileImage = UIImageView()
        profileImage.setProfileImageDownloaded(urlString: user.profileImage! as NSString)
        profileImage.translatesAutoresizingMaskIntoConstraints = false
        profileImage.layer.cornerRadius = 20
        profileImage.layer.masksToBounds = true
        contentView.addSubview(profileImage)
        NSLayoutConstraint.activate([
            profileImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            profileImage.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            profileImage.widthAnchor.constraint(equalToConstant: 40),
            profileImage.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        let nameLabel = UILabel()
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.text = user.name
        contentView.addSubview(nameLabel)
        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: profileImage.trailingAnchor, constant: 8),
            nameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            nameLabel.heightAnchor.constraint(equalTo: contentView.heightAnchor)
        ])
        
    }
    
    @objc func handleLogout() {
        
        do {
            try Auth.auth().signOut()
        } catch let error {
            print(error.localizedDescription)
        }
        
        let loginController = LoginController()
        loginController.messagesController = self
        loginController.modalPresentationStyle = .fullScreen
        loginController.modalTransitionStyle = .crossDissolve
        present(loginController, animated: true, completion: nil)
    }


}
