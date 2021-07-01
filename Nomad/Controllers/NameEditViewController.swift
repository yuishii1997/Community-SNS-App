//
//  NameEditViewController.swift
//  Nomad-App
//
//  Created by yuishii on 2020/12/23.
//  Copyright © 2020 Yu Ishii. All rights reserved.
//
// 名前を変更する画面

import UIKit
import Firebase
import SVProgressHUD

class NameEditViewController: UIViewController, UITextFieldDelegate {
    
    var userArray: [UserData] = []
    var userdata: UserData?
    var userdata2: UserData?
    
    var listener: ListenerRegistration!
    var listener2: ListenerRegistration!
    
    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var saveButton: UIBarButtonItem! {
        didSet {
            saveButton.tintColor = .link
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameTextField.attributedPlaceholder = NSAttributedString(string: "名前を変更", attributes: [NSAttributedString.Key.foregroundColor : UIColor.darkGray])
        
        nameTextField.delegate = self
        saveButton.isEnabled = false
        
        //テキストフィールドのキーボードを常時表示
        nameTextField.becomeFirstResponder()
        
        self.nameTextField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
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
        
        if ( self.listener != nil ){
            listener.remove()
            listener = nil
        }
        
        if ( self.listener2 != nil ){
            listener2.remove()
            listener2 = nil
        }
        
    }
    
    private func fetchUser() {
        
        if Auth.auth().currentUser != nil {
            let myid = Auth.auth().currentUser!.uid
            
            if ( self.listener == nil ) {
                let userRef1 = Firestore.firestore().collection("users").document(myid)
                self.listener =  userRef1.addSnapshotListener() { (documentSnapshot, error) in
                    guard let document = documentSnapshot else {
                        print("Error fetching document: \(error!)")
                        return
                    }
                    self.userdata  = UserData(document: document)
                    
                    if self.userdata?.editID != nil {
                        
                        let userRef2 = Firestore.firestore().collection("users").document(self.userdata!.editID!)
                        userRef2.addSnapshotListener() { (documentSnapshot, error) in
                            guard let document = documentSnapshot else {
                                print("Error fetching document: \(error!)")
                                return
                            }
                            self.userdata2  = UserData(document: document)
                            if self.userdata2?.name != nil {
                                self.nameTextField.text = self.userdata2!.name
                                print("userdata.name:\(self.userdata2?.name)")
                            }else{
                                self.nameTextField.text = ""
                                print("userdata.name:\(self.userdata2?.name)")
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
        let trimmedString = self.nameTextField.text!.trimmingCharacters(in: .whitespaces)
        
        if trimmedString.isEmpty || trimmedString.count > 30 {
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
        
        if trimmedString.isEmpty || trimmedString.count > 30 {
            saveButton.isEnabled = false
            print("無効化2")
        }else{
            saveButton.isEnabled = true
            print("有効化2")
        }
    }
    
    
    @IBAction func handleChangeButton(_ sender: Any) {
        
        // キーボードを閉じる
        nameTextField.endEditing(true)
        
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
        }else if displayName.count > 30{
            print("DEBUG_PRINT: ユーザー名が31文字以上です")
            //HUD.flash(.labeledError(title: "エラー", subtitle: "名前が31文字をこえています"), delay: 1.4)
            SVProgressHUD.setDefaultStyle(.custom)
            SVProgressHUD.setDefaultMaskType(.custom)
            SVProgressHUD.setForegroundColor(.black)
            SVProgressHUD.setBackgroundColor(.white)
            SVProgressHUD.setDefaultMaskType(.black)
            SVProgressHUD.showError(withStatus: "名前が30文字をこえています")
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
        
        if Auth.auth().currentUser != nil {
            let myid = Auth.auth().currentUser!.uid
            
            if self.userdata2?.uid == myid {
                
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
                        
                        let ref = Firestore.firestore().collection("users").document(myid)
                        //var updateValue: FieldValue
                        //updateValue = FieldValue.arrayUnion([displayName])
                        //            ref.setData(["name": updateValue], merge: true)
                        //ここでref.updateData(["name": updateValue])にすると、配列でデータが保存されて行ってしまう
                        ref.updateData(["name": displayName])
                        self.navigationController?.popViewController(animated: true)
                        
                    }
                }
            }else{
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
                ref.updateData(["name": displayName])
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
}

