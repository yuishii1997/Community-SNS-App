//
//  CategoryViewController.swift
//  Nomad-App
//
//  Created by yuishii on 2021/01/14.
//  Copyright © 2021 Yu Ishii. All rights reserved.
//
// 「おすすめ」画面

import UIKit
import Firebase
import NotificationBannerSwift
import SVProgressHUD

class CategoryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{
    
    @IBOutlet var tableView: UITableView!
    
    //var models = [Model]()
    
    private var refreshControl = UIRefreshControl()
    
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
    var post12: String = ""
    
    //ユーザーデータを格納する配列
    var userArray1: [UserData] = []
    var userArray2: [UserData] = []
    var userArray3: [UserData] = []
    var userArray4: [UserData] = []
    
    private var postdata: PostData?
    private var postdata2: PostData?
    private var postdata3: PostData?
    private var postdata4: PostData?
    private var postdata5: PostData?
    private var postdata6: PostData?
    private var postdata7: PostData?
    private var postdata8: PostData?
    
    // 投稿データを格納する配列
    var postArray1: [PostData] = []
    var postArray2: [PostData] = []
    var postArray3: [PostData] = []
    var postArray4: [PostData] = []
    var postArray5: [PostData] = []
    var postArray6: [PostData] = []
    var postArray7: [PostData] = []
    var postArray8: [PostData] = []
    var array1: [PostData] = []
    var array2: [PostData] = []
    var modifiedPostArray1: [PostData] = []
    var modifiedPostArray2: [PostData] = []
    var uidArray1: [String] = []
    var uidArray2: [String] = []
    var blockUserArray: [String] = []
    
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
    var listener10: ListenerRegistration!
    var listener11: ListenerRegistration!
    var listener12: ListenerRegistration!
    var listener_block: ListenerRegistration!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SVProgressHUD.setDefaultStyle(.custom)
        SVProgressHUD.setDefaultMaskType(.none)
        SVProgressHUD.setForegroundColor(.gray)
        SVProgressHUD.setBackgroundColor(.clear)
        SVProgressHUD.setBackgroundLayerColor(.clear)
        SVProgressHUD.show()
        
        self.tableView.separatorStyle = .none
        
        tableView.register(CollectionTableViewCell1.nib(), forCellReuseIdentifier: CollectionTableViewCell1.identifier)
        tableView.register(CollectionTableViewCell2.nib(), forCellReuseIdentifier: CollectionTableViewCell2.identifier)
        tableView.register(CollectionTableViewCell3.nib(), forCellReuseIdentifier: CollectionTableViewCell3.identifier)
        tableView.register(CollectionTableViewCell4.nib(), forCellReuseIdentifier: CollectionTableViewCell4.identifier)
        tableView.register(CollectionTableViewCell5.nib(), forCellReuseIdentifier: CollectionTableViewCell5.identifier)
        tableView.register(CollectionTableViewCell6.nib(), forCellReuseIdentifier: CollectionTableViewCell6.identifier)
        tableView.register(CollectionTableViewCell7.nib(), forCellReuseIdentifier: CollectionTableViewCell7.identifier)
        tableView.register(CollectionTableViewCell8.nib(), forCellReuseIdentifier: CollectionTableViewCell8.identifier)
        tableView.register(CollectionTableViewCell9.nib(), forCellReuseIdentifier: CollectionTableViewCell9.identifier)
        tableView.register(CollectionTableViewCell10.nib(), forCellReuseIdentifier: CollectionTableViewCell10.identifier)
        tableView.register(CollectionTableViewCell11.nib(), forCellReuseIdentifier: CollectionTableViewCell11.identifier)
        tableView.register(CollectionTableViewCell12.nib(), forCellReuseIdentifier: CollectionTableViewCell12.identifier)
        
        
        tableView.delegate = self
        tableView.dataSource = self
        
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        self.tabBarController?.tabBar.barTintColor = UIColor.white
        self.navigationController?.navigationBar.tintColor = UIColor.black
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.black]
        
        let nib1 = UINib(nibName: "Section1TableViewCell", bundle: nil)
        tableView.register(nib1, forCellReuseIdentifier: "Section1")
        let nib2 = UINib(nibName: "Section2TableViewCell", bundle: nil)
        tableView.register(nib2, forCellReuseIdentifier: "Section2")
        let nib3 = UINib(nibName: "Section3TableViewCell", bundle: nil)
        tableView.register(nib3, forCellReuseIdentifier: "Section3")
        let nib4 = UINib(nibName: "Section4TableViewCell", bundle: nil)
        tableView.register(nib4, forCellReuseIdentifier: "Section4")
        let nib5 = UINib(nibName: "Section5TableViewCell", bundle: nil)
        tableView.register(nib5, forCellReuseIdentifier: "Section5")
        let nib6 = UINib(nibName: "Section6TableViewCell", bundle: nil)
        tableView.register(nib6, forCellReuseIdentifier: "Section6")
        let nib7 = UINib(nibName: "Section7TableViewCell", bundle: nil)
        tableView.register(nib7, forCellReuseIdentifier: "Section7")
        let nib8 = UINib(nibName: "Section8TableViewCell", bundle: nil)
        tableView.register(nib8, forCellReuseIdentifier: "Section8")
        let nib9 = UINib(nibName: "Section9TableViewCell", bundle: nil)
        tableView.register(nib9, forCellReuseIdentifier: "Section9")
        let nib10 = UINib(nibName: "Section10TableViewCell", bundle: nil)
        tableView.register(nib10, forCellReuseIdentifier: "Section10")
        let nib11 = UINib(nibName: "Section11TableViewCell", bundle: nil)
        tableView.register(nib11, forCellReuseIdentifier: "Section11")
        let nib12 = UINib(nibName: "Section12TableViewCell", bundle: nil)
        tableView.register(nib12, forCellReuseIdentifier: "Section12")
        let nib13 = UINib(nibName: "Section13TableViewCell", bundle: nil)
        tableView.register(nib13, forCellReuseIdentifier: "Section13")
        let margin = UINib(nibName: "MarginTableViewCell", bundle: nil)
        tableView.register(margin, forCellReuseIdentifier: "Margin")
        
        
        if Auth.auth().currentUser != nil {
            if listener == nil {
                
                fetchBlockUsers { [weak self] result in
                    switch result {
                    case .success:
                        print("blockUserArray:\(self!.blockUserArray)")
                        self!.fetchPost1()
                        self!.fetchPost2()
                        self!.fetchPost3()
                        self!.fetchPost4()
                        
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
                listener_block.remove()
                listener_block = nil
                
                SVProgressHUD.dismiss()
                tableView.reloadData()
            }
        }
        
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
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let backBarButtonItem = UIBarButtonItem()
        backBarButtonItem.title = "Back"
        self.navigationItem.backBarButtonItem = backBarButtonItem
        self.navigationItem.title = "おすすめ"
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
                            self!.fetchPost5()
                        }
                        if ( self?.listener2 == nil ) {
                            self!.fetchPost6()
                        }
                        if ( self?.listener3 == nil ) {
                            self!.fetchPost7()
                        }
                        if ( self?.listener4 == nil ) {
                            self!.fetchPost8()
                        }
                        if ( self?.listener5 == nil ) {
                            self!.fetchPost9()
                        }
                        if ( self?.listener6 == nil ) {
                            self!.fetchPost10()
                        }
                        if ( self?.listener7 == nil ) {
                            self!.fetchPost11()
                        }
                        if ( self?.listener8 == nil ) {
                            self!.fetchPost12()
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
                listener_block.remove()
                listener_block = nil
                
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
        
        if ( self.listener_block != nil ){
            listener_block.remove()
            listener_block = nil
        }
        print("テーブルビューを閉じます")
    }
    
    @objc func refresh(sender: UIRefreshControl?) {
        
        if Auth.auth().currentUser != nil {
            
            
            fetchBlockUsers { [weak self] result in
                switch result {
                case .success:
                    
                    self!.fetchPost1()
                    self!.fetchPost2()
                    self!.fetchPost3()
                    self!.fetchPost4()
                    sender?.endRefreshing()
                case .failure(let error):
                    print(error.localizedDescription)
                    sender?.endRefreshing()
                }
            }
            
        }
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
    
    
    func fetchPost1() {
        
        let day = Date()
        let modifiedDate = Calendar.current.date(byAdding: .day, value: -14, to: day)!
        
        //トップユーザー
        let usersRef1 = Firestore.firestore().collection("users").whereField("deleted", isEqualTo: "no").order(by: "date", descending: true).whereField("date", isGreaterThanOrEqualTo: modifiedDate).whereField("bePrivate", isEqualTo: "off").whereField("type", isEqualTo: "private")
        usersRef1.getDocuments() { (querySnapshot, error) in
            if let error = error {
                print("DEBUG_PRINT: snapshotの取得が失敗しました。 \(error)")
                return
            } else {
                self.userArray1 = querySnapshot!.documents.compactMap { document in
                    print("DEBUG_PRINT: document取得 \(document.documentID)")
                    let userData = UserData(document: document)
                    userData.id = document.documentID
                    if self.blockUserArray.contains(userData.uid) == true {
                        return nil
                    } else {
                        return userData
                    }
                }
                self.userArray1.sort { $0.follower.count > $1.follower.count }
                self.post1 = "exist"
                if self.post1 == "exist" && self.post2 == "exist" && self.post3 == "exist" && self.post4 == "exist" && self.post5 == "exist" && self.post6 == "exist" && self.post7 == "exist" && self.post8 == "exist" && self.post9 == "exist" && self.post10 == "exist" && self.post11 == "exist" && self.post12 == "exist" {
                    SVProgressHUD.dismiss()
                }
                self.tableView.reloadData()
            }
        }
    }
    
    func fetchPost2() {
        
        let day = Date()
        
        let modifiedDate = Calendar.current.date(byAdding: .day, value: -14, to: day)!
        
        let usersRef2 = Firestore.firestore().collection("users").whereField("deleted", isEqualTo: "no").order(by: "date", descending: true).whereField("date", isGreaterThanOrEqualTo: modifiedDate).whereField("bePrivate", isEqualTo: "off").whereField("type", isEqualTo: "community")
        usersRef2.getDocuments() { (querySnapshot, error) in
            if let error = error {
                print("DEBUG_PRINT: snapshotの取得が失敗しました。 \(error)")
                return
            } else {
                self.userArray2 = querySnapshot!.documents.compactMap { document in
                    //print("DEBUG_PRINT: document取得 \(document.documentID)")
                    let userData = UserData(document: document)
                    userData.id = document.documentID
                    if self.blockUserArray.contains(userData.uid) == true {
                        return nil
                    } else {
                        return userData
                    }
                }
                self.userArray2.sort { $0.follower.count > $1.follower.count }
                self.post2 = "exist"
                if self.post1 == "exist" && self.post2 == "exist" && self.post3 == "exist" && self.post4 == "exist" && self.post5 == "exist" && self.post6 == "exist" && self.post7 == "exist" && self.post8 == "exist" && self.post9 == "exist" && self.post10 == "exist" && self.post11 == "exist" && self.post12 == "exist" {
                    SVProgressHUD.dismiss()
                }
                self.tableView.reloadData()
            }
        }
    }
    
    func fetchPost3() {
        
        //人気のユーザー
        let usersRef3 = Firestore.firestore().collection("users").whereField("deleted", isEqualTo: "no").order(by: "date", descending: true).whereField("bePrivate", isEqualTo: "off").whereField("type", isEqualTo: "private")
        usersRef3.getDocuments() { (querySnapshot, error) in
            if let error = error {
                print("DEBUG_PRINT: snapshotの取得が失敗しました。 \(error)")
                return
            } else {
                self.userArray3 = querySnapshot!.documents.compactMap { document in
                    print("DEBUG_PRINT: document取得 \(document.documentID)")
                    let userData = UserData(document: document)
                    userData.id = document.documentID
                    if self.blockUserArray.contains(userData.uid) == true {
                        return nil
                    } else {
                        return userData
                    }
                }
                self.userArray3.sort { $0.follower.count > $1.follower.count }
                self.post3 = "exist"
                if self.post1 == "exist" && self.post2 == "exist" && self.post3 == "exist" && self.post4 == "exist" && self.post5 == "exist" && self.post6 == "exist" && self.post7 == "exist" && self.post8 == "exist" && self.post9 == "exist" && self.post10 == "exist" && self.post11 == "exist" && self.post12 == "exist" {
                    SVProgressHUD.dismiss()
                }
                self.tableView.reloadData()
            }
        }
    }
    
    func fetchPost4() {
        
        let usersRef4 = Firestore.firestore().collection("users").whereField("deleted", isEqualTo: "no").order(by: "date", descending: true).whereField("bePrivate", isEqualTo: "off").whereField("type", isEqualTo: "community")
        usersRef4.getDocuments() { (querySnapshot, error) in
            if let error = error {
                print("DEBUG_PRINT: snapshotの取得が失敗しました。 \(error)")
                return
            } else {
                self.userArray4 = querySnapshot!.documents.compactMap { document in
                    let userData = UserData(document: document)
                    userData.id = document.documentID
                    if self.blockUserArray.contains(userData.uid) == true {
                        return nil
                    } else {
                        return userData
                    }
                }
                self.userArray4.sort { $0.follower.count > $1.follower.count }
                self.post4 = "exist"
                if self.post1 == "exist" && self.post2 == "exist" && self.post3 == "exist" && self.post4 == "exist" && self.post5 == "exist" && self.post6 == "exist" && self.post7 == "exist" && self.post8 == "exist" && self.post9 == "exist" && self.post10 == "exist" && self.post11 == "exist" && self.post12 == "exist" {
                    SVProgressHUD.dismiss()
                }
                self.tableView.reloadData()
            }
        }
    }
    
    private func fetchPost5() {
        
        let day = Date()
        let modifiedDate = Calendar.current.date(byAdding: .day, value: -7, to: day)!
        
        //話題の投稿
        let postsRef1 = Firestore.firestore().collection("posts").whereField("deleted", isEqualTo: "no").whereField("date", isGreaterThanOrEqualTo: modifiedDate).whereField("bePrivate", isEqualTo: "off")
        listener1 = postsRef1.addSnapshotListener() { [weak self] querySnapshot, error in
            if let error = error {
                print("DEBUG_PRINT: snapshotの取得が失敗しました。 \(error)")
                return
            } else {
                self?.postArray1 = querySnapshot!.documents.compactMap { document in
                    //print("DEBUG_PRINT: document取得 \(document.documentID)")
                    let postData = PostData(document: document)
                    postData.id = document.documentID
                    if self?.blockUserArray.contains(postData.uid) == true || postData.isReported == true{
                        return nil
                    } else {
                        return postData
                    }
                }
                
                self?.postArray1.sort { $0.viewer.count > $1.viewer.count }
                self?.postArray1.sort { $0.bookmarks.count > $1.bookmarks.count }
                self?.postArray1.sort { $0.likes.count > $1.likes.count }
                self?.postArray1.sort { $0.allComments.count > $1.allComments.count }
                self?.postArray1.sort { $0.comments.count > $1.comments.count }
                self?.post5 = "exist"
                if self?.post1 == "exist" && self?.post2 == "exist" && self?.post3 == "exist" && self?.post4 == "exist" && self?.post5 == "exist" && self?.post6 == "exist" && self?.post7 == "exist" && self?.post8 == "exist" && self?.post9 == "exist" && self?.post10 == "exist" && self?.post11 == "exist" && self?.post12 == "exist" {
                    SVProgressHUD.dismiss()
                }
                self?.tableView.reloadData()
            }
        }
    }
    
    func fetchPost6() {
        
        let day = Date()
        let modifiedDate = Calendar.current.date(byAdding: .day, value: -1, to: day)!
        
        //新着の投稿
        //modifiedDate2で1日以内の投稿に限定しているので、投稿がないとpostArray1が表示されてしまうことに注意
        let postsRef2 = Firestore.firestore().collection("posts").whereField("deleted", isEqualTo: "no").whereField("date", isGreaterThanOrEqualTo: modifiedDate).whereField("bePrivate", isEqualTo: "off")
        self.listener2 = postsRef2.addSnapshotListener() { [weak self] querySnapshot, error in
            if let error = error {
                print("DEBUG_PRINT: snapshotの取得が失敗しました。 \(error)")
                return
            } else {
                self?.postArray2 = querySnapshot!.documents.compactMap { document in
                    //print("DEBUG_PRINT: document取得 \(document.documentID)")
                    let postData = PostData(document: document)
                    postData.id = document.documentID
                    if self?.blockUserArray.contains(postData.uid) == true || postData.isReported == true {
                        return nil
                    } else {
                        return postData
                    }
                }
                self?.postArray2.sort { $0.allComments.count > $1.allComments.count }
                self?.postArray2.sort { $0.comments.count > $1.comments.count }
                self?.postArray2.sort { $0.likes.count > $1.likes.count }
                self?.postArray2.sort { $0.bookmarks.count > $1.bookmarks.count }
                self?.postArray2.sort { $0.viewer.count > $1.viewer.count }
                self?.post6 = "exist"
                if self?.post1 == "exist" && self?.post2 == "exist" && self?.post3 == "exist" && self?.post4 == "exist" && self?.post5 == "exist" && self?.post6 == "exist" && self?.post7 == "exist" && self?.post8 == "exist" && self?.post9 == "exist" && self?.post10 == "exist" && self?.post11 == "exist" && self?.post12 == "exist" {
                    SVProgressHUD.dismiss()
                }
                self?.tableView.reloadData()
            }
        }
    }
    
    func fetchPost7() {
        
        let day = Date()
        let modifiedDate = Calendar.current.date(byAdding: .day, value: -7, to: day)!
        
        //高評価の投稿
        let postsRef3 = Firestore.firestore().collection("posts").whereField("deleted", isEqualTo: "no").whereField("date", isGreaterThanOrEqualTo: modifiedDate).whereField("bePrivate", isEqualTo: "off")
        self.listener3 = postsRef3.addSnapshotListener() { [weak self] querySnapshot, error in
            if let error = error {
                print("DEBUG_PRINT: snapshotの取得が失敗しました。 \(error)")
                return
            } else {
                self?.postArray3 = querySnapshot!.documents.compactMap { document in
                    //print("DEBUG_PRINT: document取得 \(document.documentID)")
                    let postData = PostData(document: document)
                    postData.id = document.documentID
                    if self?.blockUserArray.contains(postData.uid) == true || postData.isReported == true {
                        return nil
                    } else {
                        return postData
                    }
                }
                self?.postArray3.sort { $0.allComments.count > $1.allComments.count }
                self?.postArray3.sort { $0.comments.count > $1.comments.count }
                self?.postArray3.sort { $0.viewer.count > $1.viewer.count }
                self?.postArray3.sort { $0.bookmarks.count > $1.bookmarks.count }
                self?.postArray3.sort { $0.likes.count > $1.likes.count }
                self?.post7 = "exist"
                if self?.post1 == "exist" && self?.post2 == "exist" && self?.post3 == "exist" && self?.post4 == "exist" && self?.post5 == "exist" && self?.post6 == "exist" && self?.post7 == "exist" && self?.post8 == "exist" && self?.post9 == "exist" && self?.post10 == "exist" && self?.post11 == "exist" && self?.post12 == "exist" {
                    SVProgressHUD.dismiss()
                }
                self?.tableView.reloadData()
            }
        }
    }
    
    func fetchPost8() {
        
        let day = Date()
        let modifiedDate = Calendar.current.date(byAdding: .day, value: -7, to: day)!
        
        //よく閲覧されている投稿
        let postsRef4 = Firestore.firestore().collection("posts").whereField("deleted", isEqualTo: "no").whereField("date", isGreaterThanOrEqualTo: modifiedDate).whereField("bePrivate", isEqualTo: "off")
        self.listener4 = postsRef4.addSnapshotListener() { [weak self] querySnapshot, error in
            if let error = error {
                print("DEBUG_PRINT: snapshotの取得が失敗しました。 \(error)")
                return
            } else {
                self?.postArray4 = querySnapshot!.documents.compactMap { document in
                    //print("DEBUG_PRINT: document取得 \(document.documentID)")
                    let postData = PostData(document: document)
                    postData.id = document.documentID
                    if self?.blockUserArray.contains(postData.uid) == true || postData.isReported == true {
                        return nil
                    } else {
                        return postData
                    }
                }
                self?.postArray4.sort { $0.allComments.count > $1.allComments.count }
                self?.postArray4.sort { $0.comments.count > $1.comments.count }
                self?.postArray4.sort { $0.likes.count > $1.likes.count }
                self?.postArray4.sort { $0.bookmarks.count > $1.bookmarks.count }
                self?.postArray4.sort { $0.viewer.count > $1.viewer.count }
                self?.post8 = "exist"
                if self?.post1 == "exist" && self?.post2 == "exist" && self?.post3 == "exist" && self?.post4 == "exist" && self?.post5 == "exist" && self?.post6 == "exist" && self?.post7 == "exist" && self?.post8 == "exist" && self?.post9 == "exist" && self?.post10 == "exist" && self?.post11 == "exist" && self?.post12 == "exist" {
                    SVProgressHUD.dismiss()
                }
                self?.tableView.reloadData()
            }
        }
    }
    
    func fetchPost9() {
        
        let day = Date()
        let modifiedDate = Calendar.current.date(byAdding: .day, value: -1, to: day)!
        
        //日間ランキング
        let postsRef5 = Firestore.firestore().collection("posts").whereField("deleted", isEqualTo: "no").whereField("date", isGreaterThanOrEqualTo: modifiedDate).whereField("bePrivate", isEqualTo: "off")
        self.listener5 = postsRef5.addSnapshotListener() { [weak self] querySnapshot, error in
            if let error = error {
                print("DEBUG_PRINT: snapshotの取得が失敗しました。 \(error)")
                return
            } else {
                self?.postArray5 = querySnapshot!.documents.compactMap { document in
                    //print("DEBUG_PRINT: document取得 \(document.documentID)")
                    let postData = PostData(document: document)
                    postData.id = document.documentID
                    if self?.blockUserArray.contains(postData.uid) == true || postData.isReported == true {
                        return nil
                    } else {
                        return postData
                    }
                }
                self?.postArray5.sort { $0.allComments.count > $1.allComments.count }
                self?.postArray5.sort { $0.comments.count > $1.comments.count }
                self?.postArray5.sort { $0.viewer.count > $1.viewer.count }
                self?.postArray5.sort { $0.bookmarks.count > $1.bookmarks.count }
                self?.postArray5.sort { $0.likes.count > $1.likes.count }
                self?.post9 = "exist"
                if self?.post1 == "exist" && self?.post2 == "exist" && self?.post3 == "exist" && self?.post4 == "exist" && self?.post5 == "exist" && self?.post6 == "exist" && self?.post7 == "exist" && self?.post8 == "exist" && self?.post9 == "exist" && self?.post10 == "exist" && self?.post11 == "exist" && self?.post12 == "exist" {
                    SVProgressHUD.dismiss()
                }
                self?.tableView.reloadData()
            }
        }
    }
    
    func fetchPost10() {
        
        let day = Date()
        let modifiedDate = Calendar.current.date(byAdding: .day, value: -7, to: day)!
        
        //週間ランキング
        let postsRef6 = Firestore.firestore().collection("posts").whereField("deleted", isEqualTo: "no").whereField("date", isGreaterThanOrEqualTo: modifiedDate).whereField("bePrivate", isEqualTo: "off")
        self.listener6 = postsRef6.addSnapshotListener() { [weak self] querySnapshot, error in
            if let error = error {
                print("DEBUG_PRINT: snapshotの取得が失敗しました。 \(error)")
                return
            } else {
                self?.postArray6 = querySnapshot!.documents.compactMap { document in
                    //print("DEBUG_PRINT: document取得 \(document.documentID)")
                    let postData = PostData(document: document)
                    postData.id = document.documentID
                    if self?.blockUserArray.contains(postData.uid) == true || postData.isReported == true {
                        return nil
                    } else {
                        return postData
                    }
                }
                self?.postArray6.sort { $0.allComments.count > $1.allComments.count }
                self?.postArray6.sort { $0.comments.count > $1.comments.count }
                self?.postArray6.sort { $0.viewer.count > $1.viewer.count }
                self?.postArray6.sort { $0.bookmarks.count > $1.bookmarks.count }
                self?.postArray6.sort { $0.likes.count > $1.likes.count }
                self?.post10 = "exist"
                if self?.post1 == "exist" && self?.post2 == "exist" && self?.post3 == "exist" && self?.post4 == "exist" && self?.post5 == "exist" && self?.post6 == "exist" && self?.post7 == "exist" && self?.post8 == "exist" && self?.post9 == "exist" && self?.post10 == "exist" && self?.post11 == "exist" && self?.post12 == "exist" {
                    SVProgressHUD.dismiss()
                }
                self?.tableView.reloadData()
            }
        }
    }
    
    func fetchPost11() {
        
        let day = Date()
        let modifiedDate = Calendar.current.date(byAdding: .day, value: -30, to: day)!
        
        //月間ランキング
        let postsRef7 = Firestore.firestore().collection("posts").whereField("deleted", isEqualTo: "no").whereField("date", isGreaterThanOrEqualTo: modifiedDate).whereField("bePrivate", isEqualTo: "off")
        self.listener7 = postsRef7.addSnapshotListener() { [weak self] querySnapshot, error in
            if let error = error {
                print("DEBUG_PRINT: snapshotの取得が失敗しました。 \(error)")
                return
            } else {
                self?.postArray7 = querySnapshot!.documents.compactMap { document in
                    //print("DEBUG_PRINT: document取得 \(document.documentID)")
                    let postData = PostData(document: document)
                    postData.id = document.documentID
                    if self?.blockUserArray.contains(postData.uid) == true || postData.isReported == true {
                        return nil
                    } else {
                        return postData
                    }
                }
                self?.postArray7.sort { $0.allComments.count > $1.allComments.count }
                self?.postArray7.sort { $0.comments.count > $1.comments.count }
                self?.postArray7.sort { $0.viewer.count > $1.viewer.count }
                self?.postArray7.sort { $0.bookmarks.count > $1.bookmarks.count }
                self?.postArray7.sort { $0.likes.count > $1.likes.count }
                self?.post11 = "exist"
                if self?.post1 == "exist" && self?.post2 == "exist" && self?.post3 == "exist" && self?.post4 == "exist" && self?.post5 == "exist" && self?.post6 == "exist" && self?.post7 == "exist" && self?.post8 == "exist" && self?.post9 == "exist" && self?.post10 == "exist" && self?.post11 == "exist" && self?.post12 == "exist" {
                    SVProgressHUD.dismiss()
                }
                self?.tableView.reloadData()
            }
        }
    }
    
    func fetchPost12() {
        
        //総合ランキング
        let postsRef8 = Firestore.firestore().collection("posts").whereField("deleted", isEqualTo: "no").whereField("bePrivate", isEqualTo: "off")
        self.listener8 = postsRef8.addSnapshotListener() { [weak self] querySnapshot, error in
            if let error = error {
                print("DEBUG_PRINT: snapshotの取得が失敗しました。 \(error)")
                return
            } else {
                self?.postArray8 = querySnapshot!.documents.compactMap { document in
                    //print("DEBUG_PRINT: document取得 \(document.documentID)")
                    let postData = PostData(document: document)
                    postData.id = document.documentID
                    if self?.blockUserArray.contains(postData.uid) == true || postData.isReported == true {
                        return nil
                    } else {
                        return postData
                    }
                }
                self?.postArray8.sort { $0.allComments.count > $1.allComments.count }
                self?.postArray8.sort { $0.comments.count > $1.comments.count }
                self?.postArray8.sort { $0.viewer.count > $1.viewer.count }
                self?.postArray8.sort { $0.bookmarks.count > $1.bookmarks.count }
                self?.postArray8.sort { $0.likes.count > $1.likes.count }
                self?.post12 = "exist"
                if self?.post1 == "exist" && self?.post2 == "exist" && self?.post3 == "exist" && self?.post4 == "exist" && self?.post5 == "exist" && self?.post6 == "exist" && self?.post7 == "exist" && self?.post8 == "exist" && self?.post9 == "exist" && self?.post10 == "exist" && self?.post11 == "exist" && self?.post12 == "exist" {
                    SVProgressHUD.dismiss()
                }
                self?.tableView.reloadData()
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 25
    }
    
    //何行か
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Section1", for: indexPath) as! Section1TableViewCell
            cell.selectionStyle = .none
            return cell
        }else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: CollectionTableViewCell1.identifier, for: indexPath) as! CollectionTableViewCell1
            cell.collectionView.tag = 1
            cell.cell1Delegate = self
            cell.selectionStyle = .none
            print("modifiedPostArray1.count:\(modifiedPostArray1.count)")
            print("uidArray1.count:\(uidArray1.count)")
            print("array2.count:\(array1.count)")
            print("userArray1.count:\(userArray1.count)")
            if userArray1.count != 0 {
                cell.configure1(with: userArray1)
                return cell
            }else{
                return cell
            }
        }else if indexPath.section == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Section2", for: indexPath) as! Section2TableViewCell
            cell.selectionStyle = .none
            return cell
        }else if indexPath.section == 3 {
            let cell = tableView.dequeueReusableCell(withIdentifier: CollectionTableViewCell2.identifier, for: indexPath) as! CollectionTableViewCell2
            cell.collectionView.tag = 2
            cell.cell2Delegate = self
            print("modifiedPostArray2.count:\(modifiedPostArray2.count)")
            print("uidArray2.count:\(uidArray2.count)")
            print("array2.count:\(array2.count)")
            print("userArray2.count:\(userArray2.count)")
            cell.selectionStyle = .none
            if userArray2.count != 0 {
                cell.configure2(with: userArray2)
                return cell
            }else{
                return cell
            }
        }else if indexPath.section == 4 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Section3", for: indexPath) as! Section3TableViewCell
            cell.selectionStyle = .none
            return cell
        }else if indexPath.section == 5 {
            let cell = tableView.dequeueReusableCell(withIdentifier: CollectionTableViewCell3.identifier, for: indexPath) as! CollectionTableViewCell3
            cell.collectionView.tag = 3
            cell.cell3Delegate = self
            cell.selectionStyle = .none
            if postArray1.count != 0 {
                cell.configure3(with: postArray1)
                return cell
            }else{
                return cell
            }
        }else if indexPath.section == 6 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Section4", for: indexPath) as! Section4TableViewCell
            cell.selectionStyle = .none
            return cell
        }else if indexPath.section == 7 {
            let cell = tableView.dequeueReusableCell(withIdentifier: CollectionTableViewCell4.identifier, for: indexPath) as! CollectionTableViewCell4
            cell.collectionView.tag = 4
            cell.cell4Delegate = self
            cell.selectionStyle = .none
            if postArray2.count != 0 {
                cell.configure4(with: postArray2)
                return cell
            }else{
                return cell
            }
        }else if indexPath.section == 8 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Section5", for: indexPath) as! Section5TableViewCell
            cell.selectionStyle = .none
            return cell
        }else if indexPath.section == 9 {
            let cell = tableView.dequeueReusableCell(withIdentifier: CollectionTableViewCell5.identifier, for: indexPath) as! CollectionTableViewCell5
            cell.collectionView.tag = 5
            cell.cell5Delegate = self
            cell.selectionStyle = .none
            if postArray3.count != 0 {
                cell.configure5(with: postArray3)
                return cell
            }else{
                return cell
            }
        }else if indexPath.section == 10 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Section6", for: indexPath) as! Section6TableViewCell
            cell.selectionStyle = .none
            return cell
        }else if indexPath.section == 11 {
            let cell = tableView.dequeueReusableCell(withIdentifier: CollectionTableViewCell6.identifier, for: indexPath) as! CollectionTableViewCell6
            cell.collectionView.tag = 6
            cell.cell6Delegate = self
            cell.selectionStyle = .none
            if postArray4.count != 0 {
                cell.configure6(with: postArray4)
                return cell
            }else{
                return cell
            }
        }else if indexPath.section == 12 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Section7", for: indexPath) as! Section7TableViewCell
            cell.selectionStyle = .none
            return cell
        }else if indexPath.section == 13 {
            let cell = tableView.dequeueReusableCell(withIdentifier: CollectionTableViewCell7.identifier, for: indexPath) as! CollectionTableViewCell7
            cell.collectionView.tag = 7
            cell.cell7Delegate = self
            cell.selectionStyle = .none
            if userArray3.count != 0 {
                cell.configure7(with: userArray3)
                return cell
            }else{
                return cell
            }
        }else if indexPath.section == 14 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Section8", for: indexPath) as! Section8TableViewCell
            cell.selectionStyle = .none
            return cell
        }else if indexPath.section == 15 {
            let cell = tableView.dequeueReusableCell(withIdentifier: CollectionTableViewCell8.identifier, for: indexPath) as! CollectionTableViewCell8
            cell.collectionView.tag = 8
            cell.cell8Delegate = self
            cell.selectionStyle = .none
            if userArray4.count != 0 {
                cell.configure8(with: userArray4)
                return cell
            }else{
                return cell
            }
        }else if indexPath.section == 16 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Section9", for: indexPath) as! Section9TableViewCell
            cell.selectionStyle = .none
            return cell
        }else if indexPath.section == 17 {
            let cell = tableView.dequeueReusableCell(withIdentifier: CollectionTableViewCell9.identifier, for: indexPath) as! CollectionTableViewCell9
            cell.collectionView.tag = 9
            cell.cell9Delegate = self
            cell.selectionStyle = .none
            if postArray5.count != 0 {
                cell.configure9(with: postArray5)
                return cell
            }else{
                return cell
            }
        }else if indexPath.section == 18 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Section10", for: indexPath) as! Section10TableViewCell
            cell.selectionStyle = .none
            return cell
        }else if indexPath.section == 19 {
            let cell = tableView.dequeueReusableCell(withIdentifier: CollectionTableViewCell10.identifier, for: indexPath) as! CollectionTableViewCell10
            cell.collectionView.tag = 10
            cell.cell10Delegate = self
            cell.selectionStyle = .none
            if postArray6.count != 0 {
                cell.configure10(with: postArray6)
                return cell
            }else{
                return cell
            }
        }else if indexPath.section == 20 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Section11", for: indexPath) as! Section11TableViewCell
            cell.selectionStyle = .none
            return cell
        }else if indexPath.section == 21 {
            let cell = tableView.dequeueReusableCell(withIdentifier: CollectionTableViewCell11.identifier, for: indexPath) as! CollectionTableViewCell11
            cell.collectionView.tag = 11
            cell.cell11Delegate = self
            cell.selectionStyle = .none
            if postArray7.count != 0 {
                cell.configure11(with: postArray7)
                return cell
            }else{
                return cell
            }
        }else if indexPath.section == 22 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Section12", for: indexPath) as! Section12TableViewCell
            cell.selectionStyle = .none
            return cell
        }else if indexPath.section == 23 {
            let cell = tableView.dequeueReusableCell(withIdentifier: CollectionTableViewCell12.identifier, for: indexPath) as! CollectionTableViewCell12
            cell.collectionView.tag = 12
            cell.cell12Delegate = self
            cell.selectionStyle = .none
            if postArray8.count != 0 {
                cell.configure12(with: postArray8)
                return cell
            }else{
                return cell
            }
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "Margin", for: indexPath) as! MarginTableViewCell
            cell.selectionStyle = .none
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            
            return 55
            
        }else if indexPath.section == 1 {
            
            return 177
            
            
        }else if indexPath.section == 2 {
            
            return 55
            
        }else if indexPath.section == 3 {
            
            return 177
            
        }else if indexPath.section == 4 {
            
            return 55
            
        }else if indexPath.section == 5 {
            
            return 210
            
        }else if indexPath.section == 6 {
            
            return 55
            
        }else if indexPath.section == 7 {
            
            return 210
            
        }else if indexPath.section == 8 {
            
            return 55
            
        }else if indexPath.section == 9 {
            
            return 210
            
        }else if indexPath.section == 10 {
            
            return 55
            
        }else if indexPath.section == 11 {
            
            return 210
            
        }else if indexPath.section == 12 {
            
            
            return 55
            
        }else if indexPath.section == 13 {
            
            return 177
            
            
        }else if indexPath.section == 14 {
            
            return 55
            
        }else if indexPath.section == 15 {
            
            return 177
            
        }else if indexPath.section == 16 {
            
            return 55
            
        }else if indexPath.section == 17 {
            
            return 210
            
            
        }else if indexPath.section == 18 {
            
            return 55
            
        }else if indexPath.section == 19 {
            
            return 210
            
        }else if indexPath.section == 20 {
            
            return 55
            
        }else if indexPath.section == 21 {
            
            return 210
            
        }else if indexPath.section == 22 {
            
            return 55
            
        }else if indexPath.section == 23 {
            
            return 210
            
        }else{
            return 30
        }
    }
}

//struct Model {
//    let text: String
//    let imageName: String
//
//    init(text: String, imageName: String) {
//        self.text = text
//        self.imageName = imageName
//    }
//}

extension CategoryViewController : CollectionTableViewCell1Delegate {
    func onCollectoinViewCell1DidSelect(tag: Int, indexPath: IndexPath) {
        
        if tag == 1 {
            let postdata = userArray1[indexPath.row]
            let uid = postdata.uid
            let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
            let baseViewController = storyboard.instantiateViewController(identifier: "Profile") as! BaseViewController
            baseViewController.userID = uid
            baseViewController.type = "private"
            //コメント画面にPush遷移
            navigationController?.pushViewController(baseViewController, animated: true)
        }
    }
}

extension CategoryViewController : CollectionTableViewCell2Delegate {
    func onCollectoinViewCell2DidSelect(tag: Int, indexPath: IndexPath) {
        
        if tag == 2 {
            let postdata = userArray2[indexPath.row]
            let uid = postdata.uid
            let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
            let baseViewController = storyboard.instantiateViewController(identifier: "Profile") as! BaseViewController
            baseViewController.userID = uid
            baseViewController.type = "community"
            //コメント画面にPush遷移
            navigationController?.pushViewController(baseViewController, animated: true)
        }
    }
}

extension CategoryViewController : CollectionTableViewCell3Delegate {
    func onCollectoinViewCell3DidSelect(tag: Int, indexPath: IndexPath) {
        
        if tag == 3 {
            print("collectionView.tag == 3 Selected Cell: (indexPath.row \(indexPath.row)")
            
            let storyboard = UIStoryboard.init(name: "ChatRoom", bundle: nil)
            let chatRoomViewController = storyboard.instantiateViewController(identifier: "ChatRoomViewController") as! ChatRoomViewController
            postdata = self.postArray1[indexPath.row]
            //postdataをChatRoomViewControllerに渡す
            chatRoomViewController.postdata = postdata
            navigationController?.pushViewController(chatRoomViewController, animated: true)
            
        }
    }
}

extension CategoryViewController : CollectionTableViewCell4Delegate {
    func onCollectoinViewCell4DidSelect(tag: Int, indexPath: IndexPath) {
        
        if tag == 4 {
            print("collectionView.tag == 4 Selected Cell: (indexPath.row \(indexPath.row)")
            
            let storyboard = UIStoryboard.init(name: "ChatRoom", bundle: nil)
            let chatRoomViewController = storyboard.instantiateViewController(identifier: "ChatRoomViewController") as! ChatRoomViewController
            postdata = self.postArray2[indexPath.row]
            //postdataをChatRoomViewControllerに渡す
            chatRoomViewController.postdata = postdata
            navigationController?.pushViewController(chatRoomViewController, animated: true)
            
        }
    }
}

extension CategoryViewController : CollectionTableViewCell5Delegate {
    func onCollectoinViewCell5DidSelect(tag: Int, indexPath: IndexPath) {
        
        if tag == 5 {
            print("collectionView.tag == 5 Selected Cell: (indexPath.row \(indexPath.row)")
            
            let storyboard = UIStoryboard.init(name: "ChatRoom", bundle: nil)
            let chatRoomViewController = storyboard.instantiateViewController(identifier: "ChatRoomViewController") as! ChatRoomViewController
            postdata = self.postArray3[indexPath.row]
            //postdataをChatRoomViewControllerに渡す
            chatRoomViewController.postdata = postdata
            navigationController?.pushViewController(chatRoomViewController, animated: true)
            
        }
    }
}

extension CategoryViewController : CollectionTableViewCell6Delegate {
    func onCollectoinViewCell6DidSelect(tag: Int, indexPath: IndexPath) {
        
        if tag == 6 {
            print("collectionView.tag == 6 Selected Cell: (indexPath.row \(indexPath.row)")
            
            let storyboard = UIStoryboard.init(name: "ChatRoom", bundle: nil)
            let chatRoomViewController = storyboard.instantiateViewController(identifier: "ChatRoomViewController") as! ChatRoomViewController
            postdata = self.postArray4[indexPath.row]
            //postdataをChatRoomViewControllerに渡す
            chatRoomViewController.postdata = postdata
            navigationController?.pushViewController(chatRoomViewController, animated: true)
            
        }
    }
}

extension CategoryViewController : CollectionTableViewCell7Delegate {
    func onCollectoinViewCell7DidSelect(tag: Int, indexPath: IndexPath) {
        
        if tag == 7 {
            let postdata = userArray3[indexPath.row]
            let uid = postdata.uid
            let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
            let baseViewController = storyboard.instantiateViewController(identifier: "Profile") as! BaseViewController
            baseViewController.userID = uid
            baseViewController.type = "private"
            //コメント画面にPush遷移
            navigationController?.pushViewController(baseViewController, animated: true)
        }
    }
}

extension CategoryViewController : CollectionTableViewCell8Delegate {
    func onCollectoinViewCell8DidSelect(tag: Int, indexPath: IndexPath) {
        
        if tag == 8 {
            let postdata = userArray4[indexPath.row]
            let uid = postdata.uid
            let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
            let baseViewController = storyboard.instantiateViewController(identifier: "Profile") as! BaseViewController
            baseViewController.userID = uid
            //コメント画面にPush遷移
            navigationController?.pushViewController(baseViewController, animated: true)
        }
    }
}

extension CategoryViewController : CollectionTableViewCell9Delegate {
    func onCollectoinViewCell9DidSelect(tag: Int, indexPath: IndexPath) {
        
        if tag == 9 {
            print("collectionView.tag == 9 Selected Cell: (indexPath.row \(indexPath.row)")
            
            let storyboard = UIStoryboard.init(name: "ChatRoom", bundle: nil)
            let chatRoomViewController = storyboard.instantiateViewController(identifier: "ChatRoomViewController") as! ChatRoomViewController
            postdata = self.postArray5[indexPath.row]
            //postdataをChatRoomViewControllerに渡す
            chatRoomViewController.postdata = postdata
            navigationController?.pushViewController(chatRoomViewController, animated: true)
            
        }
    }
}

extension CategoryViewController : CollectionTableViewCell10Delegate {
    func onCollectoinViewCell10DidSelect(tag: Int, indexPath: IndexPath) {
        
        if tag == 10 {
            print("collectionView.tag == 10 Selected Cell: (indexPath.row \(indexPath.row)")
            
            let storyboard = UIStoryboard.init(name: "ChatRoom", bundle: nil)
            let chatRoomViewController = storyboard.instantiateViewController(identifier: "ChatRoomViewController") as! ChatRoomViewController
            postdata = self.postArray6[indexPath.row]
            //postdataをChatRoomViewControllerに渡す
            chatRoomViewController.postdata = postdata
            navigationController?.pushViewController(chatRoomViewController, animated: true)
            
        }
    }
}

extension CategoryViewController : CollectionTableViewCell11Delegate {
    func onCollectoinViewCell11DidSelect(tag: Int, indexPath: IndexPath) {
        
        if tag == 11 {
            print("collectionView.tag == 11 Selected Cell: (indexPath.row \(indexPath.row)")
            
            let storyboard = UIStoryboard.init(name: "ChatRoom", bundle: nil)
            let chatRoomViewController = storyboard.instantiateViewController(identifier: "ChatRoomViewController") as! ChatRoomViewController
            postdata = self.postArray7[indexPath.row]
            //postdataをChatRoomViewControllerに渡す
            chatRoomViewController.postdata = postdata
            navigationController?.pushViewController(chatRoomViewController, animated: true)
            
        }
    }
}

extension CategoryViewController : CollectionTableViewCell12Delegate {
    func onCollectoinViewCell12DidSelect(tag: Int, indexPath: IndexPath) {
        
        if tag == 12 {
            print("collectionView.tag == 12 Selected Cell: (indexPath.row \(indexPath.row)")
            
            let storyboard = UIStoryboard.init(name: "ChatRoom", bundle: nil)
            let chatRoomViewController = storyboard.instantiateViewController(identifier: "ChatRoomViewController") as! ChatRoomViewController
            postdata = self.postArray8[indexPath.row]
            //postdataをChatRoomViewControllerに渡す
            chatRoomViewController.postdata = postdata
            navigationController?.pushViewController(chatRoomViewController, animated: true)
            
        }
    }
}





