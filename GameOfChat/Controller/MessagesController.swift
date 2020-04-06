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
    
    var messages = [Message]()
    var messagesDictionary = [String: Message]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "square.and.pencil"), style: .plain, target: self, action: #selector(handleNewMessage))

        tableView.register(UserCell.self, forCellReuseIdentifier: "CellId")
        
        isUserLoggedIn() // **************************
    }
    
    @objc func handleNewMessage() {
        let newMessageController = NewMessageController()
        newMessageController.messagesController = self
        newMessageController.modalTransitionStyle = .coverVertical
        present(UINavigationController(rootViewController: newMessageController), animated: true, completion: nil)
    }
    
    func isUserLoggedIn() {
        if Auth.auth().currentUser?.uid == nil {
            perform(#selector(handleLogout), with: nil, afterDelay: 0)
        } else {
            self.fetchUserAndSetupNavBarTitle()
            
            fetchMessages() // **************************
        }
    }
    
    func fetchMessages() {
        Database.database().reference().child("messages").observe(.childAdded, with: { [weak self] (snapshot) in
            guard let self = self else { return }
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
                
                let message = Message(dictionary: dictionary)
//                self.messages.append(message)
                
                guard let toId = message.toId else { return }
                self.messagesDictionary[toId] = message
                self.messages = Array(self.messagesDictionary.values)
                self.messages.sort { (message1, message2) -> Bool in
                    return message1.timestamp!.intValue > message2.timestamp!.intValue
                }
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                
            }
            }, withCancel: nil)
    }
    
    func fetchUserAndSetupNavBarTitle() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: {[weak self] (snapshot) in
            guard let self = self else { return }
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let userId = snapshot.key
                let user = User(dictionary: dictionary, userId: userId)
                self.fetchProfileImageAndNameNavTabBar(user: user)
            }
            
        }, withCancel: nil)
    }
    
//    class NavigationItemTitleView: UIView {
//        override var intrinsicContentSize: CGSize {
//            // return UILayoutFittingExpandedSize
//            return UIView.layoutFittingExpandedSize
//        }
//    }
    
    func fetchProfileImageAndNameNavTabBar(user: User) {
        
        let myTitleView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 40))

        let contentView = UIView()
        myTitleView.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentView.centerXAnchor.constraint(equalTo: myTitleView.centerXAnchor),
            contentView.centerYAnchor.constraint(equalTo: myTitleView.centerYAnchor)
        ])
        
        let profileImage = UIImageView()
        contentView.addSubview(profileImage)
        profileImage.setProfileImageDownloaded(urlString: user.profileImage)
        profileImage.translatesAutoresizingMaskIntoConstraints = false
        profileImage.layer.cornerRadius = 20
        profileImage.layer.masksToBounds = true
        NSLayoutConstraint.activate([
            profileImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            profileImage.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            profileImage.widthAnchor.constraint(equalToConstant: 40),
            profileImage.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        let nameLabel = UILabel()
        contentView.addSubview(nameLabel)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.text = user.name
        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: profileImage.trailingAnchor, constant: 8),
            nameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            nameLabel.heightAnchor.constraint(equalTo: contentView.heightAnchor)
        ])
        
        let button = UIButton()
        myTitleView.addSubview(button)
        button.backgroundColor = .clear
        button.translatesAutoresizingMaskIntoConstraints = false
        //button.addTarget(self, action: #selector(showChatController), for: .touchUpInside)
        NSLayoutConstraint.activate([
            button.leadingAnchor.constraint(equalTo: profileImage.leadingAnchor),
            button.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            button.widthAnchor.constraint(equalTo: myTitleView.widthAnchor),
            button.heightAnchor.constraint(equalTo: myTitleView.heightAnchor)
        ])
        
        self.navigationItem.titleView = myTitleView

//        let tap = UITapGestureRecognizer(target: self, action: #selector(showChatController))
//        tap.numberOfTapsRequired = 1
//        alltitleView.isUserInteractionEnabled = true
//        alltitleView.addGestureRecognizer(tap)

    }
    
    @objc func showChatControllerForUser(user: User) {
        let chatLogController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
        chatLogController.user = user
        self.navigationController?.pushViewController(chatLogController, animated: true)
    }
    
    @objc func handleLogout() {
        
        do {
            try Auth.auth().signOut()
            self.navigationItem.titleView = UIView()
        } catch let error {
            print(error.localizedDescription)
        }
        
        let loginController = LoginController()
        loginController.messagesController = self
        loginController.modalPresentationStyle = .fullScreen
        loginController.modalTransitionStyle = .crossDissolve
        present(loginController, animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "CellId", for: indexPath) as! UserCell
        cell.setUserCell(message: messages[indexPath.row])
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }


}
