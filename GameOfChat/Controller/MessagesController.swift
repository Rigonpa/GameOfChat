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
        }
    }
    
    func fetchUserAndSetupNavBarTitle() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: {[weak self] (snapshot) in
            guard let self = self else { return }
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let userId = snapshot.key
                let user = User(dictionary: dictionary, userId: userId)
                self.setupNavBarWithUser(user: user)
            }
            
            }, withCancel: nil)
        
        messages.removeAll()
        messagesDictionary.removeAll()
        tableView.reloadData()
        fetchUserMessages()
    }
    
    func fetchUserMessages() {
        guard let fromId = Auth.auth().currentUser?.uid else { return }
        let userMessagesRef = Database.database().reference().child("user-messages").child(fromId)
        userMessagesRef.observe(.childAdded, with: { (snapshot) in
            
            let toId = snapshot.key // Stairs
            Database.database().reference().child("user-messages").child(fromId).child(toId).observe(.childAdded, with: { (snapshot) in
                let messageId = snapshot.key
                self.fetchSpecificMessage(messageId: messageId)
            }, withCancel: nil)
        }, withCancel: nil)
    }
    
    private func fetchSpecificMessage(messageId: String) {
        
        let messageRef = Database.database().reference().child("messages").child(messageId)
        messageRef.observeSingleEvent(of: .value, with: {[weak self] (snapshot) in
            guard let self = self else { return }
            
            guard let dictionary = snapshot.value as? [String: AnyObject] else { return }
            
            let message = Message(dictionary: dictionary)
            
            guard let chatPartnerId = message.chatPartnerId() else { return } // From toId to chatPartnerId in episode 13
            self.messagesDictionary[chatPartnerId] = message
            self.attemptReloadOfTable()
            
        }, withCancel: nil)
    }
    
    private func attemptReloadOfTable() {
        self.timer?.invalidate()
//        print("we just canceled our timer")
        self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.handleReloadTable), userInfo: nil, repeats: false)
//        print("schedule a table reload in 0.1 sec")
    }
    
    var timer: Timer? // With this workaround we just launch reloadData once when all messages are fetched.
    
    @objc func handleReloadTable() {
        self.messages = Array(self.messagesDictionary.values)
        self.messages.sort { (message1, message2) -> Bool in
            return message1.timestamp!.intValue > message2.timestamp!.intValue
        }
        
        //this will crash because of background thread, so lets call this on dispatch_async main thread
        DispatchQueue.main.async {
            print("we reloaded the table")
            self.tableView.reloadData()
        }
    }
    
    //    class NavigationItemTitleView: UIView {
    //        override var intrinsicContentSize: CGSize {
    //            // return UILayoutFittingExpandedSize
    //            return UIView.layoutFittingExpandedSize
    //        }
    //    }
    
    func setupNavBarWithUser(user: User) {
        
        let myTitleView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 40))
        
        let containerView = UIView()
        myTitleView.addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            containerView.centerXAnchor.constraint(equalTo: myTitleView.centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: myTitleView.centerYAnchor)
        ])
        
        let profileImage = UIImageView()
        containerView.addSubview(profileImage)
        profileImage.setImageDownloaded(urlString: user.profileImage)
        profileImage.translatesAutoresizingMaskIntoConstraints = false
        profileImage.layer.cornerRadius = 20
        profileImage.layer.masksToBounds = true
        NSLayoutConstraint.activate([
            profileImage.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
            profileImage.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            profileImage.widthAnchor.constraint(equalToConstant: 40),
            profileImage.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        let nameLabel = UILabel()
        containerView.addSubview(nameLabel)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.text = user.name
        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: profileImage.trailingAnchor, constant: 8),
            nameLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            nameLabel.heightAnchor.constraint(equalTo: containerView.heightAnchor)
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        dismiss(animated: true) { [weak self] in
            guard let self = self else{ return }
            let message = self.messages[indexPath.row]
            guard let chatUserId = message.chatPartnerId() else { return }
            let chatUserRef = Database.database().reference().child("users").child(chatUserId)
            chatUserRef.observeSingleEvent(of: .value, with: {[weak self] (snapshot) in
                guard let self = self else { return }
                guard let dictionary = snapshot.value as? [String: AnyObject] else { return }
                let userId = snapshot.key
                let user = User(dictionary: dictionary, userId: userId)
                
                self.showChatControllerForUser(user: user)
                }, withCancel: nil)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
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
