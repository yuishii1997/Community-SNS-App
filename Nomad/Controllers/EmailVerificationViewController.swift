//
//  EmailVerificationViewController.swift
//  Nomad-App
//
//  Created by yuishii on 2020/07/13.
//  Copyright © 2020 Yu Ishii. All rights reserved.
//
// 新規登録時のメール確認画面

import UIKit
import Firebase
import Darwin

class EmailVerificationViewController: UIViewController {
    
    var timer: Timer!
    
    // ユーザーデータを格納する配列
    var userArray: [UserData] = []
    private var userdata: UserData?
    
    var listener: ListenerRegistration!
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        navigationController?.setNavigationBarHidden(true, animated: false)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        
        backButton.layer.cornerRadius = 15
        
        textView.font = UIFont.systemFont(ofSize: 14.0)
        
        if Auth.auth().currentUser != nil {
            Auth.auth().currentUser?.reload(completion: { error in
                if error == nil {
                    if Auth.auth().currentUser?.isEmailVerified == true {
                        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
                        let rootViewController = storyboard.instantiateViewController(withIdentifier: "RootTabBarController")
                        //保存した時刻削除
                        UserDefaults.standard.removeObject(forKey: "creationTime")
                        self.present(rootViewController, animated: true, completion: nil)
                    } else if Auth.auth().currentUser?.isEmailVerified == false {
                        //10分後までにリンクをクリックしなければアカウント削除してトップに戻る
                        if let date = UserDefaults.standard.object(forKey: "creationTime") as? Date {
                            if let diff = Calendar.current.dateComponents([.minute], from: date, to: Date()).minute, diff > 10 {
                                //10分経過した場合の処理
                                // ログイン中のユーザーアカウントを削除する。
                                Auth.auth().currentUser?.delete() {  (error) in
                                    // エラーが無ければ、ログイン画面へ戻る
                                    if error == nil {
                                        print("アカウント削除完了(1)")
                                        
                                        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
                                        let rootViewController = storyboard.instantiateViewController(withIdentifier: "LoginNavi")
                                        //保存した時刻削除
                                        UserDefaults.standard.removeObject(forKey: "creationTime")
                                        self.present(rootViewController, animated: true, completion: nil)
                                    }else{
                                        print("アカウント削除完了(2)")
                                        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
                                        let rootViewController = storyboard.instantiateViewController(withIdentifier: "LoginNavi")
                                        //保存した時刻削除
                                        UserDefaults.standard.removeObject(forKey: "creationTime")
                                        self.present(rootViewController, animated: true, completion: nil)
                                    }
                                }
                            }
                            //10分経過していない場合の処理
                            print("10分経過していません")
                        }
                        print("メール認証が完了していません")
                    }
                }
            })
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("DEBUG_PRINT: viewWillAppear")
        
        
        if Auth.auth().currentUser != nil {
            // ログイン済み
            if listener == nil {
                // listener未登録なら、登録してスナップショットを受信する
                let ref = Firestore.firestore().collection("Users").order(by: "date", descending: true)
                listener = ref.addSnapshotListener() { [weak self] querySnapshot, error in
                    if let error = error {
                        print("DEBUG_PRINT: snapshotの取得が失敗しました。 \(error)")
                        return
                    }
                    // 取得したdocumentをもとにPostDataを作成し、postArrayの配列にする。
                    self!.userArray = querySnapshot!.documents.compactMap { document in
                        print("DEBUG_PRINT: document取得 \(document.documentID)")
                        let userData = UserData(document: document)
                        return userData
                    }
                }
            }
        } else {
            // ログイン未(またはログアウト済み)
            if listener != nil {
                // listener登録済みなら削除してpostArrayをクリアする
                listener.remove()
                listener = nil
                userArray = []
            }
        }
    }
    
    
    @IBAction func back(_ sender: Any) {
        
        let alert: UIAlertController = UIAlertController.init(title: "トップに戻る", message: "仮登録したアカウントは削除されますがよろしいですか？",
                                                              preferredStyle: UIAlertController.Style.alert)
        let cancelAction: UIAlertAction = UIAlertAction.init(title: "キャンセル", style: UIAlertAction.Style.cancel,
                                                             handler: { (UIAlertAction) in
                                                                print("キャンセルが選択されました。")
                                                                alert.dismiss(animated: true, completion: nil)
                                                             })
        alert.addAction(cancelAction)
        let okAction: UIAlertAction = UIAlertAction.init(title: "はい", style: UIAlertAction.Style.destructive,
                                                         handler: { (UIAlertAction) in
                                                            print("OKが選択されました。")
                                                            // ログイン中のユーザーアカウントを削除する。
                                                            Auth.auth().currentUser?.delete() {  (error) in
                                                                // エラーが無ければ、ログイン画面へ戻る
                                                                if error == nil {
                                                                    print("アカウント削除完了")
                                                                    //保存した時刻削除
                                                                    UserDefaults.standard.removeObject(forKey: "creationTime")
                                                                    let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
                                                                    let rootViewController = storyboard.instantiateViewController(withIdentifier: "LoginNavi")
                                                                    self.present(rootViewController, animated: true, completion: nil)
                                                                }else{
                                                                    let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
                                                                    let rootViewController = storyboard.instantiateViewController(withIdentifier: "LoginNavi")
                                                                    self.present(rootViewController, animated: true, completion: nil)
                                                                }
                                                            }
                                                         })
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        timer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(self.reload), userInfo: nil, repeats: true)
    }
    
    // 画面が閉じる直前に呼ばれる
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // タイマーを停止する
        if let workingTimer = timer{
            workingTimer.invalidate()
        }
        
        if ( self.listener != nil ){
            listener.remove()
            listener = nil
        }
        
    }
    
    func randomString(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyz0123456789._"
        return String((0..<length).map{ _ in letters.randomElement()! })
    }
    
    @objc func reload(_ sender: Timer) {
        
        if Auth.auth().currentUser != nil {
            Auth.auth().currentUser?.reload(completion: { error in
                if error == nil {
                    
                    if Auth.auth().currentUser?.isEmailVerified == true {
                        
                        //タブ画面に移動
                        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
                        let rootViewController = storyboard.instantiateViewController(withIdentifier: "RootTabBarController")
                        self.present(rootViewController, animated: true, completion: {
                            
                            //保存した時刻削除
                            UserDefaults.standard.removeObject(forKey: "creationTime")
                            
                            let name = Auth.auth().currentUser?.displayName
                            let email = Auth.auth().currentUser?.email
                            let myid = Auth.auth().currentUser?.uid
                            let locale = NSLocale.current
                            let country = locale.regionCode
                            let language = locale.languageCode
                            let number: Int = 0
                            
                            print("countryCode\(country)")
                            print("languageCode\(language)")
                            
                            let ref = Firestore.firestore().collection("users").document(myid!)
                            let userDic = [
                                "name": name!,
                                "type": "private",
                                "bePrivate": "off",
                                "email": email!,
                                "uid": myid!,
                                "destID": myid!,
                                "date": FieldValue.serverTimestamp(),
                                "country": country,
                                "language": language,
                                "with_iconImage" : "notExist",
                                "with_headerImage": "notExist",
                                "imageNo": number,
                                "headerNo": number,
                                "deleted": "no",
                            ] as [String : Any]
                            ref.setData(userDic)
                            
                        })
                        
                    }else{
                        //10分後までにリンクをクリックしなければアカウント削除してトップに戻る
                        if let date = UserDefaults.standard.object(forKey: "creationTime") as? Date {
                            if let diff = Calendar.current.dateComponents([.minute], from: date, to: Date()).minute, diff > 10 {
                                //10分経過した場合の処理
                                // ログイン中のユーザーアカウントを削除する。
                                Auth.auth().currentUser?.delete() {  (error) in
                                    // エラーが無ければ、ログイン画面へ戻る
                                    if error == nil {
                                        print("アカウント削除完了(1)")
                                        
                                        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
                                        let rootViewController = storyboard.instantiateViewController(withIdentifier: "LoginNavi")
                                        //保存した時刻削除
                                        UserDefaults.standard.removeObject(forKey: "creationTime")
                                        self.present(rootViewController, animated: true, completion: nil)
                                    }else{
                                        print("アカウント削除完了(2)")
                                        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
                                        let rootViewController = storyboard.instantiateViewController(withIdentifier: "LoginNavi")
                                        //保存した時刻削除
                                        UserDefaults.standard.removeObject(forKey: "creationTime")
                                        self.present(rootViewController, animated: true, completion: nil)
                                    }
                                }
                            }
                            //10分経過していない場合の処理
                            print("10分経過していません")
                        }
                        print("メール認証が完了していません")
                    }
                }
            })
        }
    }
}
