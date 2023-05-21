//
//  PostViewController.swift
//  TikTok
//
//  Created by jake on 4/6/23.
//

import UIKit
import AVFoundation

protocol PostViewControllerDelegate: AnyObject {
    func postViewController(_ vc: PostViewController, didTapCommentButtonFor post: PostModel)
    func postViewController(_ vc: PostViewController, didTapProfileButtonFor post: PostModel)
}

class PostViewController: UIViewController {
    
    weak var delegate: PostViewControllerDelegate?
    
    var post: PostModel
    
    var player: AVPlayer?
    
    private let videoView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.clipsToBounds = true
        return view
    }()
    
    private let spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.tintColor = .label
        spinner.hidesWhenStopped = true
        spinner.startAnimating()
        return spinner
    }()
    
    private var playerDidFinishObserver: NSObjectProtocol?
    
    private let likeButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setBackgroundImage(UIImage(systemName: "heart.fill"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.tintColor = .white
        return button
    }()
    
    private let commentButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setBackgroundImage(UIImage(systemName: "text.bubble.fill"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.tintColor = .white
        return button
    }()
    
    private let shareButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setBackgroundImage(UIImage(systemName: "square.and.arrow.up"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.tintColor = .white
        return button
    }()
    
    private let profileButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setBackgroundImage(UIImage(systemName: "person.fill"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.tintColor = .white
        return button
    }()
    
    private let captionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 24)
        label.textColor = .white
        label.textAlignment = .left
        label.numberOfLines = 0
        label.text = "Check this out"
        return label
    }()
    
    init(model: PostModel) {
        self.post = model
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        
        view.addSubview(videoView)
        videoView.frame = view.bounds
        view.addSubview(spinner)
        spinner.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        spinner.center = view.center
        
        configurePlayer()
        setupButtons()
        setupDoubleTapLike()
        setupCaption()
    }
    
    func setupButtons() {
        view.addSubview(likeButton)
        view.addSubview(commentButton)
        view.addSubview(shareButton)
        view.addSubview(profileButton)
        
        likeButton.addTarget(self, action: #selector(didTapLike), for: .touchUpInside)
        commentButton.addTarget(self, action: #selector(didTapComment), for: .touchUpInside)
        shareButton.addTarget(self, action: #selector(didTapShare), for: .touchUpInside)
        profileButton.addTarget(self, action: #selector(didTapProfile), for: .touchUpInside)
        
        let size: CGFloat = 40
        let edgePadding: CGFloat = 8
        
        NSLayoutConstraint.activate([
            shareButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -120),
            shareButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -edgePadding),
            shareButton.widthAnchor.constraint(equalToConstant: size),
            shareButton.heightAnchor.constraint(equalToConstant: size),
            commentButton.bottomAnchor.constraint(equalTo: shareButton.topAnchor, constant: -10),
            commentButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -edgePadding),
            commentButton.widthAnchor.constraint(equalToConstant: size),
            commentButton.heightAnchor.constraint(equalToConstant: size),
            likeButton.bottomAnchor.constraint(equalTo: commentButton.topAnchor, constant: -10),
            likeButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -edgePadding),
            likeButton.widthAnchor.constraint(equalToConstant: size),
            likeButton.heightAnchor.constraint(equalToConstant: size),
            profileButton.bottomAnchor.constraint(equalTo: likeButton.topAnchor, constant: -10),
            profileButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -edgePadding),
            profileButton.widthAnchor.constraint(equalToConstant: size),
            profileButton.heightAnchor.constraint(equalToConstant: size),
        ])
    }
    
    @objc private func didTapLike() {
        post.isLikedByCurrentUser = !post.isLikedByCurrentUser
        likeButton.tintColor = post.isLikedByCurrentUser ? .systemRed : .white
    }
    
    @objc private func didTapComment() {
        delegate?.postViewController(self, didTapCommentButtonFor: post)
    }
    
    @objc private func didTapShare() {
        guard let url = URL(string: "https://www.tiktok.com") else {
            return
        }
        
        let activity = UIActivityViewController(
            activityItems: [url], applicationActivities: []
        )
        
        present(activity, animated: true)
    }
    
    @objc private func didTapProfile() {
        delegate?.postViewController(self, didTapProfileButtonFor: post)
    }
    
    private func setupDoubleTapLike() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(didDoubleTap(_:)))
        tap.numberOfTapsRequired = 2
        view.addGestureRecognizer(tap)
        view.isUserInteractionEnabled = true
    }
    
    @objc private func didDoubleTap(_ gesture: UIGestureRecognizer) {
        if !post.isLikedByCurrentUser {
            post.isLikedByCurrentUser = true
        }
        
        let touchPoint = gesture.location(in: view)
        let imageView = UIImageView(image: UIImage(systemName: "heart.fill"))
        imageView.tintColor = .systemRed
        imageView.contentMode = .scaleAspectFit
        imageView.alpha = 0
        imageView.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        imageView.center = touchPoint
        view.addSubview(imageView)
        
        UIView.animate(withDuration: 0.2, animations: {
                imageView.alpha = 1
        }) { done in
            if done {
                UIView.animate(withDuration: 0.3, delay: 0.2, animations: {
                        imageView.alpha = 0
                }) { done in
                    if done {
                        imageView.removeFromSuperview()
                    }
                }
            }
        }
    }
    
    private func setupCaption() {
        view.addSubview(captionLabel)
        captionLabel.sizeToFit()
        NSLayoutConstraint.activate([
            captionLabel.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 8),
            captionLabel.heightAnchor.constraint(equalToConstant: captionLabel.height),
            captionLabel.widthAnchor.constraint(equalToConstant: view.width - 16 - 40 - 16),
            captionLabel.topAnchor.constraint(equalTo: likeButton.topAnchor),
        ])
    }
    
    private func configurePlayer() {
        StorageService.shared.getDownloadURL(for: post) { [weak self] result in
            DispatchQueue.main.async {
                self?.spinner.stopAnimating()
                self?.spinner.removeFromSuperview()
                
                switch result {
                case .success(let url):
                    self?.player = AVPlayer(url: url)
                    
                    let playerLayer = AVPlayerLayer(player: self?.player)
                    playerLayer.frame = self?.view.bounds ?? .zero
                    playerLayer.videoGravity = .resizeAspectFill
                    self?.view.layer.addSublayer(playerLayer)
    
                    self?.player?.volume = 0
                    self?.player?.play()
                case .failure(let error):
                    break
                }
            }
        }
        
        playerDidFinishObserver = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: player?.currentItem,
            queue: .main,
            using: { [weak self] _ in
                self?.player?.seek(to: .zero)
                self?.player?.play()
            }
        )
    }
}
