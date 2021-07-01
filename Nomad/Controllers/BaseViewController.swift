//
//  BaseViewController.swift
//  Nomad-App
//
//  Created by yuishii on 2020/07/13.
//  Copyright © 2020 Yu Ishii. All rights reserved.
//
// プロフィール画面のSegementSlideを設定

import UIKit
import SegementSlide
import Firebase

class BaseViewController: SegementSlideViewController {
    
    var userID: String = ""
    var type: String = ""
    
    // ユーザーデータを格納する配列
    var userArray: [UserData] = []
    private var userdata: UserData?
    
    // Firestoreのリスナー
    var listener: ListenerRegistration!
    
    
    @IBOutlet weak var profileNameButton: UIBarButtonItem!
    @IBOutlet weak var backButton: UIBarButtonItem!
    
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
        
        //segementslideのナビゲーションバーとタブバーが標準で透明になっているため、それを解除する。
        self.tabBarController?.tabBar.isTranslucent = false
        self.navigationController?.navigationBar.isTranslucent = false
        
        //ナビゲーションバーの色
        self.navigationController?.navigationBar.barTintColor = UIColor.rgb(red: 66, green: 80, blue: 109)
        //タブバーの色
        self.tabBarController?.tabBar.barTintColor = UIColor.white
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
        
        // ナビゲージョンアイテムの文字色
        UINavigationBar.appearance().tintColor = UIColor.white
        // ナビゲーションバーのタイトルの文字色
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor.white]
        
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
    }
    
    
    @objc func toBack() {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let backBarButtonItem = UIBarButtonItem()
        backBarButtonItem.title = "Back"
        self.navigationItem.backBarButtonItem = backBarButtonItem
        
        reloadData()
        
        scrollToSlide(at: 0, animated: true)
        
        print("BaseViewController-userID:\(userID)")
        
        let backButtonItem:UIBarButtonItem =  UIBarButtonItem(customView:self.createButton())
        navigationItem.leftBarButtonItem = backButtonItem
        
    }
    
    
    
    func createButton() -> UIButton {
        
        let button: UIButton = UIButton(type: .system)
        button.frame = CGRect(x: 0, y: 0, width: 130, height: 40)
        button.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.left;     //中身左寄せ
        
        if self.type == "private" {
            button.setTitle("プライベート", for: UIControl.State.normal)
        }else{
            button.setTitle("コミュニティ", for: UIControl.State.normal)
        }
        
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font = UIFont(name:"HiraKakuProN-W3",size: 16)
        button.setImage(UIImage(named: "icons8-左-20"), for: .normal)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 7, bottom: 0, right: 0);     //テキストにマージン。左に7px
        button.addTarget(self, action: #selector(toBack), for: .touchUpInside)
        
        return button
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if ( self.listener != nil ){
            listener.remove()
            listener = nil
        }
        
    }
    
    private func fetchUser() {
        if ( self.listener == nil ) {
            let userRef = Firestore.firestore().collection("users").document(userID)
            self.listener = userRef.addSnapshotListener() { (documentSnapshot, error) in
                guard let document = documentSnapshot else {
                    print("Error fetching document: \(error!)")
                    return
                }
                self.userdata  = UserData(document: document)
                //self.navigationItem.title = self.userdata!.name
                
            }
        }
    }
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    
    
    @IBAction func menu(_ sender: UIBarButtonItem) {
        
        if Auth.auth().currentUser != nil {
            let myid = Auth.auth().currentUser!.uid
            
            if self.userdata?.type == "private" {
                if myid == userID {
                    let alert: UIAlertController = UIAlertController.init(title: "プロフィールを変更しますか？", message: nil,
                                                                          preferredStyle: UIAlertController.Style.actionSheet)
                    let cancelAction: UIAlertAction = UIAlertAction.init(title: "キャンセル", style: UIAlertAction.Style.cancel,
                                                                         handler: { (UIAlertAction) in
                                                                            print("キャンセルが選択されました。")
                                                                            alert.dismiss(animated: true, completion: nil)
                                                                         })
                    alert.addAction(cancelAction)
                    let okAction: UIAlertAction = UIAlertAction.init(title: "変更する", style: UIAlertAction.Style.default,
                                                                     handler: { (UIAlertAction) in
                                                                        print("OKが選択されました。")
                                                                        
                                                                        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
                                                                        let viewController = storyboard.instantiateViewController(identifier: "ProfileEditViewController") as! ProfileEditViewController
                                                                        
                                                                        if Auth.auth().currentUser != nil {
                                                                            let myid = Auth.auth().currentUser!.uid
                                                                            let ref = Firestore.firestore().collection("users").document(myid)
                                                                            ref.updateData(["editID": self.userID])
                                                                            
                                                                            self.navigationController?.pushViewController(viewController, animated: true)
                                                                        }
                                                                        
                                                                     })
                    alert.addAction(okAction)
                    present(alert, animated: true, completion: nil)
                }else{
                    let alert: UIAlertController = UIAlertController.init(title: nil, message: nil,
                                                                          preferredStyle: UIAlertController.Style.actionSheet)
                    let cancelAction: UIAlertAction = UIAlertAction.init(title: "キャンセル", style: UIAlertAction.Style.cancel,
                                                                         handler: { (UIAlertAction) in
                                                                            print("キャンセルが選択されました。")
                                                                            alert.dismiss(animated: true, completion: nil)
                                                                         })
                    let okAction1 = UIAlertAction(title: "ブロックする", style: UIAlertAction.Style.destructive, handler: {
                        (action: UIAlertAction!) in
                        
                        let alert: UIAlertController = UIAlertController(title: "よろしいですか？", message: "このユーザーの投稿は今後表示されなくなります。", preferredStyle:  UIAlertController.Style.alert)
                        let defaultAction: UIAlertAction = UIAlertAction(title: "はい", style: UIAlertAction.Style.destructive, handler:{
                            (action: UIAlertAction!) -> Void in
                            
                            if self.userdata?.isBlocked == false {
                                
                                var updateValue1: FieldValue
                                var updateValue2: FieldValue
                                var updateValue3: FieldValue
                                var updateValue4: FieldValue
                                
                                let time = Date.timeIntervalSinceReferenceDate
                                
                                updateValue1 = FieldValue.arrayUnion([["uid": myid, "time": time]])
                                updateValue2 = FieldValue.arrayUnion([self.userID])
                                updateValue3 = FieldValue.arrayUnion([myid])
                                updateValue4 = FieldValue.arrayUnion([["uid": self.userID, "time": time]])
                                
                                let userRef1 = Firestore.firestore().collection("users").document(self.userID)
                                userRef1.updateData(["blocked": updateValue1])
                                let userRef2 = Firestore.firestore().collection("users").document(myid)
                                userRef2.updateData(["block": updateValue4])
                                
                                let blockingRef = Firestore.firestore().collection("blockUsers").document(myid)
                                
                                blockingRef.getDocument { [weak self] document, error in
                                    if let document = document, document.exists {
                                        let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                                        print("Document data: \(dataDescription)")
                                        blockingRef.updateData(["users": updateValue2])
                                    } else {
                                        print("Document does not exist")
                                        blockingRef.setData(["users": updateValue2])
                                    }
                                }
                                
                                let blockedRef = Firestore.firestore().collection("blockedUsers").document(self.userID)
                                
                                blockedRef.getDocument { [weak self] document, error in
                                    if let document = document, document.exists {
                                        let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                                        print("Document data: \(dataDescription)")
                                        blockedRef.updateData(["users": updateValue3])
                                    } else {
                                        print("Document does not exist")
                                        blockedRef.setData(["users": updateValue3])
                                    }
                                }
                            }else{
                                print("すでにブロックしています")
                            }
                        })
                        let cancelAction: UIAlertAction = UIAlertAction(title: "キャンセル", style: UIAlertAction.Style.default, handler:{
                            (action: UIAlertAction!) -> Void in
                            print("Cancel")
                        })
                        alert.addAction(cancelAction)
                        alert.addAction(defaultAction)
                        self.present(alert, animated: true, completion: nil)
                        
                    })
                    let okAction2: UIAlertAction = UIAlertAction.init(title: "報告する", style: UIAlertAction.Style.destructive,
                                                                      handler: { (UIAlertAction) in
                                                                        
                                                                        
                                                                        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
                                                                        let viewController = storyboard.instantiateViewController(identifier: "ContactUs") as! ContactUsViewController
                                                                        viewController.targetUid = self.userdata!.uid
                                                                        self.navigationController?.pushViewController(viewController, animated: true)
                                                                        
                                                                      })
                    alert.addAction(okAction1)
                    alert.addAction(okAction2)
                    alert.addAction(cancelAction)
                    present(alert, animated: true, completion: nil)
                }
            }else{
                
                if self.userdata?.isModerated == true {
                    let alert: UIAlertController = UIAlertController.init(title: "プロフィールを変更しますか？", message: nil,
                                                                          preferredStyle: UIAlertController.Style.actionSheet)
                    let cancelAction: UIAlertAction = UIAlertAction.init(title: "キャンセル", style: UIAlertAction.Style.cancel,
                                                                         handler: { (UIAlertAction) in
                                                                            print("キャンセルが選択されました。")
                                                                            alert.dismiss(animated: true, completion: nil)
                                                                         })
                    alert.addAction(cancelAction)
                    let okAction: UIAlertAction = UIAlertAction.init(title: "変更する", style: UIAlertAction.Style.default,
                                                                     handler: { (UIAlertAction) in
                                                                        print("OKが選択されました。")
                                                                        
                                                                        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
                                                                        let viewController = storyboard.instantiateViewController(identifier: "ProfileEditViewController") as! ProfileEditViewController
                                                                        
                                                                        if Auth.auth().currentUser != nil {
                                                                            let myid = Auth.auth().currentUser!.uid
                                                                            let ref = Firestore.firestore().collection("users").document(myid)
                                                                            ref.updateData(["editID": self.userID])
                                                                            
                                                                            self.navigationController?.pushViewController(viewController, animated: true)
                                                                        }
                                                                        
                                                                     })
                    alert.addAction(okAction)
                    present(alert, animated: true, completion: nil)
                }else{
                    let alert: UIAlertController = UIAlertController.init(title: "このコミュニティを報告しますか？", message: nil,
                                                                          preferredStyle: UIAlertController.Style.actionSheet)
                    let cancelAction: UIAlertAction = UIAlertAction.init(title: "キャンセル", style: UIAlertAction.Style.cancel,
                                                                         handler: { (UIAlertAction) in
                                                                            print("キャンセルが選択されました。")
                                                                            alert.dismiss(animated: true, completion: nil)
                                                                         })
                    alert.addAction(cancelAction)
                    let okAction: UIAlertAction = UIAlertAction.init(title: "報告する", style: UIAlertAction.Style.destructive,
                                                                     handler: { (UIAlertAction) in
                                                                        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
                                                                        let viewController = storyboard.instantiateViewController(identifier: "ContactUs") as! ContactUsViewController
                                                                        viewController.targetUid = self.userdata!.uid
                                                                        self.navigationController?.pushViewController(viewController, animated: true)
                                                                     })
                    alert.addAction(okAction)
                    present(alert, animated: true, completion: nil)
                }
                
            }
        }
    }
    
    
    //遷移元の色を戻す
    override func willMove(toParent parent: UIViewController?) {
        super.willMove(toParent: parent)
        self.navigationController?.navigationBar.shadowImage = nil
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        self.tabBarController?.tabBar.barTintColor = UIColor.white
        self.navigationController?.navigationBar.tintColor = UIColor.black
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.black]
    }
    
    let titleArray1: [String] = ["ホーム","人気","モデレート","概要"]
    let titleArray2: [String] = ["ホーム","人気","モデレーター","概要"]
    
    //タイトル部分
    override var titlesInSwitcher: [String]{
        
        if self.type == "private" {
            return titleArray1
        }else{
            return titleArray2
        }
    }
    
    override var bouncesType: BouncesType {
        return .child
    }
    
    override func segementSlideContentViewController(at index: Int) -> SegementSlideContentScrollViewDelegate? {
        
        if self.type == "private" {
            
            switch index {
            case 0:
                let pageVC = Page1ViewController()
                pageVC.userID = userID
                pageVC.userdata = userdata
                return pageVC
            case 1:
                let pageVC = Page2ViewController()
                pageVC.userID = userID
                return pageVC
            case 2:
                let pageVC = Page3ViewController()
                pageVC.userID = userID
                return pageVC
            case 3:
                let pageVC = Page4ViewController()
                pageVC.userID = userID
                return pageVC
            default:
                let pageVC = Page1ViewController()
                pageVC.userID = userID
                return pageVC
            }
        }else{
            switch index {
            case 0:
                let pageVC = Page1ComViewController()
                pageVC.userID = userID
                pageVC.userdata = userdata
                return pageVC
            case 1:
                let pageVC = Page2ComViewController()
                pageVC.userID = userID
                return pageVC
            case 2:
                let pageVC = Page3ComViewController()
                pageVC.userID = userID
                return pageVC
            case 3:
                let pageVC = Page4ComViewController()
                pageVC.userID = userID
                return pageVC
            default:
                let pageVC = Page1ComViewController()
                pageVC.userID = userID
                return pageVC
            }
        }
    }
    
    
    @IBAction func unwind(_ segue: UIStoryboardSegue) {
        // 他の画面から segue を使って戻ってきた時に呼ばれる
    }
}
