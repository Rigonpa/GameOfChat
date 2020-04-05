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
        cell.profileImage.setProfileImageDownloaded(urlString: profileImagePath as NSString)
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

class UserCell: UITableViewCell {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        guard let textLabel = self.textLabel, let detailTextLabel = self.detailTextLabel else { return }
        textLabel.frame = CGRect(
            x: 100,
            y: textLabel.frame.origin.y - 3,
            width: textLabel.frame.width,
            height: textLabel.frame.height)
        detailTextLabel.frame = CGRect(
            x: 100,
            y: detailTextLabel.frame.origin.y + 3,
            width: detailTextLabel.frame.width,
            height: detailTextLabel.frame.height)
        
        detailTextLabel.font = UIFont.italicSystemFont(ofSize: 12.0)
    }
    
    lazy var profileImage: UIImageView = {
        let iv = UIImageView(frame: .zero)
        iv.layer.cornerRadius = 30
        iv.layer.masksToBounds = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
                
        contentView.addSubview(profileImage)
        
        NSLayoutConstraint.activate([
            profileImage.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            profileImage.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            profileImage.widthAnchor.constraint(equalToConstant: 60),
            profileImage.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
