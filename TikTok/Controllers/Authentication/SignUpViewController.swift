//
//  SignUpViewController.swift
//  TikTok
//
//  Created by jake on 4/6/23.
//

import UIKit
import SafariServices

class SignUpViewController: UIViewController {

    var completion: (() -> Void)?
    
    private let logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "logo")
        imageView.layer.cornerRadius = 8
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    private let emailField = AuthField(type: .email)
    private let usernameField = AuthField(type: .username)
    private let passwordField = AuthField(type: .password)
    
    private let signUpButton = AuthButton(type: .signUp, title: nil)
    private let termsServiceButton = AuthButton(type: .plain, title: "Terms of service")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        configureSubviews()
        configureToolbar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        usernameField.becomeFirstResponder()
    }
    
    private func configureSubviews() {
        view.addSubview(logoImageView)
        view.addSubview(emailField)
        view.addSubview(usernameField)
        view.addSubview(passwordField)
        view.addSubview(signUpButton)
        view.addSubview(termsServiceButton)
        
        emailField.delegate = self
        usernameField.delegate = self
        passwordField.delegate = self
        
        signUpButton.addTarget(self, action: #selector(didTapSignUp), for: .touchUpInside)
        termsServiceButton.addTarget(self, action: #selector(didTapTermsService), for: .touchUpInside)
        
        let imageSize: CGFloat = 120
        
        NSLayoutConstraint.activate([
            logoImageView.widthAnchor.constraint(equalToConstant: imageSize),
            logoImageView.heightAnchor.constraint(equalToConstant: imageSize),
            logoImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            usernameField.heightAnchor.constraint(equalToConstant: 50),
            usernameField.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16),
            usernameField.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16),
            usernameField.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 24),
            
            emailField.heightAnchor.constraint(equalToConstant: 50),
            emailField.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16),
            emailField.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16),
            emailField.topAnchor.constraint(equalTo: usernameField.bottomAnchor, constant: 8),
            
            passwordField.heightAnchor.constraint(equalToConstant: 50),
            passwordField.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16),
            passwordField.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16),
            passwordField.topAnchor.constraint(equalTo: emailField.bottomAnchor, constant: 8),
            
            signUpButton.heightAnchor.constraint(equalToConstant: 50),
            signUpButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16),
            signUpButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16),
            signUpButton.topAnchor.constraint(equalTo: passwordField.bottomAnchor, constant: 16),
            
            termsServiceButton.heightAnchor.constraint(equalToConstant: 50),
            termsServiceButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16),
            termsServiceButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16),
            termsServiceButton.topAnchor.constraint(equalTo: signUpButton.bottomAnchor, constant: 44),
        ])
    }
    
    func configureToolbar() {
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.width, height: 50))
        toolbar.items = [
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil),
            UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(didTapDone))
        ]
        toolbar.sizeToFit()
        emailField.inputAccessoryView = toolbar
        usernameField.inputAccessoryView = toolbar
        passwordField.inputAccessoryView = toolbar
    }

    @objc func didTapSignUp() {
        didTapDone()
        
        print(emailField.text)
        print(usernameField.text)
        print(passwordField.text)
        
        guard let email = emailField.text,
              let username = usernameField.text,
              let password = passwordField.text,
              !email.trimmingCharacters(in: .whitespaces).isEmpty,
              !username.trimmingCharacters(in: .whitespaces).isEmpty,
              !password.trimmingCharacters(in: .whitespaces).isEmpty,
              password.count >= 6 else {

            let alert = UIAlertController(title: "Oops", message: "Please enter a valid email and password", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel))
            present(alert, animated: true)
            
            return
        }
        
        AuthenticationService.shared.signUp(with: email, username: username, password: password) { [weak self] success in
            DispatchQueue.main.async {
                if success {
                    self?.dismiss(animated: true)
                } else {
                    let alert = UIAlertController(title: "Sign up failed", message: "Please try again", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel))
                    self?.present(alert, animated: true)
                    self?.passwordField.text = nil
                }
            }
        }
    }
    
    @objc func didTapTermsService() {
        didTapDone()
        
        guard let url = URL(string: "https://www.tiktok.com/terms") else {
            return
        }
        
        let safariVc = SFSafariViewController(url: url)
        present(safariVc, animated: true)
    }
    
    @objc func didTapDone() {
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
    }
}

extension SignUpViewController: UITextFieldDelegate {
    
}
