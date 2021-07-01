//
//  PrivacyPolicyViewController.swift
//  Nomad-App
//
//  Created by yuishii on 2020/11/16.
//  Copyright © 2020 Yu Ishii. All rights reserved.
//
// プライバシーポリシーを表示する画面

import UIKit
import Firebase

class PrivacyPolicyViewController: UIViewController {
    
    @IBOutlet weak var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textView.font = UIFont.systemFont(ofSize: 14.0)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let backBarButtonItem = UIBarButtonItem()
        backBarButtonItem.title = "Back"
        self.navigationItem.backBarButtonItem = backBarButtonItem
        self.navigationItem.title = "プライバシーポリシー"
        self.navigationController?.navigationBar.titleTextAttributes
            = [NSAttributedString.Key.font: UIFont(name: "Helvetica", size: 16)!]
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        self.tabBarController?.tabBar.barTintColor = UIColor.white
        self.navigationController?.navigationBar.tintColor = UIColor.black
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.black]
        self.navigationController?.navigationBar.shadowImage = UIImage()
    }
}
