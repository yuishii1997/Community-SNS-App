//
//  Search2ViewController.swift
//  Nomad-App
//
//  Created by yuishii on 2021/02/02.
//  Copyright © 2021 Yu Ishii. All rights reserved.
//
// 検索画面(サーチバーをタップしたとき)

import UIKit
import Firebase
import NotificationBannerSwift
import GoogleMobileAds
import SVProgressHUD

class Search2ViewController: UIViewController,UITableViewDataSource,UITableViewDelegate, UISearchResultsUpdating, UIViewControllerPreviewingDelegate {
    
    var userArray: [UserData] = []
    var userArray2: [UserData] = []
    var currentUserArray: [UserData] = []
    var emptyUserArray: [UserData] = []
    
    var userdata: UserData?
    
    var searchBar: UISearchBar!
    weak var searchController: UISearchController!
    
    // ブロックユーザーデータを格納する配列
    var blockUserArray: [String] = []
    // Firestoreのリスナー
    var listener: ListenerRegistration!
    var listener1: ListenerRegistration!
    var listener2: ListenerRegistration!
    
    //フラグ
    var userIsTapped = false
    
    var ActivityIndicator: UIActivityIndicatorView!
    
    weak var navigationDelegate: NavigateFromSearchResultProtocol?
    
    var forceTouch: UIForceTouchCapability = .unknown
    
    //結果表示用テーブルビュー
    var tableView:UITableView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        print("Search2ViewControllerを表示しています")
        
        //結果表示用のテーブルビューを作成する。
        tableView = UITableView(frame: self.view.bounds, style: .plain)
        tableView.dataSource = self
        tableView.delegate = self
        self.tableView.tableFooterView = UIView(frame: .zero)
        tableView.separatorInset = .zero
        self.view.addSubview(tableView)
        tableView.separatorStyle = .none
        
        //スクロールしたらキーボード閉じる
        tableView.keyboardDismissMode = .onDrag
        
        // カスタムセルを登録する
        let nib1 = UINib(nibName: "Following1TableViewCell", bundle: nil)
        tableView.register(nib1, forCellReuseIdentifier: "Following1")
        let nib2 = UINib(nibName: "Following2TableViewCell", bundle: nil)
        tableView.register(nib2, forCellReuseIdentifier: "Following2")
        let nib3 = UINib(nibName: "NotResults1TableViewCell", bundle: nil)
        tableView.register(nib3, forCellReuseIdentifier: "NotResults1")
        let nib4 = UINib(nibName: "NotResults2TableViewCell", bundle: nil)
        tableView.register(nib4, forCellReuseIdentifier: "NotResults2")
        let nib5 = UINib(nibName: "Following7TableViewCell", bundle: nil)
        tableView.register(nib5, forCellReuseIdentifier: "Following7")
        let nib6 = UINib(nibName: "Following8TableViewCell", bundle: nil)
        tableView.register(nib6, forCellReuseIdentifier: "Following8")
        tableView.register(UINib(nibName: "GoogleMobileAdsTableCell", bundle: nil),
                           forCellReuseIdentifier: "GoogleMobileAdsTableCell")
        let recently = UINib(nibName: "RecentlyTableViewCell", bundle: nil)
        tableView.register(recently, forCellReuseIdentifier: "Recently")
        let marginNib = UINib(nibName: "Margin2TableViewCell", bundle: nil)
        tableView.register(marginNib, forCellReuseIdentifier: "Margin2")
        
        
        if #available(iOS 9.0, *){
            if forceTouch == .available{
                self.registerForPreviewing(with: self, sourceView: self.view)
            }
        }
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
        
        //self.navigationController?.navigationBar.barTintColor = UIColor.rgb(red: 66, green: 80, blue: 109)
        
        if Auth.auth().currentUser != nil {
            // ログイン済み
            if listener == nil {
                fetchBlockUsers { [weak self] result in
                    switch result {
                    case .success:
                        
                        if ( self?.listener2 == nil ) {
                            let postsRef = Firestore.firestore().collection("users").whereField("deleted", isEqualTo: "no")
                            self?.listener2 = postsRef.addSnapshotListener() { [weak self] querySnapshot, error in
                                if let error = error {
                                    print("DEBUG_PRINT: snapshotの取得が失敗しました。 \(error)")
                                    return
                                } else {
                                    //サーチバーに何も入力していない時にこのuserArray2をupdateSearchResultsでフィルターをかける
                                    self?.userArray2 = querySnapshot!.documents.compactMap { document in
                                        print("DEBUG_PRINT: document取得 \(document.documentID)")
                                        let postData = UserData(document: document)
                                        postData.id = document.documentID
                                        if self?.blockUserArray.contains(postData.uid) == false && postData.isReported == false && postData.viewed {
                                            return postData
                                        } else {
                                            return nil
                                        }
                                    }
                                    self?.userArray2.sort { $0.viewedTime > $1.viewedTime }
                                    SVProgressHUD.dismiss()
                                    self?.tableView.reloadData()
                                }
                            }
                        }
                        
                        
                        if ( self?.listener1 == nil ) {
                            let postsRef = Firestore.firestore().collection("users").whereField("deleted", isEqualTo: "no").order(by: "date", descending: true)
                            self?.listener1 = postsRef.addSnapshotListener() { [weak self] querySnapshot, error in
                                if let error = error {
                                    print("DEBUG_PRINT: snapshotの取得が失敗しました。 \(error)")
                                    return
                                } else {
                                    //このuserArrayをupdateSearchResultsでフィルターをかける
                                    self?.userArray = querySnapshot!.documents.compactMap { document in
                                        print("DEBUG_PRINT: document取得 \(document.documentID)")
                                        let postData = UserData(document: document)
                                        postData.id = document.documentID
                                        if self?.blockUserArray.contains(postData.uid) == false && postData.isReported == false {
                                            return postData
                                        } else {
                                            return nil
                                        }
                                    }
                                    self?.userArray.sort { $0.follower.count > $1.follower.count }
                                    if self?.searchController.searchBar.text != "", let userArray = self?.userArray {
                                        self?.currentUserArray = userArray.filter { post -> Bool in
                                            guard let searchText = self?.searchController.searchBar.text else { return false }
                                            return post.name!.lowercased().contains(searchText.lowercased())
                                        }
                                    }
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
                SVProgressHUD.dismiss()
                tableView.reloadData()
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        //セルをタップして遷移し、遷移元から戻ってキャンセルボタンを押したときに出力される
        if self.userIsTapped {
            print("self.userIsTapped")
            self.navigationController?.navigationBar.barTintColor = UIColor.rgb(red: 66, green: 80, blue: 109)
            userIsTapped = false
        }
        
        
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
        print("テーブルビューを閉じます")
    }
    
    //検索された時に実行される関数
    func updateSearchResults(for searchController: UISearchController) {
        
        print("searchController.isActive")
        if searchController.searchBar.text == "" {
            print("検索欄が空白です")
            //検索欄が空白のときは何も表示しない
            currentUserArray = userArray2
            tableView.reloadData()
            return
        }else{
            currentUserArray = userArray.filter({ post -> Bool in
                print("検索欄は空白ではありません")
                guard let searchText = searchController.searchBar.text else { return false }
                return post.name!.lowercased().contains(searchText.lowercased())
            })
            tableView.reloadData()
        }
    }
    
    //ブロックしているユーザーの情報取得
    func fetchBlockUsers(completion: @escaping (Result<Any?, Error>) -> Void) {
        if let myid = Auth.auth().currentUser?.uid {
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if self.searchController.searchBar.text == "" {
            
            if self.userArray2.count == 0 {
                return 1
            }else if self.userArray2.count > 10 {
                if section == 0 {
                    return 1
                }else if section == 1 {
                    return 10
                }else{
                    return 1
                }
            }else{
                if section == 0 {
                    return 1
                }else if section == 1 {
                    return userArray2.count
                }else{
                    return 1
                }
            }
        }else{
            
            if self.currentUserArray.count != 0 {
                if section == 0 {
                    return 1
                }else if section == 1 {
                    return currentUserArray.count
                }else{
                    return 1
                }
            }else{
                return 1
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if self.searchController.searchBar.text == "" && self.userArray2.count != 0 || self.searchController.searchBar.text != "" && self.currentUserArray.count != 0{
            return 3
        }else{
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //サーチバーが空欄のとき
        if self.searchController.searchBar.text == "" {
            
            //検索履歴がないとき
            if self.userArray2.count != 0 {
                if indexPath.section == 0 {
                    print("セクション0がタップされました")
                    
                    //検索履歴があるとき
                }else{
                    if indexPath.section == 0 {
                        print("タップされました")
                    }else if indexPath.section == 1 {
                        // viewerを更新する
                        if let myid = Auth.auth().currentUser?.uid {
                            // 更新データを作成する
                            var updateValue: FieldValue
                            var updateValue2: FieldValue
                            userdata = self.userArray2[indexPath.row]
                            
                            if userdata!.viewed {
                                print("古いmyidを消して新しいmyidを加えます")
                                //再度新しい日付でmyidを加えるために一度古い日付で登録したmyidを消す
                                updateValue = FieldValue.arrayRemove([["uid": myid, "time": userdata!.viewedTime]])
                                updateValue2 = FieldValue.arrayUnion([["uid": myid, "time": Date.timeIntervalSinceReferenceDate]])
                                let postRef = Firestore.firestore().collection("users").document(self.userdata!.id)
                                postRef.updateData(["viewer": updateValue])
                                postRef.updateData(["viewer": updateValue2])
                            } else{
                                print("新しいmyidを加えます")
                                updateValue = FieldValue.arrayUnion([["uid": myid, "time": Date.timeIntervalSinceReferenceDate]])
                                let postRef = Firestore.firestore().collection("users").document(self.userdata!.id)
                                postRef.updateData(["viewer": updateValue])
                            }
                        }
                        //プロフィール画面に遷移する
                        if self.userArray2[indexPath.row].type == "community" {
                            let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
                            let uid = self.userArray2[indexPath.row].uid
                            let baseViewController = storyboard.instantiateViewController(identifier: "Profile") as! BaseViewController
                            baseViewController.userID = uid
                            baseViewController.type = "community"
                            userIsTapped = true
                            self.navigationDelegate?.navigationControllerPush(fromSearchResult: baseViewController)
                            
                        }else{
                            let uid = self.userArray2[indexPath.row].uid
                            let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
                            let baseViewController = storyboard.instantiateViewController(identifier: "Profile") as! BaseViewController
                            baseViewController.userID = uid
                            baseViewController.type = "private"
                            userIsTapped = true
                            self.navigationDelegate?.navigationControllerPush(fromSearchResult: baseViewController)
                        }
                        //選択状態の解除
                        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
                    }else{
                        print("タップされました")
                    }
                }
            }
            
            //サーチバーが空欄ではないとき
        }else{
            
            //合致しているユーザーがないとき
            if self.currentUserArray.count == 0 {
                print("タップしました")
                //合致しているユーザーがいるとき
            }else{
                if indexPath.section == 0 {
                    print("タップしました")
                }else if indexPath.section == 1 {
                    if let myid = Auth.auth().currentUser?.uid {
                        // 更新データを作成する
                        var updateValue: FieldValue
                        var updateValue2: FieldValue
                        userdata = self.currentUserArray[indexPath.row]
                        
                        if userdata!.viewed {
                            print("古いmyidを消して新しいmyidを加えます")
                            //再度新しい日付でmyidを加えるために一度古い日付で登録したmyidを消す
                            updateValue = FieldValue.arrayRemove([["uid": myid, "time": userdata!.viewedTime]])
                            updateValue2 = FieldValue.arrayUnion([["uid": myid, "time": Date.timeIntervalSinceReferenceDate]])
                            let postRef = Firestore.firestore().collection("users").document(self.userdata!.id)
                            postRef.updateData(["viewer": updateValue])
                            postRef.updateData(["viewer": updateValue2])
                        } else{
                            print("新しいmyidを加えます")
                            updateValue = FieldValue.arrayUnion([["uid": myid, "time": Date.timeIntervalSinceReferenceDate]])
                            let postRef = Firestore.firestore().collection("users").document(self.userdata!.id)
                            postRef.updateData(["viewer": updateValue])
                        }
                    }
                    
                    //プロフィール画面に遷移する
                    if self.currentUserArray[indexPath.row].type == "community" {
                        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
                        let uid = self.currentUserArray[indexPath.row].uid
                        let baseViewController = storyboard.instantiateViewController(identifier: "Profile") as! BaseViewController
                        baseViewController.userID = uid
                        baseViewController.type = "community"
                        userIsTapped = true
                        self.navigationController?.navigationBar.barTintColor = UIColor.rgb(red: 66, green: 80, blue: 109)
                        self.navigationDelegate?.navigationControllerPush(fromSearchResult: baseViewController)
                        
                    }else{
                        let uid = self.currentUserArray[indexPath.row].uid
                        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
                        let baseViewController = storyboard.instantiateViewController(identifier: "Profile") as! BaseViewController
                        baseViewController.userID = uid
                        baseViewController.type = "private"
                        userIsTapped = true
                        self.navigationController?.navigationBar.barTintColor = UIColor.rgb(red: 66, green: 80, blue: 109)
                        self.navigationDelegate?.navigationControllerPush(fromSearchResult: baseViewController)
                    }
                    //選択状態の解除
                    tableView.deselectRow(at: indexPath as IndexPath, animated: true)
                }else{
                    print("タップしました")
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        if self.searchController.searchBar.text == "" {
            
            if self.userArray2.count == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "NotResults1", for: indexPath) as! NotResults1TableViewCell
                cell.selectionStyle = .none
                return cell
            }else{
                if indexPath.section == 0 {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "Recently", for: indexPath) as! RecentlyTableViewCell
                    cell.selectionStyle = .none
                    cell.recentlyButton.addTarget(self, action:#selector(allDeleteButton(_:forEvent:)), for: .touchUpInside)
                    return cell
                    
                }else if indexPath.section == 1 {
                    
                    if self.userArray2[indexPath.row].caption == "" || self.userArray2[indexPath.row].caption == nil{
                        print("captionなし:\(self.userArray2[indexPath.row])")
                        // セルを取得してデータを設定する
                        let cell = tableView.dequeueReusableCell(withIdentifier: "Following7", for: indexPath) as! Following7TableViewCell
                        //セル押下時のハイライト(色が濃くなる)を無効
                        cell.selectionStyle = .none
                        cell.setUserData(self.userArray2[indexPath.row])
                        cell.deleteButton.addTarget(self, action:#selector(deleteButton(_:forEvent:)), for: .touchUpInside)
                        return cell
                    }else{
                        print("captionあり:\(self.userArray2[indexPath.row])")
                        // セルを取得してデータを設定する
                        let cell = tableView.dequeueReusableCell(withIdentifier: "Following8", for: indexPath) as! Following8TableViewCell
                        //セル押下時のハイライト(色が濃くなる)を無効
                        cell.selectionStyle = .none
                        cell.setUserData(self.userArray2[indexPath.row])
                        cell.deleteButton.addTarget(self, action:#selector(deleteButton(_:forEvent:)), for: .touchUpInside)
                        return cell
                    }
                }else{
                    let cell = tableView.dequeueReusableCell(withIdentifier: "Margin2", for: indexPath) as! Margin2TableViewCell
                    //セル押下時のハイライト(色が濃くなる)を無効
                    cell.selectionStyle = .none
                    return cell
                }
            }
        }else{
            
            if self.currentUserArray.count == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "NotResults2", for: indexPath) as! NotResults2TableViewCell
                cell.selectionStyle = .none
                return cell
            }else{
                if indexPath.section == 0 {
                    
                    let cell = tableView.dequeueReusableCell(withIdentifier: "Margin2", for: indexPath) as! Margin2TableViewCell
                    //セル押下時のハイライト(色が濃くなる)を無効
                    cell.selectionStyle = .none
                    return cell
                    
                }else if indexPath.section == 1 {
                    
                    if self.currentUserArray[indexPath.row].caption == "" || self.currentUserArray[indexPath.row].caption == nil{
                        print("captionなし:\(self.currentUserArray[indexPath.row])")
                        // セルを取得してデータを設定する
                        let cell = tableView.dequeueReusableCell(withIdentifier: "Following1", for: indexPath) as! Following1TableViewCell
                        //セル押下時のハイライト(色が濃くなる)を無効
                        cell.selectionStyle = .none
                        cell.setUserData(currentUserArray[indexPath.row])
                        return cell
                    }else{
                        print("captionあり:\(self.currentUserArray[indexPath.row])")
                        // セルを取得してデータを設定する
                        let cell = tableView.dequeueReusableCell(withIdentifier: "Following2", for: indexPath) as! Following2TableViewCell
                        //セル押下時のハイライト(色が濃くなる)を無効
                        cell.selectionStyle = .none
                        cell.setUserData(currentUserArray[indexPath.row])
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
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        print("peek")
        return nil
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        self.navigationDelegate?.previewingContext(fromSearchResult: previewingContext, commit: viewControllerToCommit)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("キーボードを閉じる")
        view.endEditing(true)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        view.endEditing(true)
    }
    
    // セル内のボタンがタップされた時に呼ばれるメソッド
    @objc func deleteButton(_ sender: UIButton, forEvent event: UIEvent) {
        
        if Auth.auth().currentUser?.uid != nil {
            let myid = Auth.auth().currentUser!.uid
            // タップされたセルのインデックスを求める
            let touch = event.allTouches?.first
            let point = touch!.location(in: self.tableView)
            let indexPath = tableView.indexPathForRow(at: point)
            // 配列からタップされたインデックスのデータを取り出す
            let userData = userArray2[indexPath!.row]
            var updateValue: FieldValue
            updateValue = FieldValue.arrayRemove([["uid": myid, "time": userData.viewedTime]])
            let postRef = Firestore.firestore().collection("users").document(userData.id)
            postRef.updateData(["viewer": updateValue])
        }
    }
    
    @objc func allDeleteButton(_ sender: UIButton, forEvent event: UIEvent) {
        
        
        let alert: UIAlertController = UIAlertController(title: "検索履歴を削除してもよろしいでしょうか？", message: nil, preferredStyle:  UIAlertController.Style.alert)
        
        let defaultAction: UIAlertAction = UIAlertAction(title: "はい", style: UIAlertAction.Style.destructive, handler:{
            // ボタンが押された時の処理を書く（クロージャ実装）
            (action: UIAlertAction!) -> Void in
            print("OK")
            if let myid = Auth.auth().currentUser?.uid {
                
                for postData in self.userArray2 {
                    // 更新データを作成する
                    var updateValue: FieldValue
                    updateValue = FieldValue.arrayRemove([["uid": myid, "time": postData.viewedTime]])
                    let postRef = Firestore.firestore().collection("users").document(postData.id)
                    postRef.updateData(["viewer": updateValue])
                    
                }
            }
        })
        // キャンセルボタン
        let cancelAction: UIAlertAction = UIAlertAction(title: "キャンセル", style: UIAlertAction.Style.default, handler:{
            // ボタンが押された時の処理を書く（クロージャ実装）
            (action: UIAlertAction!) -> Void in
            print("Cancel")
        })
        
        // ③ UIAlertControllerにActionを追加
        alert.addAction(cancelAction)
        alert.addAction(defaultAction)
        
        // ④ Alertを表示
        present(alert, animated: true, completion: nil)
        
        
    }
    
}
