//
//  NewMessageController.swift
//  GameOfChat
//
//  Created by Ricardo González Pacheco on 02/04/2020.
//  Copyright © 2020 Ricardo González Pacheco. All rights reserved.
//

import UIKit
import Firebase

class NewMessageController: UITableViewController {
    
    var users = [User]()
    var messagesController = MessagesController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(backHandle))
        tableView.register(UserCell.self, forCellReuseIdentifier: "cellId")
        fetchUsers()
        
    }
    
    @objc func backHandle() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func fetchUsers() {
        Database.database().reference().child("users").observe(.childAdded, with: {[weak self] (snapshot) in
            guard let self = self else { return }
            print(snapshot)
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let user = User(dictionary: dictionary, userId: snapshot.key)
                self.users.append(user)
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }, withCancel: nil)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath) as! UserCell
        cell.textLabel?.text = users[indexPath.row].name
        cell.detailTextLabel?.text = users[indexPath.row].email
        
        guard let profileImagePath = users[indexPath.row].profileImage else { return UITableViewCell()}
        cell.profileImage.setProfileImageDownloaded(urlString: profileImagePath)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            let user = self.users[indexPath.row]
            self.messagesController.showChatControllerForUser(user: user)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
}
