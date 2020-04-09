//
//  MessageCell.swift
//  GameOfChat
//
//  Created by Ricardo González Pacheco on 08/04/2020.
//  Copyright © 2020 Ricardo González Pacheco. All rights reserved.
//

import UIKit

class MessageCell: UICollectionViewCell {
    
    let messageView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.backgroundColor = .clear
        textView.textColor = .white
        return textView
    }()
    
    let bubbleView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(r: 0, g: 137, b: 249)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        return view
    }()
    
    var bubbleWidthAnchor: NSLayoutConstraint?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(bubbleView)
        contentView.addSubview(messageView)
        
        
        bubbleWidthAnchor = bubbleView.widthAnchor.constraint(equalToConstant: 300)
        NSLayoutConstraint.activate([
            bubbleView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
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
}
