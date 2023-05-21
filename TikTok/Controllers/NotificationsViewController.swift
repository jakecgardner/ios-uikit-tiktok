//
//  NotificationsViewController.swift
//  TikTok
//
//  Created by jake on 4/6/23.
//

import UIKit

class NotificationsViewController: UIViewController {

    private let noNotificationsLabel: UILabel = {
        let label = UILabel()
        label.textColor = .secondaryLabel
        label.text = "No notifications"
        label.textAlignment = .center
        return label
    }()
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.isHidden = true
        table.register(NotificationsUserFollowTableViewCell.self, forCellReuseIdentifier: NotificationsUserFollowTableViewCell.identifier)
        table.register(NotificationsPostLikeTableViewCell.self, forCellReuseIdentifier: NotificationsPostLikeTableViewCell.identifier)
        table.register(NotificationsPostCommentTableViewCell.self, forCellReuseIdentifier: NotificationsPostCommentTableViewCell.identifier)
        return table
    }()
    
    private let spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.tintColor = .label
        spinner.startAnimating()
        return spinner
    }()
    
    var notifications: [Notification] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(didPullToRefresh(_:)), for: .valueChanged)
        tableView.refreshControl = refreshControl
        
        view.addSubview(noNotificationsLabel)
        view.addSubview(spinner)
        
        fetchNotifications()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
        noNotificationsLabel.frame = CGRect(x: 0, y: 0, width: 100, height: 50)
        noNotificationsLabel.center = view.center
        spinner.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        spinner.center = view.center
    }
    
    private func fetchNotifications() {
        DatabaseService.shared.getNotifications { [weak self] notifications in
            DispatchQueue.main.async {
                self?.notifications = notifications
                self?.refreshUI()
            }
        }
    }
    
    private func refreshUI() {
        noNotificationsLabel.isHidden = !notifications.isEmpty
        tableView.isHidden = notifications.isEmpty
        self.tableView.reloadData()
        self.spinner.stopAnimating()
        self.spinner.isHidden = true
    }
    
    @objc private func didPullToRefresh(_ sender: UIRefreshControl) {
        sender.beginRefreshing()
        DatabaseService.shared.getNotifications { [weak self] notifications in
            DispatchQueue.main.asyncAfter(deadline: .now()+3) {
                self?.notifications = notifications
                self?.tableView.reloadData()
                sender.endRefreshing()
            }
        }
    }
}

extension NotificationsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let defaultCell = UITableViewCell()
        
        let model = notifications[indexPath.row]
        
        switch model.type {
        case .postLike(let postName):
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: NotificationsPostLikeTableViewCell.identifier, for: indexPath) as? NotificationsPostLikeTableViewCell else {
                return defaultCell
            }
            cell.configure(with: postName, model: model)
            cell.delegate = self
            return cell
        case .postComment(let postName):
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: NotificationsPostCommentTableViewCell.identifier, for: indexPath) as? NotificationsPostCommentTableViewCell else {
                return defaultCell
            }
            cell.configure(with: postName, model: model)
            cell.delegate = self
            return cell
        case .userFollow(let username):
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: NotificationsUserFollowTableViewCell.identifier, for: indexPath) as? NotificationsUserFollowTableViewCell else {
                return defaultCell
            }
            cell.configure(with: username, model: model)
            cell.delegate = self
            return cell
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 58
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else {
            return
        }
        
        let model = notifications[indexPath.row]
        model.isHidden = true
        
        DatabaseService.shared.markNotificationAsHidden(notificationId: model.identifier) { [weak self] success in
            if success {
                DispatchQueue.main.async {
                    self?.notifications = self?.notifications.filter({ $0.isHidden == false }) ?? []
                    
                    tableView.beginUpdates()
                    tableView.deleteRows(at: [indexPath], with: .none)
                    tableView.endUpdates()
                }
            }
        }
    }
}

extension NotificationsViewController: NotificationsUserFollowTableViewCellDelegate {
    func notificationsUserFollowTableViewCell(_ cell: NotificationsUserFollowTableViewCell, didTapAvatarFor username: String) {
        let profileVc = ProfileViewController(user: User(username: "test", profileImageUrl: nil, identifier: UUID().uuidString))
        profileVc.title = username.uppercased()
        navigationController?.pushViewController(profileVc, animated: true)
    }
    
    func notificationsUserFollowTableViewCell(_ cell: NotificationsUserFollowTableViewCell, didTapFollowFor username: String) {
        DatabaseService.shared.follow(username: username) { success in
            if !success {
                
            }
        }
    }
}

extension NotificationsViewController: NotificationsPostLikeTableViewCellDelegate {
    func notificationsPostLikeTableViewCell(_ cell: NotificationsPostLikeTableViewCell, didTapPostWith identifier: String) {
        openPost(with: identifier)
    }
}

extension NotificationsViewController: NotificationsPostCommentTableViewCellDelegate {
    func notificationsPostCommentTableViewCell(_ cell: NotificationsPostCommentTableViewCell, didTapPostWith identifier: String) {
        openPost(with: identifier)
    }
}

extension NotificationsViewController {
    func openPost(with identifier: String) {
        let postVc = PostViewController(model: PostModel(identifier: identifier, user: User(username: "Me", profileImageUrl: nil, identifier: "Me")))
        navigationController?.pushViewController(postVc, animated: true)
    }
}
