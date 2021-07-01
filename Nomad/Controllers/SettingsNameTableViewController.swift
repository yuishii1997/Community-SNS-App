//
//  SettingsNameTableViewController.swift
//  Nomad-App
//
//  Created by yuishii on 2020/07/13.
//  Copyright © 2020 Yu Ishii. All rights reserved.
//
// 名前を変更する画面

import UIKit
import Firebase
import SVProgressHUD

class SettingsNameTableViewController: UITableViewController,UITextFieldDelegate {
    
    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let userName = Auth.auth().currentUser?.displayName
        nameTextField.text = userName
        
        nameTextField.delegate = self
        saveButton.isEnabled = false
        
        //テキストフィールドのキーボードを常時表示
        nameTextField.becomeFirstResponder()
        
        self.nameTextField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
        
        self.tableView.separatorInset = .zero
        
        nameTextField.textColor = .link
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        SVProgressHUD.dismiss()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("DEBUG_PRINT: viewWillAppear")
        
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
    
    
    @IBAction func backButton(_ sender: Any) {
        //遷移元に戻る
        self.navigationController?.popViewController(animated: true)
    }
    
    
    func textFieldDidEndEditing(_ textField:UITextField){
        //テキストの半角空白文字削除
        let trimmedString = self.nameTextField.text!.trimmingCharacters(in: .whitespaces)
        
        if trimmedString.isEmpty || trimmedString.count > 20 {
            saveButton.isEnabled = false
            print("無効化1")
        }else{
            saveButton.isEnabled = true
            print("有効化1")
        }
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        
        //テキストの半角空白文字削除
        let trimmedString = self.nameTextField.text!.trimmingCharacters(in: .whitespaces)
        
        if trimmedString.isEmpty || trimmedString.count > 20 {
            saveButton.isEnabled = false
            print("無効化2")
        }else{
            saveButton.isEnabled = true
            print("有効化2")
        }
    }
    
    
    @IBAction func handleChangeButton(_ sender: Any) {
        
        let displayName = self.nameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // 表示名が入力されていない時はHUDを出して何もしない
        if displayName.isEmpty {
            //HUD.flash(.labeledError(title: "エラー", subtitle: "ユーザー名を入力してください"), delay: 1.4)
            SVProgressHUD.setDefaultStyle(.custom)
            SVProgressHUD.setDefaultMaskType(.custom)
            SVProgressHUD.setForegroundColor(.black)
            SVProgressHUD.setBackgroundColor(.white)
            SVProgressHUD.setDefaultMaskType(.black)
            SVProgressHUD.showError(withStatus: "名前を入力してください")
            //withDelayにIntを設定
            SVProgressHUD.dismiss(withDelay: 1.7)
            return
        }else if displayName.count > 20{
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
        }
        SVProgressHUD.setDefaultStyle(.custom)
        SVProgressHUD.setDefaultMaskType(.custom)
        SVProgressHUD.setForegroundColor(.black)
        SVProgressHUD.setBackgroundColor(.white)
        SVProgressHUD.setDefaultMaskType(.black)
        //HUD.show(.progress, onView: view)
        SVProgressHUD.show()
        
        // 表示名を設定する
        let user = Auth.auth().currentUser
        if let user = user {
            let changeRequest = user.createProfileChangeRequest()
            changeRequest.displayName = displayName
            changeRequest.commitChanges { error in
                if let error = error {
                    
                    //HUD.flash(.labeledError(title: "エラー", subtitle: "ユーザー名の変更に失敗しました"), delay: 1.4)
                    SVProgressHUD.setDefaultStyle(.custom)
                    SVProgressHUD.setDefaultMaskType(.custom)
                    SVProgressHUD.setForegroundColor(.black)
                    SVProgressHUD.setBackgroundColor(.white)
                    SVProgressHUD.setDefaultMaskType(.black)
                    SVProgressHUD.showError(withStatus: "名前の変更に失敗しました")
                    //withDelayにIntを設定
                    SVProgressHUD.dismiss(withDelay: 1.7)
                    
                    print("DEBUG_PRINT: " + error.localizedDescription)
                    return
                }
                
                //HUD.flash(.labeledSuccess(title: "変更完了", subtitle: nil), delay: 1.4)
                SVProgressHUD.setDefaultStyle(.custom)
                SVProgressHUD.setDefaultMaskType(.custom)
                SVProgressHUD.setForegroundColor(.black)
                SVProgressHUD.setBackgroundColor(.white)
                SVProgressHUD.setDefaultMaskType(.black)
                SVProgressHUD.show()
                print("DEBUG_PRINT: [displayName = \(user.displayName!)]の設定に成功しました。")
                // 遷移元の画面に戻る
                //遷移元に戻る
                self.navigationController?.popViewController(animated: true)
            }
        }
        
        // キーボードを閉じる
        self.view.endEditing(true)
    }
    
}
