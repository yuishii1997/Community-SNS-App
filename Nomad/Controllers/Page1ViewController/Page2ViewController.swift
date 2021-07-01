//
//  Page2ViewController.swift
//  Nomad-App
//
//  Created by yuishii on 2020/12/08.
//  Copyright © 2020 Yu Ishii. All rights reserved.
//
// プロフィール画面の2ページ目

import UIKit
import SegementSlide
import Firebase
import MessageUI
import NotificationBannerSwift
import SVProgressHUD

class Page2ViewController: UITableViewController,SegementSlideContentScrollViewDelegate {
    
    var userID: String = ""
    var userdata: UserData?
    
    // 投稿データを格納する配列
    var postArray: [PostData] = []
    // ブロックユーザーデータを格納する配列
    var blockUserArray: [String] = []
    
    private var postdata: PostData?
    
    // Firestoreのリスナー
    var listener: ListenerRegistration!
    var listener1: ListenerRegistration!
    var listener_block: ListenerRegistration!
    
    lazy var adLoader: GADAdLoader = {
        let multipleAdsOptions = GADMultipleAdsAdLoaderOptions()
        multipleAdsOptions.numberOfAds = Constants.numberOfAds
        let adLoader: GADAdLoader = GADAdLoader(
            adUnitID: Constants.adUnitID, rootViewController: self,
            adTypes: [GADAdLoaderAdType.unifiedNative],
            options: [multipleAdsOptions])
        adLoader.delegate = self
        return adLoader
    }()
    private var nativeAds: [GADUnifiedNativeAd] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        adLoader.load(GADRequest())
        
        tableView.separatorStyle = .none
        tableView.separatorInset = .zero
        tableView.backgroundColor = .white
        self.tableView.backgroundColor = .white
        
        // カスタムセルを登録する
        let nib1 = UINib(nibName: "Post5TableViewCell", bundle: nil)
        tableView.register(nib1, forCellReuseIdentifier: "Cell5")
        let nib2 = UINib(nibName: "Post6TableViewCell", bundle: nil)
        let nib3 = UINib(nibName: "NotP3PostsTableViewCell", bundle: nil)
        tableView.register(nib3, forCellReuseIdentifier: "NotP3Posts")
        tableView.register(nib2, forCellReuseIdentifier: "Cell6")
        tableView.register(UINib(nibName: "GoogleMobileAdsTableCell2", bundle: nil),
                           forCellReuseIdentifier: "GoogleMobileAdsTableCell2")
        
        //空セルのseparator(しきり線)を消す
        tableView.tableFooterView = UIView(frame: .zero)
        let refreshControl = UIRefreshControl()
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(Page3ViewController.refresh(sender:)), for: .valueChanged)
        
        SVProgressHUD.setDefaultStyle(.custom)
        SVProgressHUD.setDefaultMaskType(.none)
        SVProgressHUD.setForegroundColor(.gray)
        SVProgressHUD.setBackgroundColor(.clear)
        SVProgressHUD.setBackgroundLayerColor(.clear)
        SVProgressHUD.show()
        
    }
    
    // 一番上までスクロール
    @objc func page1Top() {
        
        if self.postArray.count == 0{
            // NavigationBarを表示したい場合
            self.navigationController!.setNavigationBarHidden(false, animated: false)
            print("投稿がありません。")
        }else{
            tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
            // NavigationBarを表示したい場合
            self.navigationController!.setNavigationBarHidden(false, animated: false)
            print("上にスクロールします")
        }
    }
    
    @objc func refresh(sender: UIRefreshControl?) {
        print("refresh")
        self.fetchBlockUsers { [weak self] result in
            switch result {
            case .failure(let error):
                debugPrint(error.localizedDescription)
            case .success:
                
                let postsRef = Firestore.firestore().collection("posts").whereField("deleted", isEqualTo: "no").order(by: "date", descending: true)
                self?.listener = postsRef.addSnapshotListener() { (querySnapshot, error) in
                    if let error = error {
                        print("DEBUG_PRINT: snapshotの取得が失敗しました。 \(error)")
                        return
                    }else{
                        // 取得したdocumentをもとにPostDataを作成し、postArrayの配列にする。
                        self?.postArray = querySnapshot!.documents.compactMap { document in
                            print("DEBUG_PRINT: document取得 \(document.documentID)")
                            let postData = PostData(document: document)
                            postData.id = document.documentID
                            if postData.uid == self!.userID && postData.isReported == false && self?.blockUserArray.contains(postData.uid) == false {
                                return postData
                            } else {
                                return nil
                            }
                        }
                        
                        self?.postArray.sort { $0.bookmarks.count > $1.bookmarks.count }
                        self?.postArray.sort { $0.viewer.count > $1.viewer.count }
                        self?.postArray.sort { $0.allComments.count > $1.allComments.count }
                        self?.postArray.sort { $0.comments.count > $1.comments.count }
                        self?.postArray.sort { $0.likes.count > $1.likes.count }
                        
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
            fetchUser()
        }
        
        if (self.listener == nil) {
            fetchPosts()
        } else {
            // ログイン未(またはログアウト済み)
            if listener != nil {
                // listener登録済みなら削除してpostArrayをクリアする
                listener.remove()
                listener = nil
                postArray = []
                // クルクルストップ
                SVProgressHUD.dismiss()
                tableView.reloadData()
            }
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
        if ( self.listener_block != nil ){
            listener_block.remove()
            listener_block = nil
        }
        print("テーブルビューを閉じます")
    }
    
    // ユーザーの情報を取得
    private func fetchUser() {
        
        let userRef = Firestore.firestore().collection("users").document(userID)
        self.listener1 = userRef.addSnapshotListener() { (documentSnapshot, error) in
            guard let document = documentSnapshot else {
                print("Error fetching document: \(error!)")
                return
            }
            self.userdata  = UserData(document: document)
            print("self.userdata.name:\(self.userdata!.name)")
            self.tableView.reloadData()
        }
    }
    
    // 表示する投稿を取得
    private func fetchPosts() {
        
        self.fetchBlockUsers { [weak self] result in
            switch result {
            case .failure(let error):
                debugPrint(error.localizedDescription)
            case .success:
                if ( self?.listener == nil ) {
                    
                    let postsRef = Firestore.firestore().collection("posts").whereField("deleted", isEqualTo: "no").order(by: "date", descending: true)
                    self?.listener = postsRef.addSnapshotListener() { (querySnapshot, error) in
                        if let error = error {
                            print("DEBUG_PRINT: snapshotの取得が失敗しました。 \(error)")
                            return
                        }else{
                            // 取得したdocumentをもとにPostDataを作成し、postArrayの配列にする。
                            self?.postArray = querySnapshot!.documents.compactMap { document in
                                print("DEBUG_PRINT: document取得 \(document.documentID)")
                                let postData = PostData(document: document)
                                postData.id = document.documentID
                                if postData.uid == self!.userID && postData.isReported == false && self?.blockUserArray.contains(postData.uid) == false {
                                    return postData
                                } else {
                                    return nil
                                }
                            }
                            self?.postArray.sort { $0.bookmarks.count > $1.bookmarks.count }
                            self?.postArray.sort { $0.viewer.count > $1.viewer.count }
                            self?.postArray.sort { $0.allComments.count > $1.allComments.count }
                            self?.postArray.sort { $0.comments.count > $1.comments.count }
                            self?.postArray.sort { $0.likes.count > $1.likes.count }
                            
                            SVProgressHUD.dismiss()
                            self?.tableView.reloadData()
                        }
                    }
                    
                }
            }
        }
    }
    
    // 広告を抜いた、postDataのrowを返す
    private func postRow(row: Int) -> Int {
        let num = row + 1
        let interval = Constants.adInterval + 1
        switch (num, nativeAds.count) {
        case (let num, let adsCount) where (num / interval) <= adsCount:
            return row - (num / interval)
        case (let num, let adsCount) where adsCount < (num / interval):
            return row - adsCount
        default:
            return row
        }
    }
    
    //ブロックしているユーザーの情報取得
    func fetchBlockUsers(completion: @escaping (Result<Any?, Error>) -> Void) {
        if let myid = Auth.auth().currentUser?.uid, listener_block == nil {
            let postsRef_block = Firestore.firestore().collection("blockUsers").document(myid)
            postsRef_block.getDocument { (document, error) in
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
                            self.blockUserArray = blockUsers
                            print("blockUsers:\(blockUsers)")
                            self.tableView.reloadData()
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
    
    @objc var scrollView: UIScrollView{
        return tableView
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let myid = Auth.auth().currentUser?.uid
        
        if postArray.count == 0 || blockUserArray.contains(self.userID) || self.userdata?.bePrivate == "on" && self.userID != myid && self.userdata?.isFollowed == false {
            print("遷移なし")
        }else{
            // 広告の場合はreturn
            let num = indexPath.row + 1
            if (num % Constants.numberOfAds) == 0,
               (num / Constants.numberOfAds) <= nativeAds.count { return }
            
            let storyboard = UIStoryboard.init(name: "ChatRoom", bundle: nil)
            let chatRoomViewController = storyboard.instantiateViewController(identifier: "ChatRoomViewController") as! ChatRoomViewController
            postdata = self.postArray[postRow(row: indexPath.row)]
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
            }
            navigationController?.pushViewController(chatRoomViewController, animated: true)
            //選択状態の解除
            tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let myid = Auth.auth().currentUser?.uid
        if self.postArray.count == 0 || blockUserArray.contains(self.userID)  || self.userdata?.bePrivate == "on" && self.userID != myid && self.userdata?.isFollowed == false {
            return 1
        }else{
            let segment = postArray.count / Constants.adInterval
            if segment < Constants.numberOfAds {
                return postArray.count + (segment < nativeAds.count ? segment : nativeAds.count)
            } else if Constants.numberOfAds < segment {
                return postArray.count + nativeAds.count
            } else {
                return postArray.count
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // 広告
        let num = indexPath.row + 1
        let interval = Constants.adInterval + 1
        if (num % interval) == 0,
           (num / interval) <= nativeAds.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: "GoogleMobileAdsTableCell2", for: indexPath) as! GoogleMobileAdsTableCell2
            cell.apply(nativeAd: nativeAds[(num / interval) - 1])
            return cell
        }
        
        let row = postRow(row: indexPath.row)
        //現在ログイン中のユーザーIDのみ取り出す
        let uid = Auth.auth().currentUser?.uid
        
        if blockUserArray.contains(self.userID){
            let cell = tableView.dequeueReusableCell(withIdentifier: "NotP3Posts", for: indexPath) as! NotP3PostsTableViewCell
            cell.label.text = "このユーザーをブロックしています。ブロックを解除すると投稿が表示されます。"
            return cell
        }else if self.userdata?.bePrivate == "on" && self.userID != uid && self.userdata?.isFollowed == false {
            let cell = tableView.dequeueReusableCell(withIdentifier: "NotP3Posts", for: indexPath) as! NotP3PostsTableViewCell
            cell.label.text = "このアカウントは非公開です。"
            return cell
        }else{
            if self.postArray.count == 0 {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "NotP3Posts", for: indexPath) as! NotP3PostsTableViewCell
                cell.label.text = "このユーザーは投稿をしていません。"
                return cell
                
            }else{
                
                // with_imageがtrueの場合 Post2TableViewCell
                if self.postArray[row].with_image == true {
                    print("Create Post2TableViewCell")
                    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell6", for: indexPath) as! Post6TableViewCell
                    
                    postdata = self.postArray[row]
                    cell.setPostData(self.postArray[row])
                    // セル内のボタンのアクションをソースコードで設定する
                    cell.likeButton.addTarget(self, action:#selector(handleButton(_:forEvent:)), for: .touchUpInside)
                    cell.bookmarkButton.addTarget(self, action:#selector(bookmarkButton(_:forEvent:)), for: .touchUpInside)
                    //セル押下時のハイライト(色が濃くなる)を無効
                    cell.selectionStyle = .none
                    if postdata?.uid == uid {
                        cell.alertButton.removeTarget(self, action: #selector(alertButton2(_:forEvent:)), for: .touchUpInside)
                        cell.alertButton.addTarget(self, action:#selector(alertButton(_:forEvent:)), for: .touchUpInside)
                    }else{
                        cell.alertButton.removeTarget(self, action: #selector(alertButton(_:forEvent:)), for: .touchUpInside)
                        cell.alertButton.addTarget(self, action:#selector(alertButton2(_:forEvent:)), for: .touchUpInside)
                    }
                    cell.commentButton.addTarget(self, action:#selector(toComment(_:forEvent:)), for: .touchUpInside)
                    cell.nameButton.addTarget(self, action:#selector(userProfileButton(_:forEvent:)), for: .touchUpInside)
                    cell.iconButton.addTarget(self, action:#selector(userProfileButton(_:forEvent:)), for: .touchUpInside)
                    cell.communityButton.addTarget(self, action:#selector(userProfileButton2(_:forEvent:)), for: .touchUpInside)
                    
                    return cell
                }
                // with_imageがfalseの場合 Post1TableViewCell
                else {
                    print("Create Post1TableViewCell")
                    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell5", for: indexPath) as! Post5TableViewCell
                    
                    postdata = self.postArray[row]
                    cell.setPostData(self.postArray[row])
                    // セル内のボタンのアクションをソースコードで設定する
                    cell.likeButton.addTarget(self, action:#selector(handleButton(_:forEvent:)), for: .touchUpInside)
                    cell.bookmarkButton.addTarget(self, action:#selector(bookmarkButton(_:forEvent:)), for: .touchUpInside)
                    //セル押下時のハイライト(色が濃くなる)を無効
                    cell.selectionStyle = .none
                    if postdata?.uid == uid {
                        cell.alertButton.removeTarget(self, action: #selector(alertButton2(_:forEvent:)), for: .touchUpInside)
                        cell.alertButton.addTarget(self, action:#selector(alertButton(_:forEvent:)), for: .touchUpInside)
                    }else{
                        cell.alertButton.removeTarget(self, action: #selector(alertButton(_:forEvent:)), for: .touchUpInside)
                        cell.alertButton.addTarget(self, action:#selector(alertButton2(_:forEvent:)), for: .touchUpInside)
                    }
                    cell.commentButton.addTarget(self, action:#selector(toComment(_:forEvent:)), for: .touchUpInside)
                    cell.nameButton.addTarget(self, action:#selector(userProfileButton(_:forEvent:)), for: .touchUpInside)
                    cell.iconButton.addTarget(self, action:#selector(userProfileButton(_:forEvent:)), for: .touchUpInside)
                    cell.communityButton.addTarget(self, action:#selector(userProfileButton2(_:forEvent:)), for: .touchUpInside)
                    
                    return cell
                }
            }
        }
    }
    
    // セル内のボタンがタップされた時に呼ばれるメソッド
    @objc func userProfileButton(_ sender: UIButton, forEvent event: UIEvent) {
        
        // タップされたセルのインデックスを求める
        let touch = event.allTouches?.first
        let point = touch!.location(in: self.tableView)
        guard let indexPath = tableView.indexPathForRow(at: point) else { return }
        
        // 配列からタップされたインデックスのデータを取り出す
        let postData = self.postArray[self.postRow(row: indexPath.row)]
        let uid = postData.uid
        
        if uid == self.userID {
            print("一緒のuidです")
        }else{
            let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
            let baseViewController = storyboard.instantiateViewController(identifier: "Profile") as! BaseViewController
            
            baseViewController.userID = uid
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
        let postData = postArray[postRow(row: indexPath.row)]
        let communityUid = postData.community
        let uid = postData.uid
        
        if communityUid != nil {
            print("確認1")
            
            let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
            let baseViewController = storyboard.instantiateViewController(identifier: "Profile") as! BaseViewController
            baseViewController.userID = communityUid!
            baseViewController.type = "community"
            //コメント画面にPush遷移
            navigationController?.pushViewController(baseViewController, animated: true)
        }else{
            print("確認2")
            
            let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
            let baseViewController = storyboard.instantiateViewController(identifier: "Profile") as! BaseViewController
            
            baseViewController.userID = uid
            baseViewController.type = "private"
            //コメント画面にPush遷移
            navigationController?.pushViewController(baseViewController, animated: true)
        }
    }
    
    
    @objc func editProfileButton(_ sender: UIButton, forEvent event: UIEvent) {
        
        SVProgressHUD.setDefaultStyle(.custom)
        SVProgressHUD.setDefaultMaskType(.none)
        SVProgressHUD.setForegroundColor(.gray)
        SVProgressHUD.setBackgroundColor(.clear)
        SVProgressHUD.setBackgroundLayerColor(.clear)
        SVProgressHUD.show()
        
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(identifier: "ProfileEditViewController") as! ProfileEditViewController
        
        if Auth.auth().currentUser != nil {
            let myid = Auth.auth().currentUser!.uid
            let ref = Firestore.firestore().collection("users").document(myid)
            ref.updateData(["editID": self.userID])
            
            navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    
    @objc func alertButton(_ sender: UIButton, forEvent event: UIEvent){
        
        
        // タップされたセルのインデックスを求める
        let touch = event.allTouches?.first
        let point = touch!.location(in: self.tableView)
        guard let indexPath = tableView.indexPathForRow(at: point) else { return }
        // 配列からタップされたインデックスのデータを取り出す
        let postData = self.postArray[self.postRow(row: indexPath.row)]
        
        print("アラートボタン")
        // インスタンス生成　styleはActionSheet.
        
        // インスタンス生成　styleはActionSheet.
        let myAlert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        let myAction_1 = UIAlertAction(title: "詳細設定を変更する", style: UIAlertAction.Style.default, handler: {
            (action: UIAlertAction!) in
            let storyboard = UIStoryboard(name: "ChatRoom", bundle: Bundle.main)
            let nextView = storyboard.instantiateViewController(withIdentifier: "PostEdit")as! PostEditViewController
            nextView.documentID = postData.id
            //ここがpushとは違う
            self.navigationController?.pushViewController(nextView, animated: true)
        })
        let myAction_2 = UIAlertAction(title: "投稿を削除する", style: UIAlertAction.Style.destructive, handler: {
            (action: UIAlertAction!) in
            let alert: UIAlertController = UIAlertController(title: "投稿を削除", message: "本当にこの投稿を削除してよろしいですか？", preferredStyle:  UIAlertController.Style.alert)
            let defaultAction: UIAlertAction = UIAlertAction(title: "削除", style: UIAlertAction.Style.destructive, handler:{
                (action: UIAlertAction!) -> Void in
                //削除のコード
                //firestoreをインスタンスにしてメンバにしておく
                if let myid = Auth.auth().currentUser?.uid {
                    // 更新データを作成する
                    var updateValue: FieldValue
                    print("新しいmyidを加えます")
                    updateValue = FieldValue.arrayUnion([["uid": myid, "time": Date.timeIntervalSinceReferenceDate]])
                    let postRef = Firestore.firestore().collection("posts").document(postData.id)
                    postRef.updateData(["deletes": updateValue])
                    postRef.updateData(["deleted": "done"])
                    //遷移してから以下のコメントを出したい
                    let banner = NotificationBanner(title: "削除しました", leftView: nil, rightView: nil, style: .info, colors: nil)
                    banner.autoDismiss = false
                    banner.dismissOnTap = true
                    banner.show(queuePosition: .front, bannerPosition: .top, queue: .default, on: self.navigationController!)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.2, execute: {
                        banner.dismiss()
                        //遷移元に戻る
                        self.navigationController?.popViewController(animated: true)
                    })
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
        
        let myAction_3 = UIAlertAction(title: "キャンセル", style: UIAlertAction.Style.cancel, handler: {
            (action: UIAlertAction!) in
            print("キャンセル")
        })
        // アクションを追加.
        myAlert.addAction(myAction_1)
        myAlert.addAction(myAction_2)
        myAlert.addAction(myAction_3)
        self.present(myAlert, animated: true, completion: nil)
    }
    
    @objc func alertButton2(_ sender: UIButton, forEvent event: UIEvent){
        
        // タップされたセルのインデックスを求める
        let touch = event.allTouches?.first
        let point = touch!.location(in: self.tableView)
        let indexPath = self.tableView.indexPathForRow(at: point)
        
        print("alert")
        // インスタンス生成
        let myAlert = UIAlertController(title: "問題のある投稿", message: "あてはまるものをお選びください", preferredStyle: UIAlertController.Style.alert)
        
        // アクションを生成.
        let myAction_1 = UIAlertAction(title: "投稿を通報する", style: UIAlertAction.Style.default, handler: {
            (action: UIAlertAction!) in
            print("通報")
            
            // 配列からタップされたインデックスのデータを取り出す
            let postData = self.postArray[self.postRow(row: indexPath!.row)]
            let documentId = postData.id
            let documentUid = postData.uid
            let caption:String = String(postData.caption!)
            
            if let myid = Auth.auth().currentUser?.uid {
                // 更新データを作成する
                var updateValue: FieldValue
                if postData.myReportExist {
                    print("既に通報しています")
                    let alertController:UIAlertController =
                        UIAlertController(title:"投稿の通報",
                                          message: "あてはまるものをお選びください",
                                          preferredStyle: .alert)
                    
                    // Default のaction
                    let action1:UIAlertAction =
                        UIAlertAction(title: "不審な内容またはスパム投稿である",
                                      style: .default,
                                      handler:{
                                        (action:UIAlertAction!) -> Void in
                                        // 処理
                                        print("新しいmyidを加えます")
                                        
                                        let banner = NotificationBanner(title: "通報しました", leftView: nil, rightView: nil, style: .info, colors: nil)
                                        banner.autoDismiss = false
                                        banner.dismissOnTap = true
                                        banner.show(queuePosition: .front, bannerPosition: .top, queue: .default, on: self.navigationController!)
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2, execute: {
                                            banner.dismiss()
                                            
                                            let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
                                            let viewController = storyboard.instantiateViewController(identifier: "ContactUs2") as! ContactUs2ViewController
                                            viewController.targetId = documentId
                                            viewController.targetUid = documentUid
                                            self.navigationController?.pushViewController(viewController, animated: true)
                                        })
                                      })
                    
                    let action2:UIAlertAction =
                        UIAlertAction(title: "誹謗中傷をしている",
                                      style: .default,
                                      handler:{
                                        (action:UIAlertAction!) -> Void in
                                        let banner = NotificationBanner(title: "通報しました", leftView: nil, rightView: nil, style: .info, colors: nil)
                                        banner.autoDismiss = false
                                        banner.dismissOnTap = true
                                        banner.show(queuePosition: .front, bannerPosition: .top, queue: .default, on: self.navigationController!)
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2, execute: {
                                            banner.dismiss()
                                            
                                            let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
                                            let viewController = storyboard.instantiateViewController(identifier: "ContactUs2") as! ContactUs2ViewController
                                            viewController.targetId = documentId
                                            viewController.targetUid = documentUid
                                            self.navigationController?.pushViewController(viewController, animated: true)
                                        })
                                      })
                    
                    let action3:UIAlertAction =
                        UIAlertAction(title: "不適切な内容を含んでいる",
                                      style: .default,
                                      handler:{
                                        (action:UIAlertAction!) -> Void in
                                        let banner = NotificationBanner(title: "通報しました", leftView: nil, rightView: nil, style: .info, colors: nil)
                                        banner.autoDismiss = false
                                        banner.dismissOnTap = true
                                        banner.show(queuePosition: .front, bannerPosition: .top, queue: .default, on: self.navigationController!)
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2, execute: {
                                            banner.dismiss()
                                            
                                            let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
                                            let viewController = storyboard.instantiateViewController(identifier: "ContactUs2") as! ContactUs2ViewController
                                            viewController.targetId = documentId
                                            viewController.targetUid = documentUid
                                            self.navigationController?.pushViewController(viewController, animated: true)
                                        })
                                      })
                    
                    let action4:UIAlertAction =
                        UIAlertAction(title: "自殺の意思をほのめかしている",
                                      style: .default,
                                      handler:{
                                        (action:UIAlertAction!) -> Void in
                                        // 処理
                                        print("新しいmyidを加えます")
                                        
                                        let banner = NotificationBanner(title: "通報しました", leftView: nil, rightView: nil, style: .info, colors: nil)
                                        banner.autoDismiss = false
                                        banner.dismissOnTap = true
                                        banner.show(queuePosition: .front, bannerPosition: .top, queue: .default, on: self.navigationController!)
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2, execute: {
                                            banner.dismiss()
                                            
                                            let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
                                            let viewController = storyboard.instantiateViewController(identifier: "ContactUs2") as! ContactUs2ViewController
                                            viewController.targetId = documentId
                                            viewController.targetUid = documentUid
                                            self.navigationController?.pushViewController(viewController, animated: true)
                                        })
                                      })
                    
                    // Cancel のaction
                    let cancelAction:UIAlertAction =
                        UIAlertAction(title: "キャンセル",
                                      style: .cancel,
                                      handler:{
                                        (action:UIAlertAction!) -> Void in
                                        // 処理
                                        print("キャンセル")
                                      })
                    
                    // actionを追加
                    alertController.addAction(action1)
                    alertController.addAction(action2)
                    alertController.addAction(action3)
                    alertController.addAction(action4)
                    alertController.addAction(cancelAction)
                    
                    // UIAlertControllerの起動
                    self.present(alertController, animated: true, completion: nil)
                    
                } else{
                    
                    let alertController:UIAlertController =
                        UIAlertController(title:"投稿の通報",
                                          message: "あてはまるものをお選びください",
                                          preferredStyle: .alert)
                    
                    
                    updateValue = FieldValue.arrayUnion([["uid": myid, "time": Date.timeIntervalSinceReferenceDate]])
                    let postRef = Firestore.firestore().collection("posts").document(postData.id)
                    
                    // Default のaction
                    let action1:UIAlertAction =
                        UIAlertAction(title: "不審な内容またはスパム投稿である",
                                      style: .default,
                                      handler:{
                                        (action:UIAlertAction!) -> Void in
                                        // 処理
                                        print("新しいmyidを加えます")
                                        
                                        postRef.updateData(["reports": updateValue])
                                        
                                        let banner = NotificationBanner(title: "通報しました", leftView: nil, rightView: nil, style: .info, colors: nil)
                                        banner.autoDismiss = false
                                        banner.dismissOnTap = true
                                        banner.show(queuePosition: .front, bannerPosition: .top, queue: .default, on: self.navigationController!)
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2, execute: {
                                            banner.dismiss()
                                            
                                            let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
                                            let viewController = storyboard.instantiateViewController(identifier: "ContactUs2") as! ContactUs2ViewController
                                            viewController.targetId = documentId
                                            viewController.targetUid = documentUid
                                            self.navigationController?.pushViewController(viewController, animated: true)
                                        })
                                      })
                    
                    let action2:UIAlertAction =
                        UIAlertAction(title: "誹謗中傷をしている",
                                      style: .default,
                                      handler:{
                                        (action:UIAlertAction!) -> Void in
                                        // 処理
                                        print("新しいmyidを加えます")
                                        
                                        postRef.updateData(["reports": updateValue])
                                        
                                        let banner = NotificationBanner(title: "通報しました", leftView: nil, rightView: nil, style: .info, colors: nil)
                                        banner.autoDismiss = false
                                        banner.dismissOnTap = true
                                        banner.show(queuePosition: .front, bannerPosition: .top, queue: .default, on: self.navigationController!)
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2, execute: {
                                            banner.dismiss()
                                            
                                            let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
                                            let viewController = storyboard.instantiateViewController(identifier: "ContactUs2") as! ContactUs2ViewController
                                            viewController.targetId = documentId
                                            viewController.targetUid = documentUid
                                            self.navigationController?.pushViewController(viewController, animated: true)
                                        })
                                      })
                    
                    let action3:UIAlertAction =
                        UIAlertAction(title: "不適切な内容を含んでいる",
                                      style: .default,
                                      handler:{
                                        (action:UIAlertAction!) -> Void in
                                        // 処理
                                        print("新しいmyidを加えます")
                                        
                                        postRef.updateData(["reports": updateValue])
                                        
                                        let banner = NotificationBanner(title: "通報しました", leftView: nil, rightView: nil, style: .info, colors: nil)
                                        banner.autoDismiss = false
                                        banner.dismissOnTap = true
                                        banner.show(queuePosition: .front, bannerPosition: .top, queue: .default, on: self.navigationController!)
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2, execute: {
                                            banner.dismiss()
                                            
                                            let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
                                            let viewController = storyboard.instantiateViewController(identifier: "ContactUs2") as! ContactUs2ViewController
                                            viewController.targetId = documentId
                                            viewController.targetUid = documentUid
                                            self.navigationController?.pushViewController(viewController, animated: true)
                                        })
                                      })
                    
                    let action4:UIAlertAction =
                        UIAlertAction(title: "自殺の意思をほのめかしている",
                                      style: .default,
                                      handler:{
                                        (action:UIAlertAction!) -> Void in
                                        // 処理
                                        print("新しいmyidを加えます")
                                        
                                        postRef.updateData(["reports": updateValue])
                                        
                                        let banner = NotificationBanner(title: "通報しました", leftView: nil, rightView: nil, style: .info, colors: nil)
                                        banner.autoDismiss = false
                                        banner.dismissOnTap = true
                                        banner.show(queuePosition: .front, bannerPosition: .top, queue: .default, on: self.navigationController!)
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2, execute: {
                                            banner.dismiss()
                                            
                                            let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
                                            let viewController = storyboard.instantiateViewController(identifier: "ContactUs2") as! ContactUs2ViewController
                                            viewController.targetId = documentId
                                            viewController.targetUid = documentUid
                                            self.navigationController?.pushViewController(viewController, animated: true)
                                        })
                                      })
                    
                    // Cancel のaction
                    let cancelAction:UIAlertAction =
                        UIAlertAction(title: "キャンセル",
                                      style: .cancel,
                                      handler:{
                                        (action:UIAlertAction!) -> Void in
                                        // 処理
                                        print("キャンセル")
                                      })
                    
                    // actionを追加
                    alertController.addAction(action1)
                    alertController.addAction(action2)
                    alertController.addAction(action3)
                    alertController.addAction(action4)
                    alertController.addAction(cancelAction)
                    
                    // UIAlertControllerの起動
                    self.present(alertController, animated: true, completion: nil)
                    
                }
            }
        })
        
        let myAction_2 = UIAlertAction(title: "投稿を非表示にする", style: UIAlertAction.Style.default, handler: {
            (action: UIAlertAction!) in
            
            let alert: UIAlertController = UIAlertController(title: "投稿を非表示", message: "本当にこの投稿を非表示にしてよろしいですか？", preferredStyle:  UIAlertController.Style.alert)
            
            let defaultAction: UIAlertAction = UIAlertAction(title: "非表示", style: UIAlertAction.Style.destructive, handler:{
                (action: UIAlertAction!) -> Void in
                
                print("非表示")
                
                // 配列からタップされたインデックスのデータを取り出す
                let postData = self.postArray[self.postRow(row: indexPath!.row)]
                
                if let myid = Auth.auth().currentUser?.uid {
                    // 更新データを作成する
                    var updateValue: FieldValue
                    print("新しいmyidを加えます")
                    updateValue = FieldValue.arrayUnion([["uid": myid, "time": Date.timeIntervalSinceReferenceDate]])
                    let postRef = Firestore.firestore().collection("posts").document(postData.id)
                    postRef.updateData(["blocks": updateValue])
                    let banner = NotificationBanner(title: "非表示にしました", leftView: nil, rightView: nil, style: .info, colors: nil)
                    banner.autoDismiss = false
                    banner.dismissOnTap = true
                    banner.show(queuePosition: .front, bannerPosition: .top, queue: .default, on: self.navigationController!)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.2, execute: {
                        banner.dismiss()
                    })
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
        
        let myAction_3 = UIAlertAction(title: "ユーザーをブロックする", style: UIAlertAction.Style.default, handler: {
            (action: UIAlertAction!) in
            
            let alert: UIAlertController = UIAlertController(title: "このユーザーの投稿は今後表示されなくなりますがよろしいでしょうか？", message: nil, preferredStyle:  UIAlertController.Style.alert)
            
            let defaultAction: UIAlertAction = UIAlertAction(title: "ブロック", style: UIAlertAction.Style.destructive, handler:{
                (action: UIAlertAction!) -> Void in
                
                print("ブロック")
                // 配列からタップされたインデックスのデータを取り出す
                let postData = self.postArray[self.postRow(row: indexPath!.row)]
                
                if let myid = Auth.auth().currentUser?.uid {
                    
                    let time = Date.timeIntervalSinceReferenceDate
                    
                    let banner = NotificationBanner(title: "ブロックしました", leftView: nil, rightView: nil, style: .info, colors: nil)
                    banner.autoDismiss = false
                    banner.dismissOnTap = true
                    banner.show(queuePosition: .front, bannerPosition: .top, queue: .default, on: self.navigationController!)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.2, execute: {
                        banner.dismiss()
                        self.refresh(sender: nil)
                    })
                    
                    var updateValue1: FieldValue
                    var updateValue2: FieldValue
                    var updateValue3: FieldValue
                    var updateValue4: FieldValue
                    
                    updateValue1 = FieldValue.arrayUnion([["uid": myid, "time": time]])
                    updateValue2 = FieldValue.arrayUnion([postData.uid])
                    updateValue3 = FieldValue.arrayUnion([myid])
                    updateValue4 = FieldValue.arrayUnion([["uid": postData.uid, "time": time]])
                    
                    let userRef1 = Firestore.firestore().collection("users").document(postData.uid)
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
                    
                    let blockedRef = Firestore.firestore().collection("blockedUsers").document(postData.uid)
                    
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
                    
                    print("arrayUnion")
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
        
        let cancelAction = UIAlertAction(title: "キャンセル", style: UIAlertAction.Style.cancel, handler: {
            (action: UIAlertAction!) in
            print("キャンセル")
        })
        // アクションを追加.
        myAlert.addAction(myAction_1)
        myAlert.addAction(myAction_2)
        myAlert.addAction(myAction_3)
        myAlert.addAction(cancelAction)
        self.present(myAlert, animated: true, completion: nil)
    }
    
    // セル内のボタンがタップされた時に呼ばれるメソッド
    @objc func handleButton(_ sender: UIButton, forEvent event: UIEvent) {
        print("DEBUG_PRINT: likeボタンがタップされました。")
        
        //ここで振動させる
        
        // タップされたセルのインデックスを求める
        let touch = event.allTouches?.first
        let point = touch!.location(in: self.tableView)
        let indexPath = tableView.indexPathForRow(at: point)
        
        // 配列からタップされたインデックスのデータを取り出す
        let postData = self.postArray[self.postRow(row: indexPath!.row)]
        
        // likesを更新する
        if let myid = Auth.auth().currentUser?.uid {
            // 更新データを作成する
            var updateValue: FieldValue
            if postData.isLiked {
                // すでにいいねをしている場合は、いいね解除のためmyidを取り除く更新データを作成
                updateValue = FieldValue.arrayRemove([["uid": myid, "time": postData.likedTime]])
            } else {
                // 今回新たにいいねを押した場合は、myidを追加する更新データを作成
                updateValue = FieldValue.arrayUnion([["uid": myid, "time": Date.timeIntervalSinceReferenceDate]])
            }
            // likesに更新データを書き込む
            let postRef = Firestore.firestore().collection("posts").document(postData.id)
            postRef.updateData(["likes": updateValue])
        }
    }
    
    @objc func bookmarkButton(_ sender: UIButton, forEvent event: UIEvent) {
        print("DEBUG_PRINT: likeボタンがタップされました。")
        
        //ここで振動させる
        
        let touch = event.allTouches?.first
        let point = touch!.location(in: self.tableView)
        guard let indexPath = tableView.indexPathForRow(at: point) else { return }
        
        // 配列からタップされたインデックスのデータを取り出す
        let postData = self.postArray[self.postRow(row: indexPath.row)]
        
        // bookmarksを更新する
        if let myid = Auth.auth().currentUser?.uid {
            // 更新データを作成する
            var updateValue: FieldValue
            if postData.isBookmarked {
                // すでにいいねをしている場合は、いいね解除のためmyidを取り除く更新データを作成
                updateValue = FieldValue.arrayRemove([["uid": myid, "time": postData.bookmarkedTime]])
            } else {
                // 今回新たにブックマークを押した場合は、myidを追加する更新データを作成
                updateValue = FieldValue.arrayUnion([["uid": myid, "time": Date.timeIntervalSinceReferenceDate]])
            }
            // bookmarksに更新データを書き込む
            let postRef = Firestore.firestore().collection("posts").document(postData.id)
            postRef.updateData(["bookmarks": updateValue])
        }
    }
    
    @objc func toComment(_ sender: UIButton, forEvent event: UIEvent) {
        // タップされたセルのインデックスを求める
        let touch = event.allTouches?.first
        let point = touch!.location(in: self.tableView)
        guard let indexPath = tableView.indexPathForRow(at: point) else { return }
        
        let storyboard = UIStoryboard.init(name: "ChatRoom", bundle: nil)
        let chatRoomViewController = storyboard.instantiateViewController(identifier: "ChatRoomViewController") as! ChatRoomViewController
        
        postdata = postArray[postRow(row: indexPath.row)]
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
        }
        
        navigationController?.pushViewController(chatRoomViewController, animated: true)
        //選択状態の解除
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}

// MARK: GADUnifiedNativeAdLoaderDelegate
extension Page2ViewController: GADUnifiedNativeAdLoaderDelegate {
    func adLoader(_ adLoader: GADAdLoader, didReceive nativeAd: GADUnifiedNativeAd) {
        if Constants.numberOfAds < nativeAds.count { nativeAds.removeAll() }
        nativeAds.append(nativeAd)
    }
    
    func adLoaderDidFinishLoading(_ adLoader: GADAdLoader) {
        tableView.reloadData()
    }
    
    func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: GADRequestError) {
        debugPrint(error.description)
    }
}


