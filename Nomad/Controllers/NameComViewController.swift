//
//  NameComViewController.swift
//  Nomad-App
//
//  Created by yuishii on 2020/12/29.
//  Copyright © 2020 Yu Ishii. All rights reserved.
//
// コミュニティー新規作成時に名前を設定する画面

import UIKit
import Firebase
import SVProgressHUD

class NameComViewController: UIViewController, UITextFieldDelegate {
    
    var userdata: UserData?
    
    var listener: ListenerRegistration!
    
    @IBOutlet weak var textField: UITextField!
    
    @IBOutlet weak var saveButton: UIBarButtonItem! {
        didSet {
            saveButton.tintColor = .link
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textField.attributedPlaceholder = NSAttributedString(string: "コミュニティ名を入力", attributes: [NSAttributedString.Key.foregroundColor : UIColor.darkGray])
        
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
        
        if ( self.listener != nil ){
            listener.remove()
            listener = nil
        }
        
    }
    
    private func fetchUser() {
        if Auth.auth().currentUser != nil {
            let myid = Auth.auth().currentUser!.uid
            if ( self.listener == nil ) {
                let userRef = Firestore.firestore().collection("users").document(myid)
                self.listener = userRef.addSnapshotListener() { (documentSnapshot, error) in
                    guard let document = documentSnapshot else {
                        print("Error fetching document: \(error!)")
                        return
                    }
                    self.userdata  = UserData(document: document)
                    if self.userdata?.communityName != nil {
                        self.textField.text = self.userdata!.communityName
                    }else{
                        self.textField.text = ""
                    }
                }
            }
        }
    }
    
    func textFieldDidEndEditing(_ textField:UITextField){
        //テキストの半角空白文字削除
        let trimmedString = self.textField.text!.trimmingCharacters(in: .whitespaces)
        
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
        let trimmedString = self.textField.text!.trimmingCharacters(in: .whitespaces)
        
        if trimmedString.isEmpty || trimmedString.count > 30 {
            saveButton.isEnabled = false
            print("無効化2")
        }else{
            saveButton.isEnabled = true
            print("有効化2")
        }
    }
    
    @IBAction func saveButton(_ sender: Any) {
        
        let displayName = self.textField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        
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
            let ref = Firestore.firestore().collection("users").document(myid)
            ref.updateData(["communityName": displayName])
            
            SVProgressHUD.setDefaultStyle(.custom)
            SVProgressHUD.setDefaultMaskType(.custom)
            SVProgressHUD.setForegroundColor(.black)
            SVProgressHUD.setBackgroundColor(.white)
            SVProgressHUD.setDefaultMaskType(.black)
            //withDelayにIntを設定
            SVProgressHUD.dismiss()
            
            self.navigationController?.popViewController(animated: true)
        }
    }
    
}
