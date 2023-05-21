//
//  AuthButton.swift
//  TikTok
//
//  Created by jake on 4/20/23.
//

import UIKit

class AuthButton: UIButton {
    enum ButtonType {
        case signIn
        case signUp
        case plain
        
        var title: String {
            switch self {
            case .signIn:
                return "Sign In"
            case .signUp:
                return "Sign Up"
            case .plain:
                return ""
            }
        }
    }
    
    private let type: ButtonType
    
    init(type: ButtonType, title: String?) {
        self.type = type
        super.init(frame: .zero)
        
        if let title = title {
            setTitle(title, for: .normal)
        }
        
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        translatesAutoresizingMaskIntoConstraints = false
        
        if type != .plain {
            setTitle(type.title, for: .normal)
        }
        
        switch type {
        case .signIn:
            setTitleColor(.white, for: .normal)
            backgroundColor = .systemBlue
        case .signUp:
            setTitleColor(.white, for: .normal)
            backgroundColor = .systemGreen
        case .plain:
            setTitleColor(.link, for: .normal)
            backgroundColor = .clear
        }
        
        layer.cornerRadius = 8
        layer.masksToBounds = true
        
        titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
    }
}
