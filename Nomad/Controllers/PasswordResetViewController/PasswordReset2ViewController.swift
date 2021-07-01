//
//  PasswordReset2ViewController.swift
//  Nomad-App
//
//  Created by yuishii on 2021/02/19.
//  Copyright © 2021 Yu Ishii. All rights reserved.
//
// パスワードをリセットする画面

import UIKit
import FirebaseAuth
import SVProgressHUD

class PasswordReset2ViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var textField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textField.delegate = self
        
        textView.font = UIFont.systemFont(ofSize: 14.0)
        button.layer.borderWidth = 0.5                                              // 枠線の幅
        button.layer.borderColor = UIColor.gray.cgColor                            // 枠線の色
        button.layer.cornerRadius = 5.0
        
        textField.layer.borderWidth = 0.5                                              // 枠線の幅
        textField.layer.borderColor = UIColor.gray.cgColor                            // 枠線の色
        textField.layer.cornerRadius = 5.0
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // キーボードを閉じる
        view.endEditing(true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let backBarButtonItem = UIBarButtonItem()
        backBarButtonItem.title = "Back"
        self.navigationItem.backBarButtonItem = backBarButtonItem
        self.navigationItem.title = "パスワードの再設定"
        self.navigationController?.navigationBar.titleTextAttributes
            = [NSAttributedString.Key.font: UIFont(name: "Helvetica", size: 16)!]
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        self.tabBarController?.tabBar.barTintColor = UIColor.white
        self.navigationController?.navigationBar.tintColor = UIColor.black
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.black]
        
    }
    
    
    @IBAction func sendButton(_ sender: Any) {
        
        textField.endEditing(true)
        
        // HUDで投稿処理中の表示を開始
        //HUD.show(.progress, onView: view)
        // HUDで処理中を表示
        SVProgressHUD.show()
        
        if textField.text != "" {
            Auth.auth().sendPasswordReset(withEmail: textField.text!, completion: { (error) in
                DispatchQueue.main.async {
                    if error != nil {
                        //HUD.flash(.labeledError(title: "エラー", subtitle: "このメールアドレスは登録されてません"), delay: 1.4)
                        SVProgressHUD.setDefaultStyle(.custom)
                        SVProgressHUD.setDefaultMaskType(.custom)
                        SVProgressHUD.setForegroundColor(.black)
                        SVProgressHUD.setBackgroundColor(.white)
                        SVProgressHUD.setDefaultMaskType(.black)
                        SVProgressHUD.showError(withStatus: "このメールアドレスは登録されてません")
                        //withDelayにIntを設定
                        SVProgressHUD.dismiss(withDelay: 1.7)
                    } else {
                        //HUD.flash(.labeledSuccess(title: "送信しました", subtitle: nil), delay: 1.4)
                        SVProgressHUD.setDefaultStyle(.custom)
                        SVProgressHUD.setDefaultMaskType(.custom)
                        SVProgressHUD.setForegroundColor(.black)
                        SVProgressHUD.setBackgroundColor(.white)
                        SVProgressHUD.setDefaultMaskType(.black)
                        SVProgressHUD.showSuccess(withStatus: "送信しました")
                        //withDelayにIntを設定
                        SVProgressHUD.dismiss(withDelay: 1.7)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
                            self.navigationController?.popViewController(animated: true)
                        }
                    }
                }
            })
        }else{
            //HUD.flash(.labeledError(title: "エラー", subtitle: "メールアドレスを入力してください"), delay: 1.4)
            SVProgressHUD.setDefaultStyle(.custom)
            SVProgressHUD.setDefaultMaskType(.custom)
            SVProgressHUD.setForegroundColor(.black)
            SVProgressHUD.setBackgroundColor(.white)
            SVProgressHUD.setDefaultMaskType(.black)
            SVProgressHUD.showError(withStatus: "メールアドレスを入力してください")
            //withDelayにIntを設定
            SVProgressHUD.dismiss(withDelay: 1.7)
        }
        
    }
}
