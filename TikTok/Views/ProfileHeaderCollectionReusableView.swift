//
//  ProfileHeaderCollectionReusableView.swift
//  TikTok
//
//  Created by jake on 4/25/23.
//

import UIKit
import SDWebImage

protocol ProfileHeaderCollectionReusableViewDelegate: AnyObject {
    func profileHeaderCollectionReusableView(
        _ header: ProfileHeaderCollectionReusableView,
        didTapPrimaryButtonWith viewModel: ProfileHeaderViewModel)
    func profileHeaderCollectionReusableView(
        _ header: ProfileHeaderCollectionReusableView,
        didTapFollowersButtonWith viewModel: ProfileHeaderViewModel)
    func profileHeaderCollectionReusableView(
        _ header: ProfileHeaderCollectionReusableView,
        didTapFollowingButtonWith viewModel: ProfileHeaderViewModel)
    func profileHeaderCollectionReusableView(
        _ header: ProfileHeaderCollectionReusableView,
        didTapAvatarFor viewModel: ProfileHeaderViewModel)
}

class ProfileHeaderCollectionReusableView: UICollectionReusableView {
    static let identifier = "ProfileHeaderCollectionReusableView"
    
    weak var delegate: ProfileHeaderCollectionReusableViewDelegate?
    
    var viewModel: ProfileHeaderViewModel?
    
    private let avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "person.fill")
        imageView.tintColor = .label
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.masksToBounds = true
        imageView.backgroundColor = .secondarySystemBackground
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 50
        return imageView
    }()
    
    private let primaryButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 8
        button.layer.masksToBounds = true
        button.setTitle("Follow", for: .normal)
        button.backgroundColor = .systemPink
        button.titleLabel?.font = .systemFont(ofSize: 20)
        return button
    }()
    
    private let followersButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 8
        button.layer.masksToBounds = true
        button.setTitle("0\nFollowers", for: .normal)
        button.titleLabel?.textAlignment = .center
        button.titleLabel?.numberOfLines = 2
        button.backgroundColor = .secondarySystemBackground
        return button
    }()
    
    private let followingButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 8
        button.layer.masksToBounds = true
        button.setTitle("0\nFollowing", for: .normal)
        button.titleLabel?.textAlignment = .center
        button.titleLabel?.numberOfLines = 2
        button.backgroundColor = .secondarySystemBackground
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = true
        backgroundColor = .systemBackground
        
        addSubview(avatarImageView)
        addSubview(primaryButton)
        addSubview(followersButton)
        addSubview(followingButton)
        
        primaryButton.addTarget(self, action: #selector(didTapPrimaryButton), for: .touchUpInside)
        followersButton.addTarget(self, action: #selector(didTapFollowersButton), for: .touchUpInside)
        followingButton.addTarget(self, action: #selector(didTapFollowingButton), for: .touchUpInside)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapAvator))
        avatarImageView.isUserInteractionEnabled = true
        avatarImageView.addGestureRecognizer(tap)
    }
    
    @objc func didTapAvator() {
        guard let viewModel = self.viewModel else {
            return
        }
        delegate?.profileHeaderCollectionReusableView(self, didTapAvatarFor: viewModel)
    }
    
    @objc func didTapPrimaryButton() {
        guard let viewModel = self.viewModel else {
            return
        }
        delegate?.profileHeaderCollectionReusableView(self, didTapPrimaryButtonWith: viewModel)
    }
    
    @objc func didTapFollowersButton() {
        guard let viewModel = self.viewModel else {
            return
        }
        delegate?.profileHeaderCollectionReusableView(self, didTapFollowersButtonWith: viewModel)
    }
    
    @objc func didTapFollowingButton() {
        guard let viewModel = self.viewModel else {
            return
        }
        delegate?.profileHeaderCollectionReusableView(self, didTapFollowingButtonWith: viewModel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let avatarSize: CGFloat = 100
        let buttonHeight: CGFloat = 50
        let followersButtonWidth: CGFloat = 100
        let editProfileButtonWidth: CGFloat = 220
        
        NSLayoutConstraint.activate([
            avatarImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            avatarImageView.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            avatarImageView.widthAnchor.constraint(equalToConstant: avatarSize),
            avatarImageView.heightAnchor.constraint(equalToConstant: avatarSize),
            
            followersButton.rightAnchor.constraint(equalTo: centerXAnchor, constant: -8),
            followersButton.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 16),
            followersButton.widthAnchor.constraint(equalToConstant: followersButtonWidth),
            followersButton.heightAnchor.constraint(equalToConstant: buttonHeight),
            
            followingButton.leftAnchor.constraint(equalTo: centerXAnchor, constant: 8),
            followingButton.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 16),
            followingButton.widthAnchor.constraint(equalToConstant: followersButtonWidth),
            followingButton.heightAnchor.constraint(equalToConstant: buttonHeight),
            
            primaryButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            primaryButton.topAnchor.constraint(equalTo: followingButton.bottomAnchor, constant: 16),
            primaryButton.widthAnchor.constraint(equalToConstant: editProfileButtonWidth),
            primaryButton.heightAnchor.constraint(equalToConstant: buttonHeight),
        ])
    }
    
    func configure(with viewModel: ProfileHeaderViewModel) {
        self.viewModel = viewModel
        followersButton.setTitle("\(viewModel.followerCount)\nFollowers", for: .normal)
        followingButton.setTitle("\(viewModel.followingCount)\nFollowing", for: .normal)
        
        if let avatarUrl = viewModel.avatarImageUrl {
            avatarImageView.sd_setImage(with: avatarUrl)
        }
        
        if let isFollowing = viewModel.isFollowing {
            primaryButton.backgroundColor = isFollowing ? .secondarySystemBackground : .systemPink
            primaryButton.setTitle(isFollowing ? "Unfollow" : "Follow", for: .normal)
        } else {
            primaryButton.backgroundColor = .secondarySystemBackground
            primaryButton.setTitle("Edit profile", for: .normal)
        }
    }
}
