//
//  LoginViewController.swift
//  Nomad-App
//
//  Created by yuishii on 2020/07/13.
//  Copyright © 2020 Yu Ishii. All rights reserved.
//
// ログイン画面

import UIKit
import Firebase
import SVProgressHUD

class LoginViewController: UIViewController,UITextFieldDelegate {
    
    @IBOutlet weak var mailAddressTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mailAddressTextField.attributedPlaceholder = NSAttributedString(string: "メールアドレス", attributes: [NSAttributedString.Key.foregroundColor : UIColor.gray])
        
        passwordTextField.attributedPlaceholder = NSAttributedString(string: "パスワード", attributes: [NSAttributedString.Key.foregroundColor : UIColor.gray])
        
        mailAddressTextField.delegate = self
        passwordTextField.delegate = self
        
        loginButton.layer.cornerRadius = 22.0
        
        self.navigationItem.title = "ログイン"
        
        self.mailAddressTextField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
        self.passwordTextField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
        
        loginButton.backgroundColor = UIColor.rgb(red: 199, green: 199, blue: 204)
        
        loginButton.isEnabled = false
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let backBarButtonItem = UIBarButtonItem()
        backBarButtonItem.title = "Back"
        self.navigationItem.backBarButtonItem = backBarButtonItem
        self.navigationItem.title = "ログイン"
        self.navigationController?.navigationBar.titleTextAttributes
            = [NSAttributedString.Key.font: UIFont(name: "Helvetica", size: 16)!]
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        self.tabBarController?.tabBar.barTintColor = UIColor.white
        self.navigationController?.navigationBar.tintColor = UIColor.black
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.black]
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
        if let address = mailAddressTextField.text, let password = passwordTextField.text {
            if  address.isEmpty == true {
                //テキストフィールドのキーボードを常時表示
                mailAddressTextField.becomeFirstResponder()
            } else if password.isEmpty == true {
                //テキストフィールドのキーボードを常時表示
                passwordTextField.becomeFirstResponder()
            } 
        }
    }
    
    
    // 画面から非表示になる直前に呼ばれます。
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // キーボードを閉じる
        mailAddressTextField.endEditing(true)
        passwordTextField.endEditing(true)
        //HUD.hide()
        // HUDを消す
        SVProgressHUD.setDefaultStyle(.custom)
        SVProgressHUD.setDefaultMaskType(.custom)
        SVProgressHUD.setForegroundColor(.black)
        SVProgressHUD.setBackgroundColor(.white)
        SVProgressHUD.setDefaultMaskType(.black)
        SVProgressHUD.dismiss()
        print("viewWillDisappear")
    }
    
    @objc func textFieldDidChange(_ textFiled: UITextField) {
        
        guard let email = mailAddressTextField.text, !email.isEmpty,let password = passwordTextField.text, !password.isEmpty else {
            loginButton.backgroundColor = UIColor.rgb(red: 199, green: 199, blue: 204)
            loginButton.isEnabled = false
            print("ボタンの色をグレーにします")
            return
        }
        print("ボタンの色を黒にします")
        loginButton.isEnabled = true
        loginButton.backgroundColor = .black
    }
    
    @IBAction func cancelButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // ログインボタンをタップしたときに呼ばれるメソッド
    @IBAction func handleLoginButton(_ sender: Any) {
        
        // キーボードを閉じる
        mailAddressTextField.endEditing(true)
        passwordTextField.endEditing(true)
        
        if let address = mailAddressTextField.text, let password = passwordTextField.text {
            
            // アドレスとパスワード名のいずれかでも入力されていない時は何もしない
            if address.isEmpty || password.isEmpty {
                //HUD.flash(.labeledError(title: "エラー", subtitle: "必要項目を入力して下さい"), delay: 1.4)
                SVProgressHUD.setDefaultStyle(.custom)
                SVProgressHUD.setDefaultMaskType(.custom)
                SVProgressHUD.setForegroundColor(.black)
                SVProgressHUD.setBackgroundColor(.white)
                SVProgressHUD.setDefaultMaskType(.black)
                SVProgressHUD.showError(withStatus: "必要項目を入力して下さい")
                //withDelayにIntを設定
                SVProgressHUD.dismiss(withDelay: 1.7)
                return
            }
            
            //HUD.show(.progress, onView: view)
            
            SVProgressHUD.setDefaultStyle(.custom)
            SVProgressHUD.setDefaultMaskType(.custom)
            SVProgressHUD.setForegroundColor(.black)
            SVProgressHUD.setBackgroundColor(.white)
            SVProgressHUD.setDefaultMaskType(.black)
            // HUDで処理中を表示
            SVProgressHUD.show()
            
            Auth.auth().signIn(withEmail: address, password: password) { authResult, error in
                if let error = error {
                    print("DEBUG_PRINT: " + error.localizedDescription)
                    //HUD.flash(.labeledError(title: "エラー", subtitle: "サインインに失敗しました"), delay: 1.4)
                    SVProgressHUD.setDefaultStyle(.custom)
                    SVProgressHUD.setDefaultMaskType(.custom)
                    SVProgressHUD.setForegroundColor(.black)
                    SVProgressHUD.setBackgroundColor(.white)
                    SVProgressHUD.setDefaultMaskType(.black)
                    SVProgressHUD.showError(withStatus: "サインインに失敗しました")
                    //withDelayにIntを設定
                    SVProgressHUD.dismiss(withDelay: 1.7)
                    return
                }
                print("DEBUG_PRINT: ログインに成功しました。")
                
                // 画面を閉じてタブ画面に戻る
                let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
                let rootViewController = storyboard.instantiateViewController(withIdentifier: "RootTabBarController")
                self.present(rootViewController, animated: true, completion: nil)
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // キーボードを閉じる
        view.endEditing(true)
    }
    
    @IBAction func unwind(_ segue: UIStoryboardSegue) {
    }
    
}
