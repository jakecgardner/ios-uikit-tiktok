//
//  ProfileViewController.swift
//  TikTok
//
//  Created by jake on 4/6/23.
//

import UIKit

class ProfileViewController: UIViewController {

    var user: User
    
    var isCurrentUserProfile: Bool {
        if let currentUsername = UserDefaults.standard.string(forKey: "username") {
            return user.username.lowercased() == currentUsername.lowercased()
        }
        return false
    }
    
    private var posts: [PostModel] = []
    private var followers: [String] = []
    private var following: [String] = []
    private var isFollower: Bool = false
    
    enum PicturePickerType {
        case camera
        case photoLibrary
    }
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.backgroundColor = .systemBackground
        collection.showsVerticalScrollIndicator = false
        collection.register(PostCollectionViewCell.self, forCellWithReuseIdentifier: PostCollectionViewCell.identifier)
        collection.register(ProfileHeaderCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: ProfileHeaderCollectionReusableView.identifier)
        return collection
    }()
    
    init(user: User) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = user.username.uppercased()
        view.backgroundColor = .systemBackground
        view.addSubview(collectionView)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.frame = view.bounds
        
        let username = UserDefaults.standard.string(forKey: "username")?.uppercased() ?? "Me"
        if title == username {
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "gear"), style: .done, target: self, action: #selector(didTapSettings))
        }
        
        fetchPosts()
    }
    
    @objc private func didTapSettings() {
        
    }
    
    private func fetchPosts() {
        DatabaseService.shared.getPosts(for: user) { [weak self] posts in
            DispatchQueue.main.async {
                self?.posts = posts
                self?.collectionView.reloadData()
            }
        }
    }
    
}

extension ProfileViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PostCollectionViewCell.identifier, for: indexPath) as? PostCollectionViewCell else {
            return UICollectionViewCell()
        }
        let postModel = posts[indexPath.row]
        cell.configure(with: postModel)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        let post = posts[indexPath.row]
        let postVc = PostViewController(model: post)
        postVc.delegate = self
        postVc.title = "Video"
        navigationController?.pushViewController(postVc, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width: CGFloat = (view.width - 16) / 3
        return CGSize(width: width, height: width * 1.67)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader,
              let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: UICollectionView.elementKindSectionHeader,
                withReuseIdentifier: ProfileHeaderCollectionReusableView.identifier,
                for: indexPath) as? ProfileHeaderCollectionReusableView else {
            return UICollectionReusableView()
        }
        header.delegate = self
        
        let group = DispatchGroup()
        group.enter()
        group.enter()
        group.enter()
        
        DatabaseService.shared.getRelationships(for: user, type: .followers) { [weak self] followers in
            defer {
                group.leave()
            }
            self?.followers = followers
        }
        DatabaseService.shared.getRelationships(for: user, type: .following) { [weak self] following in
            defer {
                group.leave()
            }
            self?.following = following
        }
        
        DatabaseService.shared.isValidRelationship(for: user, type: .followers) { [weak self] isFollower in
            defer {
                group.leave()
            }
            self?.isFollower = isFollower
        }
        
        group.notify(queue: .main) {
            let viewModel = ProfileHeaderViewModel(
                avatarImageUrl: URL(string: self.user.profileImageUrl ?? ""),
                followerCount: self.followers.count,
                followingCount: self.following.count,
                isFollowing: self.isCurrentUserProfile ? nil : self.isFollower
            )
            header.configure(with: viewModel)
        }
        
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.width, height: 300)
    }
}

extension ProfileViewController: ProfileHeaderCollectionReusableViewDelegate {
    func profileHeaderCollectionReusableView(_ header: ProfileHeaderCollectionReusableView, didTapPrimaryButtonWith viewModel: ProfileHeaderViewModel) {
        
        if isCurrentUserProfile {
            let editProfileVc = EditProfileViewController()
            present(UINavigationController(rootViewController: editProfileVc), animated: true)
        } else {
            DatabaseService.shared.updateRelationship(for: user, follow: !self.isFollower) { [weak self] success in
                if success {
                    DispatchQueue.main.async {
                        self?.isFollower = self?.isFollower ?? false
                        self?.collectionView.reloadData()
                    }
                }
            }
        }
    }
    
    func profileHeaderCollectionReusableView(_ header: ProfileHeaderCollectionReusableView, didTapFollowersButtonWith viewModel: ProfileHeaderViewModel) {
        let userListVc = UserListViewController(type: .followers, for: user, users: self.followers)
        navigationController?.pushViewController(userListVc, animated: true)
    }
    
    func profileHeaderCollectionReusableView(_ header: ProfileHeaderCollectionReusableView, didTapFollowingButtonWith viewModel: ProfileHeaderViewModel) {
        let userListVc = UserListViewController(type: .following, for: user, users: self.followers)
        navigationController?.pushViewController(userListVc, animated: true)
    }
    
    func profileHeaderCollectionReusableView(_ header: ProfileHeaderCollectionReusableView, didTapAvatarFor viewModel: ProfileHeaderViewModel) {
        guard isCurrentUserProfile else {
            return
        }
        let actionSheet = UIAlertController(title: "Profile picture", message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { [weak self] _ in
            DispatchQueue.main.async {
                self?.presentProfilePicturePicker(type: .camera)
            }
        }))
        actionSheet.addAction(UIAlertAction(title: "Photo library", style: .default, handler: { [weak self] _ in
            DispatchQueue.main.async {
                self?.presentProfilePicturePicker(type: .photoLibrary)
            }
        }))
        present(actionSheet, animated: true)
    }
                                            
    func presentProfilePicturePicker(type: PicturePickerType) {
        let picker = UIImagePickerController()
        picker.sourceType = type == .camera ? .camera : .photoLibrary
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
    }
}

extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            return
        }
        
        StorageService.shared.uploadProfilePhoto(with: image) { [weak self] result in
            DispatchQueue.main.async {
                guard let strongSelf = self else {
                    return
                }
                switch result {
                case .success(let url):
                    UserDefaults.standard.setValue(url.absoluteString, forKey: "profilePhoto")
                    strongSelf.user = User(username: strongSelf.user.username, profileImageUrl: url.absoluteString, identifier: strongSelf.user.identifier)
                    strongSelf.collectionView.reloadData()
                case .failure(let error):
                    print(error.localizedDescription)
                }
                
                picker.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

extension ProfileViewController: PostViewControllerDelegate {
    func postViewController(_ vc: PostViewController, didTapCommentButtonFor post: PostModel) {
        
    }
    
    func postViewController(_ vc: PostViewController, didTapProfileButtonFor post: PostModel) {
        
    }
}
