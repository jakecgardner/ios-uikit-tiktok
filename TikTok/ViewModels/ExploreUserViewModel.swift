//
//  ExploreUserViewModel.swift
//  TikTok
//
//  Created by jake on 4/18/23.
//

import UIKit

struct ExploreUserViewModel {
    let profileImage: UIImage?
    let username: String
    let followerCount: Int
    let handler: (() -> Void)
}
