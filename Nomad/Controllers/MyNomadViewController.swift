//
//  MyNomadViewController.swift
//  Nomad-App
//
//  Created by yuishii on 2021/01/17.
//  Copyright © 2021 Yu Ishii. All rights reserved.
//
// 「マイページ」画面

import UIKit
import Firebase
import NotificationBannerSwift
import SVProgressHUD

class MyNomadViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    
    @IBOutlet var tableView: UITableView!
    
    private var refreshControl = UIRefreshControl()
    
    // ユーザーデータを格納する配列
    var userArray: [UserData] = []
    var userdata: UserData?
    
    // 投稿データを格納する配列
    var postArray: [PostData] = []
    
    private var postdata: PostData?
    var modifiedPostArray: [PostData] = []
    
    // ブロックユーザーデータを格納する配列
    var blockUserArray: [String] = []
    // Firestoreのリスナー
    var listener: ListenerRegistration!
    var listener1: ListenerRegistration!
    
    var listener_block: ListenerRegistration!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.separatorStyle = .none
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(CollectionTableViewCell13.nib(), forCellReuseIdentifier: CollectionTableViewCell13.identifier)
        
        let nib1 = UINib(nibName: "ViewedTableViewCell", bundle: nil)
        tableView.register(nib1, forCellReuseIdentifier: "Viewed")
        let library = UINib(nibName: "Library2TableViewCell", bundle: nil)
        tableView.register(library, forCellReuseIdentifier: "Library2")
        let nib3 = UINib(nibName: "ViewedTableViewCell2", bundle: nil)
        tableView.register(nib3, forCellReuseIdentifier: "Viewed2")
        let nib4 = UINib(nibName: "Post9TableViewCell", bundle: nil)
        tableView.register(nib4, forCellReuseIdentifier: "Cell9")
        let nib5 = UINib(nibName: "Post10TableViewCell", bundle: nil)
        tableView.register(nib5, forCellReuseIdentifier: "Cell10")
        let nib6 = UINib(nibName: "Post11TableViewCell", bundle: nil)
        tableView.register(nib6, forCellReuseIdentifier: "Cell11")
        let marginNib = UINib(nibName: "MarginTableViewCell", bundle: nil)
        tableView.register(marginNib, forCellReuseIdentifier: "Margin")
        
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(self.refresh(sender:)), for: .valueChanged)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if Auth.auth().currentUser != nil {
            if Auth.auth().currentUser?.isEmailVerified == true {
                print("メール認証が完了しています。")
            } else {
                print("メール認証が完了していません")
                let rootViewController = self.storyboard?.instantiateViewController(withIdentifier: "EmailVerification")
                self.present(rootViewController!, animated: false, completion: nil)
            }
        }else {
            let loginViewController = self.storyboard?.instantiateViewController(withIdentifier: "LoginNavi")
            self.present(loginViewController!, animated: false, completion: nil)
        }
    }
    
    @objc func refresh(sender: UIRefreshControl?) {
        print("refresh")
        
        self.fetchBlockUsers { [weak self] result in
            switch result {
            case .failure(let error):
                debugPrint(error.localizedDescription)
                sender?.endRefreshing()
            case .success:
                
                let postsRef = Firestore.firestore().collection("posts").whereField("deleted", isEqualTo: "no")
                self?.listener1 = postsRef.addSnapshotListener() { [weak self] querySnapshot, error in
                    if let error = error {
                        print("DEBUG_PRINT: snapshotの取得が失敗しました。 \(error)")
                        return
                    } else {
                        self?.postArray = querySnapshot!.documents.compactMap { document in
                            //print("DEBUG_PRINT: document取得 \(document.documentID)")
                            let postData = PostData(document: document)
                            postData.id = document.documentID
                            let currentUser = Auth.auth().currentUser
                            if postData.uid == currentUser?.uid && postData.isReported == false && postData.viewed == true && self?.blockUserArray.contains(postData.uid) == false || postData.viewed == true && postData.bePrivate == "off" && postData.isReported == false && self?.blockUserArray.contains(postData.uid) == false {
                                return postData
                            } else {
                                print("表示しない投稿 uid=", postData.uid)
                                return nil
                            }
                        }
                        self?.postArray.sort { $0.viewedTime > $1.viewedTime }
                        
                        // クルクルストップ
                        //self?.ActivityIndicator.stopAnimating()
                        self?.tableView.reloadData()
                        sender?.endRefreshing()
                    }
                }
            }
        }
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("DEBUG_PRINT: viewWillAppear")
        
        let backBarButtonItem = UIBarButtonItem()
        backBarButtonItem.title = "Back"
        self.navigationItem.backBarButtonItem = backBarButtonItem
        self.navigationItem.title = "マイページ"
        self.navigationController?.navigationBar.titleTextAttributes
            = [NSAttributedString.Key.font: UIFont(name: "Helvetica", size: 16)!]
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        self.tabBarController?.tabBar.barTintColor = UIColor.white
        self.navigationController?.navigationBar.tintColor = UIColor.black
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.black]
        
        
        if Auth.auth().currentUser != nil {
            
            if listener == nil {
                fetchBlockUsers { [weak self] result in
                    switch result {
                    case .success:
                        
                        if ( self?.listener1 == nil ) {
                            
                            let postsRef2 = Firestore.firestore().collection("posts").whereField("deleted", isEqualTo: "no").whereField("deleted", isEqualTo: "no")
                            self?.listener1 = postsRef2.addSnapshotListener() { [weak self] querySnapshot, error in
                                if let error = error {
                                    print("DEBUG_PRINT: snapshotの取得が失敗しました。 \(error)")
                                    return
                                } else {
                                    self?.postArray = querySnapshot!.documents.compactMap { document in
                                        //print("DEBUG_PRINT: document取得 \(document.documentID)")
                                        let postData = PostData(document: document)
                                        postData.id = document.documentID
                                        let currentUser = Auth.auth().currentUser
                                        if postData.uid == currentUser?.uid && postData.isReported == false && postData.viewed == true && self?.blockUserArray.contains(postData.uid) == false || postData.viewed == true && postData.bePrivate == "off" && postData.isReported == false && self?.blockUserArray.contains(postData.uid) == false {
                                            return postData
                                        } else {
                                            print("表示しない投稿 uid=", postData.uid)
                                            return nil
                                        }
                                    }
                                    self?.postArray.sort { $0.viewedTime > $1.viewedTime }
                                    SVProgressHUD.dismiss()
                                    self?.tableView.reloadData()
                                }
                            }
                        }
                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                }
            }
        } else {
            // ログイン未(またはログアウト済み)
            if listener != nil {
                // listener登録済みなら削除してpostArrayをクリアする
                listener.remove()
                listener = nil
                postArray = []
                //self.ActivityIndicator.stopAnimating()
                SVProgressHUD.dismiss()
                tableView.reloadData()
            }
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if ( self.listener != nil ){
            listener.remove()
            listener = nil
        }
        if ( self.listener1 != nil ){
            listener1.remove()
            listener1 = nil
        }
        if ( self.listener_block != nil ){
            listener_block.remove()
            listener_block = nil
        }
        print("テーブルビューを閉じます")
    }
    
    //ブロックしているユーザーの情報取得
    func fetchBlockUsers(completion: @escaping (Result<Any?, Error>) -> Void) {
        if let myid = Auth.auth().currentUser?.uid, listener_block == nil {
            let postsRef_block = Firestore.firestore().collection("blockUsers").document(myid)
            postsRef_block.getDocument { [weak self] document, error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    if let document = document, document.exists {
                        let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                        print("Document data: \(dataDescription)")
                    } else {
                        print("Document does not exist")
                    }
                    let postDic = document?.data()
                    if postDic != nil {
                        if let blockUsers = postDic!["users"] as? [String] {
                            self?.blockUserArray = blockUsers
                            print("blockUsers:\(blockUsers)")
                        }
                    }
                    completion(.success(nil))
                }
            }
            print("block user list")
            print("self.blockUserArray.description:\(self.blockUserArray.description)")
        } else {
            completion(.failure(NSError(domain: "FetchError", code: 0, userInfo: nil)))
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 4
        
    }
    
    //何行か
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            return 1
        }else if section == 1 {
            return 1
        }else if section == 2 {
            if self.postArray.count == 0 {
                return 1
            }else if self.postArray.count > 10 {
                return 10
            }else{
                return self.postArray.count
            }
        }else{
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "Library2", for: indexPath) as! Library2TableViewCell
            //セル押下時のハイライト(色が濃くなる)を無効
            cell.selectionStyle = .none
            cell.toMyProfileButton.addTarget(self, action:#selector(userProfileButton(_:forEvent:)), for: .touchUpInside)
            cell.toMyPostsButton.addTarget(self, action:#selector(myPostsButton(_:forEvent:)), for: .touchUpInside)
            cell.toMyHistoryButton.addTarget(self, action:#selector(myHistoryButton(_:forEvent:)), for: .touchUpInside)
            cell.toMyBookmarkButton.addTarget(self, action:#selector(myBookmarksButton(_:forEvent:)), for: .touchUpInside)
            cell.toMySettingsButton.addTarget(self, action:#selector(mySettingsButton(_:forEvent:)), for: .touchUpInside)
            
            return cell
            
        }else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Viewed2", for: indexPath) as! ViewedTableViewCell2
            //セル押下時のハイライト(色が濃くなる)を無効
            cell.selectionStyle = .none
            return cell
        }else if indexPath.section == 2 {
            
            if self.postArray.count != 0 {
                // with_imageがtrueの場合 Post2TableViewCell
                if self.postArray[indexPath.row].with_image == true {
                    print("Create Post10TableViewCell")
                    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell10", for: indexPath) as! Post10TableViewCell
                    postdata = self.postArray[indexPath.row]
                    cell.postdata = postdata
                    cell.setPostData(postArray[indexPath.row])
                    return cell
                }
                // with_imageがfalseの場合 Post1TableViewCell
                else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell9", for: indexPath) as! Post9TableViewCell
                    //Post1TableViewCellのpostdataにpostArray[indexPath.row]を渡す
                    postdata = self.postArray[indexPath.row]
                    //Post1TableViewCellのpostdataにpostArray[indexPath.row]を渡す
                    cell.postdata = postdata
                    cell.setPostData(self.postArray[indexPath.row])
                    return cell
                }
            }else{
                let cell = tableView.dequeueReusableCell(withIdentifier: "Cell11", for: indexPath) as! Post11TableViewCell
                //セル押下時のハイライト(色が濃くなる)を無効
                cell.selectionStyle = .none
                return cell
            }
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "Margin", for: indexPath) as! MarginTableViewCell
            //セル押下時のハイライト(色が濃くなる)を無効
            cell.selectionStyle = .none
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 2 {
            
            if self.postArray.count != 0 {
                print("viewerを更新")
                let storyboard = UIStoryboard.init(name: "ChatRoom", bundle: nil)
                let chatRoomViewController = storyboard.instantiateViewController(identifier: "ChatRoomViewController") as! ChatRoomViewController
                postdata = self.postArray[indexPath.row]
                //postdataをChatRoomViewControllerに渡す
                chatRoomViewController.postdata = postdata
                // viewerを更新する
                if let myid = Auth.auth().currentUser?.uid {
                    // 更新データを作成する
                    var updateValue: FieldValue
                    var updateValue2: FieldValue
                    
                    if postdata!.viewed {
                        print("古いmyidを消して新しいmyidを加えます")
                        //再度新しい日付でmyidを加えるために一度古い日付で登録したmyidを消す
                        updateValue = FieldValue.arrayRemove([["uid": myid, "time": postdata!.viewedTime]])
                        updateValue2 = FieldValue.arrayUnion([["uid": myid, "time": Date.timeIntervalSinceReferenceDate]])
                        let postRef = Firestore.firestore().collection("posts").document(self.postdata!.id)
                        postRef.updateData(["viewer": updateValue])
                        postRef.updateData(["viewer": updateValue2])
                    } else{
                        print("新しいmyidを加えます")
                        updateValue = FieldValue.arrayUnion([["uid": myid, "time": Date.timeIntervalSinceReferenceDate]])
                        let postRef = Firestore.firestore().collection("posts").document(self.postdata!.id)
                        postRef.updateData(["viewer": updateValue])
                    }
                    
                    navigationController?.pushViewController(chatRoomViewController, animated: true)
                    //選択状態の解除
                    tableView.deselectRow(at: indexPath as IndexPath, animated: true)
                }
            }else{
                print("タップされました。")
            }
        }else{
            print("タップされました。")
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.section == 0 {
            return 247.7
        }else if indexPath.section == 1 {
            return 47.5
        }else if indexPath.section == 2 {
            return 53
        }else{
            return 22
        }
    }
    
    // セル内のボタンがタップされた時に呼ばれるメソッド
    @objc func userProfileButton(_ sender: UIButton, forEvent event: UIEvent) {
        
        if Auth.auth().currentUser != nil {
            let myid = Auth.auth().currentUser!.uid
            let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
            let baseViewController = storyboard.instantiateViewController(identifier: "Profile") as! BaseViewController
            baseViewController.userID = myid
            baseViewController.type = "private"
            //コメント画面にPush遷移
            navigationController?.pushViewController(baseViewController, animated: true)
        }
    }
    
    // セル内のボタンがタップされた時に呼ばれるメソッド
    @objc func userProfileButton2(_ sender: UIButton, forEvent event: UIEvent) {
        
        // タップされたセルのインデックスを求める
        let touch = event.allTouches?.first
        let point = touch!.location(in: self.tableView)
        guard let indexPath = tableView.indexPathForRow(at: point) else { return }
        
        // 配列からタップされたインデックスのデータを取り出す
        let userData = userArray[indexPath.row]
        let uid = userData.uid
        
        print("MyNomad uid:\(uid)")
        
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let baseViewController = storyboard.instantiateViewController(identifier: "Profile") as! BaseViewController
        baseViewController.userID = uid
        baseViewController.type = "community"
        //コメント画面にPush遷移
        navigationController?.pushViewController(baseViewController, animated: true)
        
    }
    
    // セル内のボタンがタップされた時に呼ばれるメソッド
    @objc func myPostsButton(_ sender: UIButton, forEvent event: UIEvent) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let myPostsViewController = storyboard.instantiateViewController(identifier: "MyPosts") as! MyPostsViewController
        //コメント画面にPush遷移
        navigationController?.pushViewController(myPostsViewController, animated: true)
    }
    
    // セル内のボタンがタップされた時に呼ばれるメソッド
    @objc func myHistoryButton(_ sender: UIButton, forEvent event: UIEvent) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let viewedViewController = storyboard.instantiateViewController(identifier: "Viewed") as! ViewedViewController
        //コメント画面にPush遷移
        navigationController?.pushViewController(viewedViewController, animated: true)
    }
    
    // セル内のボタンがタップされた時に呼ばれるメソッド
    @objc func myBookmarksButton(_ sender: UIButton, forEvent event: UIEvent) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let bookmarksViewController = storyboard.instantiateViewController(identifier: "Bookmarks") as! BookmarksViewController
        //コメント画面にPush遷移
        navigationController?.pushViewController(bookmarksViewController, animated: true)
    }
    
    // セル内のボタンがタップされた時に呼ばれるメソッド
    @objc func mySettingsButton(_ sender: UIButton, forEvent event: UIEvent) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let settingsViewController = storyboard.instantiateViewController(identifier: "Settings") as! SettingsViewController
        //コメント画面にPush遷移
        navigationController?.pushViewController(settingsViewController, animated: true)
    }
}
