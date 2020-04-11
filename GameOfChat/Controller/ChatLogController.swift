//
//  LogChatController.swift
//  GameOfChat
//
//  Created by Ricardo González Pacheco on 05/04/2020.
//  Copyright © 2020 Ricardo González Pacheco. All rights reserved.
//

import UIKit
import Firebase

class ChatLogController: UICollectionViewController, UITextFieldDelegate,
UICollectionViewDelegateFlowLayout {
    
    // This is the user that I am talking to, my recipient.
    var user: User? {
        didSet {
            title = user?.name
            
            observeMessages()
        }
    }
    
    var messages = [Message]()
    
    func observeMessages() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let userMessagesRef = Database.database().reference().child("user-messages").child(uid)
        userMessagesRef.observe(.childAdded, with: { (snapshot) in
            
            let messageId = snapshot.key
            let messageRef = Database.database().reference().child("messages").child(messageId)
            messageRef.observeSingleEvent(of: .value, with: {[weak self] (snapshot) in
                guard let self = self else { return }
                
                guard let dictionary = snapshot.value as? [String: AnyObject] else { return }
                let message = Message(dictionary: dictionary)
                
                if message.chatPartnerId() == self.user?.userId {
                    self.messages.append(message)
                    DispatchQueue.main.async {
                        self.collectionView.reloadData()
                    }
                }
            }, withCancel: nil)
            
        }, withCancel: nil)
    }
    
    lazy var inputTextField: UITextField = {
        let textField = UITextField(frame: .zero)
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Enter message..."
        return textField
    }()
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
    var bottomViewBottomAnchor: NSLayoutConstraint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 60, right: 0)
        collectionView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 80, right: 0)
        collectionView.register(MessageCell.self, forCellWithReuseIdentifier: "CellId")
        collectionView.backgroundColor = .white
        collectionView.alwaysBounceVertical = true
        inputTextField.delegate = self
        
        setBottomView()
        setupKeyboardObservers()
    }
    
    func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func handleKeyboardWillShow(notification: Notification) {
        guard let keyboardFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue else { return }
        guard let keyboardDuration = (notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue else { return }
        
        // Moves the input area up
        bottomViewBottomAnchor?.constant = -keyboardFrame.height
        UIView.animate(withDuration: keyboardDuration) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func handleKeyboardWillHide(notification: Notification) {
        bottomViewBottomAnchor?.constant = 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CellId", for: indexPath) as? MessageCell else { return MessageCell()}
        cell.messageView.text = messages[indexPath.item].message
        cell.myMessageOrYours(message: messages[indexPath.item], user: user!)
        cell.bubbleWidthAnchor?.constant = estimateFrameForText(text: messages[indexPath.item].message!).width + 32
        return cell
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var height: CGFloat = 80
        
        // get the estimated height how????
        if let text = messages[indexPath.item].message {
            height = estimateFrameForText(text: text).height + 20
        }
        let width = UIScreen.main.bounds.width
        return CGSize(width: width, height: height)
    }
    
    fileprivate func estimateFrameForText(text: String) -> CGRect {
        
        let size = CGSize(width: 250, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        
        return NSString(string: text).boundingRect(with: size,
                                                   options: options,
                                                   attributes:[NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)],
                                                   context: nil)
    
    }
    
    func setBottomView() {
        
        let bottomView = UIView()
        view.addSubview(bottomView)
        bottomView.translatesAutoresizingMaskIntoConstraints = false
        bottomView.backgroundColor = .white
        
        bottomViewBottomAnchor = bottomView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        NSLayoutConstraint.activate([
            bottomView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomViewBottomAnchor!,
            bottomView.widthAnchor.constraint(equalTo: view.widthAnchor),
            bottomView.heightAnchor.constraint(equalToConstant: 80)
        ])
        
        let sendButton = UIButton(type: .system)
        bottomView.addSubview(sendButton)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.setTitle("Send", for: .normal)
        sendButton.setTitleColor(MessageCell.blueColor, for: .normal)
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
        guard let fromId = Auth.auth().currentUser?.uid else { return } // fromId
        guard let user = user else { return } // toId
        guard let toId = user.userId else { return } // toId
        let timestamp: Int = Int(NSDate().timeIntervalSince1970) // timestamp

        let values = ["message": text,
                      "fromId": fromId,
                      "toId": toId,
                      "timestamp": timestamp] as [String : Any]
        
        let ref = Database.database().reference().child("messages").childByAutoId()
//        ref.updateChildValues(values)
        ref.updateChildValues(values) {[weak self] (error, ref) in
            guard let self = self else { return }
            if let error = error {
                print(error.localizedDescription)
                return
            }
            self.inputTextField.text = nil
            
            guard let messageId = ref.key else { return }

            let fromUserMessagesRef = Database.database().reference().child("user-messages").child(fromId)
            fromUserMessagesRef.updateChildValues([messageId: 1])

            let toUserMessagesRef = Database.database().reference().child("user-messages").child(toId)
            toUserMessagesRef.updateChildValues([messageId: 1])

        }
        
    }
    
    // Puts enter to work
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleSend()
        return true
    }
    
}
