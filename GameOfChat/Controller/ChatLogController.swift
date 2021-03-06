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
UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // This is the user that I am talking to, my recipient.
    var user: User? {
        didSet {
            title = user?.name
            observeMessages()
        }
    }
    
    var messages = [Message]()
    
    func observeMessages() {
        guard let fromId = Auth.auth().currentUser?.uid else { return }
        guard let toId = self.user?.userId else { return }
        let userMessagesRef = Database.database().reference().child("user-messages").child(fromId).child(toId)
        userMessagesRef.observe(.childAdded, with: { (snapshot) in
            
            let messageId = snapshot.key
            let messageRef = Database.database().reference().child("messages").child(messageId)
            messageRef.observeSingleEvent(of: .value, with: {[weak self] (snapshot) in
                guard let self = self else { return }
                
                guard let dictionary = snapshot.value as? [String: AnyObject] else { return }
                self.messages.append(Message(dictionary: dictionary))
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                    // scroll to the last index
                    let indexPath = IndexPath(item: self.messages.count - 1, section: 0)
                    self.collectionView.scrollToItem(at: indexPath, at: .bottom, animated: true)
                }
                
//                if message.chatPartnerId() == self.user?.userId {
//                    self.messages.append(message)
//                    DispatchQueue.main.async {
//                        self.collectionView.reloadData()
//                    }
//                }
            }, withCancel: nil)
            
        }, withCancel: nil)
    }
    
    lazy var inputTextField: UITextField = {
        let textField = UITextField(frame: .zero)
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Enter message..."
        return textField
    }()
    
    var bottomViewBottomAnchor: NSLayoutConstraint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 56, right: 0)
//        collectionView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 80, right: 0)

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
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardDidShow), name: UIResponder.keyboardDidShowNotification, object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func handleKeyboardDidShow() {
        if messages.count > 0 { // To avoid this bug: Starting new chat crashes
            let indexPath = IndexPath(item: self.messages.count - 1, section: 0)
            collectionView.scrollToItem(at: indexPath, at: .top, animated: true)
        }
    }
    
    @objc func handleKeyboardWillShow(notification: Notification) {
        guard let keyboardFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue else { return }
        guard let keyboardDuration = (notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue else { return }


        // Moves the input area up
        bottomViewBottomAnchor?.constant = -keyboardFrame.height
        UIView.animate(withDuration: keyboardDuration) {
            self.view.layoutIfNeeded()
        }
        collectionView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 90, right: 0)
    }
    
    @objc func handleKeyboardWillHide(notification: Notification) {
        bottomViewBottomAnchor?.constant = 0
        collectionView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 56, right: 0)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CellId", for: indexPath) as? MessageCell else { return MessageCell()}
        
        cell.chatLogController = self
        
        cell.messageView.text = messages[indexPath.item].message
        guard let user = self.user else { return MessageCell()}
        cell.myMessageOrYours(message: messages[indexPath.item], user: user)
        
        if let message = messages[indexPath.item].message {
            //a text message
            cell.bubbleWidthAnchor?.constant = estimateFrameForText(text: message).width + 32
            cell.messageImage.isHidden = true
            cell.messageView.isHidden = false
        } else {
            //fall in here if its an image message
            cell.messageImage.setImageDownloaded(urlString: messages[indexPath.item].urlMessageImage)
            cell.bubbleWidthAnchor?.constant = 200
            cell.bubbleView.backgroundColor = .clear
            cell.messageImage.isHidden = false
            cell.messageView.isHidden = true  // For handling image zoom tap
        }
        
        return cell
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var height: CGFloat = 80
        let message = messages[indexPath.item]
        let width = UIScreen.main.bounds.width
        // get the estimated height how????
        if let text = message.message {
            height = estimateFrameForText(text: text).height + 20
        } else if let imageWidth = message.imageWidth, let imageHeight = message.imageHeight {
            // h1 / w1 = h2 / w2 -> h1 = h2 / w2 * w1
            height = CGFloat(imageHeight / imageWidth * 200)
        }
        
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
        
        let uploadImageView = UIImageView()
        bottomView.addSubview(uploadImageView)
        uploadImageView.translatesAutoresizingMaskIntoConstraints = false
        uploadImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleUploadTap)))
        uploadImageView.isUserInteractionEnabled = true
        uploadImageView.image = UIImage(systemName: "paperclip")
        
        NSLayoutConstraint.activate([
            uploadImageView.leadingAnchor.constraint(equalTo: bottomView.leadingAnchor, constant: 8),
            uploadImageView.centerYAnchor.constraint(equalTo: bottomView.centerYAnchor),
            uploadImageView.widthAnchor.constraint(equalToConstant: 44),
            uploadImageView.heightAnchor.constraint(equalToConstant: 44)
        ])

        
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
            inputTextField.leadingAnchor.constraint(equalTo: uploadImageView.trailingAnchor, constant: 8),
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
    
    @objc func handleUploadTap() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.allowsEditing = true
        imagePickerController.delegate = self
        imagePickerController.modalPresentationStyle = .currentContext // Removes presentation to hide bug with bottom view.
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        var selectedImageFromPicker: UIImage?
        
        if let editedImage = info[.editedImage] {
            selectedImageFromPicker = editedImage as? UIImage
        } else if let originalImage = info[.originalImage] {
            selectedImageFromPicker = originalImage as? UIImage
        }
        
        if let selectedImage = selectedImageFromPicker{
            self.imageMessageSent(image: selectedImage)
        }
        dismiss(animated: true, completion: nil)
        bottomViewBottomAnchor?.constant = 0
    }
    
    private func imageMessageSent(image: UIImage) {
        // 1st upload it to Firebase Storage
        let imageName = NSUUID().uuidString
        let ref = Storage.storage().reference().child("messages_images").child(imageName)
        
        guard let uploadData = image.jpegData(compressionQuality: 0.2) else { return }
        ref.putData(uploadData, metadata: nil) { (metadata, error) in
            if let error = error {
                print("Failed to upload image: ", error.localizedDescription)
                return
            }
            // 2nd Download from Firebase Storage
            Storage.storage().reference().child("messages_images").child(imageName).downloadURL { (url, err) in
                if let err = err {
                    print("Error downloading image file, \(err.localizedDescription)")
                    return
                }
                guard let url = url else { return }
                
                // 3rd upload the image message to Firebase Database.
                // Each image message sent is composed by the image, its width and height, fromId, toId and timestamp. Here that is loaded:
                let urlMessageImage = url.absoluteString // Image message
                
                let properties: [String: Any] = [
                    "urlMessageImage": urlMessageImage,
                    "imageWidth": image.size.width,
                    "imageHeight": image.size.height
                ]
                self.uploadImageMessageToFirebase(properties)
            }
        }
    }
    
    @objc func handleSend() {
        // Each text message sent is composed by the message, fromId, toId and timestamp. Here that is loaded:
        guard let message = self.inputTextField.text, message != "" else { return } // message
        let properties: [String: Any] = ["message": message]
        self.uploadImageMessageToFirebase(properties)
    }
    
    func uploadImageMessageToFirebase(_ properties: [String: Any]) {
        guard let fromId = Auth.auth().currentUser?.uid else { return } // fromId
        guard let toId = self.user?.userId else { return } // toId
        let timestamp: Int = Int(NSDate().timeIntervalSince1970) // timestamp
        
        var values = ["fromId": fromId,
                      "toId": toId,
                      "timestamp": timestamp] as [String : Any]
        
        properties.forEach { values[$0] = $1}
        
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
            
            let fromUserMessagesRef = Database.database().reference().child("user-messages").child(fromId).child(toId)
            fromUserMessagesRef.updateChildValues([messageId: 1])
            
            let toUserMessagesRef = Database.database().reference().child("user-messages").child(toId).child(fromId)
            toUserMessagesRef.updateChildValues([messageId: 1])
            
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        bottomViewBottomAnchor?.constant = 0
        dismiss(animated: true, completion: nil)
        bottomViewBottomAnchor?.constant = 0
    }
    
    // Puts enter key to work
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleSend()
        return true
    }
    
    var startingFrame: CGRect?
    var blackBackgroundView: UIView?
    var startingImageView: UIImageView?
    
    // My custom zooming logic
    func zoomInMessageImage(_ startingImageView: UIImageView) {
        
        self.startingImageView = startingImageView
        startingImageView.isHidden = true
        
        // Creating a red imageView of same extension than the messageImage frame
        startingFrame = startingImageView.superview?.convert(startingImageView.frame, to: nil)
        
        
        let zoomingImageView = UIImageView(frame: startingFrame!)
        zoomingImageView.backgroundColor = .red
        zoomingImageView.image = startingImageView.image
        zoomingImageView.isUserInteractionEnabled = true
        zoomingImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomOut)))
        
        if let keyWindow = UIApplication.shared.keyWindow {
            
            blackBackgroundView = UIView(frame: keyWindow.frame)
            blackBackgroundView?.backgroundColor = .black
            blackBackgroundView?.alpha = 0
            keyWindow.addSubview(blackBackgroundView!)
            
            keyWindow.addSubview(zoomingImageView)
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.blackBackgroundView?.alpha = 1
                
                // hf / wf = hi / wi -> hf = (hi / wi) * wf
                let height = self.startingFrame!.height / self.startingFrame!.width * keyWindow.frame.width
                
                zoomingImageView.frame = CGRect(x: 0, y: 0, width: keyWindow.frame.width, height: height)
                zoomingImageView.center = keyWindow.center
            }) { (completed: Bool) in
//                zoomOutImageView.removeFromSuperview()
            }
        }
    }
    
    @objc func handleZoomOut(tapGesture: UITapGestureRecognizer) {
        if let zoomOutImageView = tapGesture.view {
            //need to animate back out to controller
            zoomOutImageView.layer.cornerRadius = 16
            zoomOutImageView.layer.masksToBounds = true

            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                zoomOutImageView.frame = self.startingFrame!
                self.blackBackgroundView?.alpha = 0
            }) {[weak self] (completed: Bool) in
                guard let self = self else { return }
                zoomOutImageView.removeFromSuperview()
                self.startingImageView?.isHidden = false
            }
        }
    }
}
