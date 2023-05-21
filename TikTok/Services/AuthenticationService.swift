//
//  AuthenticationService.swift
//  TikTok
//
//  Created by jake on 4/6/23.
//

import Foundation
import FirebaseAuth

final class AuthenticationService {
    public static let shared = AuthenticationService()
    
    private init() {}
    
    enum SignInMethod {
        case email
    }
    
    enum AuthError: Error {
        case signInFailed
    }
    
    public var isSignedIn: Bool {
        return Auth.auth().currentUser != nil
    }
    
    public func signOut(completion: (Bool) -> Void) {
        do {
            try Auth.auth().signOut()
            completion(true)
        } catch {
            completion(false)
        }
    }
    
    public func signIn(with email: String, password: String, completion: @escaping (Result<String, Error>) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            guard result != nil, error == nil else {
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.failure(AuthError.signInFailed))
                }
                return
            }
            
            DatabaseService.shared.getUsername(for: email) { username in
                if let username = username {
                    UserDefaults.standard.set(username, forKey: "username")
                }
            }
            
            completion(.success(email))
        }
    }
    
    public func signUp(with email: String, username: String, password: String, completion: @escaping (Bool) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            guard result != nil, error == nil else {
                return completion(false)
            }
            
            DatabaseService.shared.insertUser(with: email, username: username, completion: completion)
            UserDefaults.standard.set(username, forKey: "username")
        }
    }
}
