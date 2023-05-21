//
//  CommentTableViewCell.swift
//  TikTok
//
//  Created by jake on 4/17/23.
//

import UIKit

class CommentTableViewCell: UITableViewCell {
    static let identifier = "commentCell"
    
    private let avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.clipsToBounds = true
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    private let commentLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.textColor = .label
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.textColor = .secondaryLabel
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        clipsToBounds = true
        contentView.backgroundColor = .systemBackground
        contentView.addSubview(avatarImageView)
        contentView.addSubview(commentLabel)
        contentView.addSubview(dateLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        commentLabel.sizeToFit()
        dateLabel.sizeToFit()
        
        NSLayoutConstraint.activate([
            avatarImageView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 8),
            avatarImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            avatarImageView.widthAnchor.constraint(equalToConstant: 70),
            avatarImageView.heightAnchor.constraint(equalToConstant: 70),
            commentLabel.leftAnchor.constraint(equalTo: avatarImageView.rightAnchor, constant: 8),
            commentLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            commentLabel.widthAnchor.constraint(equalToConstant: commentLabel.width),
            commentLabel.heightAnchor.constraint(equalToConstant: commentLabel.height),
            dateLabel.leftAnchor.constraint(equalTo: avatarImageView.rightAnchor, constant: 8),
            dateLabel.topAnchor.constraint(equalTo: commentLabel.bottomAnchor, constant: 4),
            dateLabel.widthAnchor.constraint(equalToConstant: dateLabel.width),
            dateLabel.heightAnchor.constraint(equalToConstant: dateLabel.height),
        ])
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        dateLabel.text = nil
        commentLabel.text = nil
        avatarImageView.image = nil
    }
    
    public func configure(with model: PostComment) {
        commentLabel.text = model.text
        dateLabel.text = .date(with: model.date)
        if let url = model.user.profileImageUrl {
            print(url)
        } else {
            avatarImageView.image = UIImage(systemName: "person.circle")
        }
    }
}
