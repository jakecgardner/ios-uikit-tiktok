//
//  SignInViewController.swift
//  TikTok
//
//  Created by jake on 4/6/23.
//

import UIKit
import SafariServices

class SignInViewController: UIViewController {

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
    private let passwordField = AuthField(type: .password)
    
    private let signInButton = AuthButton(type: .signIn, title: nil)
    private let forgotPasswordButton = AuthButton(type: .plain, title: "Forgot password?")
    private let createAccountButton = AuthButton(type: .plain, title: "New user? Create account")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        configureSubviews()
        configureToolbar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        emailField.becomeFirstResponder()
    }
    
    private func configureSubviews() {
        view.addSubview(logoImageView)
        view.addSubview(emailField)
        view.addSubview(passwordField)
        view.addSubview(signInButton)
        view.addSubview(forgotPasswordButton)
        view.addSubview(createAccountButton)
        
        emailField.delegate = self
        passwordField.delegate = self
        
        signInButton.addTarget(self, action: #selector(didTapSignIn), for: .touchUpInside)
        forgotPasswordButton.addTarget(self, action: #selector(didTapForgotPassword), for: .touchUpInside)
        createAccountButton.addTarget(self, action: #selector(didTapCreateAccount), for: .touchUpInside)
        
        let imageSize: CGFloat = 120
        
        NSLayoutConstraint.activate([
            logoImageView.widthAnchor.constraint(equalToConstant: imageSize),
            logoImageView.heightAnchor.constraint(equalToConstant: imageSize),
            logoImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            emailField.heightAnchor.constraint(equalToConstant: 50),
            emailField.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16),
            emailField.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16),
            emailField.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 24),
            
            passwordField.heightAnchor.constraint(equalToConstant: 50),
            passwordField.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16),
            passwordField.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16),
            passwordField.topAnchor.constraint(equalTo: emailField.bottomAnchor, constant: 8),
            
            signInButton.heightAnchor.constraint(equalToConstant: 50),
            signInButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16),
            signInButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16),
            signInButton.topAnchor.constraint(equalTo: passwordField.bottomAnchor, constant: 16),
            
            forgotPasswordButton.heightAnchor.constraint(equalToConstant: 50),
            forgotPasswordButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16),
            forgotPasswordButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16),
            forgotPasswordButton.topAnchor.constraint(equalTo: signInButton.bottomAnchor, constant: 44),
            
            createAccountButton.heightAnchor.constraint(equalToConstant: 50),
            createAccountButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16),
            createAccountButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16),
            createAccountButton.topAnchor.constraint(equalTo: forgotPasswordButton.bottomAnchor, constant: 44),
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
        passwordField.inputAccessoryView = toolbar
    }

    @objc func didTapSignIn() {
        didTapDone()
        
        guard let email = emailField.text,
              let password = passwordField.text,
              !email.trimmingCharacters(in: .whitespaces).isEmpty,
              !password.trimmingCharacters(in: .whitespaces).isEmpty,
              password.count >= 6 else {
            
            let alert = UIAlertController(title: "Oops", message: "Please enter a valid email and password", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel))
            present(alert, animated: true)
            
            return
        }
        
        AuthenticationService.shared.signIn(with: email, password: password, completion: { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(_):
                    self?.dismiss(animated: true)
                case .failure(_):
                    let alert = UIAlertController(title: "Oops", message: "Please enter a valid email and password", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel))
                    self?.present(alert, animated: true)
                    self?.passwordField.text = nil
                }
            }
        })
    }
    
    @objc func didTapForgotPassword() {
        didTapDone()
        
        guard let url = URL(string: "https://www.tiktok.com/forgot-password") else {
            return
        }
        
        let safariVc = SFSafariViewController(url: url)
        present(safariVc, animated: true)
    }
    
    @objc func didTapCreateAccount() {
        didTapDone()
        let signUpVc = SignUpViewController()
        navigationController?.pushViewController(signUpVc, animated: true)
    }
    
    @objc func didTapDone() {
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
    }
}

extension SignInViewController: UITextFieldDelegate {
    
}
