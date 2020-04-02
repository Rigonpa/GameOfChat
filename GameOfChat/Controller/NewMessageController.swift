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
                let user = User(dictionary: dictionary)
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath)
        cell.textLabel?.text = users[indexPath.row].name
        cell.detailTextLabel?.text = users[indexPath.row].email
        return cell
    }
    
}

class UserCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
