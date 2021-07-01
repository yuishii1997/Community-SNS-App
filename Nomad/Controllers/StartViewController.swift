//
//  StartViewController.swift
//  Nomad-App
//
//  Created by yuishii on 2020/11/15.
//  Copyright © 2020 Yu Ishii. All rights reserved.
//
// アプリ起動直後ログインと新規登録選択画面

import UIKit

class StartViewController: UIViewController {
    
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.barTintColor = .white
        self.navigationController?.navigationBar.tintColor = UIColor.white
        
        signInButton.layer.borderWidth = 1.0 // 枠線の幅
        signInButton.layer.borderColor = UIColor.systemGray3.cgColor // 枠線の色
        signInButton.layer.cornerRadius = 22
        
        signupButton.layer.borderWidth = 1.0 // 枠線の幅
        signupButton.layer.borderColor = UIColor.systemGray3.cgColor // 枠線の色
        signupButton.layer.cornerRadius = 22
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        let backBarButtonItem = UIBarButtonItem()
        backBarButtonItem.title = "Back"
        self.navigationItem.backBarButtonItem = backBarButtonItem
        self.navigationController?.navigationBar.shadowImage = UIImage()
    }
}
