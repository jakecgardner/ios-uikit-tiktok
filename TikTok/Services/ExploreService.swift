//
//  ExploreService.swift
//  TikTok
//
//  Created by jake on 4/20/23.
//

import UIKit

protocol ExploreServiceDelegate: AnyObject {
    func pushViewController(_ vc: UIViewController)
    func didTagHashTag(_ tag: String)
}

final class ExploreService {
    static let shared = ExploreService()
    
    private init() {}
    
    weak var delegate: ExploreServiceDelegate?
    
    enum BannerAction: String {
        case post
        case hashtag
        case user
    }
    
    public func getExploreBanners() -> [ExploreBannerViewModel] {
        guard let exploreData = parseExploreData() else {
            return []
        }
        return exploreData.banners.compactMap { banner in
            ExploreBannerViewModel(
                image: UIImage(named: banner.image),
                title: banner.title) { [weak self] in
                    guard let action = BannerAction(rawValue: banner.action) else {
                        return
                    }
                    switch action {
                    case .user:
                        break
                    case .hashtag:
                        break
                    case .post:
                        break
                    }
                }
        }
    }
    
    public func getExploreCreators() -> [ExploreUserViewModel] {
        guard let exploreData = parseExploreData() else {
            return []
        }
        return exploreData.creators.compactMap { creator in
            ExploreUserViewModel(
                profileImage: UIImage(named: creator.image),
                username: creator.username,
                followerCount: creator.followers_count) { [weak self] in
                    
                }
        }
    }
    
    public func getExploreHashTags() -> [ExploreHashTagViewModel] {
        guard let exploreData = parseExploreData() else {
            return []
        }
        return exploreData.hashtags.compactMap { tag in
            ExploreHashTagViewModel(
                icon: UIImage(systemName: tag.image),
                text: "#" + tag.tag,
                count: tag.count) { [weak self] in
                    self?.delegate?.didTagHashTag(tag.tag)
                }
        }
    }
    
    public func getExploreTrendingPosts() -> [ExplorePostViewModel] {
        guard let exploreData = parseExploreData() else {
            return []
        }
        return exploreData.trendingPosts.compactMap { post in
            ExplorePostViewModel(image: UIImage(named: post.image), caption: post.caption) { [weak self] in
                
            }
        }
    }
    
    public func getExploreRecentPosts() -> [ExplorePostViewModel] {
        guard let exploreData = parseExploreData() else {
            return []
        }
        return exploreData.recentPosts.compactMap { post in
            ExplorePostViewModel(image: UIImage(named: post.image), caption: post.caption) { [weak self] in
                
            }
        }
    }
    
    public func getExplorePopularPosts() -> [ExplorePostViewModel] {
        guard let exploreData = parseExploreData() else {
            return []
        }
        return exploreData.popular.compactMap { post in
            ExplorePostViewModel(image: UIImage(named: post.image), caption: post.caption) { [weak self] in
                
            }
        }
    }
    
    public func getExploreRecommendedPosts() -> [ExplorePostViewModel] {
        guard let exploreData = parseExploreData() else {
            return []
        }
        return exploreData.recommended.compactMap { post in
            ExplorePostViewModel(image: UIImage(named: post.image), caption: post.caption) { [weak self] in
                
            }
        }
    }
    
    private func parseExploreData() -> ExploreResponse? {
        guard let path = Bundle.main.path(forResource: "explore", ofType: "json") else {
            return nil
        }
        do {
            let url = URL(fileURLWithPath: path)
            let data = try Data(contentsOf: url)
            let result = try JSONDecoder().decode(ExploreResponse.self, from: data)
            return result
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
}

struct ExploreResponse: Codable {
    let banners: [Banner]
    let trendingPosts: [Post]
    let creators: [Creator]
    let recentPosts: [Post]
    let hashtags: [HashTag]
    let popular: [Post]
    let recommended: [Post]
}

struct Banner: Codable {
    let id: String
    let image: String
    let title: String
    let action: String
}

struct Post: Codable {
    let id: String
    let image: String
    let caption: String
}

struct HashTag: Codable {
    let image: String
    let tag: String
    let count: Int
}

struct Creator: Codable {
    let id: String
    let image: String
    let username: String
    let followers_count: Int
}
