//
//  DeleteViewController.swift
//  Nomad-App
//
//  Created by yuishii on 2021/02/19.
//  Copyright © 2021 Yu Ishii. All rights reserved.
//
// アカウントを削除画面

import UIKit
import SegementSlide
import Firebase
import NotificationBannerSwift
import SVProgressHUD

class DeleteViewController: UIViewController,UITableViewDataSource, UITableViewDelegate {
    
    var post1: String = ""
    var post2: String = ""
    var post3: String = ""
    var post4: String = ""
    var post5: String = ""
    var post6: String = ""
    var post7: String = ""
    var post8: String = ""
    var post9: String = ""
    var post10: String = ""
    var post11: String = ""
    
    var delete1: String = ""
    
    
    @IBOutlet weak var moderateTitle: UILabel!
    @IBOutlet weak var moderateCaption: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    // 表示するユーザーデータをmoderateUserArrayの順に格納する配列
    var userArray: [UserData] = []
    var userArray2: [UserData] = []
    var userArray3: [UserData] = []
    var userArray4: [UserData] = []
    var userArray5: [UserData] = []
    var userArray6: [UserData] = []
    var userArray7: [UserData] = []
    var userArray8: [UserData] = []
    var postArray: [PostData] = []
    var postArray2: [PostData] = []
    var postArray3: [PostData] = []
    
    var messageArray = [Message]()
    
    var moderateUserArray: [String] = []
    var blockUserArray: [String] = []
    var followerArray: [String] = []
    
    var userdata: UserData?
    
    // Firestoreのリスナー
    var listener: ListenerRegistration!
    var listener1: ListenerRegistration!
    var listener2: ListenerRegistration!
    var listener3: ListenerRegistration!
    var listener4: ListenerRegistration!
    var listener5: ListenerRegistration!
    var listener6: ListenerRegistration!
    var listener7: ListenerRegistration!
    var listener8: ListenerRegistration!
    var listener9: ListenerRegistration!
    //listener10はmessageArrayを作るときに使っている
    var listener10: ListenerRegistration!
    var listener_moderate: ListenerRegistration!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SVProgressHUD.setDefaultStyle(.custom)
        SVProgressHUD.setForegroundColor(.gray)
        SVProgressHUD.setBackgroundColor(.clear)
        SVProgressHUD.setBackgroundLayerColor(.clear)
        SVProgressHUD.setDefaultMaskType(.custom)
        SVProgressHUD.show()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.separatorStyle = .none
        //空セルのseparator(しきり線)を消す
        tableView.tableFooterView = UIView(frame: .zero)
        
        //テーブルビューの仕切り線を左端までつける
        tableView.separatorInset = .zero
        tableView.backgroundColor = .white
        
        let nib = UINib(nibName: "Following9TableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "Following9")
        
        let nib2 = UINib(nibName: "Following10TableViewCell", bundle: nil)
        tableView.register(nib2, forCellReuseIdentifier: "Following10")
        
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
        
        // NavigationBarを表示したい場合
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        
        let backBarButtonItem = UIBarButtonItem()
        backBarButtonItem.title = "Back"
        self.navigationItem.backBarButtonItem = backBarButtonItem
        self.navigationItem.title = "アカウントを削除"
        self.navigationController?.navigationBar.titleTextAttributes
            = [NSAttributedString.Key.font: UIFont(name: "Helvetica", size: 16)!]
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        self.tabBarController?.tabBar.barTintColor = UIColor.white
        self.navigationController?.navigationBar.tintColor = UIColor.black
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.black]
        
        fetchPost()
        fetchPost2()
        fetchUser()
        fetchUser2()
        fetchUser3()
        fetchUser4()
        fetchUser5()
        fetchUser6()
        
        follower()
        blocker()
        
        if listener == nil {
            
            print("fetchUser1()")
            //userArray　自分がモデレートしているコミュニティ
            let userRef = Firestore.firestore().collection("users").whereField("deleted", isEqualTo: "no")
            self.listener = userRef.addSnapshotListener() { [weak self] querySnapshot, error in
                if let error = error {
                    print("DEBUG_PRINT: snapshotの取得が失敗しました。 \(error)")
                    return
                } else {
                    self?.userArray = querySnapshot!.documents.compactMap { document in
                        print("DEBUG_PRINT: document取得 \(document.documentID)")
                        let userData = UserData(document: document)
                        if userData.isModerated == true {
                            return userData
                        } else {
                            return nil
                        }
                    }
                    self?.userArray.sort { $0.moderatedTime > $1.moderatedTime }
                    self?.post11 = "exist"
                    SVProgressHUD.dismiss()
                    self?.tableView.reloadData()
                }
            }
        } else {
            // ログイン未(またはログアウト済み)
            if listener != nil {
                // listener登録済みなら削除してpostArrayをクリアする
                listener.remove()
                listener = nil
                userArray = []
                //self.ActivityIndicator.stopAnimating()
                SVProgressHUD.dismiss()
                tableView.reloadData()
            }
        }
    }
    
    private func fetchPost() {
        
        //postArray　自分の投稿
        let myid = Auth.auth().currentUser!.uid
        if (self.listener1 == nil) {
            let postsRef = Firestore.firestore().collection("posts").whereField("uid", isEqualTo: myid).whereField("deleted", isEqualTo: "no").order(by: "date", descending: true)
            self.listener1 = postsRef.addSnapshotListener() { [weak self] querySnapshot, error in
                if let error = error {
                    print("DEBUG_PRINT: snapshotの取得が失敗しました。 \(error)")
                    return
                } else {
                    self?.postArray = querySnapshot!.documents.map { document in
                        print("DEBUG_PRINT: document取得 \(document.documentID)")
                        let postData = PostData(document: document)
                        return postData
                    }
                    self?.post1 = "exist"
                }
            }
        }
    }
    
    private func fetchUser() {
        
        //userdata　自分のユーザーデータ
        let myid = Auth.auth().currentUser!.uid
        if (self.listener2 == nil) {
            let userRef = Firestore.firestore().collection("users").document(myid)
            self.listener2 = userRef.addSnapshotListener() { (documentSnapshot, error) in
                guard let document = documentSnapshot else {
                    print("Error fetching document: \(error!)")
                    return
                }
                self.post2 = "exist"
                self.userdata  = UserData(document: document)
            }
        }
    }
    
    
    private func fetchUser2() {
        
        //userArray2 自分が選択したコミュニティ(削除確定前)
        let userRef = Firestore.firestore().collection("users").whereField("deleted", isEqualTo: "no")
        userRef.getDocuments() { (querySnapshot, error) in
            if let error = error {
                print("DEBUG_PRINT: snapshotの取得が失敗しました。 \(error)")
                return
            } else {
                self.userArray2 = querySnapshot!.documents.compactMap { document in
                    print("DEBUG_PRINT: document取得 \(document.documentID)")
                    let userData = UserData(document: document)
                    if userData.isChosen {
                        return userData
                    } else {
                        return nil
                    }
                }
                if self.userArray2.count != 0 {
                    for userData in self.userArray2 {
                        if let myid = Auth.auth().currentUser?.uid {
                            if userData.isChosen {
                                var updateValue: FieldValue
                                updateValue = FieldValue.arrayRemove([myid])
                                let postRef = Firestore.firestore().collection("users").document(userData.id)
                                postRef.updateData(["choose": updateValue])
                            }
                        }
                    }
                }
                self.post3 = "exist"
                self.tableView.reloadData()
            }
        }
    }
    
    
    private func fetchUser3() {
        
        //userArray3 自分が選択したコミュニティ(削除確定)
        if ( self.listener3 == nil ) {
            let userRef = Firestore.firestore().collection("users").whereField("deleted", isEqualTo: "no")
            self.listener3 = userRef.addSnapshotListener() { [weak self] querySnapshot, error in
                if let error = error {
                    print("DEBUG_PRINT: snapshotの取得が失敗しました。 \(error)")
                    return
                } else {
                    self?.userArray3 = querySnapshot!.documents.compactMap { document in
                        print("DEBUG_PRINT: document取得 \(document.documentID)")
                        let userData = UserData(document: document)
                        if userData.isChosen {
                            return userData
                        } else {
                            return nil
                        }
                    }
                    self?.post4 = "exist"
                    self?.tableView.reloadData()
                }
            }
        }
    }
    
    private func fetchUser4() {
        
        //userArray4 自分がフォローしているユーザー
        if ( self.listener4 == nil ) {
            let userRef = Firestore.firestore().collection("users").whereField("deleted", isEqualTo: "no")
            self.listener4 = userRef.addSnapshotListener() { [weak self] querySnapshot, error in
                if let error = error {
                    print("DEBUG_PRINT: snapshotの取得が失敗しました。 \(error)")
                    return
                } else {
                    self?.userArray4 = querySnapshot!.documents.compactMap { document in
                        print("DEBUG_PRINT: document取得 \(document.documentID)")
                        let userData = UserData(document: document)
                        if userData.isFollowed == true {
                            return userData
                        } else {
                            return nil
                        }
                    }
                    self?.post5 = "exist"
                }
            }
        }
    }
    
    private func fetchUser5() {
        
        //userArray6 自分がモデレートしているコミュニティ
        if listener5 == nil {
            let userRef = Firestore.firestore().collection("users").whereField("type", isEqualTo: "community").whereField("deleted", isEqualTo: "no")
            self.listener5 = userRef.addSnapshotListener() { [weak self] querySnapshot, error in
                if let error = error {
                    print("DEBUG_PRINT: snapshotの取得が失敗しました。 \(error)")
                    return
                } else {
                    self?.userArray5 = querySnapshot!.documents.compactMap { document in
                        print("DEBUG_PRINT: document取得 \(document.documentID)")
                        let userData = UserData(document: document)
                        if userData.isModerated == true {
                            return userData
                        } else {
                            return nil
                        }
                    }
                    self?.post6 = "exist"
                }
            }
        }
    }
    
    private func fetchUser6() {
        
        //userArray6 ブロックしているユーザー
        if listener6 == nil {
            let userRef = Firestore.firestore().collection("users").whereField("deleted", isEqualTo: "no")
            self.listener6 = userRef.addSnapshotListener() { [weak self] querySnapshot, error in
                if let error = error {
                    print("DEBUG_PRINT: snapshotの取得が失敗しました。 \(error)")
                    return
                } else {
                    self?.userArray6 = querySnapshot!.documents.compactMap { document in
                        print("DEBUG_PRINT: document取得 \(document.documentID)")
                        let userData = UserData(document: document)
                        if userData.isBlocked == true {
                            return userData
                        } else {
                            return nil
                        }
                    }
                    self?.post7 = "exist"
                }
            }
        }
    }
    
    
    func follower() {
        
        //userArray7 自分をフォローしているユーザー
        if let myid = Auth.auth().currentUser?.uid {
            Firestore.firestore().collection("followUsers").whereField("users", arrayContains: myid).getDocuments { (snaps, error) in
                if let error = error {
                    fatalError("\(error)")
                }
                guard let snaps = snaps else { return }
                print("snaps.documents:\(snaps.documents)")
                
                if snaps.documents.count != 0 {
                    for document in snaps.documents {
                        self.followerArray.append(document.documentID)
                        print("follower document.data():\(document.data())")
                        print("follower document.documentID:\(document.documentID)")
                    }
                }
                
                if self.listener7 == nil {
                    
                    let userRef = Firestore.firestore().collection("users").whereField("deleted", isEqualTo: "no")
                    self.listener7 = userRef.addSnapshotListener() { [weak self] querySnapshot, error in
                        if let error = error {
                            print("DEBUG_PRINT: snapshotの取得が失敗しました。 \(error)")
                            return
                        } else {
                            self?.userArray7 = querySnapshot!.documents.compactMap { document in
                                print("DEBUG_PRINT: document取得 \(document.documentID)")
                                let userData = UserData(document: document)
                                if self?.followerArray.contains(userData.uid) == true {
                                    return userData
                                } else {
                                    return nil
                                }
                            }
                            self?.post8 = "exist"
                        }
                    }
                }
                
            }
        }
    }
    
    func blocker() {
        
        //userArray8 自分をブロックしているユーザー
        if let myid = Auth.auth().currentUser?.uid {
            Firestore.firestore().collection("blockUsers").whereField("users", arrayContains: myid).getDocuments { (snaps, error) in
                if let error = error {
                    fatalError("\(error)")
                }
                guard let snaps = snaps else { return }
                print("snaps.documents:\(snaps.documents)")
                
                if snaps.documents.count != 0 {
                    for document in snaps.documents {
                        self.blockUserArray.append(document.documentID)
                        print("moderator document.data():\(document.data())")
                        print("moderator document.documentID:\(document.documentID)")
                    }
                }
                
                if self.listener8 == nil {
                    
                    let userRef = Firestore.firestore().collection("users").whereField("deleted", isEqualTo: "no")
                    self.listener8 = userRef.addSnapshotListener() { [weak self] querySnapshot, error in
                        if let error = error {
                            print("DEBUG_PRINT: snapshotの取得が失敗しました。 \(error)")
                            return
                        } else {
                            self?.userArray8 = querySnapshot!.documents.compactMap { document in
                                print("DEBUG_PRINT: document取得 \(document.documentID)")
                                let userData = UserData(document: document)
                                if self?.blockUserArray.contains(userData.uid) == true {
                                    return userData
                                } else {
                                    return nil
                                }
                            }
                            self?.post9 = "exist"
                        }
                    }
                }
            }
        }
    }
    
    private func fetchPost2() {
        
        if ( self.listener9 == nil ) {
            
            let postsRef = Firestore.firestore().collection("posts").whereField("deleted", isEqualTo: "no")
            self.listener9 = postsRef.addSnapshotListener() { [weak self] querySnapshot, error in
                if let error = error {
                    print("DEBUG_PRINT: snapshotの取得が失敗しました。 \(error)")
                    return
                } else {
                    self?.postArray3 = querySnapshot!.documents.compactMap { document in
                        print("DEBUG_PRINT: document取得 \(document.documentID)")
                        let postData = PostData(document: document)
                        
                        let currentUser = Auth.auth().currentUser
                        if postData.uid == currentUser?.uid && postData.isReported == false && postData.isCommented == true || postData.isCommented == true && postData.bePrivate == "off" && postData.isReported == false && self?.blockUserArray.contains(postData.uid) == false {
                            return postData
                        } else {
                            print("表示しない投稿 uid=", postData.uid)
                            return nil
                        }
                    }
                    self?.postArray3.sort { $0.joinedTime > $1.joinedTime }
                    self?.post10 = "exist"
                }
            }
        }
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 50
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        SVProgressHUD.dismiss()
        
        if ( self.listener != nil ){
            listener.remove()
            listener = nil
        }
        if ( self.listener1 != nil ){
            listener1.remove()
            listener1 = nil
        }
        if ( self.listener2 != nil ){
            listener2.remove()
            listener2 = nil
        }
        if ( self.listener3 != nil ){
            listener3.remove()
            listener3 = nil
        }
        if ( self.listener4 != nil ){
            listener4.remove()
            listener4 = nil
        }
        if ( self.listener5 != nil ){
            listener5.remove()
            listener5 = nil
        }
        if ( self.listener6 != nil ){
            listener6.remove()
            listener6 = nil
        }
        if ( self.listener7 != nil ){
            listener7.remove()
            listener7 = nil
        }
        if ( self.listener8 != nil ){
            listener8.remove()
            listener8 = nil
        }
        if ( self.listener9 != nil ){
            listener9.remove()
            listener9 = nil
        }
        if ( self.listener10 != nil ){
            listener10.remove()
            listener10 = nil
        }
        
        if self.userArray2.count != 0 {
            for userData in self.userArray {
                
                if let myid = Auth.auth().currentUser?.uid {
                    
                    if userData.isChosen {
                        
                        var updateValue: FieldValue
                        updateValue = FieldValue.arrayRemove([myid])
                        let postRef = Firestore.firestore().collection("users").document(userData.id)
                        postRef.updateData(["choose": updateValue])
                    }
                }
            }
        }
        
        print("テーブルビューを閉じます")
    }
    
    
    
    @IBAction func deleteAction(_ sender: Any) {
        
        if self.post1 != "exist" || self.post2 != "exist" || self.post3 != "exist" || self.post4 != "exist" || self.post5 != "exist" || self.post6 != "exist" || self.post7 != "exist" || self.post8 != "exist" || self.post9 != "exist" || self.post10 != "exist" || self.post11 != "exist"{
            
            print("データ未出力")
            print("self.post1:\(self.post1)")
            print("self.post2:\(self.post2)")
            print("self.post3:\(self.post3)")
            print("self.post4:\(self.post4)")
            print("self.post5:\(self.post5)")
            print("self.post6:\(self.post6)")
            print("self.post7:\(self.post7)")
            print("self.post8:\(self.post8)")
            print("self.post9:\(self.post9)")
            print("self.post10:\(self.post10)")
            
        }else{
            
            
            let alert: UIAlertController = UIAlertController.init(title: "アカウントを削除する", message: "注意事項や削除するコミュニティの選択は確認済みですか？",
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
                                                                self.alertDelete()
                                                                
                                                             })
            alert.addAction(okAction)
            present(alert, animated: true, completion: nil)
            
        }
    }
    
    
    //フォロー　フォロワーもそれぞれ解除
    
    func alertDelete(){
        let alert: UIAlertController = UIAlertController.init(title: "データが削除されます", message: "本当に削除してよろしいですか？",
                                                              preferredStyle: UIAlertController.Style.alert)
        let cancelAction: UIAlertAction = UIAlertAction.init(title: "キャンセル", style: UIAlertAction.Style.cancel,
                                                             handler: { (UIAlertAction) in
                                                                print("キャンセルが選択されました。")
                                                                alert.dismiss(animated: true, completion: nil)
                                                             })
        alert.addAction(cancelAction)
        let okAction: UIAlertAction = UIAlertAction.init(title: "削除する", style: UIAlertAction.Style.destructive,
                                                         handler: { (UIAlertAction) in
                                                            print("OKが選択されました。")
                                                            // ログイン中のユーザーアカウントを削除する。
                                                            Auth.auth().currentUser?.delete() {  (error) in
                                                                // エラーが無ければ、ログイン画面へ戻る
                                                                if error == nil {
                                                                    
                                                                    SVProgressHUD.setDefaultStyle(.custom)
                                                                    SVProgressHUD.setDefaultMaskType(.custom)
                                                                    SVProgressHUD.setForegroundColor(.black)
                                                                    SVProgressHUD.setBackgroundColor(.white)
                                                                    SVProgressHUD.setDefaultMaskType(.black)
                                                                    //HUD.show(.progress, onView: view)
                                                                    SVProgressHUD.show()
                                                                    
                                                                    if let myid = Auth.auth().currentUser?.uid {
                                                                        
                                                                        //userArray3 自分がモデレートしているコミュニティのうち選択した(消す)コミュニティ
                                                                        print("self.userArray3.count:\(self.userArray3.count)")
                                                                        if self.userArray3.count != 0 {
                                                                            
                                                                            for userData in self.userArray3 {
                                                                                
                                                                                var updateValue: FieldValue
                                                                                updateValue = FieldValue.arrayUnion([["uid": myid, "time": Date.timeIntervalSinceReferenceDate]])
                                                                                
                                                                                //userArray3のそれぞれのコミュニティに投稿された投稿postArray2を削除する
                                                                                let postsRef = Firestore.firestore().collection("posts").whereField("community", isEqualTo: userData.uid).whereField("deleted", isEqualTo: "no").order(by: "date", descending: true)
                                                                                postsRef.addSnapshotListener() { [weak self] querySnapshot, error in
                                                                                    if let error = error {
                                                                                        print("DEBUG_PRINT: snapshotの取得が失敗しました。 \(error)")
                                                                                        return
                                                                                    } else {
                                                                                        self?.postArray2 = querySnapshot!.documents.map { document in
                                                                                            print("DEBUG_PRINT: document取得 \(document.documentID)")
                                                                                            let postData = PostData(document: document)
                                                                                            return postData
                                                                                        }
                                                                                        
                                                                                        if self?.postArray2.count != 0 {
                                                                                            for postData in self!.postArray2 {
                                                                                                
                                                                                                let postRef = Firestore.firestore().collection("posts").document(postData.id)
                                                                                                postRef.updateData(["deletes": updateValue])
                                                                                                postRef.updateData(["deleted": "done"])
                                                                                                
                                                                                            }
                                                                                        }
                                                                                        
                                                                                    }
                                                                                }
                                                                                
                                                                                let userRef = Firestore.firestore().collection("users").document(userData.id)
                                                                                //アカウント削除したかどうか
                                                                                userRef.updateData(["deleted": "done"])
                                                                                //アカウント削除した日時
                                                                                userRef.updateData(["deletedDate": FieldValue.serverTimestamp()])
                                                                                
                                                                                
                                                                                userRef.updateData(["follow": FieldValue.delete()]) { err in
                                                                                    if let err = err {
                                                                                        print("Error updating document: \(err)")
                                                                                    } else {
                                                                                        print("Document successfully updated")
                                                                                    }
                                                                                }
                                                                                userRef.updateData(["follower": FieldValue.delete()]) { err in
                                                                                    if let err = err {
                                                                                        print("Error updating document: \(err)")
                                                                                    } else {
                                                                                        print("Document successfully updated")
                                                                                    }
                                                                                }
                                                                                userRef.updateData(["moderate": FieldValue.delete()]) { err in
                                                                                    if let err = err {
                                                                                        print("Error updating document: \(err)")
                                                                                    } else {
                                                                                        print("Document successfully updated")
                                                                                    }
                                                                                }
                                                                                userRef.updateData(["moderator": FieldValue.delete()]) { err in
                                                                                    if let err = err {
                                                                                        print("Error updating document: \(err)")
                                                                                    } else {
                                                                                        print("Document successfully updated")
                                                                                    }
                                                                                }
                                                                                userRef.updateData(["block": FieldValue.delete()]) { err in
                                                                                    if let err = err {
                                                                                        print("Error updating document: \(err)")
                                                                                    } else {
                                                                                        print("Document successfully updated")
                                                                                    }
                                                                                }
                                                                                userRef.updateData(["blocked": FieldValue.delete()]) { err in
                                                                                    if let err = err {
                                                                                        print("Error updating document: \(err)")
                                                                                    } else {
                                                                                        print("Document successfully updated")
                                                                                    }
                                                                                }
                                                                            }
                                                                        }
                                                                        
                                                                        //userArray4 自分がフォローしているユーザー
                                                                        print("self.userArray4.count:\(self.userArray4.count)")
                                                                        if self.userArray4.count != 0 {
                                                                            
                                                                            for userData in self.userArray4 {
                                                                                
                                                                                var updateValue: FieldValue
                                                                                var updateValue2: FieldValue
                                                                                var updateValue3: FieldValue
                                                                                
                                                                                updateValue = FieldValue.arrayRemove([["uid": myid, "time": userData.followedTime]])
                                                                                updateValue2 = FieldValue.arrayRemove([userData.uid])
                                                                                updateValue3 = FieldValue.arrayRemove([myid])
                                                                                
                                                                                let userRef = Firestore.firestore().collection("users").document(userData.uid)
                                                                                userRef.updateData(["follower": updateValue])
                                                                                
                                                                                let followingRef = Firestore.firestore().collection("followUsers").document(myid)
                                                                                
                                                                                followingRef.getDocument { [weak self] document, error in
                                                                                    if let document = document, document.exists {
                                                                                        let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                                                                                        print("Document data: \(dataDescription)")
                                                                                        followingRef.updateData(["users": updateValue2])
                                                                                    } else {
                                                                                        print("Document does not exist")
                                                                                        followingRef.setData(["users": updateValue2])
                                                                                    }
                                                                                }
                                                                                
                                                                                let followedRef = Firestore.firestore().collection("followers").document(userData.uid)
                                                                                
                                                                                followedRef.getDocument { [weak self] document, error in
                                                                                    if let document = document, document.exists {
                                                                                        let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                                                                                        print("Document data: \(dataDescription)")
                                                                                        followedRef.updateData(["users": updateValue3])
                                                                                    } else {
                                                                                        print("Document does not exist")
                                                                                        followedRef.setData(["users": updateValue3])
                                                                                    }
                                                                                }
                                                                                print("arrayRemove")
                                                                                
                                                                            }
                                                                        }
                                                                        
                                                                        
                                                                        //userArray5
                                                                        print("self.userArray5.count:\(self.userArray5.count)")
                                                                        if self.userArray5.count != 0 {
                                                                            
                                                                            for userData in self.userArray5 {
                                                                                
                                                                                var updateValue: FieldValue
                                                                                var updateValue2: FieldValue
                                                                                var updateValue3: FieldValue
                                                                                
                                                                                updateValue = FieldValue.arrayRemove([["uid": myid, "time": userData.moderatedTime]])
                                                                                updateValue2 = FieldValue.arrayRemove([userData.uid])
                                                                                updateValue3 = FieldValue.arrayRemove([myid])
                                                                                
                                                                                let userRef = Firestore.firestore().collection("users").document(userData.uid)
                                                                                userRef.updateData(["moderator": updateValue])
                                                                                
                                                                                let moderatingRef = Firestore.firestore().collection("moderateUsers").document(myid)
                                                                                
                                                                                moderatingRef.getDocument { [weak self] document, error in
                                                                                    if let document = document, document.exists {
                                                                                        let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                                                                                        print("Document data: \(dataDescription)")
                                                                                        moderatingRef.updateData(["users": updateValue2])
                                                                                    } else {
                                                                                        print("Document does not exist")
                                                                                        moderatingRef.setData(["users": updateValue2])
                                                                                    }
                                                                                }
                                                                                
                                                                                let moderatedRef = Firestore.firestore().collection("moderator").document(userData.uid)
                                                                                
                                                                                moderatedRef.getDocument { [weak self] document, error in
                                                                                    if let document = document, document.exists {
                                                                                        let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                                                                                        print("Document data: \(dataDescription)")
                                                                                        moderatedRef.updateData(["users": updateValue3])
                                                                                    } else {
                                                                                        print("Document does not exist")
                                                                                        moderatedRef.setData(["users": updateValue3])
                                                                                    }
                                                                                }
                                                                                print("arrayRemove")
                                                                                
                                                                            }
                                                                        }
                                                                        
                                                                        //userArray6 ブロックしているユーザー
                                                                        print("self.userArray6.count:\(self.userArray6.count)")
                                                                        if self.userArray6.count != 0 {
                                                                            
                                                                            for userData in self.userArray6 {
                                                                                
                                                                                var updateValue: FieldValue
                                                                                var updateValue2: FieldValue
                                                                                var updateValue3: FieldValue
                                                                                
                                                                                updateValue = FieldValue.arrayRemove([["uid": myid, "time": userData.blockedTime]])
                                                                                updateValue2 = FieldValue.arrayRemove([userData.uid])
                                                                                updateValue3 = FieldValue.arrayRemove([myid])
                                                                                
                                                                                let userRef = Firestore.firestore().collection("users").document(userData.uid)
                                                                                userRef.updateData(["blocked": updateValue])
                                                                                
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
                                                                                
                                                                                let blockedRef = Firestore.firestore().collection("blockedUsers").document(userData.uid)
                                                                                
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
                                                                                print("arrayRemove")
                                                                            }
                                                                        }
                                                                        
                                                                        //userArray7 自分をフォローしているユーザー
                                                                        print("self.userArray7.count:\(self.userArray7.count)")
                                                                        if self.userArray7 != [] {
                                                                            for userData in self.userArray7 {
                                                                                
                                                                                var updateValue: FieldValue
                                                                                var updateValue2: FieldValue
                                                                                var updateValue3: FieldValue
                                                                                
                                                                                updateValue = FieldValue.arrayRemove([["uid": myid, "time": userData.followingTime]])
                                                                                updateValue2 = FieldValue.arrayRemove([userData.uid])
                                                                                updateValue3 = FieldValue.arrayRemove([myid])
                                                                                
                                                                                //updateValueでは"follow"フィールドが消せない
                                                                                let userRef = Firestore.firestore().collection("users").document(userData.uid)
                                                                                userRef.updateData(["follow": updateValue])
                                                                                
                                                                                let followingRef = Firestore.firestore().collection("followUsers").document(myid)
                                                                                
                                                                                followingRef.getDocument { [weak self] document, error in
                                                                                    if let document = document, document.exists {
                                                                                        let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                                                                                        print("Document data: \(dataDescription)")
                                                                                        followingRef.updateData(["users": updateValue2])
                                                                                    } else {
                                                                                        print("Document does not exist")
                                                                                        followingRef.setData(["users": updateValue2])
                                                                                    }
                                                                                }
                                                                                
                                                                                let followedRef = Firestore.firestore().collection("followers").document(userData.uid)
                                                                                
                                                                                followedRef.getDocument { [weak self] document, error in
                                                                                    if let document = document, document.exists {
                                                                                        let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                                                                                        print("Document data: \(dataDescription)")
                                                                                        followedRef.updateData(["users": updateValue3])
                                                                                    } else {
                                                                                        print("Document does not exist")
                                                                                        followedRef.setData(["users": updateValue3])
                                                                                    }
                                                                                }
                                                                                print("arrayRemove")
                                                                            }
                                                                        }
                                                                        
                                                                        //userArray8 自分をブロックしているユーザー
                                                                        print("self.userArray8.count:\(self.userArray8.count)")
                                                                        if self.userArray8 != [] {
                                                                            for userData in self.userArray8 {
                                                                                
                                                                                var updateValue: FieldValue
                                                                                var updateValue2: FieldValue
                                                                                var updateValue3: FieldValue
                                                                                
                                                                                updateValue = FieldValue.arrayRemove([["uid": myid, "time": userData.blockingTime]])
                                                                                updateValue2 = FieldValue.arrayRemove([userData.uid])
                                                                                updateValue3 = FieldValue.arrayRemove([myid])
                                                                                
                                                                                //updateValueでは"block"フィールドが消せない
                                                                                let userRef = Firestore.firestore().collection("users").document(userData.uid)
                                                                                userRef.updateData(["block": updateValue])
                                                                                
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
                                                                                
                                                                                let blockedRef = Firestore.firestore().collection("blockedUsers").document(userData.uid)
                                                                                
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
                                                                                print("arrayRemove")
                                                                            }
                                                                        }
                                                                        
                                                                        
                                                                        //自分がコメントした投稿のコメントを消す
                                                                        let deleteTime = Date.timeIntervalSinceReferenceDate
                                                                        
                                                                        if self.postArray3.count != 0 {
                                                                            
                                                                            if let myid = Auth.auth().currentUser?.uid {
                                                                                
                                                                                for postData in self.postArray3 {
                                                                                    
                                                                                    print("確認1")
                                                                                    
                                                                                    let postsRef = Firestore.firestore().collection("posts").document(postData.id).collection("messages").order(by: "createdAt", descending: true).whereField("deleted", isEqualTo: "no")
                                                                                    self.listener10 = postsRef.addSnapshotListener() { [weak self] querySnapshot, error in
                                                                                        if let error = error {
                                                                                            print("DEBUG_PRINT: snapshotの取得が失敗しました。 \(error)")
                                                                                            return
                                                                                        }
                                                                                        self?.messageArray = querySnapshot!.documents.compactMap { document in
                                                                                            print("DEBUG_PRINT: document取得 \(document.documentID)")
                                                                                            let message = Message(document: document)
                                                                                            message.id = document.documentID
                                                                                            if message.uid == myid{
                                                                                                return message
                                                                                            } else {
                                                                                                return nil
                                                                                            }
                                                                                        }
                                                                                        
                                                                                        if self?.messageArray.count != 0 {
                                                                                            
                                                                                            for messageData in self!.messageArray {
                                                                                                
                                                                                                print("確認2")
                                                                                                
                                                                                                // 更新データを作成する
                                                                                                var updateValue: FieldValue
                                                                                                var updateValue2: FieldValue
                                                                                                var updateValue3: FieldValue
                                                                                                
                                                                                                let postRef = Firestore.firestore().collection("posts").document(postData.id)
                                                                                                
                                                                                                let messageRef = Firestore.firestore().collection("posts").document(postData.id).collection("messages").document(messageData.id)
                                                                                                
                                                                                                updateValue = FieldValue.arrayRemove([["uid": messageData.uid, "time": messageData.time]])
                                                                                                postRef.updateData(["comments": updateValue])
                                                                                                
                                                                                                updateValue2 = FieldValue.arrayRemove([["uid": messageData.uid, "time": messageData.time]])
                                                                                                postRef.updateData(["allComments": updateValue2])
                                                                                                
                                                                                                updateValue3 = FieldValue.arrayUnion([["uid": messageData.uid, "time": deleteTime]])
                                                                                                
                                                                                                messageRef.updateData(["deletes2": updateValue3])
                                                                                                
                                                                                                //アカウント削除したかどうか
                                                                                                messageRef.updateData(["deleted": "done"])
                                                                                                //アカウント削除した日時
                                                                                                messageRef.updateData(["deletedDate": FieldValue.serverTimestamp()])
                                                                                            }
                                                                                        }
                                                                                    }
                                                                                }
                                                                            }
                                                                            
                                                                        }
                                                                        
                                                                        
                                                                        // 更新データを作成する
                                                                        var updateValue: FieldValue
                                                                        updateValue = FieldValue.arrayUnion([["uid": myid, "time": Date.timeIntervalSinceReferenceDate]])
                                                                        
                                                                        let postRef = Firestore.firestore().collection("users").document(self.userdata!.id)
                                                                        //アカウント削除したかどうか
                                                                        postRef.updateData(["deleted": "done"])
                                                                        //アカウント削除した日時
                                                                        postRef.updateData(["deletedDate": FieldValue.serverTimestamp()])
                                                                        
                                                                        //自分の投稿
                                                                        if self.postArray.count != 0 {
                                                                            for postData in self.postArray {
                                                                                
                                                                                let postRef = Firestore.firestore().collection("posts").document(postData.id)
                                                                                postRef.updateData(["deletes": updateValue])
                                                                                postRef.updateData(["deleted": "done"])
                                                                                
                                                                            }
                                                                        }
                                                                        
                                                                        postRef.updateData(["follow": FieldValue.delete()]) { err in
                                                                            if let err = err {
                                                                                print("Error updating document: \(err)")
                                                                            } else {
                                                                                print("Document successfully updated")
                                                                            }
                                                                        }
                                                                        postRef.updateData(["follower": FieldValue.delete()]) { err in
                                                                            if let err = err {
                                                                                print("Error updating document: \(err)")
                                                                            } else {
                                                                                print("Document successfully updated")
                                                                            }
                                                                        }
                                                                        postRef.updateData(["moderate": FieldValue.delete()]) { err in
                                                                            if let err = err {
                                                                                print("Error updating document: \(err)")
                                                                            } else {
                                                                                print("Document successfully updated")
                                                                            }
                                                                        }
                                                                        postRef.updateData(["moderator": FieldValue.delete()]) { err in
                                                                            if let err = err {
                                                                                print("Error updating document: \(err)")
                                                                            } else {
                                                                                print("Document successfully updated")
                                                                            }
                                                                        }
                                                                        postRef.updateData(["block": FieldValue.delete()]) { err in
                                                                            if let err = err {
                                                                                print("Error updating document: \(err)")
                                                                            } else {
                                                                                print("Document successfully updated")
                                                                            }
                                                                        }
                                                                        postRef.updateData(["blocked": FieldValue.delete()]) { err in
                                                                            if let err = err {
                                                                                print("Error updating document: \(err)")
                                                                            } else {
                                                                                print("Document successfully updated")
                                                                            }
                                                                        }
                                                                    }
                                                                    
                                                                    
                                                                    //7秒後に遷移する
                                                                    DispatchQueue.main.asyncAfter(deadline: .now() + 6.0) {
                                                                        self.navigationController?.popViewController(animated: false)
                                                                    }
                                                                    
                                                                    
                                                                }else{
                                                                    print("エラー：\(String(describing: error?.localizedDescription))")
                                                                    //HUD.flash(.labeledError(title: "エラー", subtitle: "再度ログインしてお試しください"), delay: 1.4)
                                                                    SVProgressHUD.setDefaultStyle(.custom)
                                                                    SVProgressHUD.setDefaultMaskType(.custom)
                                                                    SVProgressHUD.setForegroundColor(.black)
                                                                    SVProgressHUD.setBackgroundColor(.white)
                                                                    SVProgressHUD.setDefaultMaskType(.black)
                                                                    SVProgressHUD.showError(withStatus: "再度ログインしてお試しください")
                                                                    //withDelayにIntを設定
                                                                    SVProgressHUD.dismiss(withDelay: 1.7)
                                                                }
                                                            }
                                                         })
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if userArray.count == 0 {
            return 1
        }else{
            return userArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if userArray.count == 0 {
            print("タップされました")
        }else{
            // 配列からタップされたインデックスのデータを取り出す
            let userData = userArray[indexPath.row]
            
            if let myid = Auth.auth().currentUser?.uid {
                // 更新データを作成する
                var updateValue: FieldValue
                if userData.isChosen {
                    // すでにいいねをしている場合は、いいね解除のためmyidを取り除く更新データを作成
                    updateValue = FieldValue.arrayRemove([myid])
                } else {
                    // 今回新たにいいねを押した場合は、myidを追加する更新データを作成
                    updateValue = FieldValue.arrayUnion([myid])
                }
                
                let userRef = Firestore.firestore().collection("users").document(userData.id)
                userRef.updateData(["choose": updateValue])
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if userArray.count == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Following10", for: indexPath) as! Following10TableViewCell
            //セル押下時のハイライト(色が濃くなる)を無効
            cell.selectionStyle = .none
            return cell
        }else{
            
            // セルを取得してデータを設定する
            let cell = tableView.dequeueReusableCell(withIdentifier: "Following9", for: indexPath) as! Following9TableViewCell
            //セル押下時のハイライト(色が濃くなる)を無効
            cell.selectionStyle = .none
            cell.setUserData(userArray[indexPath.row])
            
            return cell
        }
        
    }
    
    
}
