//
//  CaptionViewController.swift
//  TikTok
//
//  Created by jake on 4/21/23.
//

import UIKit
import JGProgressHUD

class CaptionViewController: UIViewController {

    let videoURL: URL
    
    private let captionTextView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.contentInset = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
        textView.backgroundColor = .secondarySystemBackground
        textView.layer.cornerRadius = 8
        textView.layer.masksToBounds = true
        return textView
    }()
    
    init(with videoURL: URL) {
        self.videoURL = videoURL
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Add caption"
        view.backgroundColor = .systemBackground
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Post", style: .done, target: self, action: #selector(didTapPost))
        
        view.addSubview(captionTextView)
        NSLayoutConstraint.activate([
            captionTextView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 8),
            captionTextView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            captionTextView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -8),
            captionTextView.heightAnchor.constraint(equalToConstant: 150),
        ])
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        captionTextView.becomeFirstResponder()
    }
    
    @objc private func didTapPost() {
        captionTextView.resignFirstResponder()
        let caption = captionTextView.text ?? ""
        
        let hud = JGProgressHUD.init()
        hud.show(in: view)
        
        let newVideoName = StorageService.shared.generateVideoName()
        StorageService.shared.uploadVideo(from: videoURL, fileName: newVideoName) { [weak self] success in
            DispatchQueue.main.async {
                hud.dismiss(animated: true)
                
                if success {
                    DatabaseService.shared.insertPost(fileName: newVideoName, caption: caption) { success in
                        if success {
                            HapticsService.shared.vibrate(for: .success)
                            
                            self?.navigationController?.popToRootViewController(animated: true)
                            self?.tabBarController?.selectedIndex = 0
                            self?.tabBarController?.tabBar.isHidden = false
                        } else {
                            HapticsService.shared.vibrate(for: .error)
                            
                            let alert = UIAlertController(title: "Oops", message: "Unable to upload video. Try again", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel))
                            self?.present(alert, animated: true)
                        }
                    }
                } else {
                    HapticsService.shared.vibrate(for: .error)
                    
                    let alert = UIAlertController(title: "Oops", message: "Unable to upload video. Try again", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel))
                    self?.present(alert, animated: true)
                }
            }
        }
    }

}
