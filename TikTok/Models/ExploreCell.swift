//
//  ExploreCell.swift
//  TikTok
//
//  Created by jake on 4/18/23.
//

import Foundation

enum ExploreSectionType {
    case banners
    case trendingPosts
    case trendingHashtags
    case recommended
    case popular
    case new
    case users
    
    var title: String {
        switch self {
        case .banners:
            return "Featured"
        case .trendingPosts:
            return "Trending videos"
        case .trendingHashtags:
            return "Hashtags"
        case .recommended:
            return "Recommended"
        case .popular:
            return "Popular"
        case .new:
            return "Recently posted"
        case .users:
            return "Creators"
        }
    }
}

enum ExploreCell {
    case banner(viewModel: ExploreBannerViewModel)
    case post(viewModel: ExplorePostViewModel)
    case hashtag(viewModel: ExploreHashTagViewModel)
    case user(viewModel: ExploreUserViewModel)
}

struct ExploreSection {
    let type: ExploreSectionType
    let cells: [ExploreCell]
}
