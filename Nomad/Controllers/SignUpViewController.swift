//
//  SignUpViewController.swift
//  Nomad-App
//
//  Created by yuishii on 2020/07/13.
//  Copyright © 2020 Yu Ishii. All rights reserved.
//
// 新規登録画面

import UIKit
import Firebase
import SVProgressHUD

class SignUpViewController: UIViewController,UITextFieldDelegate {
    
    @IBOutlet weak var displayNameTextField: UITextField!
    @IBOutlet weak var mailAddressTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var termsButton: UIButton!
    @IBOutlet weak var policyButton: UIButton!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        displayNameTextField.attributedPlaceholder = NSAttributedString(string: "名前", attributes: [NSAttributedString.Key.foregroundColor : UIColor.gray])
        
        mailAddressTextField.attributedPlaceholder = NSAttributedString(string: "メールアドレス", attributes: [NSAttributedString.Key.foregroundColor : UIColor.gray])
        
        passwordTextField.attributedPlaceholder = NSAttributedString(string: "パスワード", attributes: [NSAttributedString.Key.foregroundColor : UIColor.gray])
        
        displayNameTextField.delegate = self
        mailAddressTextField.delegate = self
        passwordTextField.delegate = self
        
        signupButton.layer.cornerRadius = 22.0
        self.navigationItem.title = "新規登録"
        
        self.displayNameTextField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
        self.mailAddressTextField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
        self.passwordTextField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
        
        signupButton.backgroundColor = UIColor.rgb(red: 199, green: 199, blue: 204)
        
        signupButton.isEnabled = false
        
        let AttributedString = NSAttributedString(string: "利用規約", attributes: [.underlineStyle: NSUnderlineStyle.single.rawValue, NSAttributedString.Key.foregroundColor : UIColor.black])
        termsButton.setAttributedTitle(AttributedString, for: .normal)
        let AttributedString2 = NSAttributedString(string: "プライバシーポリシー", attributes: [.underlineStyle: NSUnderlineStyle.single.rawValue, NSAttributedString.Key.foregroundColor : UIColor.black])
        policyButton.setAttributedTitle(AttributedString2, for: .normal)
        
        //仮の新規登録が完了した時刻を保存し、メール確認画面で10分経過したかどうか確認する
        UserDefaults.standard.set(Date(), forKey:"creationTime")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let backBarButtonItem = UIBarButtonItem()
        backBarButtonItem.title = "Back"
        self.navigationItem.backBarButtonItem = backBarButtonItem
        self.navigationItem.title = "新規登録"
        self.navigationController?.navigationBar.titleTextAttributes
            = [NSAttributedString.Key.font: UIFont(name: "Helvetica", size: 16)!]
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        self.tabBarController?.tabBar.barTintColor = UIColor.white
        self.navigationController?.navigationBar.tintColor = UIColor.black
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.black]
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
        if let name = displayNameTextField.text, let address = mailAddressTextField.text, let password = passwordTextField.text {
            
            if  name.isEmpty == true {
                //テキストフィールドのキーボードを常時表示
                displayNameTextField.becomeFirstResponder()
            } else if address.isEmpty  == true {
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
        displayNameTextField.endEditing(true)
        mailAddressTextField.endEditing(true)
        passwordTextField.endEditing(true)
        //HUD.hide()
        // HUDを消す
        SVProgressHUD.dismiss()
        print("viewWillDisappear")
    }
    
    
    
    @objc func textFieldDidChange(_ textFiled: UITextField) {
        
        guard let name = displayNameTextField.text, !name.isEmpty, let email = mailAddressTextField.text, !email.isEmpty,let password = passwordTextField.text, !password.isEmpty else {
            signupButton.backgroundColor = UIColor.rgb(red: 199, green: 199, blue: 204)
            signupButton.isEnabled = false
            print("ボタンの色をグレーにします")
            return
        }
        print("ボタンの色を黒にします")
        signupButton.isEnabled = true
        signupButton.backgroundColor = .black
    }
    
    @IBAction func toTermsButton(_ sender: Any) {
        
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let termsViewController = storyboard.instantiateViewController(identifier: "Terms") as! TermsViewController
        navigationController?.pushViewController(termsViewController, animated: true)
    }
    
    @IBAction func toPrivacyPolicyButton(_ sender: Any) {
        
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let privacyPolicyViewController = storyboard.instantiateViewController(identifier: "PrivacyPolicy") as! PrivacyPolicyViewController
        navigationController?.pushViewController(privacyPolicyViewController, animated: true)
    }
    
    
    @IBAction func cancelButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // アカウント作成ボタンをタップしたときに呼ばれるメソッド
    @IBAction func handleCreateAccountButton(_ sender: Any) {
        
        // キーボードを閉じる
        displayNameTextField.endEditing(true)
        mailAddressTextField.endEditing(true)
        passwordTextField.endEditing(true)
        
        let displayName = displayNameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        if let address = mailAddressTextField.text, let password = passwordTextField.text {
            
            // アドレスとパスワードと表示名のいずれかでも入力されていない時は何もしない
            if address.isEmpty || password.isEmpty || displayName.isEmpty {
                print("DEBUG_PRINT: 何かが空文字です。")
                //HUD.flash(.labeledError(title: "エラー", subtitle: "必要項目を入力してください"), delay: 1.4)
                SVProgressHUD.setDefaultStyle(.custom)
                SVProgressHUD.setDefaultMaskType(.custom)
                SVProgressHUD.setForegroundColor(.black)
                SVProgressHUD.setBackgroundColor(.white)
                SVProgressHUD.setDefaultMaskType(.black)
                SVProgressHUD.showError(withStatus: "必要項目を入力して下さい")
                //withDelayにIntを設定
                SVProgressHUD.dismiss(withDelay: 1.7)
                return
            } else if displayName.count > 20{
                print("DEBUG_PRINT: ユーザー名が21文字以上です")
                //HUD.flash(.labeledError(title: "エラー", subtitle: "名前が20文字をこえています"), delay: 1.4)
                SVProgressHUD.setDefaultStyle(.custom)
                SVProgressHUD.setDefaultMaskType(.custom)
                SVProgressHUD.setForegroundColor(.black)
                SVProgressHUD.setBackgroundColor(.white)
                SVProgressHUD.setDefaultMaskType(.black)
                SVProgressHUD.showError(withStatus: "名前が20文字をこえています")
                //withDelayにIntを設定
                SVProgressHUD.dismiss(withDelay: 1.7)
                return
            } else if password.count < 6 {
                //HUD.flash(.labeledError(title: "エラー", subtitle: "パスワードは6文字以上にしてください"), delay: 1.4)
                SVProgressHUD.setDefaultStyle(.custom)
                SVProgressHUD.setDefaultMaskType(.custom)
                SVProgressHUD.setForegroundColor(.black)
                SVProgressHUD.setBackgroundColor(.white)
                SVProgressHUD.setDefaultMaskType(.black)
                SVProgressHUD.showError(withStatus: "パスワードは6文字以上にしてください")
                //withDelayにIntを設定
                SVProgressHUD.dismiss(withDelay: 1.7)
                return
            } else if isValidEmail(emailID: address) == false {
                //HUD.flash(.labeledError(title: "エラー", subtitle: "無効なメールアドレスです"), delay: 1.4)
                SVProgressHUD.setDefaultStyle(.custom)
                SVProgressHUD.setDefaultMaskType(.custom)
                SVProgressHUD.setForegroundColor(.black)
                SVProgressHUD.setBackgroundColor(.white)
                SVProgressHUD.setDefaultMaskType(.black)
                SVProgressHUD.showError(withStatus: "無効なメールアドレスです")
                //withDelayにIntを設定
                SVProgressHUD.dismiss(withDelay: 1.7)
                return
            }
            
            let alert: UIAlertController = UIAlertController(title: "利用規約とプライバシーポリシーに同意の上、新規登録しますか？", message: nil, preferredStyle:  UIAlertController.Style.alert)
            
            let defaultAction: UIAlertAction = UIAlertAction(title: "同意する", style: UIAlertAction.Style.default, handler:{
                // ボタンが押された時の処理を書く（クロージャ実装）
                (action: UIAlertAction!) -> Void in
                print("OK")
                
                let email = self.mailAddressTextField.text ?? ""
                let password = self.passwordTextField.text ?? ""
                let name = self.displayNameTextField.text ?? ""
                //                let randomString = randomString(length: 10) // 10桁のランダムな英数字を生成
                //                print(randomString)
                
                // HUDで投稿処理中の表示を開始
                //HUD.show(.progress, onView: self.view)
                
                SVProgressHUD.setDefaultStyle(.custom)
                SVProgressHUD.setDefaultMaskType(.custom)
                SVProgressHUD.setForegroundColor(.black)
                SVProgressHUD.setBackgroundColor(.white)
                SVProgressHUD.setDefaultMaskType(.black)
                SVProgressHUD.show()
                Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
                    guard let self = self else { return }
                    if let user = result?.user {
                        let req = user.createProfileChangeRequest()
                        req.displayName = name
                        req.commitChanges() { [weak self] error in
                            guard let self = self else { return }
                            if error == nil {
                                user.sendEmailVerification() { [weak self] error in
                                    guard let self = self else { return }
                                    if error == nil {
                                        print("確認メールを送信しました。")
                                        //メール認証が完了していなかったら
                                        self.performSegue(withIdentifier: "toEmailVerification", sender: nil)
                                    }
                                    self.showErrorIfNeeded(error)
                                }
                            }
                            self.showErrorIfNeeded(error)
                        }
                    }
                    self.showErrorIfNeeded(error)
                }
            })
            // キャンセルボタン
            let cancelAction: UIAlertAction = UIAlertAction(title: "キャンセル", style: UIAlertAction.Style.cancel, handler:{
                // ボタンが押された時の処理を書く（クロージャ実装）
                (action: UIAlertAction!) -> Void in
                print("Cancel")
            })
            
            alert.addAction(cancelAction)
            alert.addAction(defaultAction)
            
            present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func unwind(_ segue: UIStoryboardSegue) {
    }
    
    func isValidEmail(emailID:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: emailID)
    }
    
    private func showErrorIfNeeded(_ errorOrNil: Error?) {
        // エラーがなければ何もしません
        guard errorOrNil != nil else { return }
        let message = "エラーが起きました"
        let alert = UIAlertController(title: message, message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        //HUD.hide()
        SVProgressHUD.setDefaultStyle(.custom)
        SVProgressHUD.setDefaultMaskType(.custom)
        SVProgressHUD.setForegroundColor(.black)
        SVProgressHUD.setBackgroundColor(.white)
        SVProgressHUD.setDefaultMaskType(.black)
        //withDelayにIntを設定
        SVProgressHUD.dismiss()
        present(alert, animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // キーボードを閉じる
        view.endEditing(true)
    }
}
