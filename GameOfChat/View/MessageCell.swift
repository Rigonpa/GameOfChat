//
//  MessageCell.swift
//  GameOfChat
//
//  Created by Ricardo González Pacheco on 08/04/2020.
//  Copyright © 2020 Ricardo González Pacheco. All rights reserved.
//

import UIKit
import Firebase

class MessageCell: UICollectionViewCell {
    
    let messageView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.backgroundColor = .clear
//        textView.textColor = .white
        return textView
    }()
    
    let bubbleView: UIView = {
        let view = UIView()
//        view.backgroundColor = .darkGray
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        return view
    }()
    
    let profileImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "paperplane")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 16
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    var bubbleLeadingAnchor: NSLayoutConstraint?
    var bubbleTrailingAnchor: NSLayoutConstraint?
    var bubbleWidthAnchor: NSLayoutConstraint?
    static var blueColor = UIColor(r: 0, g: 137, b: 249)
    static var greyColor = UIColor(r: 240, g: 240, b: 240)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        // The order in which elements are added in the views hierarchy matters.
        contentView.addSubview(bubbleView)
        contentView.addSubview(profileImage)
        contentView.addSubview(messageView)
        
        NSLayoutConstraint.activate([
            profileImage.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            profileImage.bottomAnchor.constraint(equalTo: bottomAnchor),
            profileImage.widthAnchor.constraint(equalToConstant: 32),
            profileImage.heightAnchor.constraint(equalToConstant: 32)
        ])
        
        bubbleLeadingAnchor = bubbleView.leadingAnchor.constraint(equalTo: profileImage.trailingAnchor, constant: 8)
        bubbleTrailingAnchor = bubbleView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8)
        bubbleWidthAnchor = bubbleView.widthAnchor.constraint(equalToConstant: 250)
        NSLayoutConstraint.activate([
            bubbleTrailingAnchor!,
//            bubbleLeadingAnchor!,
            bubbleView.topAnchor.constraint(equalTo: contentView.topAnchor),
            bubbleWidthAnchor!, // !: I am sure always have value here as 5-lines-above line has been typed out
            bubbleView.heightAnchor.constraint(equalTo: contentView.heightAnchor)
        ])
        
        NSLayoutConstraint.activate([
            messageView.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: 8),
            messageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            messageView.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -8),
            messageView.heightAnchor.constraint(equalTo: contentView.heightAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func myMessageOrYours(message: Message, user: User) {
        guard let profileImageURL = user.profileImage else { return }
        profileImage.setProfileImageDownloaded(urlString: profileImageURL)
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        if uid == message.fromId {
            // My message - Blue
            bubbleView.backgroundColor = MessageCell.blueColor
            messageView.textColor = .white
            profileImage.isHidden = true
            
            bubbleLeadingAnchor?.isActive = false
            bubbleTrailingAnchor?.isActive = true

        } else {
            //Your message - Grey
            bubbleView.backgroundColor = MessageCell.greyColor
            messageView.textColor = .darkGray
            profileImage.isHidden = false
            
            bubbleLeadingAnchor?.isActive = true
            bubbleTrailingAnchor?.isActive = false
        }
    }
}
