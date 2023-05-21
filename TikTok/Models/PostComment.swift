//
//  PostComment.swift
//  TikTok
//
//  Created by jake on 4/13/23.
//

import Foundation

struct PostComment {
    let text: String
    let user: User
    let date: Date
    
    static func mockComments() -> [PostComment] {
        let user = User(username: "uncle waffles", profileImageUrl: nil, identifier: UUID().uuidString)
        return [
            PostComment(text: "Great post", user: user, date: Date()),
            PostComment(text: "Great post", user: user, date: Date()),
            PostComment(text: "Great post", user: user, date: Date())
        ]
    }
}
