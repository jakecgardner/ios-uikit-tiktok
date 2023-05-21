//
//  NotificationsUserFollowTableViewCell.swift
//  TikTok
//
//  Created by jake on 4/24/23.
//

import UIKit

protocol NotificationsUserFollowTableViewCellDelegate: AnyObject {
    func notificationsUserFollowTableViewCell(_ cell: NotificationsUserFollowTableViewCell, didTapFollowFor username: String)
    func notificationsUserFollowTableViewCell(_ cell: NotificationsUserFollowTableViewCell, didTapAvatarFor username: String)
}

class NotificationsUserFollowTableViewCell: UITableViewCell {
    static let identifier = "NotificationsUserFollowTableViewCell"
    
    weak var delegate: NotificationsUserFollowTableViewCellDelegate?
    
    var username: String?
    
    private let avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = imageView.height / 2
        return imageView
    }()
    
    private let label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .label
        label.numberOfLines = 1
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .secondaryLabel
        label.numberOfLines = 1
        return label
    }()
    
    private let followButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Follow", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 6
        button.layer.masksToBounds = true
        return button
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.clipsToBounds = true
        contentView.addSubview(avatarImageView)
        contentView.addSubview(label)
        contentView.addSubview(dateLabel)
        contentView.addSubview(followButton)
        selectionStyle = .none
        
        followButton.addTarget(self, action: #selector(didTapFollow), for: .touchUpInside)
        avatarImageView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapAvatar))
        avatarImageView.addGestureRecognizer(tap)
    }
    
    @objc private func didTapFollow() {
        guard let username = username else {
            return
        }
        
        followButton.setTitle("Following", for: .normal)
        followButton.backgroundColor = .clear
        followButton.layer.borderWidth = 1
        followButton.layer.borderColor = UIColor.lightGray.cgColor
        
        delegate?.notificationsUserFollowTableViewCell(self, didTapFollowFor: username)
    }
    
    @objc private func didTapAvatar() {
        guard let username = username else {
            return
        }
        delegate?.notificationsUserFollowTableViewCell(self, didTapAvatarFor: username)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let iconSize: CGFloat = 50
        let buttonSize: CGFloat = 40
        followButton.sizeToFit()
        dateLabel.sizeToFit()
        
        NSLayoutConstraint.activate([
            avatarImageView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 8),
            avatarImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            avatarImageView.widthAnchor.constraint(equalToConstant: iconSize),
            avatarImageView.heightAnchor.constraint(equalToConstant: iconSize),
            label.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            label.leftAnchor.constraint(equalTo: avatarImageView.rightAnchor, constant: 8),
            label.rightAnchor.constraint(equalTo: followButton.leftAnchor, constant: -8),
            label.heightAnchor.constraint(equalToConstant: 24),
            dateLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            dateLabel.leftAnchor.constraint(equalTo: avatarImageView.rightAnchor, constant: 8),
            dateLabel.rightAnchor.constraint(equalTo: followButton.leftAnchor, constant: -8),
            dateLabel.heightAnchor.constraint(equalToConstant: 18),
            followButton.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -8),
            followButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            followButton.widthAnchor.constraint(equalToConstant: followButton.width),
            followButton.heightAnchor.constraint(equalToConstant: buttonSize),
        ])
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        avatarImageView.image = nil
        label.text = nil
        dateLabel.text = nil
        
        followButton.setTitle("Follow", for: .normal)
        followButton.backgroundColor = .systemBlue
        followButton.layer.borderWidth = 0
        followButton.layer.borderColor = nil
    }
    
    func configure(with username: String, model: Notification) {
        avatarImageView.image = nil
        label.text = model.text
        dateLabel.text = .date(with: model.date)
        self.username = username
    }
}
