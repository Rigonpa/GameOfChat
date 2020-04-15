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
    
    var chatLogController: ChatLogController?
    
    let messageView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.isEditable = false
        textView.isSelectable = false
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
    
    lazy var messageImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "paperplane")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 16
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.isUserInteractionEnabled = true // To make the image tap to work it has to be lazy var!!!
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomTap)))
        return imageView
    }()
    
    @objc func handleZoomTap(_ tapGesture: UITapGestureRecognizer) {
        if let imageView = tapGesture.view as? UIImageView {
            // Pro tip: Do not perform a lot of custom logic inside of a view class
            self.chatLogController?.zoomInMessageImage(imageView)
        }
    }
    
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
        bubbleView.addSubview(messageImage)
        
        NSLayoutConstraint.activate([
            messageImage.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor),
            messageImage.topAnchor.constraint(equalTo: bubbleView.topAnchor),
            messageImage.widthAnchor.constraint(equalTo: bubbleView.widthAnchor),
            messageImage.heightAnchor.constraint(equalTo: bubbleView.heightAnchor)
        ])
        
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
    
    func myMessageOrYours(message: Message, user: User) {
        guard let profileImageURL = user.profileImage else { return }
        profileImage.setImageDownloaded(urlString: profileImageURL)
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        if uid == message.fromId {
            // My message - Blue
            bubbleView.backgroundColor = MessageCell.blueColor
            messageView.textColor = .white
            profileImage.isHidden = true
            
            bubbleLeadingAnchor?.isActive = false
            bubbleTrailingAnchor?.isActive = true
            
//            self.contentView.layoutIfNeeded()

        } else {
            //Your message - Grey
            bubbleView.backgroundColor = MessageCell.greyColor
            messageView.textColor = .darkGray
            profileImage.isHidden = false
            
            bubbleTrailingAnchor?.isActive = false // First deactivate then activate
            bubbleLeadingAnchor?.isActive = true

//            self.contentView.layoutIfNeeded()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
