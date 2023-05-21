//
//  NotificationsPostLikeTableViewCell.swift
//  TikTok
//
//  Created by jake on 4/24/23.
//

import UIKit

protocol NotificationsPostLikeTableViewCellDelegate: AnyObject {
    func notificationsPostLikeTableViewCell(_ cell: NotificationsPostLikeTableViewCell, didTapPostWith identifier: String)
}

class NotificationsPostLikeTableViewCell: UITableViewCell {
    static let identifier = "NotificationsPostLikeTableViewCell"
    
    weak var delegate: NotificationsPostLikeTableViewCellDelegate?
    
    var postId: String?
    
    private let postThumbnail: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .red
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.contentMode = .scaleToFill
        return imageView
    }()
    
    private let label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.textColor = .label
        label.font = .systemFont(ofSize: 14)
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .secondaryLabel
        label.numberOfLines = 1
        label.font = .systemFont(ofSize: 12)
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.clipsToBounds = true
        contentView.addSubview(postThumbnail)
        contentView.addSubview(label)
        contentView.addSubview(dateLabel)
        selectionStyle = .none
        
        let tap = UIGestureRecognizer(target: self, action: #selector(didTapPost))
        postThumbnail.addGestureRecognizer(tap)
    }
    
    @objc private func didTapPost() {
        guard let postId = postId else {
            return
        }
        delegate?.notificationsPostLikeTableViewCell(self, didTapPostWith: postId)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let iconSize: CGFloat = 50
        
        NSLayoutConstraint.activate([
            postThumbnail.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 8),
            postThumbnail.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            postThumbnail.widthAnchor.constraint(equalToConstant: iconSize),
            postThumbnail.heightAnchor.constraint(equalToConstant: iconSize),
            label.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            label.leftAnchor.constraint(equalTo: postThumbnail.rightAnchor, constant: 8),
            label.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -8),
            dateLabel.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 2),
            dateLabel.leftAnchor.constraint(equalTo: postThumbnail.rightAnchor, constant: 8),
            dateLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -8),
        ])
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        postThumbnail.image = nil
        label.text = nil
        dateLabel.text = nil
        postId = nil
    }
    
    func configure(with postFileName: String, model: Notification) {
        postThumbnail.image = nil
        label.text = model.text
        dateLabel.text = .date(with: model.date)
        self.postId = postFileName
    }
}
