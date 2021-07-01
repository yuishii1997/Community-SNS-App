//
//  WebEditViewController.swift
//  Nomad-App
//
//  Created by yuishii on 2020/12/24.
//  Copyright © 2020 Yu Ishii. All rights reserved.
//
// WebのURLを変更する画面

import UIKit
import Firebase
import SVProgressHUD

class WebEditViewController: UIViewController, UITextFieldDelegate {
    
    var userArray: [UserData] = []
    var userdata: UserData?
    var userdata2: UserData?
    
    var listener1: ListenerRegistration!
    var listener2: ListenerRegistration!
    
    @IBOutlet weak var textField: UITextField!
    
    @IBOutlet weak var saveButton: UIBarButtonItem! {
        didSet {
            saveButton.tintColor = .link
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textField.attributedPlaceholder = NSAttributedString(string: "Webを追加", attributes: [NSAttributedString.Key.foregroundColor : UIColor.darkGray])
        
        textField.delegate = self
        saveButton.isEnabled = false
        
        //テキストフィールドのキーボードを常時表示
        textField.becomeFirstResponder()
        
        self.textField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
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
        
        fetchUser()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        SVProgressHUD.dismiss()
        
        if ( self.listener1 != nil ){
            listener1.remove()
            listener1 = nil
        }
        if ( self.listener2 != nil ){
            listener2.remove()
            listener2 = nil
        }
        
    }
    
    private func fetchUser() {
        
        if Auth.auth().currentUser != nil {
            let myid = Auth.auth().currentUser!.uid
            
            let userRef = Firestore.firestore().collection("users").document(myid)
            if ( self.listener1 == nil ) {
                self.listener1 = userRef.addSnapshotListener() { (documentSnapshot, error) in
                    guard let document = documentSnapshot else {
                        print("Error fetching document: \(error!)")
                        return
                    }
                    self.userdata  = UserData(document: document)
                    
                    if self.userdata?.editID != nil {
                        
                        let userRef = Firestore.firestore().collection("users").document(self.userdata!.editID!)
                        
                        userRef.addSnapshotListener() { (documentSnapshot, error) in
                            guard let document = documentSnapshot else {
                                print("Error fetching document: \(error!)")
                                return
                            }
                            self.userdata2  = UserData(document: document)
                            if self.userdata2?.web != nil {
                                self.textField.text = self.userdata2!.web
                                print("userdata.name:\(self.userdata2?.web)")
                            }else{
                                self.textField.text = ""
                                print("userdata.name:\(self.userdata2?.web)")
                            }
                        }
                    }
                }
            }
            
        }
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    
    func textFieldDidEndEditing(_ textField:UITextField){
        //テキストの半角空白文字削除
        let trimmedString = self.textField.text!.trimmingCharacters(in: .whitespaces)
        
        if trimmedString.isEmpty {
            saveButton.isEnabled = false
            print("無効化1")
        }else{
            saveButton.isEnabled = true
            print("有効化1")
        }
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        
        //テキストの半角空白文字削除
        let trimmedString = self.textField.text!.trimmingCharacters(in: .whitespaces)
        
        if trimmedString.isEmpty {
            saveButton.isEnabled = false
            print("無効化2")
        }else{
            saveButton.isEnabled = true
            print("有効化2")
        }
    }
    
    
    @IBAction func handleChangeButton(_ sender: Any) {
        
        // キーボードを閉じる
        textField.endEditing(true)
        
        let web = self.textField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // 表示名が入力されていない時はHUDを出して何もしない
        if web.isEmpty {
            //HUD.flash(.labeledError(title: "エラー", subtitle: "ユーザー名を入力してください"), delay: 1.4)
            SVProgressHUD.setDefaultStyle(.custom)
            SVProgressHUD.setDefaultMaskType(.custom)
            SVProgressHUD.setForegroundColor(.black)
            SVProgressHUD.setBackgroundColor(.white)
            SVProgressHUD.setDefaultMaskType(.black)
            SVProgressHUD.showError(withStatus: "URLを入力してください")
            //withDelayにIntを設定
            SVProgressHUD.dismiss(withDelay: 1.7)
            return
        }else if web.count >= 100 {
            SVProgressHUD.setDefaultStyle(.custom)
            SVProgressHUD.setDefaultMaskType(.custom)
            SVProgressHUD.setForegroundColor(.black)
            SVProgressHUD.setBackgroundColor(.white)
            SVProgressHUD.setDefaultMaskType(.black)
            SVProgressHUD.showError(withStatus: "有効なURLを入力してください")
            //withDelayにIntを設定
            SVProgressHUD.dismiss(withDelay: 1.7)
            return
        }
        
        //HUD.flash(.labeledSuccess(title: "変更完了", subtitle: nil), delay: 1.4)
        SVProgressHUD.setDefaultStyle(.custom)
        SVProgressHUD.setDefaultMaskType(.custom)
        SVProgressHUD.setForegroundColor(.black)
        SVProgressHUD.setBackgroundColor(.white)
        SVProgressHUD.setDefaultMaskType(.black)
        SVProgressHUD.show()
        
        let ref = Firestore.firestore().collection("users").document(self.userdata2!.uid)
        //var updateValue: FieldValue
        //updateValue = FieldValue.arrayUnion([displayName])
        //            ref.setData(["name": updateValue], merge: true)
        //ここでref.updateData(["name": updateValue])にすると、配列でデータが保存されて行ってしまう
        ref.updateData(["web": web])
        self.navigationController?.popViewController(animated: true)
        
    }
}

