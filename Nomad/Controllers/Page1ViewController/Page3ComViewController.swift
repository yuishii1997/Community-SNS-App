//
//  Page3ComViewController.swift
//  Nomad-App
//
//  Created by yuishii on 2020/12/15.
//  Copyright © 2020 Yu Ishii. All rights reserved.
//
// プロフィール画面の3ページ目

import UIKit
import SegementSlide
import Firebase
import NotificationBannerSwift
import GoogleMobileAds
import SVProgressHUD

class Page3ComViewController: UITableViewController,SegementSlideContentScrollViewDelegate {
    
    var userID: String = ""
    
    // フォローユーザーデータを格納する配列
    var moderateUserArray: [String] = []
    
    // 表示するユーザーデータをmoderateUserArrayの順に格納する配列
    var userArray: [UserData] = []
    var userdata: UserData?
    var userdata2: UserData?
    
    // Firestoreのリスナー
    var listener: ListenerRegistration!
    var listener1: ListenerRegistration!
    var listener2: ListenerRegistration!
    var listener_moderate: ListenerRegistration!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.separatorStyle = .none
        //空セルのseparator(しきり線)を消す
        tableView.tableFooterView = UIView(frame: .zero)
        
        //テーブルビューの仕切り線を左端までつける
        tableView.separatorInset = .zero
        
        tableView.backgroundColor = .white
        
        // カスタムセルを登録する
        let nib = UINib(nibName: "Following1TableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "Following1")
        let nib2 = UINib(nibName: "Following2TableViewCell", bundle: nil)
        tableView.register(nib2, forCellReuseIdentifier: "Following2")
        let nib3 = UINib(nibName: "NotP2PostsTableViewCell", bundle: nil)
        tableView.register(nib3, forCellReuseIdentifier: "NotP2Posts")
        let marginNib = UINib(nibName: "Margin2TableViewCell", bundle: nil)
        tableView.register(marginNib, forCellReuseIdentifier: "Margin2")
        
        let refreshControl = UIRefreshControl()
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(Page1ViewController.refresh(sender:)), for: .valueChanged)
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
        // ナビゲーションバーの下部ボーダーを消す
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
        if ( self.listener1 == nil ) {
            fetchUser2()
        }
        
        if let currentUser = Auth.auth().currentUser {
            
            print("currentUser.uid:\(currentUser.uid)")
            // ログイン済み
            if listener == nil {
                fetchModerateUsers { [weak self] result in
                    
                    switch result {
                    case .success:
                        // listener未登録なら、登録してスナップショットを受信する
                        if ( self?.listener2 == nil ) {
                            let postsRef = Firestore.firestore().collection("users")
                            self?.listener2 = postsRef.addSnapshotListener() { [weak self] querySnapshot, error in
                                if let error = error {
                                    print("DEBUG_PRINT: snapshotの取得が失敗しました。 \(error)")
                                    return
                                } else {
                                    var docs = querySnapshot!.documents
                                    var sortArray: [String: UserData] = [:]
                                    for doc in docs {
                                        let userData = UserData(document: doc)
                                        sortArray[userData.uid] = userData
                                    }
                                    if let moderateArray = self?.moderateUserArray {
                                        // 最初の状態を作る
                                        if ( (self?.userArray.count)! == 0 ) {
                                            print(moderateArray)
                                            for uid in moderateArray {
                                                self?.userArray.append(sortArray[uid]!)
                                            }
                                        }
                                        // 途中で更新があった場合は消して追加(置き換える)
                                        else {
                                            for uid in moderateArray {
                                                for  i in 0..<(self?.userArray.count)! - 1  {
                                                    if ( self?.userArray[i].uid == uid ) {
                                                        self?.userArray.remove(at: i)
                                                        self?.userArray.append(sortArray[uid]!)
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    else {
                                        print("followArray is empty.")
                                    }
                                    // クルクルストップ
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
                userArray = []
                //self.ActivityIndicator.stopAnimating()
                SVProgressHUD.dismiss()
                tableView.reloadData()
            }
        }
    }
    
    @objc func refresh(sender: UIRefreshControl?) {
        print("refresh")
        if Auth.auth().currentUser != nil {
            self.fetchModerateUsers { [weak self] result in
                switch result {
                case .failure(let error):
                    debugPrint(error.localizedDescription)
                    sender?.endRefreshing()
                case .success:
                    let postsRef = Firestore.firestore().collection("users")
                    self?.listener2 = postsRef.addSnapshotListener() { [weak self] querySnapshot, error in
                        if let error = error {
                            print("DEBUG_PRINT: snapshotの取得が失敗しました。 \(error)")
                            return
                        } else {
                            var docs = querySnapshot!.documents
                            var sortArray: [String: UserData] = [:]
                            for doc in docs {
                                let userData = UserData(document: doc)
                                sortArray[userData.uid] = userData
                            }
                            if let moderateArray = self?.moderateUserArray {
                                // 最初の状態を作る
                                if ( (self?.userArray.count)! == 0 ) {
                                    print(moderateArray)
                                    for uid in moderateArray {
                                        self?.userArray.append(sortArray[uid]!)
                                    }
                                }
                                // 途中で更新があった場合は消して追加(置き換える)
                                else {
                                    for uid in moderateArray {
                                        for  i in 0..<(self?.userArray.count)! - 1  {
                                            if ( self?.userArray[i].uid == uid ) {
                                                self?.userArray.remove(at: i)
                                                self?.userArray.append(sortArray[uid]!)
                                            }
                                        }
                                    }
                                }
                            }
                            else {
                                print("followArray is empty.")
                            }
                            
                            self?.tableView.reloadData()
                            sender?.endRefreshing()
                        }
                    }
                }
            }
        }
    }
    
    func fetchModerateUsers(completion: @escaping (Result<Any?, Error>) -> Void) {
        if listener_moderate == nil {
            let ref_moderate = Firestore.firestore().collection("moderator").document(userID)
            ref_moderate.getDocument { [weak self] document, error in
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
                        if let followUsers = postDic!["users"] as? [String] {
                            self?.moderateUserArray = followUsers.reversed()
                            print("followUsers:\(followUsers)")
                        }
                    }
                    completion(.success(nil))
                }
            }
            print("follow user list")
            print("self.followUserArray.description:\(self.moderateUserArray.description)")
        } else {
            completion(.failure(NSError(domain: "FetchError", code: 0, userInfo: nil)))
        }
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
    }
    
    private func fetchUser2() {
        
        let uid = Auth.auth().currentUser!.uid
        let userRef2 = Firestore.firestore().collection("users").document(uid)
        listener1 = userRef2.addSnapshotListener() { (documentSnapshot, error) in
            guard let document = documentSnapshot else {
                print("Error fetching document: \(error!)")
                return
            }
            self.userdata2  = UserData(document: document)
            
        }
    }
    
    
    @objc var scrollView: UIScrollView! {
        return tableView
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if self.userArray.count == 0 {
            return 1
        }else{
            return 3
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if self.userArray.count == 0 {
            return 1
        }else{
            if section == 0 {
                return 1
            }else if section == 1 {
                return userArray.count
            }else{
                return 1
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if userArray.count == 0 {
            print("遷移なし")
        }else{
            
            if indexPath.section == 0 {
                print("遷移なし")
            }else if indexPath.section == 1 {
                if self.userArray[indexPath.row].type == "community" {
                    let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
                    let uid = self.userArray[indexPath.row].uid
                    let baseViewController = storyboard.instantiateViewController(identifier: "Profile") as! BaseViewController
                    baseViewController.userID = uid
                    baseViewController.type = "community"
                    //コメント画面にPush遷移
                    navigationController?.pushViewController(baseViewController, animated: true)
                }else{
                    let uid = self.userArray[indexPath.row].uid
                    let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
                    let baseViewController = storyboard.instantiateViewController(identifier: "Profile") as! BaseViewController
                    baseViewController.userID = uid
                    baseViewController.type = "private"
                    //コメント画面にPush遷移
                    navigationController?.pushViewController(baseViewController, animated: true)
                }
            }else{
                print("遷移なし")
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if self.userArray.count == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "NotP2Posts", for: indexPath) as! NotP2PostsTableViewCell
            cell.label.text = "このコミュニティにはモデレーターがいません。"
            return cell
        }else{
            
            if indexPath.section == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "Margin2", for: indexPath) as! Margin2TableViewCell
                //セル押下時のハイライト(色が濃くなる)を無効
                cell.selectionStyle = .none
                return cell
            }else if indexPath.section == 1 {
                if self.userArray[indexPath.row].caption == "" || self.userArray[indexPath.row].caption == nil{
                    
                    print("captionなし:\(self.userArray[indexPath.row])")
                    // セルを取得してデータを設定する
                    let cell = tableView.dequeueReusableCell(withIdentifier: "Following1", for: indexPath) as! Following1TableViewCell
                    //セル押下時のハイライト(色が濃くなる)を無効
                    cell.selectionStyle = .none
                    cell.setUserData(userArray[indexPath.row])
                    
                    return cell
                }else{
                    print("captionあり:\(self.userArray[indexPath.row])")
                    // セルを取得してデータを設定する
                    let cell = tableView.dequeueReusableCell(withIdentifier: "Following2", for: indexPath) as! Following2TableViewCell
                    //セル押下時のハイライト(色が濃くなる)を無効
                    cell.selectionStyle = .none
                    cell.setUserData(userArray[indexPath.row])
                    
                    return cell
                }
            }else{
                let cell = tableView.dequeueReusableCell(withIdentifier: "Margin2", for: indexPath) as! Margin2TableViewCell
                //セル押下時のハイライト(色が濃くなる)を無効
                cell.selectionStyle = .none
                return cell
            }
        }
    }
}
