//
//  ContactUsViewController.swift
//  Nomad-App
//
//  Created by yuishii on 2021/02/19.
//  Copyright © 2021 Yu Ishii. All rights reserved.
//
// お問い合わせ画面 設定画面から報告するとき

import UIKit
import KMPlaceholderTextView
import Firebase
import SVProgressHUD
import NotificationBannerSwift

class ContactUsViewController: UIViewController, UITextViewDelegate{
    
    var targetUid: String = "" // 通報する対象のuid
    
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
        
        let backBarButtonItem = UIBarButtonItem()
        backBarButtonItem.title = "Back"
        self.navigationItem.backBarButtonItem = backBarButtonItem
        self.navigationItem.title = "問題を報告"
        self.navigationController?.navigationBar.titleTextAttributes
            = [NSAttributedString.Key.font: UIFont(name: "Helvetica", size: 16)!]
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        self.tabBarController?.tabBar.barTintColor = UIColor.white
        self.navigationController?.navigationBar.tintColor = UIColor.black
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.black]
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        SVProgressHUD.dismiss()
    }
    
    //テキストビューを入力し終わったときのボタンの有効化/無効化
    func textViewDidChange(_ textView: UITextView) {
        
        //不要な改行削除
        let msg = self.textView.text!.replace("\n", "")
        //テキストの半角空白文字削除
        let trimmedString = msg.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmedString.count > 200{
            textView.textColor = .red
        } else {
            textView.textColor = .black
        }
        
        if trimmedString != "" && trimmedString.count <= 201 {
            saveButton.isEnabled = true
            print("有効化1")
        }else{
            saveButton.isEnabled = false
            print("無効化1")
        }
    }
    
    
    //送信ボタンを押して内容を送信
    @IBAction func saveButton(_ sender: Any) {
        
        if Auth.auth().currentUser != nil {
            
            SVProgressHUD.setDefaultStyle(.custom)
            SVProgressHUD.setDefaultMaskType(.custom)
            SVProgressHUD.setForegroundColor(.black)
            SVProgressHUD.setBackgroundColor(.white)
            SVProgressHUD.setDefaultMaskType(.black)
            SVProgressHUD.show()
            
            textView.endEditing(true)
            
            //不要な改行削除
            let msg = self.textView.text!.replace("\n", "")
            //テキストの半角空白文字削除
            let trimmedString = msg.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmedString.count > 200{
                print("DEBUG_PRINT: タイトルが201文字以上です")
                //HUD.flash(.labeledError(title: "エラー", subtitle: "タイトルは200文字以下にしてください"), delay: 1.4)
                SVProgressHUD.setDefaultStyle(.custom)
                SVProgressHUD.setDefaultMaskType(.custom)
                SVProgressHUD.setForegroundColor(.black)
                SVProgressHUD.setBackgroundColor(.white)
                SVProgressHUD.setDefaultMaskType(.black)
                SVProgressHUD.showError(withStatus: "タイトルは200文字以下にしてください")
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
            
            let trimmedString2 = self.textView.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            
            SVProgressHUD.setDefaultStyle(.custom)
            SVProgressHUD.setDefaultMaskType(.custom)
            SVProgressHUD.setForegroundColor(.black)
            SVProgressHUD.setBackgroundColor(.white)
            SVProgressHUD.setDefaultMaskType(.black)
            SVProgressHUD.show()
            
            let myid = Auth.auth().currentUser!.uid
            let name = Auth.auth().currentUser?.displayName
            
            // 通報する対象のuid(targetUid)がない場合
            if self.targetUid == "" {
                let reportRef = Firestore.firestore().collection("reports").document()
                let postDic = [
                    "name": name!,
                    "uid": myid,
                    "caption": trimmedString2,
                    "date": FieldValue.serverTimestamp(),
                ] as [String : Any]
                reportRef.setData(postDic)
                
            // 通報する対象のuid(targetUid)がある場合
            }else{
                let reportRef = Firestore.firestore().collection("reports").document()
                let postDic = [
                    "name": name!,
                    "uid": myid,
                    "targetUid": self.targetUid,
                    "caption": trimmedString2,
                    "date": FieldValue.serverTimestamp(),
                ] as [String : Any]
                reportRef.setData(postDic)
            }
            
            let banner = NotificationBanner(title: "問題を報告しました", leftView: nil, rightView: nil, style: .info, colors: nil)
            banner.autoDismiss = false
            banner.dismissOnTap = true
            banner.show(queuePosition: .front, bannerPosition: .top, queue: .default, on: self.navigationController!)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2, execute: {
                banner.dismiss()
            })
            self.navigationController?.popViewController(animated: true)
        }
    }
}
