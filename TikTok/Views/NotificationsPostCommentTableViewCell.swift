//
//  NotificationsPostCommentTableViewCell.swift
//  TikTok
//
//  Created by jake on 4/24/23.
//

import UIKit

protocol NotificationsPostCommentTableViewCellDelegate: AnyObject {
    func notificationsPostCommentTableViewCell(_ cell: NotificationsPostCommentTableViewCell, didTapPostWith identifier: String)
}

class NotificationsPostCommentTableViewCell: UITableViewCell {
    static let identifier = "NotificationsPostCommentTableViewCell"
    
    weak var delegate: NotificationsPostCommentTableViewCellDelegate?
    
    var postId: String?
    
    private let postThumbnail: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.contentMode = .scaleToFill
        return imageView
    }()
    
    private let label: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textColor = .label
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.textColor = .secondaryLabel
        label.numberOfLines = 1
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
        delegate?.notificationsPostCommentTableViewCell(self, didTapPostWith: postId)
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
            label.heightAnchor.constraint(equalToConstant: 24),
            dateLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            dateLabel.leftAnchor.constraint(equalTo: postThumbnail.rightAnchor, constant: 8),
            dateLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -8),
            dateLabel.heightAnchor.constraint(equalToConstant: 18),
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
