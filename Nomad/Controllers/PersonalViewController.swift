//
//  PersonalViewController.swift
//  Nomad-App
//
//  Created by yuishii on 2020/11/17.
//  Copyright © 2020 Yu Ishii. All rights reserved.
//
// 個人の情報を表示する画面

import UIKit
import Firebase
import FirebaseUI

class PersonalViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var mailLabel: UILabel!
    @IBOutlet weak var idLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let mail = Auth.auth().currentUser?.email
        let uid = Auth.auth().currentUser?.uid
        
        mailLabel.text = mail
        idLabel.text = uid
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("DEBUG_PRINT: viewWillAppear")
        
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
