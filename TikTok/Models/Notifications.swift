//
//  Notifications.swift
//  TikTok
//
//  Created by jake on 4/24/23.
//

import Foundation

enum NotificationType {
    case postLike(postName: String)
    case postComment(postName: String)
    case userFollow(userName: String)
    
    var id: String {
        switch self {
        case .postLike:
            return "postLike"
        case .postComment:
            return "postComment"
        case .userFollow:
            return "userFollow"
        }
    }
}

class Notification {
    var identifier = UUID().uuidString
    var isHidden = false
    let text: String
    let type: NotificationType
    let date: Date
    
    init(text: String, type: NotificationType, date: Date) {
        self.text = text
        self.type = type
        self.date = date
    }
    
    static func mockData() -> [Notification] {
        return Array(0...100).compactMap { i in
            Notification(text: "Notification \(i)", type: .postLike(postName: "Like"), date: Date())
        }
    }
}
