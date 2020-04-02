//
//  LoginController.swift
//  GameOfChat
//
//  Created by Ricardo González Pacheco on 01/04/2020.
//  Copyright © 2020 Ricardo González Pacheco. All rights reserved.
//

import UIKit
import Firebase

class LoginController: UIViewController {
    
    lazy var profileImageView: UIImageView = {
        let image = UIImageView(image: UIImage(named: "gameofthrones_splash"))
        image.translatesAutoresizingMaskIntoConstraints = false
        image.contentMode = .scaleAspectFill
        return image
    }()
    
    lazy var loginRegisterSegmentedControl: UISegmentedControl = {
        let sc = UISegmentedControl(items: ["Login", "Register"])
        sc.translatesAutoresizingMaskIntoConstraints = false
        sc.selectedSegmentIndex = 1
        sc.tintColor = .white
        sc.addTarget(self, action: #selector(handleSegmentedControlChange), for: .valueChanged)
        return sc
    }()
    
    @objc func handleSegmentedControlChange() {
        
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
//            inputContainerViewHeightAnchor = loginRegisterSegmentedControl.selectedSegmentIndex == 1 ?
//            inputsContainerView.heightAnchor.constraint(equalToConstant: 150) :
//            inputsContainerView.heightAnchor.constraint(equalToConstant: 100)
        inputContainerViewHeightAnchor?.isActive = true

        
        // 1st: Button value change with selected control changes
        let title = loginRegisterSegmentedControl.titleForSegment(at: loginRegisterSegmentedControl.selectedSegmentIndex)
        loginRegisterButton.setTitle(title, for: .normal)

//        let buttonTextValue = loginRegisterSegmentedControl.selectedSegmentIndex == 1 ? "Register" : "Login"
//        loginRegisterButton.setTitle(buttonTextValue, for: .normal)
    }
    
    lazy var loginRegisterButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.backgroundColor = UIColor(r: 80, g: 101, b: 161)
        btn.setTitle("Register", for: .normal)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.layer.cornerRadius = 5
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        btn.addTarget(self, action: #selector(handleLoginRegisterAction), for: .touchUpInside)
        return btn
    }()
    
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
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func handleRegister() {
        
        guard let email = emailTextField.text, let password = passwordTextField.text,
            let name = nameTextField.text else { return }
        
        Auth.auth().createUser(withEmail: email, password: password) { (authDataResult: AuthDataResult?, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
        
            guard let id = authDataResult?.user.uid else { return }
            //SUCCESS!
            let ref = Database.database().reference(fromURL: "https://gameofchat-fe9a7.firebaseio.com/")
            let refTop = ref.child("users").child(id)
            let values = ["name":name, "email":email]
            refTop.updateChildValues(values) { (error, ref) in
                
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
            }
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    lazy var inputsContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
        return view
    }()
    
    let nameTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Name"
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    lazy var nameSeparatorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        return view
    }()
    
    let emailTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Email"
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    lazy var emailSeparatorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        return view
    }()
    
    let passwordTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Password"
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.isSecureTextEntry = true
        return tf
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(r: 61, g: 91, b: 151)

        view.addSubview(profileImageView)
        view.addSubview(loginRegisterSegmentedControl)
        view.addSubview(inputsContainerView)
        view.addSubview(loginRegisterButton)

        setupInputsContainerView()
        setupLoginRegisterButton()
        setupLogoImage()
        setupLoginRegisterSegmentedControl()
    }
    
    func setupLogoImage() {
        view.addSubview(profileImageView)
        NSLayoutConstraint.activate([
            profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            profileImageView.bottomAnchor.constraint(equalTo: loginRegisterSegmentedControl.topAnchor, constant: -30),
//            profileImageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 100),
            profileImageView.widthAnchor.constraint(equalToConstant: 200),
            profileImageView.heightAnchor.constraint(equalToConstant: 200)
        ])
    }
    
    func setupLoginRegisterSegmentedControl() {
        NSLayoutConstraint.activate([
            loginRegisterSegmentedControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loginRegisterSegmentedControl.bottomAnchor.constraint(equalTo: inputsContainerView.topAnchor, constant: -12),
            loginRegisterSegmentedControl.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor),
            loginRegisterSegmentedControl.heightAnchor.constraint(equalToConstant: 36)
        ])
    }
    
//    var inputContainerViewHeightAnchor = NSLayoutConstraint() Jared DavidSon, friend of LBTA
    var inputContainerViewHeightAnchor: NSLayoutConstraint?
    var nameTextFieldHeightAnchor: NSLayoutConstraint?
    var emailTextFieldHeightAnchor: NSLayoutConstraint?
    var passwordTextFieldHeightAnchor: NSLayoutConstraint?

    func setupInputsContainerView(){
        
        inputContainerViewHeightAnchor = inputsContainerView.heightAnchor.constraint(equalToConstant: 150)
        NSLayoutConstraint.activate([
            inputsContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            inputsContainerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            inputsContainerView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -40),
            inputContainerViewHeightAnchor! // !: I am sure always have value here as 5-lines-above line has been typed out
        ])
        
        inputsContainerView.addSubview(nameTextField)
        nameTextFieldHeightAnchor = nameTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/3)
        NSLayoutConstraint.activate([
            nameTextField.topAnchor.constraint(equalTo: inputsContainerView.topAnchor),
            nameTextField.leadingAnchor.constraint(equalTo: inputsContainerView.leadingAnchor, constant: 12),
            nameTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor),
            nameTextFieldHeightAnchor! // !: I am sure always have value here as 5-lines-above line has been typed out
        ])
        
        inputsContainerView.addSubview(nameSeparatorView)
        NSLayoutConstraint.activate([
            nameSeparatorView.topAnchor.constraint(equalTo: nameTextField.bottomAnchor),
            nameSeparatorView.leadingAnchor.constraint(equalTo: inputsContainerView.leadingAnchor),
            nameSeparatorView.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor),
            nameSeparatorView.heightAnchor.constraint(equalToConstant: 1)
        ])
        
        inputsContainerView.addSubview(emailTextField)
        emailTextFieldHeightAnchor = emailTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/3)
        NSLayoutConstraint.activate([
            emailTextField.topAnchor.constraint(equalTo: nameTextField.bottomAnchor),
            emailTextField.leadingAnchor.constraint(equalTo: inputsContainerView.leadingAnchor, constant: 12),
            emailTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor),
            emailTextFieldHeightAnchor! // !: I am sure always have value here as 5-lines-above line has been typed out
        ])
        
        inputsContainerView.addSubview(emailSeparatorView)
        NSLayoutConstraint.activate([
            emailSeparatorView.topAnchor.constraint(equalTo: emailTextField.bottomAnchor),
            emailSeparatorView.leadingAnchor.constraint(equalTo: inputsContainerView.leadingAnchor),
            emailSeparatorView.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor),
            emailSeparatorView.heightAnchor.constraint(equalToConstant: 1)
        ])
        
        inputsContainerView.addSubview(passwordTextField)
        passwordTextFieldHeightAnchor = passwordTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/3)
        NSLayoutConstraint.activate([
            passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor),
            passwordTextField.leadingAnchor.constraint(equalTo: inputsContainerView.leadingAnchor, constant: 12),
            passwordTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor),
            passwordTextFieldHeightAnchor! // !: I am sure always have value here as 5-lines-above line has been typed out
        ])
    }
    
    func setupLoginRegisterButton() {
        NSLayoutConstraint.activate([
            loginRegisterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loginRegisterButton.topAnchor.constraint(equalTo: inputsContainerView.bottomAnchor, constant: 12),
            loginRegisterButton.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor),
            loginRegisterButton.heightAnchor.constraint(equalToConstant: 50)
            
        ])
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

extension UIColor {
    convenience init(r: CGFloat, g: CGFloat, b: CGFloat) {
        self.init(red: r/255, green: g/255, blue: b/255, alpha: 1)
    }
}

