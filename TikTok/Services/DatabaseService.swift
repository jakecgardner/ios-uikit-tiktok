//
//  DatabaseService.swift
//  TikTok
//
//  Created by jake on 4/6/23.
//

import Foundation
import FirebaseDatabase

final class DatabaseService {
    public static let shared = DatabaseService()
    private let database = Database.database().reference()
    
    private init() {}
    
    public func insertUser(with email: String, username: String, completion: @escaping (Bool) -> Void) {
        database.child("users").observeSingleEvent(of: .value) { [weak self] snapshot in
            guard var users = snapshot.value as? [String: Any] else {
                self?.database.child("users").setValue([
                    username: [
                        "email": email
                    ]
                ]) { error, _ in
                    completion(error == nil)
                }
                return
            }
            
            users[username] = ["email": email]
            self?.database.child("users").setValue(users) { error, _ in
                completion(error == nil)
            }
        }
    }
    
    public func getUsername(for email: String, completion: @escaping (String?) -> Void) {
        database.child("users").observeSingleEvent(of: .value) { snapshot in
            guard let users = snapshot.value as? [String: [String: Any]] else {
                return completion(nil)
            }
            
            for (username, value) in users {
                if value["email"] as? String == email {
                    completion(username)
                    break
                }
            }
        }
    }
    
    public func insertPost(fileName: String, caption: String, completion: @escaping (Bool) -> Void) {
        guard let username = UserDefaults.standard.string(forKey: "username") else {
            return completion(false)
        }
        
        database.child("users").child(username).observeSingleEvent(of: .value) { [weak self] snapshot, _ in
            guard var value = snapshot.value as? [String: Any] else {
                return completion(false)
            }
            
            let newPost = [
                "name": fileName,
                "caption": caption,
            ]
            
            var posts: [[String: Any]]?
            if var existingPosts = value["posts"] as? [[String: Any]] {
                existingPosts.append(newPost)
                posts = existingPosts
            } else {
                posts = [newPost]
            }
            
            value["posts"] = posts
            self?.database.child("users").child(username).setValue(value) { error, _ in
                guard error == nil else {
                    return completion(false)
                }
                completion(true)
            }
            
            
        }
    }
    
    public func markNotificationAsHidden(notificationId: String, completion: @escaping (Bool) -> Void) {
        completion(true)
    }
    
    public func getNotifications(completion: @escaping ([Notification]) -> Void) {
        completion(Notification.mockData())
    }
    
    public func follow(username: String, completion: @escaping (Bool) -> Void) {
        completion(true)
    }
    
    public func getPosts(for user: User, completion: @escaping ([PostModel]) -> Void) {
        let path = "users/\(user.username)/posts"
        database.child(path).observeSingleEvent(of: .value) { snapshot in
            guard let posts = snapshot.value as? [[String: String]] else {
                return completion([])
            }
            let models: [PostModel] = posts.compactMap { post in
                var postModel = PostModel(identifier: UUID().uuidString, user: user)
                postModel.fileName = post["name"] ?? ""
                postModel.caption = post["caption"] ?? ""
                return postModel
            }
            completion(models)
        }
    }
    
    public func getRelationships(for user: User, type: UserListViewController.ListType, completion: @escaping ([String]) -> Void) {
        let path = "users/\(user.username.lowercased())/\(type.rawValue)"
        database.child(path).observeSingleEvent(of: .value) { snapshot in
            guard let userCollection = snapshot.value as? [String] else {
                completion([])
                return
            }
            completion(userCollection)
        }
    }
    
    public func isValidRelationship(for user: User, type: UserListViewController.ListType, completion: @escaping (Bool) -> Void) {
        guard let currentUsername = UserDefaults.standard.string(forKey: "username")?.lowercased() else {
            return
        }

        let path = "users/\(user.username.lowercased())/\(type.rawValue)"
        database.child(path).observeSingleEvent(of: .value) { snapshot in
            guard let userCollection = snapshot.value as? [String] else {
                completion(false)
                return
            }
            
            completion(userCollection.contains(currentUsername))
        }
    }
    
    public func updateRelationship(for user: User, follow: Bool, completion: @escaping (Bool) -> Void) {
        guard let currentUsername = UserDefaults.standard.string(forKey: "username")?.lowercased() else {
            return
        }

        let following = "users/\(currentUsername.lowercased())/following"
        let followers = "users/\(user.username.lowercased())/followers"
        
        
        if follow {
            database.child(following).observeSingleEvent(of: .value) { snapshot in
                let usernameToInsert = user.username.lowercased()
                
                if var userCollection = snapshot.value as? [String] {
                    userCollection.append(usernameToInsert)
                    self.database.child(following).setValue(userCollection) { error, _ in
                        completion(error == nil)
                    }
                } else {
                    self.database.child(following).setValue([usernameToInsert]) { error, _ in
                        completion(error == nil)
                    }
                }
            }
            
            database.child(followers).observeSingleEvent(of: .value) { snapshot in
                let usernameToInsert = currentUsername.lowercased()
                
                if var userCollection = snapshot.value as? [String] {
                    userCollection.append(usernameToInsert)
                    self.database.child(followers).setValue(userCollection) { error, _ in
                        completion(error == nil)
                    }
                } else {
                    self.database.child(followers).setValue([usernameToInsert]) { error, _ in
                        completion(error == nil)
                    }
                }
            }
        } else {
            database.child(following).observeSingleEvent(of: .value) { snapshot in
                let usernameToRemove = user.username.lowercased()
                
                if var userCollection = snapshot.value as? [String] {
                    userCollection.removeAll(where: { $0 == usernameToRemove })
                    
                    self.database.child(following).setValue(userCollection) { error, _ in
                        completion(error == nil)
                    }
                }
            }
            
            database.child(followers).observeSingleEvent(of: .value) { snapshot in
                let usernameToRemove = currentUsername.lowercased()
                
                if var userCollection = snapshot.value as? [String] {
                    userCollection.removeAll(where: { $0 == usernameToRemove })
                    
                    self.database.child(followers).setValue(userCollection) { error, _ in
                        completion(error == nil)
                    }
                }
            }
        }
    }
}
