//
//  UserListViewController.swift
//  TikTok
//
//  Created by jake on 4/6/23.
//

import UIKit

class UserListViewController: UIViewController {
    
    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "UserListTableViewCell")
        return tableView
    }()
    
    enum ListType: String {
        case followers
        case following
    }
    
    private let noUsersLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.text = "No users"
        label.textColor = .secondaryLabel
        return label
    }()
    
    let user: User
    let type: ListType
    let users: [String]
    
    init(type: ListType, for user: User, users: [String]) {
        self.type = type
        self.user = user
        self.users = users
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        switch type {
        case .followers:
            title = "Followers"
        case .following:
            title = "Following"
        }
        
        if users.isEmpty {
            view.addSubview(noUsersLabel)
            noUsersLabel.sizeToFit()
            
        } else {
            view.addSubview(tableView)
            tableView.delegate = self
            tableView.dataSource = self
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if tableView.superview == view {
            tableView.frame = view.bounds
        } else {
            noUsersLabel.center = view.center
        }
    }

}

extension UserListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserListTableViewCell", for: indexPath)
        let userName = self.users[indexPath.row].lowercased()
        cell.textLabel?.text = userName
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
}
