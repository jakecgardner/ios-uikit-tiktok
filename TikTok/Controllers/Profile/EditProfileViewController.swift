//
//  EditProfileViewController.swift
//  TikTok
//
//  Created by jake on 4/29/23.
//

import UIKit

class EditProfileViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Edit profile"
        view.backgroundColor = .systemBackground
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(didTapClose))
    }
    
    @objc func didTapClose() {
        navigationController?.popViewController(animated: true)
    }
    
}
