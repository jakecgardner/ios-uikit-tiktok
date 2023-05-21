//
//  ViewController.swift
//  TikTok
//
//  Created by jake on 4/4/23.
//

import UIKit

class HomeViewController: UIViewController {

    private let horizontalScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.bounces = false
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()
    
    private let segmentedControl: UISegmentedControl = {
        let titles = ["Following", "For You"]
        let control = UISegmentedControl(items: titles)
        control.selectedSegmentIndex = 1
        control.backgroundColor = nil
        return control
    }()
    
    private let forYouController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .vertical)
    private let followingController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .vertical)
    
    private var forYouPosts = PostModel.mockModels()
    private var followingPosts = PostModel.mockModels()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        view.addSubview(horizontalScrollView)
        horizontalScrollView.delegate = self
        horizontalScrollView.contentSize = CGSize(width: view.width*2, height: view.height)
        horizontalScrollView.contentOffset = CGPoint(x: view.width, y: 0)
        horizontalScrollView.contentInsetAdjustmentBehavior = .never
        
        setupFollowingFeed()
        setupForYouFeed()
        setupHeaderButtons()
    }

    override func viewDidLayoutSubviews() {
        horizontalScrollView.frame = view.bounds
    }
    
    @objc func didChangeSegmentedControl(_ sender: UISegmentedControl) {
        horizontalScrollView.setContentOffset(CGPoint(x: view.width * CGFloat(sender.selectedSegmentIndex), y: 0), animated: true)
    }
    
    private func setupHeaderButtons() {
        segmentedControl.addTarget(self, action: #selector(didChangeSegmentedControl(_:)), for: .valueChanged)
        navigationItem.titleView = segmentedControl
    }
    
    private func setupFollowingFeed() {
        guard let model = followingPosts.first else {
            return
        }
        
        let postVc = PostViewController(model: model)
        postVc.delegate = self
        
        followingController.setViewControllers([postVc], direction: .forward, animated: false)
        followingController.dataSource = self
        
        addChild(followingController)
        followingController.view.frame = CGRect(x: 0, y: 0, width: horizontalScrollView.width, height: horizontalScrollView.height)
        horizontalScrollView.addSubview(followingController.view)
        followingController.didMove(toParent: self)
    }
    
    private func setupForYouFeed() {
        guard let model = forYouPosts.first else {
            return
        }
        
        let postVc = PostViewController(model: model)
        postVc.delegate = self
        
        forYouController.setViewControllers([postVc], direction: .forward, animated: false)
        forYouController.dataSource = self
        addChild(forYouController)
        
        forYouController.view.frame = CGRect(x: view.width, y: 0, width: horizontalScrollView.width, height: horizontalScrollView.height)
        horizontalScrollView.addSubview(forYouController.view)
        
        forYouController.didMove(toParent: self)
    }
}

extension HomeViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let previousPost = (viewController as? PostViewController)?.post else {
            return nil
        }
        guard let index = currentPosts.firstIndex(where: {
            $0.identifier == previousPost.identifier
        }) else {
            return nil
        }
        
        if index == 0 {
            return nil
        }
        
        let model = currentPosts[index-1]
        let vc = PostViewController(model: model)
        vc.delegate = self
        return vc
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let previousPost = (viewController as? PostViewController)?.post else {
            return nil
        }
        guard let index = currentPosts.firstIndex(where: {
            $0.identifier == previousPost.identifier
        }) else {
            return nil
        }
        
        guard index < (currentPosts.count-1) else {
            return nil
        }
        
        let model = currentPosts[index+1]
        let vc = PostViewController(model: model)
        vc.delegate = self
        return vc
    }
    
    var currentPosts: [PostModel] {
        if horizontalScrollView.contentOffset.x == 0 {
            return followingPosts
        }
        return forYouPosts
    }
}

extension HomeViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.x <= (view.width/2) {
            segmentedControl.selectedSegmentIndex = 0
        } else {
            segmentedControl.selectedSegmentIndex = 1
        }
    }
}

extension HomeViewController: PostViewControllerDelegate {
    func postViewController(_ vc: PostViewController, didTapCommentButtonFor post: PostModel) {
        horizontalScrollView.isScrollEnabled = false
        if horizontalScrollView.contentOffset.x == 0 {
            followingController.dataSource = nil
        } else {
            forYouController.dataSource = nil
        }
        
        let commentVc = CommentViewController(post: post)
        commentVc.delegate = self
        addChild(commentVc)
        commentVc.didMove(toParent: self)
        view.addSubview(commentVc.view)
        let frame = CGRect(x: 0, y: view.height, width: view.width, height: view.height * 0.75)
        commentVc.view.frame = frame
        UIView.animate(withDuration: 0.2, animations: {
            commentVc.view.frame = CGRect(x: 0, y: self.view.height - frame.height, width: frame.width, height: frame.height)
        })
    }
    
    func postViewController(_ vc: PostViewController, didTapProfileButtonFor post: PostModel) {
        let user = post.user
        let profileVc = ProfileViewController(user: user)
        navigationController?.pushViewController(profileVc, animated: true)
    }
}

extension HomeViewController: CommentViewControllerDelegate {
    func didTapCloseForComments(with viewController: UIViewController) {
        let frame = viewController.view.frame
        UIView.animate(withDuration: 0.2, animations: {
            viewController.view.frame = CGRect(x: 0, y: self.view.height, width: frame.width, height: frame.height)
        }) { [weak self] done in
            if done {
                DispatchQueue.main.async {
                    viewController.view.removeFromSuperview()
                    viewController.removeFromParent()
                    self?.horizontalScrollView.isScrollEnabled = true
                    self?.followingController.dataSource = self
                    self?.forYouController.dataSource = self
                }
            }
        }
    }
}

