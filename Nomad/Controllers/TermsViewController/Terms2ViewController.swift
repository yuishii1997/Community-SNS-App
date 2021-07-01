//
//  Terms2ViewController.swift
//  Nomad-App
//
//  Created by yuishii on 2020/11/16.
//  Copyright © 2020 Yu Ishii. All rights reserved.
//
// 利用規約を表示する画面

import UIKit
import Firebase

class Terms2ViewController: UIViewController {
    
    @IBOutlet weak var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textView.font = UIFont.systemFont(ofSize: 14.0)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
        if Auth.auth().currentUser != nil {
            if Auth.auth().currentUser?.isEmailVerified == true {
                print("メール認証が完了しています。")
            } else {
                print("メール認証が完了していません")
                navigationController?.popToRootViewController(animated: false)
            }
        }else {
            navigationController?.popToRootViewController(animated: false)
        }
    }
    
    
}
