//
//  TabBarViewController.swift
//  TikTok
//
//  Created by jake on 4/6/23.
//

import UIKit

class TabBarViewController: UITabBarController {

    private var signInPresented = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupTabs()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        presentSignInIfNeeded()
    }
    
    private func setupTabs() {
        let home = UINavigationController(rootViewController: HomeViewController())
        home.navigationBar.backgroundColor = .clear
        home.navigationBar.setBackgroundImage(UIImage(), for: .default)
        home.navigationBar.shadowImage = UIImage()
        home.tabBarItem = UITabBarItem(title: nil, image: UIImage(systemName: "house"), tag: 1)
        
        let explore = UINavigationController(rootViewController: ExploreViewController())
        explore.tabBarItem = UITabBarItem(title: nil, image: UIImage(systemName: "safari"), tag: 2)
        
        let camera = UINavigationController(rootViewController: CameraViewController())
        camera.navigationBar.backgroundColor = .clear
        camera.navigationBar.tintColor = .white
        camera.navigationBar.shadowImage = UIImage()
        camera.navigationBar.setBackgroundImage(UIImage(), for: .default)
        camera.tabBarItem = UITabBarItem(title: nil, image: UIImage(systemName: "camera"), tag: 3)
        
        let notifications = UINavigationController(rootViewController: NotificationsViewController())
        notifications.tabBarItem = UITabBarItem(title: nil, image: UIImage(systemName: "bell"), tag: 4)
        
        let profile = UINavigationController(rootViewController: ProfileViewController(
            user: User(
                username: UserDefaults.standard.string(forKey: "username")?.uppercased() ?? "Me",
                profileImageUrl: URL(string: UserDefaults.standard.string(forKey: "profilePhoto") ?? "")?.absoluteString,
                identifier: UserDefaults.standard.string(forKey: "username")?.lowercased() ?? "1")
            )
        )
        profile.tabBarItem = UITabBarItem(title: nil, image: UIImage(systemName: "person.circle"), tag: 5)
        profile.navigationBar.tintColor = .label
        
        setViewControllers([
            home,
            explore,
            camera,
            notifications,
            profile,
        ], animated: false)
    }
    
    private func presentSignInIfNeeded() {
        if !signInPresented && !AuthenticationService.shared.isSignedIn {
            signInPresented = true
            let signinVc = SignInViewController()
            signinVc.completion = { [weak self] in
                self?.signInPresented = false
            }
            let navigationVc = UINavigationController(rootViewController: signinVc)
            navigationVc.modalPresentationStyle = .fullScreen
            present(navigationVc, animated: false)
        }
    }
}
