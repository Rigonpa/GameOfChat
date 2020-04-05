//
//  LogChatController.swift
//  GameOfChat
//
//  Created by Ricardo González Pacheco on 05/04/2020.
//  Copyright © 2020 Ricardo González Pacheco. All rights reserved.
//

import UIKit
import Firebase

class ChatLogController: UICollectionViewController, UITextFieldDelegate {
    
    // This is the user that I am talking to, my recipient.
    var user: User? {
        didSet {
            title = user?.name
        }
    }
    
    lazy var inputTextField: UITextField = {
        let textField = UITextField(frame: .zero)
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Enter message..."
        textField.layer.cornerRadius = 5
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.2).cgColor
        return textField
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.backgroundColor = .white

        
        
        inputTextField.delegate = self
        
        setBottomView()
    }
    
    func setBottomView() {
        
        let bottomView = UIView()
        view.addSubview(bottomView)
        bottomView.translatesAutoresizingMaskIntoConstraints = false
        bottomView.backgroundColor = .lightGray
        NSLayoutConstraint.activate([
            bottomView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            bottomView.widthAnchor.constraint(equalTo: view.widthAnchor),
            bottomView.heightAnchor.constraint(equalToConstant: 80)
        ])
        
        let sendButton = UIButton(type: .system)
        bottomView.addSubview(sendButton)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.setTitle("Send", for: .normal)
        sendButton.setTitleColor(.black, for: .normal)
        sendButton.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
        NSLayoutConstraint.activate([
            sendButton.trailingAnchor.constraint(equalTo: bottomView.trailingAnchor, constant: -20),
            sendButton.centerYAnchor.constraint(equalTo: bottomView.centerYAnchor),
            sendButton.widthAnchor.constraint(equalToConstant: 50),
            sendButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        bottomView.addSubview(inputTextField)
        NSLayoutConstraint.activate([
            inputTextField.leadingAnchor.constraint(equalTo: bottomView.leadingAnchor, constant: 40),
            inputTextField.centerYAnchor.constraint(equalTo: bottomView.centerYAnchor),
            inputTextField.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor, constant: -20),
            inputTextField.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        let separatorLine = UIView()
        bottomView.addSubview(separatorLine)
        separatorLine.translatesAutoresizingMaskIntoConstraints = false
        separatorLine.backgroundColor = UIColor(r: 110, g: 110, b: 110)
        NSLayoutConstraint.activate([
            separatorLine.leadingAnchor.constraint(equalTo: bottomView.leadingAnchor),
            separatorLine.topAnchor.constraint(equalTo: bottomView.topAnchor),
            separatorLine.widthAnchor.constraint(equalTo: bottomView.widthAnchor),
            separatorLine.heightAnchor.constraint(equalToConstant: 0.5)
        ])
    }
    
    @objc func handleSend() {
        
        // Each message sent is composed by the message, fromId, toId and timestamp. Here that is loaded:
        
        guard let text = self.inputTextField.text else { return } // message
        guard let uid = Auth.auth().currentUser?.uid else { return } // fromId
        guard let user = user else { return } // toId
        guard let userId = user.userId else { return } // toId
        let timestamp = NSDate().timeIntervalSince1970.description // timestamp
        
        let values = ["message": text,
                      "fromId": uid,
                      "toId": userId,
                      "timestamp": timestamp]
        
        let ref = Database.database().reference().child("messages").childByAutoId()
        ref.updateChildValues(values)
    }
    
    // Puts enter to work
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleSend()
        return true
    }
    
}
