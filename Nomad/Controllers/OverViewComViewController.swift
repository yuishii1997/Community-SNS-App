//
//  OverViewComViewController.swift
//  Nomad-App
//
//  Created by yuishii on 2020/12/28.
//  Copyright © 2020 Yu Ishii. All rights reserved.
//
// コミュニティー新規作成時に概要を設定する画面

import UIKit
import KMPlaceholderTextView
import Firebase
import SVProgressHUD

class OverViewComViewController: UIViewController, UITextViewDelegate{
    
    var userdata: UserData?
    
    var listener: ListenerRegistration!
    
    @IBOutlet weak var textView: KMPlaceholderTextView!
    
    @IBOutlet weak var saveButton: UIBarButtonItem!{
        didSet {
            saveButton.tintColor = .link
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textView.delegate = self
        saveButton.isEnabled = false
        
        textView.becomeFirstResponder()
        
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
            let userRef = Firestore.firestore().collection("users").document(myid)
            if ( self.listener == nil ) {
                self.listener = userRef.addSnapshotListener() { (documentSnapshot, error) in
                    guard let document = documentSnapshot else {
                        print("Error fetching document: \(error!)")
                        return
                    }
                    self.userdata  = UserData(document: document)
                    if self.userdata?.communityOverView != nil {
                        self.textView.text = self.userdata!.communityOverView
                    }else{
                        self.textView.text = ""
                    }
                }
            }
        }
    }
    
    //テキストビューを入力し終わったときのボタンの有効化/無効化
    func textViewDidChange(_ textView: UITextView) {
        
        //不要な改行削除
        let msg = self.textView.text!.replace("\n", "")
        //テキストの半角空白文字削除
        let trimmedString = msg.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmedString.count > 1000{
            textView.textColor = .red
        } else {
            textView.textColor = .black
        }
        
        if trimmedString != "" && trimmedString.count <= 1001 {
            saveButton.isEnabled = true
            print("有効化1")
        }else{
            saveButton.isEnabled = false
            print("無効化1")
        }
    }
    
    @IBAction func saveButton(_ sender: Any) {
        
        SVProgressHUD.setDefaultStyle(.custom)
        SVProgressHUD.setDefaultMaskType(.custom)
        SVProgressHUD.setForegroundColor(.black)
        SVProgressHUD.setBackgroundColor(.white)
        SVProgressHUD.setDefaultMaskType(.black)
        SVProgressHUD.show()
        
        // キーボードを閉じる
        textView.endEditing(true)
        
        //不要な改行削除
        let msg = self.textView.text!.replace("\n", "")
        //テキストの半角空白文字削除
        let trimmedString = msg.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedString.count > 1000{
            print("DEBUG_PRINT: タイトルが1001文字以上です")
            //HUD.flash(.labeledError(title: "エラー", subtitle: "タイトルは1000文字以下にしてください"), delay: 1.4)
            SVProgressHUD.setDefaultStyle(.custom)
            SVProgressHUD.setDefaultMaskType(.custom)
            SVProgressHUD.setForegroundColor(.black)
            SVProgressHUD.setBackgroundColor(.white)
            SVProgressHUD.setDefaultMaskType(.black)
            SVProgressHUD.showError(withStatus: "タイトルは1000文字以下にしてください")
            //withDelayにIntを設定
            SVProgressHUD.dismiss(withDelay: 1.7)
            return
        }else if trimmedString.count == 0{
            print("DEBUG_PRINT: タイトルが空白です")
            //HUD.flash(.labeledError(title: "エラー", subtitle: "タイトルが空白です"), delay: 1.4)
            SVProgressHUD.setDefaultStyle(.custom)
            SVProgressHUD.setDefaultMaskType(.custom)
            SVProgressHUD.setForegroundColor(.black)
            SVProgressHUD.setBackgroundColor(.white)
            SVProgressHUD.setDefaultMaskType(.black)
            SVProgressHUD.showError(withStatus: "タイトルが空白です")
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
            ref.updateData(["communityOverView": trimmedString])
            
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
