//
//  Controller+handlers.swift
//  GameOfChat
//
//  Created by Ricardo González Pacheco on 03/04/2020.
//  Copyright © 2020 Ricardo González Pacheco. All rights reserved.
//

import UIKit
import Firebase

extension LoginController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: - Profile Image Handler
    @objc func handleSelectProfileImageView() {
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        var selectedImageFromPicker: UIImage?
        
        if let editedImage = info[.editedImage] {
            selectedImageFromPicker = editedImage as? UIImage
        } else if let originalImage = info[.originalImage] {
            selectedImageFromPicker = originalImage as? UIImage
        }
        
        if let selectedImage = selectedImageFromPicker{
            profileImageView.image = selectedImage
        }

        profileImageView.layer.cornerRadius = 5
        profileImageView.layer.borderWidth = 1
        profileImageView.layer.borderColor = UIColor.white.withAlphaComponent(0.2).cgColor
        profileImageView.layer.masksToBounds = true
        
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Login and Register handler
    
    @objc func handleLoginRegisterAction() {
        if loginRegisterSegmentedControl.selectedSegmentIndex == 1 {
            self.handleRegister()
        } else {
            self.handleLogin()
        }
    }
    
    func handleLogin() {
        guard let email = emailTextField.text, let password = passwordTextField.text else { return }
        Auth.auth().signIn(withEmail: email, password: password) { (authDataResponse, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            //SUCCESS
            self.titleDelegate?.updateTitle()
            sleep(1)
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func handleRegister() {
        
        guard let email = emailTextField.text, let password = passwordTextField.text,
            let name = nameTextField.text else { return }
        // - 1. Authenticate the new user
        Auth.auth().createUser(withEmail: email, password: password) {[weak self] (authDataResult: AuthDataResult?, error) in
            guard let self = self else { return }
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            //SUCCESS! We start to upload all data (image, name and email)
            
            let imageName = UUID().uuidString
            
            let storageRef = Storage.storage().reference().child(imageName)
            guard let imageData = self.profileImageView.image?.pngData() else { return }
            
            // - 2. Upload the profile image url string to firebase storage
            storageRef.putData(imageData, metadata: nil) {(_, error) in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
                // - 3. Download the profile image url string from firebase storage
                Storage.storage().reference().child(imageName).downloadURL { (url, err) in
                    if let err = err {
                        print("Error downloading image file, \(err.localizedDescription)")
                        return
                    }
                    guard let url = url else { return }
                    
                    // - 4. Fill in the values array is supposed to be uploaded to firebase database
                    let values = ["name": name, "email": email, "profileImage": url.absoluteString]
                    guard let uid = authDataResult?.user.uid else { return }
                    self.uploadDataToDatabase(uid: uid, values: values)
                    self.titleDelegate?.updateTitle()
                    sleep(1)
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    
    func uploadDataToDatabase(uid: String?, values: [String: String]) {
        
        // - 5. Upload the new user info to firebase database.
        let ref = Database.database().reference(fromURL: "https://gameofchat-fe9a7.firebaseio.com/")
        let refTop = ref.child("users").child(uid!)
        refTop.updateChildValues(values) { (error, ref) in
            
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            // SUCCESS!
        }
    }
    
    // MARK: - Segmented control change handler
    
    @objc func handleSegmentedControlChange() {
        
        profileImageView.image = UIImage(named: "gameofthrones_splash")
        profileImageView.isUserInteractionEnabled = loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? false : true
        profileImageView.layer.borderWidth = 0
        nameTextField.text = ""
        emailTextField.text = ""
        passwordTextField.text = ""
        
        
        // 5th: password text field height changes with selected control changes
        passwordTextFieldHeightAnchor?.isActive = false
        passwordTextFieldHeightAnchor = loginRegisterSegmentedControl.selectedSegmentIndex == 0 ?
            passwordTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/2) :
            passwordTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/3)
        passwordTextFieldHeightAnchor?.isActive = true
        
        // 4th: email text field height changes with selected control changes
        emailTextFieldHeightAnchor?.isActive = false
        emailTextFieldHeightAnchor = emailTextField.heightAnchor.constraint(
            equalTo: inputsContainerView.heightAnchor,
            multiplier: loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 1/2 : 1/3)
        emailTextFieldHeightAnchor?.isActive = true
        
        // 3rd: name text field hides or not with selected control changes
        nameTextFieldHeightAnchor?.isActive = false
        nameTextFieldHeightAnchor = nameTextField.heightAnchor.constraint(
            equalTo: inputsContainerView.heightAnchor,
            multiplier: loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 0 : 1/3)
        nameTextFieldHeightAnchor?.isActive = true
        
        // 2nd: inputs container view height change with selected control changes
        inputContainerViewHeightAnchor?.isActive = false
        inputContainerViewHeightAnchor?.constant = loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 100 : 150
//        inputContainerViewHeightAnchor = loginRegisterSegmentedControl.selectedSegmentIndex == 1 ?
//            inputsContainerView.heightAnchor.constraint(equalToConstant: 150) :
//            inputsContainerView.heightAnchor.constraint(equalToConstant: 100)
        inputContainerViewHeightAnchor?.isActive = true
        
        
        // 1st: Button value change with selected control changes
        let title = loginRegisterSegmentedControl.titleForSegment(at: loginRegisterSegmentedControl.selectedSegmentIndex)
        loginRegisterButton.setTitle(title, for: .normal)
        
//        let buttonTextValue = loginRegisterSegmentedControl.selectedSegmentIndex == 1 ? "Register" : "Login"
//        loginRegisterButton.setTitle(buttonTextValue, for: .normal)
    }
    
}
