//
//  PostModel.swift
//  TikTok
//
//  Created by jake on 4/11/23.
//

import Foundation

struct PostModel {
    let identifier: String
    
    let user: User
    
    var fileName: String = ""
    var caption: String = ""
    
    var isLikedByCurrentUser = false
    
    static func mockModels() -> [PostModel] {
        let posts = Array(0...100).compactMap({ _ in
            PostModel(
                identifier: UUID().uuidString,
                user: User(username: "Karl L.", profileImageUrl: nil, identifier: UUID().uuidString)
            )
        })
        return posts
    }
    
    var videoChildPath: String {
        return "videos/\(user.username.lowercased())/\(fileName)"
    }
}
