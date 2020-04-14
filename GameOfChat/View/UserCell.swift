//
//  UserCell.swift
//  GameOfChat
//
//  Created by Ricardo González Pacheco on 06/04/2020.
//  Copyright © 2020 Ricardo González Pacheco. All rights reserved.
//

import UIKit
import Firebase

class UserCell: UITableViewCell {
    
//    var message: Message? {
//        didSet {
//            I am fixing the setup of the cell with the setupUserCell method
//            instead of using this didset. Both ways apply
//        }
//    }
    
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
        
        detailTextLabel.font = .systemFont(ofSize: 12)
    }
    
    let timeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
//        label.text = "HH:MM"
        label.font = .italicSystemFont(ofSize: 12)
        label.textColor = .darkGray
        return label
    }()
    
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
        
        contentView.addSubview(timeLabel)
        
        NSLayoutConstraint.activate([
            timeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 10),
            timeLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            timeLabel.widthAnchor.constraint(equalToConstant: 80),
            timeLabel.heightAnchor.constraint(equalTo: textLabel!.heightAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUserCell(message: Message) {
        var chatPartnerId: String?
        
        chatPartnerId = message.chatPartnerId()
        
        self.detailTextLabel?.text = message.message
        guard let chatPartnerId1 = chatPartnerId else { return }
        let ref = Database.database().reference().child("users").child(chatPartnerId1)
        ref.observeSingleEvent(of: .value, with: { [weak self] (snapshot) in
            guard let self = self else { return }
            
            let dictionary = snapshot.value as? [String: AnyObject]
            guard let dictionary1 = dictionary else { return }
            self.textLabel?.text = dictionary1["name"] as? String
            self.profileImage.setImageDownloaded(urlString: dictionary1["profileImage"] as? String)
            self.setTimeLabel(message: message)

        }, withCancel: nil)
        
    }
    
    func setTimeLabel(message: Message) {
        
        guard let seconds = message.timestamp?.doubleValue else { return }
        let timestampDate = Date(timeIntervalSince1970: seconds)

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm a"
        
        self.timeLabel.text = dateFormatter.string(from: timestampDate)

    }
}

