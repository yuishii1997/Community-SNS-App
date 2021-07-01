//
//  ChatRoomViewController.swift
//  Nomad-App
//
//  Created by yuishii on 2020/07/13.
//  Copyright © 2020 Yu Ishii. All rights reserved.
//
// 投稿をタップした時の遷移先のコメント欄

import UIKit
import Firebase
import MessageUI
import NotificationBannerSwift
import GoogleMobileAds
import SVProgressHUD

class ChatRoomViewController: UIViewController, UINavigationControllerDelegate {
    
    var replyID = ""
    var replyName = ""
    var postName = ""
    var commentTapped = false
    var isShown = false
    
    var postdata: PostData?
    var message: Message?
    
    var transparentView = UIView()
    var tableView = UITableView()
    
    // 投稿データを格納する配列
    var postArray: [PostData] = []
    // ブロックユーザーデータを格納する配列
    var blockUserArray: [String] = []
    private let cellId = "cellId"
    private let cellId2 = "cellId2"
    private var messageArray = [Message]()
    
    private var refreshControl = UIRefreshControl()
    
    // Firestoreのリスナー
    var listener1: ListenerRegistration!
    var listener2: ListenerRegistration!
    var listener_block: ListenerRegistration!
    
    private lazy var chatInputAccessoryView: ChatInputAccessoryView = {
        let view = ChatInputAccessoryView()
        view.frame = .init(x: 0, y: 0, width: view.frame.width, height: 100)
        view.delegate = self
        return view
    }()
    
    @IBOutlet weak var inputLabel: UILabel! {
        didSet {
            inputLabel.layer.cornerRadius = inputLabel.frame.height / 2
            inputLabel.clipsToBounds = true
            inputLabel.backgroundColor = UIColor.rgb(red: 233, green: 237, blue: 236)
        }
    }
    
    @IBOutlet weak var iconView: UIView! {
        didSet {
            iconView.backgroundColor = UIColor.rgb(red: 248, green: 248, blue: 248)
            iconView.layer.cornerRadius = iconView.frame.height / 2
        }
    }
    
    @IBOutlet weak var chatRoomTableView: UITableView!
    
    
    @IBOutlet weak var iconImageView: UIImageView! {
        didSet {
            iconImageView.contentMode = .scaleToFill
            iconImageView.clipsToBounds = true
            iconImageView.layer.cornerRadius = iconImageView.frame.height / 2
        }
    }
    
    @IBOutlet weak var iconImageView2: UIImageView! {
        didSet {
            iconImageView2.contentMode = .scaleToFill
            iconImageView2.clipsToBounds = true
            iconImageView2.layer.cornerRadius = iconImageView2.frame.height / 2
        }
    }
    
    @IBOutlet weak var chatInputView: UIView!
    @IBOutlet weak var separateView: UIView!
    
    @IBOutlet weak var notInputLabel: UIView!
    @IBOutlet weak var notInputView: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.delegate = self
        
        chatRoomTableView.separatorStyle = .none
        
        self.chatRoomTableView.backgroundColor = .white
        //ナビゲーションバーの色
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        //タブバーの色
        self.tabBarController?.tabBar.barTintColor = UIColor.white
        
        // カスタムセルを登録する
        let nib1 = UINib(nibName: "Post3TableViewCell", bundle: nil)
        chatRoomTableView.register(nib1, forCellReuseIdentifier: "Cell3")
        let nib2 = UINib(nibName: "Post4TableViewCell", bundle: nil)
        chatRoomTableView.register(nib2, forCellReuseIdentifier: "Cell4")
        chatRoomTableView.register(UINib(nibName: "GoogleMobileAdsTableCell", bundle: nil),
                                   forCellReuseIdentifier: "GoogleMobileAdsTableCell")
        let nib3 = UINib(nibName: "SectionTableViewCell", bundle: nil)
        chatRoomTableView.register(nib3, forCellReuseIdentifier: "Section")
        let nib3None = UINib(nibName: "NotSectionTableViewCell", bundle: nil)
        chatRoomTableView.register(nib3None, forCellReuseIdentifier: "NotSection")
        let nib4 = UINib(nibName: "NotCommentTableViewCell", bundle: nil)
        chatRoomTableView.register(nib4, forCellReuseIdentifier: "NotComment")
        let nib5 = UINib(nibName: "Post7TableViewCell", bundle: nil)
        chatRoomTableView.register(nib5, forCellReuseIdentifier: "Cell7")
        let nib6 = UINib(nibName: "Post8TableViewCell", bundle: nil)
        chatRoomTableView.register(nib6, forCellReuseIdentifier: "Cell8")
        let nib7 = UINib(nibName: "CommentOffTableViewCell", bundle: nil)
        chatRoomTableView.register(nib7, forCellReuseIdentifier: "CommentOff")
        chatRoomTableView.register(UINib(nibName: "ChatRoomTableViewCell", bundle: nil), forCellReuseIdentifier: cellId)
        chatRoomTableView.register(UINib(nibName: "ChatRoomTableViewCell2", bundle: nil), forCellReuseIdentifier: cellId2)
        
        //空セルのseparator(しきり線)を消す
        chatRoomTableView.tableFooterView = UIView(frame: .zero)
        chatRoomTableView.separatorInset = .zero
        
        chatRoomTableView.delegate = self
        chatRoomTableView.dataSource = self
        
        navigationController?.navigationBar.tintColor = .black
        //navigationItem.title = "コメント"
        
        chatRoomTableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(self.refresh(sender:)), for: .valueChanged)
        
        let image = UIImage(named: "icons8-送信されました-24")
        let state = UIControl.State.normal
        self.chatInputAccessoryView.sendButton.setImage(image, for: state)
        self.chatInputAccessoryView.isHidden = true
        self.chatInputAccessoryView.removeText()
        self.chatInputAccessoryView.chatTextView.resignFirstResponder()
        self.isShown = false
        
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
        
        fetchPosts()
        fetchBlockUsers { [weak self] result in
            switch result {
            case .success:
                self?.fetchMessages()
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
        
        let backBarButtonItem = UIBarButtonItem()
        backBarButtonItem.title = "Back"
        self.navigationItem.backBarButtonItem = backBarButtonItem
        self.navigationItem.title = "スレッド"
        self.navigationController?.navigationBar.titleTextAttributes
            = [NSAttributedString.Key.font: UIFont(name: "Helvetica", size: 16)!]
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        self.tabBarController?.tabBar.barTintColor = UIColor.white
        self.navigationController?.navigationBar.tintColor = UIColor.black
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.black]
        
        
        if Auth.auth().currentUser != nil {
            let myid = Auth.auth().currentUser!.uid
            
            let userRef = Firestore.firestore().collection("users").document(myid)
            userRef.getDocument{ (document, error) in
                
                if let document = document{
                    let data = document.data()
                    self.postName = data!["name"] as! String
                    let with_iconImage = data!["with_iconImage"] as! String
                    let imageNo = data!["imageNo"] as! Int
                    let imageNoString: String = "\(imageNo)"
                    let iconRef = Storage.storage().reference().child("iconImages").child(myid + imageNoString + ".jpg")
                    
                    if with_iconImage == "exist" {
                        print("exist")
                        self.iconImageView2.sd_setImage(with: iconRef)
                    }else{
                        print("notExist")
                        //self.iconView.isHidden = true
                        self.iconImageView.image = UIImage(named: "icons8-男性ユーザ-80")
                    }
                }
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        
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
    
    @IBAction func input(_ sender: Any) {
        
        let image = UIImage(named: "icons8-送信されました-24")
        let state = UIControl.State.normal
        self.chatInputAccessoryView.sendButton.setImage(image, for: state)
        chatInputAccessoryView.isHidden = false
        chatInputAccessoryView.replyLabel2.text = ""
        chatInputAccessoryView.chatTextView.becomeFirstResponder()
        isShown = true
        chatInputAccessoryView.replyLabel.text = "スレッドにコメントしています"
    }
    
    
    @objc func refresh(sender: UIRefreshControl?) {
        
        print("refresh")
        
        let postsRef = Firestore.firestore().collection("posts").document(postdata!.id)
        listener1 = postsRef.addSnapshotListener() { (documentSnapshot, error) in
            guard let document = documentSnapshot else {
                print("Error fetching document: \(error!)")
                return
            }
            self.postdata  = PostData(document: document)
        }
        
        fetchBlockUsers { [weak self] result in
            switch result {
            case .success:
                self?.fetchMessages(sender: sender)
                sender?.endRefreshing()
            case .failure(let error):
                print(error.localizedDescription)
                sender?.endRefreshing()
            }
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if self.isShown == true {
            let image = UIImage(named: "icons8-送信されました-24")
            let state = UIControl.State.normal
            self.chatInputAccessoryView.sendButton.setImage(image, for: state)
            self.chatInputAccessoryView.isHidden = true
            self.chatInputAccessoryView.removeText()
            self.chatInputAccessoryView.chatTextView.resignFirstResponder()
            self.isShown = false
        } else {
            print("スクロールスタート")
            let image = UIImage(named: "icons8-送信されました-24")
            let state = UIControl.State.normal
            self.chatInputAccessoryView.sendButton.setImage(image, for: state)
            self.chatInputAccessoryView.isHidden = true
            self.chatInputAccessoryView.removeText()
            self.chatInputAccessoryView.chatTextView.resignFirstResponder()
        }
    }
    
    override var inputAccessoryView: UIView? {
        get {
            return chatInputAccessoryView
        }
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    private func fetchPosts() {
        if ( self.listener1 == nil ) {
            let postsRef = Firestore.firestore().collection("posts").document(postdata!.id)
            listener1 = postsRef.addSnapshotListener() { (documentSnapshot, error) in
                guard let document = documentSnapshot else {
                    print("Error fetching document: \(error!)")
                    return
                }
                self.postdata  = PostData(document: document)
                
                if self.postdata?.commentOff == "on" {
                    self.notInputLabel.isHidden = false
                    self.notInputView.isHidden = false
                }else{
                    self.notInputLabel.isHidden = true
                    self.notInputView.isHidden = true
                }
                
                //スレッドが削除されたら遷移元に戻る
                if self.postdata?.isReported == true || self.postdata?.deleted == "done" {
                    let alert = UIAlertController(title: "投稿が削除されました", message: "ご覧になっていた投稿が削除されたため、前の画面に戻ります。", preferredStyle: .alert)
                    
                    let confirmAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:{
                        (action: UIAlertAction!) -> Void in
                        self.navigationController?.popViewController(animated: true)
                    })
                    
                    alert.addAction(confirmAction)
                    self.present(alert, animated: true, completion: nil)
                }
                
                self.chatRoomTableView.reloadData()
            }
        }
    }
    
    private func fetchMessages(sender: UIRefreshControl? = nil) {
        
        
        fetchBlockUsers { [weak self] result in
            switch result {
            case .success:
                //ここで渡したpostdataを使う
                if ( self?.listener2 == nil ) {
                    let postsRef = Firestore.firestore().collection("posts").document(self!.postdata!.id).collection("messages").order(by: "createdAt", descending: true).whereField("deleted", isEqualTo: "no")
                    self?.listener2 = postsRef.addSnapshotListener() { [weak self] querySnapshot, error in
                        sender?.endRefreshing()
                        if let error = error {
                            print("DEBUG_PRINT: snapshotの取得が失敗しました。 \(error)")
                            return
                        }
                        self?.messageArray = querySnapshot!.documents.compactMap { document in
                            print("DEBUG_PRINT: document取得 \(document.documentID)")
                            let message = Message(document: document)
                            message.id = document.documentID
                            if self?.blockUserArray.contains(message.uid) == true {
                                return nil
                            } else {
                                return message
                            }
                        }
                        
                        guard let indexPaths = self!.chatRoomTableView.indexPathsForVisibleRows else { return }
                        
                        self?.chatRoomTableView.reloadData()
                        
                        print("indexPaths:\(indexPaths)")
                        print("messages.count\(self!.messageArray.count)")
                        
                    }
                }
                sender?.endRefreshing()
            case .failure(let error):
                print(error.localizedDescription)
                sender?.endRefreshing()
            }
        }
    }
}

extension ChatRoomViewController: ChatInputAccessoryViewDelegate {
    
    //chatroomTableViewCellのsendButtonを押したら、コメントを保存できるようにする
    func tappedSendButton(text: String) {
        
        let timeInterval = Date.timeIntervalSinceReferenceDate
        
        chatInputAccessoryView.removeText()
        
        //不要な改行削除
        let msg = text.replace("\n", "")
        //テキストの半角空白文字削除
        let trimmedString = msg.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmedString.count == 0{
            print("DEBUG_PRINT: コメントが空白です")
            
            let banner = NotificationBanner(title: "コメントが空白です", leftView: nil, rightView: nil, style: .danger, colors: nil)
            banner.autoDismiss = false
            banner.dismissOnTap = true
            banner.show(queuePosition: .front, bannerPosition: .top, queue: .default, on: self.navigationController!)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2, execute: {
                banner.dismiss()
            })
            return
        }else if trimmedString.count > 1000{
            print("DEBUG_PRINT: コメントが1000文字をこえています")
            
            let banner = NotificationBanner(title: "コメントが1000文字をこえています", leftView: nil, rightView: nil, style: .danger, colors: nil)
            banner.autoDismiss = false
            banner.dismissOnTap = true
            banner.show(queuePosition: .front, bannerPosition: .top, queue: .default, on: self.navigationController!)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2, execute: {
                banner.dismiss()
            })
            return
        }
        
        let trimmedString2 = text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        //現在ログイン中のユーザー名を取り出す
        guard let name = Auth.auth().currentUser?.displayName else {return}
        //現在ログイン中のユーザーIDを取り出す
        guard let uid = Auth.auth().currentUser?.uid else { return }
        //現在ログイン中のユーザーのメールアドレスを取り出す
        guard let email = Auth.auth().currentUser?.email else { return }
        
        if commentTapped == false {
            
            let docData = [
                "name": name,
                "createdAt": Timestamp(),
                "date": FieldValue.serverTimestamp(),
                "time": timeInterval,
                "uid": uid,
                "message": trimmedString2,
                "email": email,
                "reply": "n",
                "deleted": "no",
            ] as [String : Any]
            
            let ref = Firestore.firestore().collection("posts").document(postdata!.id).collection("messages").document()
            ref.setData(docData) { (err) in
                if let err = err{
                    print("コメント情報の保存に失敗しました。\(err)")
                    let banner = NotificationBanner(title: "コメント情報の保存に失敗しました。", leftView: nil, rightView: nil, style: .danger, colors: nil)
                    banner.autoDismiss = false
                    banner.dismissOnTap = true
                    banner.show(queuePosition: .front, bannerPosition: .top, queue: .default, on: self.navigationController!)
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.2, execute: {
                        banner.dismiss()
                    })
                    return
                }
                
                //生成されるセルのdocumentIDを取得する
                let documentId = ref.documentID
                print("コメントの保存に成功しました。")
                print("documentId:\(documentId)")
                
                // commentsを更新する
                if let myid = Auth.auth().currentUser?.uid {
                    // 更新データを作成する
                    var updateValue: FieldValue
                    var updateValue2: FieldValue
                    
                    if self.postdata!.isCommented {
                        updateValue = FieldValue.arrayUnion([["uid": myid, "time": timeInterval]])
                        updateValue2 = FieldValue.arrayUnion([["uid": myid, "time": timeInterval]])
                        let postRef = Firestore.firestore().collection("posts").document(self.postdata!.id)
                        postRef.updateData(["comments": updateValue])
                        postRef.updateData(["allComments": updateValue2])
                    } else {
                        updateValue = FieldValue.arrayUnion([["uid": myid, "time": timeInterval]])
                        updateValue2 = FieldValue.arrayUnion([["uid": myid, "time": timeInterval]])
                        let postRef = Firestore.firestore().collection("posts").document(self.postdata!.id)
                        postRef.updateData(["comments": updateValue])
                        postRef.updateData(["allComments": updateValue2])
                    }
                    
                    var updateValue3: FieldValue
                    var updateValue4: FieldValue
                    
                    if self.postdata!.isJoined {
                        print("古いmyidを消して新しいmyidを加えます")
                        //再度新しい日付でmyidを加えるために一度古い日付で登録したmyidを消す
                        updateValue3 = FieldValue.arrayRemove([["uid": myid, "time": self.postdata!.joinedTime]])
                        updateValue4 = FieldValue.arrayUnion([["uid": myid, "time": Date.timeIntervalSinceReferenceDate]])
                        let postRef = Firestore.firestore().collection("posts").document(self.postdata!.id)
                        postRef.updateData(["join": updateValue3])
                        postRef.updateData(["join": updateValue4])
                    } else{
                        print("新しいmyidを加えます")
                        updateValue3 = FieldValue.arrayUnion([["uid": myid, "time": Date.timeIntervalSinceReferenceDate]])
                        let postRef = Firestore.firestore().collection("posts").document(self.postdata!.id)
                        postRef.updateData(["join": updateValue3])
                    }
                    
                    let postRef = Firestore.firestore().collection("posts").document(self.postdata!.id)
                    postRef.updateData(["latestDate": FieldValue.serverTimestamp()])
                    
                }
                let image = UIImage(named: "icons8-送信されました-24")
                let state = UIControl.State.normal
                self.chatInputAccessoryView.sendButton.setImage(image, for: state)
                self.chatInputAccessoryView.sendButton.isEnabled = false
                self.chatInputAccessoryView.isHidden = true
                self.chatInputAccessoryView.chatTextView.resignFirstResponder()
                self.isShown = false
                self.commentTapped = false
                self.replyID = ""
                
                let banner = NotificationBanner(title: "コメントを送信しました", leftView: nil, rightView: nil, style: .info, colors: nil)
                banner.autoDismiss = false
                banner.dismissOnTap = true
                banner.show(queuePosition: .front, bannerPosition: .top, queue: .default, on: self.navigationController!)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2, execute: {
                    banner.dismiss()
                })
            }
        }else{
            let docData = [
                "name": name,
                "createdAt": Timestamp(),
                "date": FieldValue.serverTimestamp(),
                "time": timeInterval,
                "uid": uid,
                "message": trimmedString2,
                "email": email,
                "reply": self.replyID,
                "replyName": self.replyName,
                "deleted": "no",
            ] as [String : Any]
            
            let ref = Firestore.firestore().collection("posts").document(postdata!.id).collection("messages").document()
            ref.setData(docData) { (err) in
                if let err = err{
                    print("コメント情報の保存に失敗しました。\(err)")
                    let banner = NotificationBanner(title: "コメント情報の保存に失敗しました。", leftView: nil, rightView: nil, style: .danger, colors: nil)
                    banner.autoDismiss = false
                    banner.dismissOnTap = true
                    banner.show(queuePosition: .front, bannerPosition: .top, queue: .default, on: self.navigationController!)
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.2, execute: {
                        banner.dismiss()
                    })
                    return
                }
                
                //生成されるセルのdocumentIDを取得する
                let documentId = ref.documentID
                print("コメントの保存に成功しました。")
                print("documentId:\(documentId)")
                
                // commentsを更新する
                if let myid = Auth.auth().currentUser?.uid {
                    // 更新データを作成する
                    var updateValue: FieldValue
                    var updateValue2: FieldValue
                    
                    if self.postdata!.isCommented {
                        updateValue = FieldValue.arrayUnion([["uid": myid, "time": timeInterval]])
                        updateValue2 = FieldValue.arrayUnion([["uid": myid, "time": timeInterval]])
                        let postRef = Firestore.firestore().collection("posts").document(self.postdata!.id)
                        postRef.updateData(["comments": updateValue])
                        postRef.updateData(["allComments": updateValue2])
                    } else {
                        updateValue = FieldValue.arrayUnion([["uid": myid, "time": timeInterval]])
                        updateValue2 = FieldValue.arrayUnion([["uid": myid, "time": timeInterval]])
                        let postRef = Firestore.firestore().collection("posts").document(self.postdata!.id)
                        postRef.updateData(["comments": updateValue])
                        postRef.updateData(["allComments": updateValue2])
                    }
                    
                    var updateValue3: FieldValue
                    var updateValue4: FieldValue
                    
                    if self.postdata!.isJoined {
                        print("古いmyidを消して新しいmyidを加えます")
                        //再度新しい日付でmyidを加えるために一度古い日付で登録したmyidを消す
                        updateValue3 = FieldValue.arrayRemove([["uid": myid, "time": self.postdata!.joinedTime]])
                        updateValue4 = FieldValue.arrayUnion([["uid": myid, "time": Date.timeIntervalSinceReferenceDate]])
                        let postRef = Firestore.firestore().collection("posts").document(self.postdata!.id)
                        postRef.updateData(["join": updateValue3])
                        postRef.updateData(["join": updateValue4])
                    } else{
                        print("新しいmyidを加えます")
                        updateValue3 = FieldValue.arrayUnion([["uid": myid, "time": Date.timeIntervalSinceReferenceDate]])
                        let postRef = Firestore.firestore().collection("posts").document(self.postdata!.id)
                        postRef.updateData(["join": updateValue3])
                    }
                    
                    let postRef = Firestore.firestore().collection("posts").document(self.postdata!.id)
                    postRef.updateData(["latestDate": FieldValue.serverTimestamp()])
                    
                }
                let image = UIImage(named: "icons8-送信されました-24")
                let state = UIControl.State.normal
                self.chatInputAccessoryView.sendButton.setImage(image, for: state)
                self.chatInputAccessoryView.sendButton.isEnabled = false
                self.chatInputAccessoryView.isHidden = true
                self.chatInputAccessoryView.chatTextView.resignFirstResponder()
                self.isShown = false
                self.commentTapped = false
                self.replyID = ""
                
                let banner = NotificationBanner(title: "コメントを送信しました", leftView: nil, rightView: nil, style: .info, colors: nil)
                banner.autoDismiss = false
                banner.dismissOnTap = true
                banner.show(queuePosition: .front, bannerPosition: .top, queue: .default, on: self.navigationController!)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2, execute: {
                    banner.dismiss()
                })
            }
        }
    }
}

extension ChatRoomViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        // セクションの背景色を変更する
        view.tintColor = UIColor.rgb(red: 240, green: 240, blue: 240)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        chatRoomTableView.estimatedRowHeight = 20
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            return 1
        } else if section == 1 {
            return 1
        } else if section == 2 {
            if self.postdata?.commentOff == "on" {
                return 1
            }else{
                if messageArray.count != 0 {
                    return messageArray.count
                }else{
                    return 1
                }
            }
        }else{
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if self.isShown == true {
            let image = UIImage(named: "icons8-送信されました-24")
            let state = UIControl.State.normal
            self.chatInputAccessoryView.sendButton.setImage(image, for: state)
            self.chatInputAccessoryView.isHidden = true
            self.chatInputAccessoryView.removeText()
            self.chatInputAccessoryView.chatTextView.resignFirstResponder()
            self.isShown = false
        } else {
            
            if indexPath.section == 0 {
                print("スレッドがタップされました。")
                
            } else if indexPath.section == 1 {
                print("セクションがタップされました。")
            } else if indexPath.section == 2 {
                
                if messageArray.count != 0 {
                    print("コメントがタップされました。")
                    self.chatInputAccessoryView.isHidden = false
                    chatInputAccessoryView.isHidden = false
                    chatInputAccessoryView.replyLabel2.text = "さんに返信しています"
                    commentTapped = true
                    let row = indexPath.row
                    message = self.messageArray[row]
                    if message?.reply == "n" || message?.reply == nil {
                        print("リプライなし")
                        let image = UIImage(named: "icons8-送信されました-24")
                        let state = UIControl.State.normal
                        self.chatInputAccessoryView.sendButton.setImage(image, for: state)
                        chatInputAccessoryView.sendButton.isEnabled = false
                        self.replyID = message!.id
                        self.replyName = message!.uid
                        //押されたセル取得
                        let cell = tableView.cellForRow(at: indexPath) as! ChatRoomTableViewCell
                        let name = cell.nameLabel.text
                        chatInputAccessoryView.replyLabel.text = name
                        chatInputAccessoryView.chatTextView.becomeFirstResponder()
                        isShown = true
                    }else{
                        print("リプライあり")
                        let image = UIImage(named: "icons8-送信されました-24")
                        let state = UIControl.State.normal
                        self.chatInputAccessoryView.sendButton.setImage(image, for: state)
                        chatInputAccessoryView.sendButton.isEnabled = false
                        self.replyID = message!.id
                        self.replyName = message!.uid
                        //押されたセル取得
                        let cell = tableView.cellForRow(at: indexPath) as! ChatRoomTableViewCell2
                        let name = cell.nameLabel.text
                        chatInputAccessoryView.replyLabel.text = name
                        chatInputAccessoryView.chatTextView.becomeFirstResponder()
                        isShown = true
                    }
                    
                }else{
                    print("notCommentがタップされました")
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //現在ログイン中のユーザーIDを取り出す
        let uid = Auth.auth().currentUser?.uid
        switch (indexPath.section, indexPath.row) {
        case (0, _) where self.postdata?.with_image == true:
            
            if self.postdata?.overView != nil {
                // セクション1は投稿を表示。with_imageがtrueの場合 Post2TableViewCell
                print("Create Post8TableViewCell")
                let cell = tableView.dequeueReusableCell(withIdentifier: "Cell8", for: indexPath) as! Post8TableViewCell
                
                cell.postdata = postdata
                cell.setPostData(postdata!)
                // セル内のボタンのアクションをソースコードで設定する
                cell.likeButton.addTarget(self, action:#selector(handleButton(_:forEvent:)), for: .touchUpInside)
                cell.bookmarkButton.addTarget(self, action:#selector(bookmarkButton(_:forEvent:)), for: .touchUpInside)
                
                cell.nameButton.addTarget(self, action:#selector(userProfileButton(_:forEvent:)), for: .touchUpInside)
                cell.iconButton.addTarget(self, action:#selector(userProfileButton(_:forEvent:)), for: .touchUpInside)
                cell.communityButton.addTarget(self, action:#selector(userProfileButton2(_:forEvent:)), for: .touchUpInside)
                //セル押下時のハイライト(色が濃くなる)を無効
                cell.selectionStyle = .none
                //投稿した人のuidと現在操作しているuidが一緒なら
                if postdata?.uid == uid {
                    cell.alertButton.removeTarget(self, action: #selector(alertButton2(_:forEvent:)), for: .touchUpInside)
                    //スレッドの削除アラートを表示する
                    cell.alertButton.addTarget(self, action:#selector(alertButton(_:forEvent:)), for: .touchUpInside)
                } else {
                    cell.alertButton.removeTarget(self, action: #selector(alertButton(_:forEvent:)), for: .touchUpInside)
                    //スレッドの通報アラートを表示する
                    cell.alertButton.addTarget(self, action:#selector(alertButton2(_:forEvent:)), for: .touchUpInside)
                }
                
                if postdata?.category == nil || postdata?.category == "n" {
                    print("カテゴリーはありません")
                }else{
                    
                    if postdata?.category == "news" {
                        cell.categoryButton.addTarget(self, action:#selector(toCategory1(_:forEvent:)), for: .touchUpInside)
                    }else if postdata?.category == "trend" {
                        cell.categoryButton.addTarget(self, action:#selector(toCategory2(_:forEvent:)), for: .touchUpInside)
                    }else if postdata?.category == "politics" {
                        cell.categoryButton.addTarget(self, action:#selector(toCategory3(_:forEvent:)), for: .touchUpInside)
                    }else if postdata?.category == "sports" {
                        cell.categoryButton.addTarget(self, action:#selector(toCategory4(_:forEvent:)), for: .touchUpInside)
                    }else if postdata?.category == "music" {
                        cell.categoryButton.addTarget(self, action:#selector(toCategory5(_:forEvent:)), for: .touchUpInside)
                    }else if postdata?.category == "funny" {
                        cell.categoryButton.addTarget(self, action:#selector(toCategory6(_:forEvent:)), for: .touchUpInside)
                    }else if postdata?.category == "entertainment" {
                        cell.categoryButton.addTarget(self, action:#selector(toCategory7(_:forEvent:)), for: .touchUpInside)
                    }else if postdata?.category == "tv" {
                        cell.categoryButton.addTarget(self, action:#selector(toCategory8(_:forEvent:)), for: .touchUpInside)
                    }else if postdata?.category == "youtube" {
                        cell.categoryButton.addTarget(self, action:#selector(toCategory9(_:forEvent:)), for: .touchUpInside)
                    }else if postdata?.category == "economics" {
                        cell.categoryButton.addTarget(self, action:#selector(toCategory10(_:forEvent:)), for: .touchUpInside)
                    }else if postdata?.category == "business" {
                        cell.categoryButton.addTarget(self, action:#selector(toCategory11(_:forEvent:)), for: .touchUpInside)
                    }else if postdata?.category == "it" {
                        cell.categoryButton.addTarget(self, action:#selector(toCategory12(_:forEvent:)), for: .touchUpInside)
                    }else if postdata?.category == "science" {
                        cell.categoryButton.addTarget(self, action:#selector(toCategory13(_:forEvent:)), for: .touchUpInside)
                    }else if postdata?.category == "health" {
                        cell.categoryButton.addTarget(self, action:#selector(toCategory14(_:forEvent:)), for: .touchUpInside)
                    }else if postdata?.category == "beauty" {
                        cell.categoryButton.addTarget(self, action:#selector(toCategory15(_:forEvent:)), for: .touchUpInside)
                    }else if postdata?.category == "fashion" {
                        cell.categoryButton.addTarget(self, action:#selector(toCategory16(_:forEvent:)), for: .touchUpInside)
                    }else if postdata?.category == "job" {
                        cell.categoryButton.addTarget(self, action:#selector(toCategory17(_:forEvent:)), for: .touchUpInside)
                    }else if postdata?.category == "school" {
                        cell.categoryButton.addTarget(self, action:#selector(toCategory18(_:forEvent:)), for: .touchUpInside)
                    }else if postdata?.category == "hobby" {
                        cell.categoryButton.addTarget(self, action:#selector(toCategory19(_:forEvent:)), for: .touchUpInside)
                    }else if postdata?.category == "art" {
                        cell.categoryButton.addTarget(self, action:#selector(toCategory20(_:forEvent:)), for: .touchUpInside)
                    }else if postdata?.category == "manga" {
                        cell.categoryButton.addTarget(self, action:#selector(toCategory21(_:forEvent:)), for: .touchUpInside)
                    }else if postdata?.category == "game" {
                        cell.categoryButton.addTarget(self, action:#selector(toCategory22(_:forEvent:)), for: .touchUpInside)
                    }else if postdata?.category == "life" {
                        cell.categoryButton.addTarget(self, action:#selector(toCategory23(_:forEvent:)), for: .touchUpInside)
                    }else if postdata?.category == "family" {
                        cell.categoryButton.addTarget(self, action:#selector(toCategory24(_:forEvent:)), for: .touchUpInside)
                    }else if postdata?.category == "love" {
                        cell.categoryButton.addTarget(self, action:#selector(toCategory25(_:forEvent:)), for: .touchUpInside)
                    }else if postdata?.category == "parenting" {
                        cell.categoryButton.addTarget(self, action:#selector(toCategory26(_:forEvent:)), for: .touchUpInside)
                    }else if postdata?.category == "recipe" {
                        cell.categoryButton.addTarget(self, action:#selector(toCategory27(_:forEvent:)), for: .touchUpInside)
                    }else if postdata?.category == "study" {
                        cell.categoryButton.addTarget(self, action:#selector(toCategory28(_:forEvent:)), for: .touchUpInside)
                    }else if postdata?.category == "question" {
                        cell.categoryButton.addTarget(self, action:#selector(toCategory29(_:forEvent:)), for: .touchUpInside)
                    }else if postdata?.category == "mystery" {
                        cell.categoryButton.addTarget(self, action:#selector(toCategory30(_:forEvent:)), for: .touchUpInside)
                    }else if postdata?.category == "prefectures" {
                        cell.categoryButton.addTarget(self, action:#selector(toCategory31(_:forEvent:)), for: .touchUpInside)
                    }else if postdata?.category == "world" {
                        cell.categoryButton.addTarget(self, action:#selector(toCategory32(_:forEvent:)), for: .touchUpInside)
                    }else if postdata?.category == "travel" {
                        cell.categoryButton.addTarget(self, action:#selector(toCategory33(_:forEvent:)), for: .touchUpInside)
                    }else if postdata?.category == "pr" {
                        cell.categoryButton.addTarget(self, action:#selector(toCategory34(_:forEvent:)), for: .touchUpInside)
                    }else if postdata?.category == "car" {
                        cell.categoryButton.addTarget(self, action:#selector(toCategory35(_:forEvent:)), for: .touchUpInside)
                    }else if postdata?.category == "pet" {
                        cell.categoryButton.addTarget(self, action:#selector(toCategory36(_:forEvent:)), for: .touchUpInside)
                    }else if postdata?.category == "chat" {
                        cell.categoryButton.addTarget(self, action:#selector(toCategory37(_:forEvent:)), for: .touchUpInside)
                    }else if postdata?.category == "other" {
                        cell.categoryButton.addTarget(self, action:#selector(toCategory38(_:forEvent:)), for: .touchUpInside)
                    }
                }
                return cell
            }else{
                
                // セクション1は投稿を表示。with_imageがtrueの場合 Post2TableViewCell
                print("Create Post4TableViewCell")
                let cell = tableView.dequeueReusableCell(withIdentifier: "Cell4", for: indexPath) as! Post4TableViewCell
                
                cell.postdata = postdata
                cell.setPostData(postdata!)
                // セル内のボタンのアクションをソースコードで設定する
                cell.likeButton.addTarget(self, action:#selector(handleButton(_:forEvent:)), for: .touchUpInside)
                cell.bookmarkButton.addTarget(self, action:#selector(bookmarkButton(_:forEvent:)), for: .touchUpInside)
                
                cell.nameButton.addTarget(self, action:#selector(userProfileButton(_:forEvent:)), for: .touchUpInside)
                cell.iconButton.addTarget(self, action:#selector(userProfileButton(_:forEvent:)), for: .touchUpInside)
                cell.communityButton.addTarget(self, action:#selector(userProfileButton2(_:forEvent:)), for: .touchUpInside)
                //セル押下時のハイライト(色が濃くなる)を無効
                cell.selectionStyle = .none
                //投稿した人のuidと現在操作しているuidが一緒なら
                if postdata?.uid == uid {
                    cell.alertButton.removeTarget(self, action: #selector(alertButton2(_:forEvent:)), for: .touchUpInside)
                    //スレッドの削除アラートを表示する
                    cell.alertButton.addTarget(self, action:#selector(alertButton(_:forEvent:)), for: .touchUpInside)
                } else {
                    cell.alertButton.removeTarget(self, action: #selector(alertButton(_:forEvent:)), for: .touchUpInside)
                    //スレッドの通報アラートを表示する
                    cell.alertButton.addTarget(self, action:#selector(alertButton2(_:forEvent:)), for: .touchUpInside)
                }
                
                if postdata?.category == nil || postdata?.category == "n" {
                    print("カテゴリーはありません")
                }else{
                    
                    if postdata?.category == "news" {
                        cell.categoryButton.addTarget(self, action:#selector(toCategory1(_:forEvent:)), for: .touchUpInside)
                    }else if postdata?.category == "trend" {
                        cell.categoryButton.addTarget(self, action:#selector(toCategory2(_:forEvent:)), for: .touchUpInside)
                    }else if postdata?.category == "politics" {
                        cell.categoryButton.addTarget(self, action:#selector(toCategory3(_:forEvent:)), for: .touchUpInside)
                    }else if postdata?.category == "sports" {
                        cell.categoryButton.addTarget(self, action:#selector(toCategory4(_:forEvent:)), for: .touchUpInside)
                    }else if postdata?.category == "music" {
                        cell.categoryButton.addTarget(self, action:#selector(toCategory5(_:forEvent:)), for: .touchUpInside)
                    }else if postdata?.category == "funny" {
                        cell.categoryButton.addTarget(self, action:#selector(toCategory6(_:forEvent:)), for: .touchUpInside)
                    }else if postdata?.category == "entertainment" {
                        cell.categoryButton.addTarget(self, action:#selector(toCategory7(_:forEvent:)), for: .touchUpInside)
                    }else if postdata?.category == "tv" {
                        cell.categoryButton.addTarget(self, action:#selector(toCategory8(_:forEvent:)), for: .touchUpInside)
                    }else if postdata?.category == "youtube" {
                        cell.categoryButton.addTarget(self, action:#selector(toCategory9(_:forEvent:)), for: .touchUpInside)
                    }else if postdata?.category == "economics" {
                        cell.categoryButton.addTarget(self, action:#selector(toCategory10(_:forEvent:)), for: .touchUpInside)
                    }else if postdata?.category == "business" {
                        cell.categoryButton.addTarget(self, action:#selector(toCategory11(_:forEvent:)), for: .touchUpInside)
                    }else if postdata?.category == "it" {
                        cell.categoryButton.addTarget(self, action:#selector(toCategory12(_:forEvent:)), for: .touchUpInside)
                    }else if postdata?.category == "science" {
                        cell.categoryButton.addTarget(self, action:#selector(toCategory13(_:forEvent:)), for: .touchUpInside)
                    }else if postdata?.category == "health" {
                        cell.categoryButton.addTarget(self, action:#selector(toCategory14(_:forEvent:)), for: .touchUpInside)
                    }else if postdata?.category == "beauty" {
                        cell.categoryButton.addTarget(self, action:#selector(toCategory15(_:forEvent:)), for: .touchUpInside)
                    }else if postdata?.category == "fashion" {
                        cell.categoryButton.addTarget(self, action:#selector(toCategory16(_:forEvent:)), for: .touchUpInside)
                    }else if postdata?.category == "job" {
                        cell.categoryButton.addTarget(self, action:#selector(toCategory17(_:forEvent:)), for: .touchUpInside)
                    }else if postdata?.category == "school" {
                        cell.categoryButton.addTarget(self, action:#selector(toCategory18(_:forEvent:)), for: .touchUpInside)
                    }else if postdata?.category == "hobby" {
                        cell.categoryButton.addTarget(self, action:#selector(toCategory19(_:forEvent:)), for: .touchUpInside)
                    }else if postdata?.category == "art" {
                        cell.categoryButton.addTarget(self, action:#selector(toCategory20(_:forEvent:)), for: .touchUpInside)
                    }else if postdata?.category == "manga" {
                        cell.categoryButton.addTarget(self, action:#selector(toCategory21(_:forEvent:)), for: .touchUpInside)
                    }else if postdata?.category == "game" {
                        cell.categoryButton.addTarget(self, action:#selector(toCategory22(_:forEvent:)), for: .touchUpInside)
                    }else if postdata?.category == "life" {
                        cell.categoryButton.addTarget(self, action:#selector(toCategory23(_:forEvent:)), for: .touchUpInside)
                    }else if postdata?.category == "family" {
                        cell.categoryButton.addTarget(self, action:#selector(toCategory24(_:forEvent:)), for: .touchUpInside)
                    }else if postdata?.category == "love" {
                        cell.categoryButton.addTarget(self, action:#selector(toCategory25(_:forEvent:)), for: .touchUpInside)
                    }else if postdata?.category == "parenting" {
                        cell.categoryButton.addTarget(self, action:#selector(toCategory26(_:forEvent:)), for: .touchUpInside)
                    }else if postdata?.category == "recipe" {
                        cell.categoryButton.addTarget(self, action:#selector(toCategory27(_:forEvent:)), for: .touchUpInside)
                    }else if postdata?.category == "study" {
                        cell.categoryButton.addTarget(self, action:#selector(toCategory28(_:forEvent:)), for: .touchUpInside)
                    }else if postdata?.category == "question" {
                        cell.categoryButton.addTarget(self, action:#selector(toCategory29(_:forEvent:)), for: .touchUpInside)
                    }else if postdata?.category == "mystery" {
                        cell.categoryButton.addTarget(self, action:#selector(toCategory30(_:forEvent:)), for: .touchUpInside)
                    }else if postdata?.category == "prefectures" {
                        cell.categoryButton.addTarget(self, action:#selector(toCategory31(_:forEvent:)), for: .touchUpInside)
                    }else if postdata?.category == "world" {
                        cell.categoryButton.addTarget(self, action:#selector(toCategory32(_:forEvent:)), for: .touchUpInside)
                    }else if postdata?.category == "travel" {
                        cell.categoryButton.addTarget(self, action:#selector(toCategory33(_:forEvent:)), for: .touchUpInside)
                    }else if postdata?.category == "pr" {
                        cell.categoryButton.addTarget(self, action:#selector(toCategory34(_:forEvent:)), for: .touchUpInside)
                    }else if postdata?.category == "car" {
                        cell.categoryButton.addTarget(self, action:#selector(toCategory35(_:forEvent:)), for: .touchUpInside)
                    }else if postdata?.category == "pet" {
                        cell.categoryButton.addTarget(self, action:#selector(toCategory36(_:forEvent:)), for: .touchUpInside)
                    }else if postdata?.category == "chat" {
                        cell.categoryButton.addTarget(self, action:#selector(toCategory37(_:forEvent:)), for: .touchUpInside)
                    }else if postdata?.category == "other" {
                        cell.categoryButton.addTarget(self, action:#selector(toCategory38(_:forEvent:)), for: .touchUpInside)
                    }
                }
                return cell
            }
            
        case (0, _):
            
            if self.postdata?.overView != nil {
                // セクション1は投稿を表示。with_imageがfalseの場合 Post1TableViewCell
                print("Create Post7TableViewCell")
                let cell = tableView.dequeueReusableCell(withIdentifier: "Cell7", for: indexPath) as! Post7TableViewCell
                cell.postdata = postdata
                cell.setPostData(postdata!)
                // セル内のボタンのアクションをソースコードで設定する
                cell.likeButton.addTarget(self, action:#selector(handleButton(_:forEvent:)), for: .touchUpInside)
                cell.bookmarkButton.addTarget(self, action:#selector(bookmarkButton(_:forEvent:)), for: .touchUpInside)
                
                cell.nameButton.addTarget(self, action:#selector(userProfileButton(_:forEvent:)), for: .touchUpInside)
                cell.iconButton.addTarget(self, action:#selector(userProfileButton(_:forEvent:)), for: .touchUpInside)
                cell.communityButton.addTarget(self, action:#selector(userProfileButton2(_:forEvent:)), for: .touchUpInside)
                //セル押下時のハイライト(色が濃くなる)を無効
                cell.selectionStyle = .none
                //投稿した人のuidと現在操作しているuidが一緒なら
                if postdata?.uid == uid {
                    cell.alertButton.removeTarget(self, action: #selector(alertButton2(_:forEvent:)), for: .touchUpInside)
                    //スレッドの削除アラートを表示する
                    cell.alertButton.addTarget(self, action:#selector(alertButton(_:forEvent:)), for: .touchUpInside)
                } else {
                    cell.alertButton.removeTarget(self, action: #selector(alertButton(_:forEvent:)), for: .touchUpInside)
                    //スレッドの通報アラートを表示する
                    cell.alertButton.addTarget(self, action:#selector(alertButton2(_:forEvent:)), for: .touchUpInside)
                }
                
                if postdata?.category == nil || postdata?.category == "n" {
                    print("カテゴリーはありません")
                }else{
                    
                    if postdata?.category == "news" {
                        cell.categoryButton.addTarget(self, action:#selector(toCategory1(_:forEvent:)), for: .touchUpInside)
                    }else if postdata?.category == "trend" {
                        cell.categoryButton.addTarget(self, action:#selector(toCategory2(_:forEvent:)), for: .touchUpInside)
                    }else if postdata?.category == "politics" {
                        cell.categoryButton.addTarget(self, action:#selector(toCategory3(_:forEvent:)), for: .touchUpInside)
                    }else if postdata?.category == "sports" {
                        cell.categoryButton.addTarget(self, action:#selector(toCategory4(_:forEvent:)), for: .touchUpInside)
                    }else if postdata?.category == "music" {
                        cell.categoryButton.addTarget(self, action:#selector(toCategory5(_:forEvent:)), for: .touchUpInside)
                    }else if postdata?.category == "funny" {
                        cell.categoryButton.addTarget(self, action:#selector(toCategory6(_:forEvent:)), for: .touchUpInside)
                    }else if postdata?.category == "entertainment" {
                        cell.categoryButton.addTarget(self, action:#selector(toCategory7(_:forEvent:)), for: .touchUpInside)
                    }else if postdata?.category == "tv" {
                        cell.categoryButton.addTarget(self, action:#selector(toCategory8(_:forEvent:)), for: .touchUpInside)
                    }else if postdata?.category == "youtube" {
                        cell.categoryButton.addTarget(self, action:#selector(toCategory9(_:forEvent:)), for: .touchUpInside)
                    }else if postdata?.category == "economics" {
                        cell.categoryButton.addTarget(self, action:#selector(toCategory10(_:forEvent:)), for: .touchUpInside)
                    }else if postdata?.category == "business" {
                        cell.categoryButton.addTarget(self, action:#selector(toCategory11(_:forEvent:)), for: .touchUpInside)
                    }else if postdata?.category == "it" {
                        cell.categoryButton.addTarget(self, action:#selector(toCategory12(_:forEvent:)), for: .touchUpInside)
                    }else if postdata?.category == "science" {
                        cell.categoryButton.addTarget(self, action:#selector(toCategory13(_:forEvent:)), for: .touchUpInside)
                    }else if postdata?.category == "health" {
                        cell.categoryButton.addTarget(self, action:#selector(toCategory14(_:forEvent:)), for: .touchUpInside)
                    }else if postdata?.category == "beauty" {
                        cell.categoryButton.addTarget(self, action:#selector(toCategory15(_:forEvent:)), for: .touchUpInside)
                    }else if postdata?.category == "fashion" {
                        cell.categoryButton.addTarget(self, action:#selector(toCategory16(_:forEvent:)), for: .touchUpInside)
                    }else if postdata?.category == "job" {
                        cell.categoryButton.addTarget(self, action:#selector(toCategory17(_:forEvent:)), for: .touchUpInside)
                    }else if postdata?.category == "school" {
                        cell.categoryButton.addTarget(self, action:#selector(toCategory18(_:forEvent:)), for: .touchUpInside)
                    }else if postdata?.category == "hobby" {
                        cell.categoryButton.addTarget(self, action:#selector(toCategory19(_:forEvent:)), for: .touchUpInside)
                    }else if postdata?.category == "art" {
                        cell.categoryButton.addTarget(self, action:#selector(toCategory20(_:forEvent:)), for: .touchUpInside)
                    }else if postdata?.category == "manga" {
                        cell.categoryButton.addTarget(self, action:#selector(toCategory21(_:forEvent:)), for: .touchUpInside)
                    }else if postdata?.category == "game" {
                        cell.categoryButton.addTarget(self, action:#selector(toCategory22(_:forEvent:)), for: .touchUpInside)
                    }else if postdata?.category == "life" {
                        cell.categoryButton.addTarget(self, action:#selector(toCategory23(_:forEvent:)), for: .touchUpInside)
                    }else if postdata?.category == "family" {
                        cell.categoryButton.addTarget(self, action:#selector(toCategory24(_:forEvent:)), for: .touchUpInside)
                    }else if postdata?.category == "love" {
                        cell.categoryButton.addTarget(self, action:#selector(toCategory25(_:forEvent:)), for: .touchUpInside)
                    }else if postdata?.category == "parenting" {
                        cell.categoryButton.addTarget(self, action:#selector(toCategory26(_:forEvent:)), for: .touchUpInside)
                    }else if postdata?.category == "recipe" {
                        cell.categoryButton.addTarget(self, action:#selector(toCategory27(_:forEvent:)), for: .touchUpInside)
                    }else if postdata?.category == "study" {
                        cell.categoryButton.addTarget(self, action:#selector(toCategory28(_:forEvent:)), for: .touchUpInside)
                    }else if postdata?.category == "question" {
                        cell.categoryButton.addTarget(self, action:#selector(toCategory29(_:forEvent:)), for: .touchUpInside)
                    }else if postdata?.category == "mystery" {
                        cell.categoryButton.addTarget(self, action:#selector(toCategory30(_:forEvent:)), for: .touchUpInside)
                    }else if postdata?.category == "prefectures" {
                        cell.categoryButton.addTarget(self, action:#selector(toCategory31(_:forEvent:)), for: .touchUpInside)
                    }else if postdata?.category == "world" {
                        cell.categoryButton.addTarget(self, action:#selector(toCategory32(_:forEvent:)), for: .touchUpInside)
                    }else if postdata?.category == "travel" {
                        cell.categoryButton.addTarget(self, action:#selector(toCategory33(_:forEvent:)), for: .touchUpInside)
                    }else if postdata?.category == "pr" {
                        cell.categoryButton.addTarget(self, action:#selector(toCategory34(_:forEvent:)), for: .touchUpInside)
                    }else if postdata?.category == "car" {
                        cell.categoryButton.addTarget(self, action:#selector(toCategory35(_:forEvent:)), for: .touchUpInside)
                    }else if postdata?.category == "pet" {
                        cell.categoryButton.addTarget(self, action:#selector(toCategory36(_:forEvent:)), for: .touchUpInside)
                    }else if postdata?.category == "chat" {
                        cell.categoryButton.addTarget(self, action:#selector(toCategory37(_:forEvent:)), for: .touchUpInside)
                    }else if postdata?.category == "other" {
                        cell.categoryButton.addTarget(self, action:#selector(toCategory38(_:forEvent:)), for: .touchUpInside)
                    }
                }
                return cell
            }else{
                // セクション1は投稿を表示。with_imageがfalseの場合 Post1TableViewCell
                print("Create Post3TableViewCell")
                let cell = tableView.dequeueReusableCell(withIdentifier: "Cell3", for: indexPath) as! Post3TableViewCell
                cell.postdata = postdata
                cell.setPostData(postdata!)
                // セル内のボタンのアクションをソースコードで設定する
                cell.likeButton.addTarget(self, action:#selector(handleButton(_:forEvent:)), for: .touchUpInside)
                cell.bookmarkButton.addTarget(self, action:#selector(bookmarkButton(_:forEvent:)), for: .touchUpInside)
                
                cell.nameButton.addTarget(self, action:#selector(userProfileButton(_:forEvent:)), for: .touchUpInside)
                cell.iconButton.addTarget(self, action:#selector(userProfileButton(_:forEvent:)), for: .touchUpInside)
                cell.communityButton.addTarget(self, action:#selector(userProfileButton2(_:forEvent:)), for: .touchUpInside)
                //セル押下時のハイライト(色が濃くなる)を無効
                cell.selectionStyle = .none
                //投稿した人のuidと現在操作しているuidが一緒なら
                if postdata?.uid == uid {
                    cell.alertButton.removeTarget(self, action: #selector(alertButton2(_:forEvent:)), for: .touchUpInside)
                    //スレッドの削除アラートを表示する
                    cell.alertButton.addTarget(self, action:#selector(alertButton(_:forEvent:)), for: .touchUpInside)
                } else {
                    cell.alertButton.removeTarget(self, action: #selector(alertButton(_:forEvent:)), for: .touchUpInside)
                    //スレッドの通報アラートを表示する
                    cell.alertButton.addTarget(self, action:#selector(alertButton2(_:forEvent:)), for: .touchUpInside)
                }
                
                if postdata?.category == nil || postdata?.category == "n" {
                    print("カテゴリーはありません")
                }else{
                    
                    if postdata?.category == "news" {
                        cell.categoryButton.addTarget(self, action:#selector(toCategory1(_:forEvent:)), for: .touchUpInside)
                    }else if postdata?.category == "trend" {
                        cell.categoryButton.addTarget(self, action:#selector(toCategory2(_:forEvent:)), for: .touchUpInside)
                    }else if postdata?.category == "politics" {
                        cell.categoryButton.addTarget(self, action:#selector(toCategory3(_:forEvent:)), for: .touchUpInside)
                    }else if postdata?.category == "sports" {
                        cell.categoryButton.addTarget(self, action:#selector(toCategory4(_:forEvent:)), for: .touchUpInside)
                    }else if postdata?.category == "music" {
                        cell.categoryButton.addTarget(self, action:#selector(toCategory5(_:forEvent:)), for: .touchUpInside)
                    }else if postdata?.category == "funny" {
                        cell.categoryButton.addTarget(self, action:#selector(toCategory6(_:forEvent:)), for: .touchUpInside)
                    }else if postdata?.category == "entertainment" {
                        cell.categoryButton.addTarget(self, action:#selector(toCategory7(_:forEvent:)), for: .touchUpInside)
                    }else if postdata?.category == "tv" {
                        cell.categoryButton.addTarget(self, action:#selector(toCategory8(_:forEvent:)), for: .touchUpInside)
                    }else if postdata?.category == "youtube" {
                        cell.categoryButton.addTarget(self, action:#selector(toCategory9(_:forEvent:)), for: .touchUpInside)
                    }else if postdata?.category == "economics" {
                        cell.categoryButton.addTarget(self, action:#selector(toCategory10(_:forEvent:)), for: .touchUpInside)
                    }else if postdata?.category == "business" {
                        cell.categoryButton.addTarget(self, action:#selector(toCategory11(_:forEvent:)), for: .touchUpInside)
                    }else if postdata?.category == "it" {
                        cell.categoryButton.addTarget(self, action:#selector(toCategory12(_:forEvent:)), for: .touchUpInside)
                    }else if postdata?.category == "science" {
                        cell.categoryButton.addTarget(self, action:#selector(toCategory13(_:forEvent:)), for: .touchUpInside)
                    }else if postdata?.category == "health" {
                        cell.categoryButton.addTarget(self, action:#selector(toCategory14(_:forEvent:)), for: .touchUpInside)
                    }else if postdata?.category == "beauty" {
                        cell.categoryButton.addTarget(self, action:#selector(toCategory15(_:forEvent:)), for: .touchUpInside)
                    }else if postdata?.category == "fashion" {
                        cell.categoryButton.addTarget(self, action:#selector(toCategory16(_:forEvent:)), for: .touchUpInside)
                    }else if postdata?.category == "job" {
                        cell.categoryButton.addTarget(self, action:#selector(toCategory17(_:forEvent:)), for: .touchUpInside)
                    }else if postdata?.category == "school" {
                        cell.categoryButton.addTarget(self, action:#selector(toCategory18(_:forEvent:)), for: .touchUpInside)
                    }else if postdata?.category == "hobby" {
                        cell.categoryButton.addTarget(self, action:#selector(toCategory19(_:forEvent:)), for: .touchUpInside)
                    }else if postdata?.category == "art" {
                        cell.categoryButton.addTarget(self, action:#selector(toCategory20(_:forEvent:)), for: .touchUpInside)
                    }else if postdata?.category == "manga" {
                        cell.categoryButton.addTarget(self, action:#selector(toCategory21(_:forEvent:)), for: .touchUpInside)
                    }else if postdata?.category == "game" {
                        cell.categoryButton.addTarget(self, action:#selector(toCategory22(_:forEvent:)), for: .touchUpInside)
                    }else if postdata?.category == "life" {
                        cell.categoryButton.addTarget(self, action:#selector(toCategory23(_:forEvent:)), for: .touchUpInside)
                    }else if postdata?.category == "family" {
                        cell.categoryButton.addTarget(self, action:#selector(toCategory24(_:forEvent:)), for: .touchUpInside)
                    }else if postdata?.category == "love" {
                        cell.categoryButton.addTarget(self, action:#selector(toCategory25(_:forEvent:)), for: .touchUpInside)
                    }else if postdata?.category == "parenting" {
                        cell.categoryButton.addTarget(self, action:#selector(toCategory26(_:forEvent:)), for: .touchUpInside)
                    }else if postdata?.category == "recipe" {
                        cell.categoryButton.addTarget(self, action:#selector(toCategory27(_:forEvent:)), for: .touchUpInside)
                    }else if postdata?.category == "study" {
                        cell.categoryButton.addTarget(self, action:#selector(toCategory28(_:forEvent:)), for: .touchUpInside)
                    }else if postdata?.category == "question" {
                        cell.categoryButton.addTarget(self, action:#selector(toCategory29(_:forEvent:)), for: .touchUpInside)
                    }else if postdata?.category == "mystery" {
                        cell.categoryButton.addTarget(self, action:#selector(toCategory30(_:forEvent:)), for: .touchUpInside)
                    }else if postdata?.category == "prefectures" {
                        cell.categoryButton.addTarget(self, action:#selector(toCategory31(_:forEvent:)), for: .touchUpInside)
                    }else if postdata?.category == "world" {
                        cell.categoryButton.addTarget(self, action:#selector(toCategory32(_:forEvent:)), for: .touchUpInside)
                    }else if postdata?.category == "travel" {
                        cell.categoryButton.addTarget(self, action:#selector(toCategory33(_:forEvent:)), for: .touchUpInside)
                    }else if postdata?.category == "pr" {
                        cell.categoryButton.addTarget(self, action:#selector(toCategory34(_:forEvent:)), for: .touchUpInside)
                    }else if postdata?.category == "car" {
                        cell.categoryButton.addTarget(self, action:#selector(toCategory35(_:forEvent:)), for: .touchUpInside)
                    }else if postdata?.category == "pet" {
                        cell.categoryButton.addTarget(self, action:#selector(toCategory36(_:forEvent:)), for: .touchUpInside)
                    }else if postdata?.category == "chat" {
                        cell.categoryButton.addTarget(self, action:#selector(toCategory37(_:forEvent:)), for: .touchUpInside)
                    }else if postdata?.category == "other" {
                        cell.categoryButton.addTarget(self, action:#selector(toCategory38(_:forEvent:)), for: .touchUpInside)
                    }
                }
                return cell
            }
        case (1, _):
            
            //NotSectionTableViewCell
            
            if messageArray.count != 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "Section", for: indexPath) as! SectionTableViewCell
                return cell
            }else{
                let cell = tableView.dequeueReusableCell(withIdentifier: "NotSection", for: indexPath) as! NotSectionTableViewCell
                return cell
            }
        default:
            
            if postdata?.commentOff == "on" {
                let cell = chatRoomTableView.dequeueReusableCell(withIdentifier: "CommentOff", for: indexPath) as! CommentOffTableViewCell
                return cell
            }else{
                
                if messageArray.count != 0 {
                    
                    let row = indexPath.row
                    
                    if self.messageArray[row].reply == "n" {
                        //セクション2はコメント欄を表示
                        let cell = chatRoomTableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! ChatRoomTableViewCell
                        cell.tag = indexPath.row + 1
                        
                        cell.likeButton.addTarget(self, action:#selector(handleButton2(_:forEvent:)), for: .touchUpInside)
                        cell.iconButton.addTarget(self, action:#selector(userProfileButton3(_:forEvent:)), for: .touchUpInside)
                        
                        print("indexPath.row:\(indexPath.row)")
                        message = self.messageArray[row]
                        cell.setMessageData(messageArray[row])
                        
                        if blockUserArray.contains(message!.uid) {
                            cell.messageLabel.text = "[このコメントは非表示になっています]"
                            cell.messageLabel.textColor = .gray
                            cell.messageLabel.font = UIFont.systemFont(ofSize: 16)
                        }
                        //セル押下時のハイライト(色が濃くなる)を無効
                        cell.selectionStyle = .none
                        //スレッドを作成した人が他の人のコメントを削除する場合
                        if postdata?.uid == uid && message?.uid != uid {
                            cell.alertButton.removeTarget(self, action: #selector(alertButton4(_:forEvent:)), for: .touchUpInside)
                            cell.alertButton.removeTarget(self, action: #selector(alertButton3(_:forEvent:)), for: .touchUpInside)
                            //コメントの削除アラートを表示する(ただし、commentsは減らさない)
                            cell.alertButton.addTarget(self, action:#selector(alertButton3b(_:forEvent:)), for: .touchUpInside)
                        } else if message?.uid == uid {
                            //コメントした人のuidと現在操作しているuidが一緒の場合
                            cell.alertButton.removeTarget(self, action: #selector(alertButton4(_:forEvent:)), for: .touchUpInside)
                            cell.alertButton.removeTarget(self, action: #selector(alertButton3b(_:forEvent:)), for: .touchUpInside)
                            //コメントの削除アラートを表示する
                            cell.alertButton.addTarget(self, action:#selector(alertButton3(_:forEvent:)), for: .touchUpInside)
                        } else {
                            cell.alertButton.removeTarget(self, action: #selector(alertButton3(_:forEvent:)), for: .touchUpInside)
                            cell.alertButton.removeTarget(self, action: #selector(alertButton3b(_:forEvent:)), for: .touchUpInside)
                            //コメントの通報アラートを表示する
                            cell.alertButton.addTarget(self, action:#selector(alertButton4(_:forEvent:)), for: .touchUpInside)
                        }
                        cell.nameButton.addTarget(self, action:#selector(userProfileButton3(_:forEvent:)), for: .touchUpInside)
                        
                        return cell
                        
                    }else{
                        
                        let cell = chatRoomTableView.dequeueReusableCell(withIdentifier: cellId2, for: indexPath) as! ChatRoomTableViewCell2
                        cell.tag = indexPath.row + 1
                        
                        cell.likeButton.addTarget(self, action:#selector(handleButton2(_:forEvent:)), for: .touchUpInside)
                        cell.iconButton.addTarget(self, action:#selector(userProfileButton3(_:forEvent:)), for: .touchUpInside)
                        cell.replyButton.addTarget(self, action:#selector(userProfileButton4(_:forEvent:)), for: .touchUpInside)
                        
                        
                        print("indexPath.row:\(indexPath.row)")
                        message = self.messageArray[row]
                        cell.setMessageData(messageArray[row])
                        
                        if blockUserArray.contains(message!.uid) {
                            cell.messageLabel.text = "[このコメントは非表示になっています]"
                            cell.messageLabel.textColor = .gray
                            cell.messageLabel.font = UIFont.systemFont(ofSize: 16)
                        }
                        //セル押下時のハイライト(色が濃くなる)を無効
                        cell.selectionStyle = .none
                        //スレッドを作成した人が他の人のコメントを削除する場合
                        if postdata?.uid == uid && message?.uid != uid {
                            cell.alertButton.removeTarget(self, action: #selector(alertButton4(_:forEvent:)), for: .touchUpInside)
                            cell.alertButton.removeTarget(self, action: #selector(alertButton3(_:forEvent:)), for: .touchUpInside)
                            //コメントの削除アラートを表示する(ただし、commentsは減らさない)
                            cell.alertButton.addTarget(self, action:#selector(alertButton3b(_:forEvent:)), for: .touchUpInside)
                        } else if message?.uid == uid {
                            //コメントした人のuidと現在操作しているuidが一緒の場合
                            cell.alertButton.removeTarget(self, action: #selector(alertButton4(_:forEvent:)), for: .touchUpInside)
                            cell.alertButton.removeTarget(self, action: #selector(alertButton3b(_:forEvent:)), for: .touchUpInside)
                            //コメントの削除アラートを表示する
                            cell.alertButton.addTarget(self, action:#selector(alertButton3(_:forEvent:)), for: .touchUpInside)
                        } else {
                            cell.alertButton.removeTarget(self, action: #selector(alertButton3(_:forEvent:)), for: .touchUpInside)
                            cell.alertButton.removeTarget(self, action: #selector(alertButton3b(_:forEvent:)), for: .touchUpInside)
                            //コメントの通報アラートを表示する
                            cell.alertButton.addTarget(self, action:#selector(alertButton4(_:forEvent:)), for: .touchUpInside)
                        }
                        cell.nameButton.addTarget(self, action:#selector(userProfileButton3(_:forEvent:)), for: .touchUpInside)
                        
                        return cell
                        
                    }
                }else{
                    let cell = chatRoomTableView.dequeueReusableCell(withIdentifier: "NotComment", for: indexPath) as! NotCommentTableViewCell
                    return cell
                }
            }
        }
    }
    
    
    @objc func toCategory1(_ sender: UIButton, forEvent event: UIEvent) {
        
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let categoryPostsViewController = storyboard.instantiateViewController(identifier: "CategoryPosts") as! CategoryPostsViewController
        categoryPostsViewController.category = "news"
        categoryPostsViewController.titleName = "ニュース"
        navigationController?.pushViewController(categoryPostsViewController, animated: true)
    }
    
    @objc func toCategory2(_ sender: UIButton, forEvent event: UIEvent) {
        
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let categoryPostsViewController = storyboard.instantiateViewController(identifier: "CategoryPosts") as! CategoryPostsViewController
        categoryPostsViewController.category = "trend"
        categoryPostsViewController.titleName = "話題・トレンド"
        navigationController?.pushViewController(categoryPostsViewController, animated: true)
    }
    
    @objc func toCategory3(_ sender: UIButton, forEvent event: UIEvent) {
        
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let categoryPostsViewController = storyboard.instantiateViewController(identifier: "CategoryPosts") as! CategoryPostsViewController
        categoryPostsViewController.category = "politics"
        categoryPostsViewController.titleName = "政治・社会"
        navigationController?.pushViewController(categoryPostsViewController, animated: true)
    }
    
    @objc func toCategory4(_ sender: UIButton, forEvent event: UIEvent) {
        
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let categoryPostsViewController = storyboard.instantiateViewController(identifier: "CategoryPosts") as! CategoryPostsViewController
        categoryPostsViewController.category = "sports"
        categoryPostsViewController.titleName = "スポーツ"
        navigationController?.pushViewController(categoryPostsViewController, animated: true)
    }
    
    @objc func toCategory5(_ sender: UIButton, forEvent event: UIEvent) {
        
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let categoryPostsViewController = storyboard.instantiateViewController(identifier: "CategoryPosts") as! CategoryPostsViewController
        categoryPostsViewController.category = "music"
        categoryPostsViewController.titleName = "音楽"
        navigationController?.pushViewController(categoryPostsViewController, animated: true)
    }
    
    @objc func toCategory6(_ sender: UIButton, forEvent event: UIEvent) {
        
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let categoryPostsViewController = storyboard.instantiateViewController(identifier: "CategoryPosts") as! CategoryPostsViewController
        categoryPostsViewController.category = "funny"
        categoryPostsViewController.titleName = "おもしろ"
        navigationController?.pushViewController(categoryPostsViewController, animated: true)
    }
    
    @objc func toCategory7(_ sender: UIButton, forEvent event: UIEvent) {
        
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let categoryPostsViewController = storyboard.instantiateViewController(identifier: "CategoryPosts") as! CategoryPostsViewController
        categoryPostsViewController.category = "entertainment"
        categoryPostsViewController.titleName = "エンタメ"
        navigationController?.pushViewController(categoryPostsViewController, animated: true)
    }
    
    @objc func toCategory8(_ sender: UIButton, forEvent event: UIEvent) {
        
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let categoryPostsViewController = storyboard.instantiateViewController(identifier: "CategoryPosts") as! CategoryPostsViewController
        categoryPostsViewController.category = "tv"
        categoryPostsViewController.titleName = "TV・映画"
        navigationController?.pushViewController(categoryPostsViewController, animated: true)
    }
    
    @objc func toCategory9(_ sender: UIButton, forEvent event: UIEvent) {
        
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let categoryPostsViewController = storyboard.instantiateViewController(identifier: "CategoryPosts") as! CategoryPostsViewController
        categoryPostsViewController.category = "youtube"
        categoryPostsViewController.titleName = "YouTube"
        navigationController?.pushViewController(categoryPostsViewController, animated: true)
    }
    
    @objc func toCategory10(_ sender: UIButton, forEvent event: UIEvent) {
        
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let categoryPostsViewController = storyboard.instantiateViewController(identifier: "CategoryPosts") as! CategoryPostsViewController
        categoryPostsViewController.category = "economics"
        categoryPostsViewController.titleName = "経済・金融"
        navigationController?.pushViewController(categoryPostsViewController, animated: true)
    }
    
    @objc func toCategory11(_ sender: UIButton, forEvent event: UIEvent) {
        
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let categoryPostsViewController = storyboard.instantiateViewController(identifier: "CategoryPosts") as! CategoryPostsViewController
        categoryPostsViewController.category = "business"
        categoryPostsViewController.titleName = "ビジネス"
        navigationController?.pushViewController(categoryPostsViewController, animated: true)
    }
    
    @objc func toCategory12(_ sender: UIButton, forEvent event: UIEvent) {
        
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let categoryPostsViewController = storyboard.instantiateViewController(identifier: "CategoryPosts") as! CategoryPostsViewController
        categoryPostsViewController.category = "it"
        categoryPostsViewController.titleName = "IT・テクノロジー"
        navigationController?.pushViewController(categoryPostsViewController, animated: true)
    }
    
    @objc func toCategory13(_ sender: UIButton, forEvent event: UIEvent) {
        
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let categoryPostsViewController = storyboard.instantiateViewController(identifier: "CategoryPosts") as! CategoryPostsViewController
        categoryPostsViewController.category = "science"
        categoryPostsViewController.titleName = "科学"
        navigationController?.pushViewController(categoryPostsViewController, animated: true)
    }
    
    @objc func toCategory14(_ sender: UIButton, forEvent event: UIEvent) {
        
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let categoryPostsViewController = storyboard.instantiateViewController(identifier: "CategoryPosts") as! CategoryPostsViewController
        categoryPostsViewController.category = "health"
        categoryPostsViewController.titleName = "健康・医療"
        navigationController?.pushViewController(categoryPostsViewController, animated: true)
    }
    
    @objc func toCategory15(_ sender: UIButton, forEvent event: UIEvent) {
        
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let categoryPostsViewController = storyboard.instantiateViewController(identifier: "CategoryPosts") as! CategoryPostsViewController
        categoryPostsViewController.category = "beauty"
        categoryPostsViewController.titleName = "美容"
        navigationController?.pushViewController(categoryPostsViewController, animated: true)
    }
    
    @objc func toCategory16(_ sender: UIButton, forEvent event: UIEvent) {
        
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let categoryPostsViewController = storyboard.instantiateViewController(identifier: "CategoryPosts") as! CategoryPostsViewController
        categoryPostsViewController.category = "fashion"
        categoryPostsViewController.titleName = "ファッション"
        navigationController?.pushViewController(categoryPostsViewController, animated: true)
    }
    
    @objc func toCategory17(_ sender: UIButton, forEvent event: UIEvent) {
        
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let categoryPostsViewController = storyboard.instantiateViewController(identifier: "CategoryPosts") as! CategoryPostsViewController
        categoryPostsViewController.category = "job"
        categoryPostsViewController.titleName = "仕事"
        navigationController?.pushViewController(categoryPostsViewController, animated: true)
    }
    
    @objc func toCategory18(_ sender: UIButton, forEvent event: UIEvent) {
        
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let categoryPostsViewController = storyboard.instantiateViewController(identifier: "CategoryPosts") as! CategoryPostsViewController
        categoryPostsViewController.category = "school"
        categoryPostsViewController.titleName = "学校"
        navigationController?.pushViewController(categoryPostsViewController, animated: true)
    }
    
    @objc func toCategory19(_ sender: UIButton, forEvent event: UIEvent) {
        
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let categoryPostsViewController = storyboard.instantiateViewController(identifier: "CategoryPosts") as! CategoryPostsViewController
        categoryPostsViewController.category = "hobby"
        categoryPostsViewController.titleName = "趣味"
        navigationController?.pushViewController(categoryPostsViewController, animated: true)
    }
    
    @objc func toCategory20(_ sender: UIButton, forEvent event: UIEvent) {
        
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let categoryPostsViewController = storyboard.instantiateViewController(identifier: "CategoryPosts") as! CategoryPostsViewController
        categoryPostsViewController.category = "art"
        categoryPostsViewController.titleName = "文化・芸術"
        navigationController?.pushViewController(categoryPostsViewController, animated: true)
    }
    
    @objc func toCategory21(_ sender: UIButton, forEvent event: UIEvent) {
        
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let categoryPostsViewController = storyboard.instantiateViewController(identifier: "CategoryPosts") as! CategoryPostsViewController
        categoryPostsViewController.category = "manga"
        categoryPostsViewController.titleName = "漫画・アニメ"
        navigationController?.pushViewController(categoryPostsViewController, animated: true)
    }
    
    @objc func toCategory22(_ sender: UIButton, forEvent event: UIEvent) {
        
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let categoryPostsViewController = storyboard.instantiateViewController(identifier: "CategoryPosts") as! CategoryPostsViewController
        categoryPostsViewController.category = "game"
        categoryPostsViewController.titleName = "ゲーム"
        navigationController?.pushViewController(categoryPostsViewController, animated: true)
    }
    
    @objc func toCategory23(_ sender: UIButton, forEvent event: UIEvent) {
        
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let categoryPostsViewController = storyboard.instantiateViewController(identifier: "CategoryPosts") as! CategoryPostsViewController
        categoryPostsViewController.category = "life"
        categoryPostsViewController.titleName = "暮らし・生活"
        navigationController?.pushViewController(categoryPostsViewController, animated: true)
    }
    
    @objc func toCategory24(_ sender: UIButton, forEvent event: UIEvent) {
        
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let categoryPostsViewController = storyboard.instantiateViewController(identifier: "CategoryPosts") as! CategoryPostsViewController
        categoryPostsViewController.category = "family"
        categoryPostsViewController.titleName = "家族"
        navigationController?.pushViewController(categoryPostsViewController, animated: true)
    }
    
    @objc func toCategory25(_ sender: UIButton, forEvent event: UIEvent) {
        
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let categoryPostsViewController = storyboard.instantiateViewController(identifier: "CategoryPosts") as! CategoryPostsViewController
        categoryPostsViewController.category = "love"
        categoryPostsViewController.titleName = "結婚・恋愛"
        navigationController?.pushViewController(categoryPostsViewController, animated: true)
    }
    
    @objc func toCategory26(_ sender: UIButton, forEvent event: UIEvent) {
        
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let categoryPostsViewController = storyboard.instantiateViewController(identifier: "CategoryPosts") as! CategoryPostsViewController
        categoryPostsViewController.category = "parenting"
        categoryPostsViewController.titleName = "子育て・教育"
        navigationController?.pushViewController(categoryPostsViewController, animated: true)
    }
    
    @objc func toCategory27(_ sender: UIButton, forEvent event: UIEvent) {
        
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let categoryPostsViewController = storyboard.instantiateViewController(identifier: "CategoryPosts") as! CategoryPostsViewController
        categoryPostsViewController.category = "recipe"
        categoryPostsViewController.titleName = "グルメ・レシピ"
        navigationController?.pushViewController(categoryPostsViewController, animated: true)
    }
    
    @objc func toCategory28(_ sender: UIButton, forEvent event: UIEvent) {
        
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let categoryPostsViewController = storyboard.instantiateViewController(identifier: "CategoryPosts") as! CategoryPostsViewController
        categoryPostsViewController.category = "study"
        categoryPostsViewController.titleName = "勉強・学問"
        navigationController?.pushViewController(categoryPostsViewController, animated: true)
    }
    
    @objc func toCategory29(_ sender: UIButton, forEvent event: UIEvent) {
        
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let categoryPostsViewController = storyboard.instantiateViewController(identifier: "CategoryPosts") as! CategoryPostsViewController
        categoryPostsViewController.category = "question"
        categoryPostsViewController.titleName = "質問・相談"
        navigationController?.pushViewController(categoryPostsViewController, animated: true)
    }
    
    @objc func toCategory30(_ sender: UIButton, forEvent event: UIEvent) {
        
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let categoryPostsViewController = storyboard.instantiateViewController(identifier: "CategoryPosts") as! CategoryPostsViewController
        categoryPostsViewController.category = "mystery"
        categoryPostsViewController.titleName = "不思議・謎"
        navigationController?.pushViewController(categoryPostsViewController, animated: true)
    }
    
    @objc func toCategory31(_ sender: UIButton, forEvent event: UIEvent) {
        
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let categoryPostsViewController = storyboard.instantiateViewController(identifier: "CategoryPosts") as! CategoryPostsViewController
        categoryPostsViewController.category = "prefectures"
        categoryPostsViewController.titleName = "都道府県"
        navigationController?.pushViewController(categoryPostsViewController, animated: true)
    }
    
    @objc func toCategory32(_ sender: UIButton, forEvent event: UIEvent) {
        
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let categoryPostsViewController = storyboard.instantiateViewController(identifier: "CategoryPosts") as! CategoryPostsViewController
        categoryPostsViewController.category = "world"
        categoryPostsViewController.titleName = "海外"
        navigationController?.pushViewController(categoryPostsViewController, animated: true)
    }
    
    @objc func toCategory33(_ sender: UIButton, forEvent event: UIEvent) {
        
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let categoryPostsViewController = storyboard.instantiateViewController(identifier: "CategoryPosts") as! CategoryPostsViewController
        categoryPostsViewController.category = "travel"
        categoryPostsViewController.titleName = "旅行"
        navigationController?.pushViewController(categoryPostsViewController, animated: true)
    }
    
    @objc func toCategory34(_ sender: UIButton, forEvent event: UIEvent) {
        
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let categoryPostsViewController = storyboard.instantiateViewController(identifier: "CategoryPosts") as! CategoryPostsViewController
        categoryPostsViewController.category = "pr"
        categoryPostsViewController.titleName = "プロモーション"
        navigationController?.pushViewController(categoryPostsViewController, animated: true)
    }
    
    @objc func toCategory35(_ sender: UIButton, forEvent event: UIEvent) {
        
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let categoryPostsViewController = storyboard.instantiateViewController(identifier: "CategoryPosts") as! CategoryPostsViewController
        categoryPostsViewController.category = "car"
        categoryPostsViewController.titleName = "自動車・乗り物"
        navigationController?.pushViewController(categoryPostsViewController, animated: true)
    }
    
    @objc func toCategory36(_ sender: UIButton, forEvent event: UIEvent) {
        
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let categoryPostsViewController = storyboard.instantiateViewController(identifier: "CategoryPosts") as! CategoryPostsViewController
        categoryPostsViewController.category = "pet"
        categoryPostsViewController.titleName = "ペット・動物"
        navigationController?.pushViewController(categoryPostsViewController, animated: true)
    }
    
    @objc func toCategory37(_ sender: UIButton, forEvent event: UIEvent) {
        
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let categoryPostsViewController = storyboard.instantiateViewController(identifier: "CategoryPosts") as! CategoryPostsViewController
        categoryPostsViewController.category = "chat"
        categoryPostsViewController.titleName = "雑談・ネタ"
        navigationController?.pushViewController(categoryPostsViewController, animated: true)
    }
    
    @objc func toCategory38(_ sender: UIButton, forEvent event: UIEvent) {
        
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let categoryPostsViewController = storyboard.instantiateViewController(identifier: "CategoryPosts") as! CategoryPostsViewController
        categoryPostsViewController.category = "other"
        categoryPostsViewController.titleName = "その他"
        navigationController?.pushViewController(categoryPostsViewController, animated: true)
    }
    
    // セル内のボタンがタップされた時に呼ばれるメソッド
    @objc func handleButton(_ sender: UIButton, forEvent event: UIEvent) {
        print("DEBUG_PRINT: likeボタンがタップされました。")
        
        // likesを更新する
        if let myid = Auth.auth().currentUser?.uid {
            // 更新データを作成する
            var updateValue: FieldValue
            if postdata!.isLiked {
                // すでにいいねをしている場合は、いいね解除のためmyidを取り除く更新データを作成
                updateValue = FieldValue.arrayRemove([["uid": myid, "time": postdata!.likedTime]])
                postdata!.isLiked = false // falseにすべき
            } else {
                // 今回新たにいいねを押した場合は、myidを追加する更新データを作成
                updateValue = FieldValue.arrayUnion([["uid": myid, "time": Date.timeIntervalSinceReferenceDate]])
                postdata!.isLiked = true // trueにすべき
            }
            // likesに更新データを書き込む
            let postRef = Firestore.firestore().collection("posts").document(postdata!.id)
            postRef.updateData(["likes": updateValue])
        }
    }
    
    // セル内のボタンがタップされた時に呼ばれるメソッド
    @objc func handleButton2(_ sender: UIButton, forEvent event: UIEvent) {
        print("DEBUG_PRINT: likeボタンがタップされました。")
        
        // タップされたセルのインデックスを求める
        let touch = event.allTouches?.first
        let point = touch!.location(in: self.chatRoomTableView)
        guard let indexPath = chatRoomTableView.indexPathForRow(at: point) else { return }
        let row = indexPath.row
        // 配列からタップされたインデックスのデータを取り出す
        let messageData = self.messageArray[row]
        print("messageData.id:\(messageData.id)")
        
        // likesを更新する
        if let myid = Auth.auth().currentUser?.uid {
            // 更新データを作成する
            var updateValue: FieldValue
            if messageData.isLiked {
                print("messageData.isLiked")
                // すでにいいねをしている場合は、いいね解除のためmyidを取り除く更新データを作成
                updateValue = FieldValue.arrayRemove([["uid": myid, "time": messageData.likedTime]])
                messageData.isLiked = false
            } else {
                print("messageData.isLiked == false")
                // 今回新たにいいねを押した場合は、myidを追加する更新データを作成
                updateValue = FieldValue.arrayUnion([["uid": myid, "time": Date.timeIntervalSinceReferenceDate]])
                messageData.isLiked = true
            }
            // likesに更新データを書き込む
            let postRef = Firestore.firestore().collection("posts").document(postdata!.id).collection("messages").document(messageData.id)
            postRef.updateData(["likes": updateValue])
        }
    }
    
    @objc func bookmarkButton(_ sender: UIButton, forEvent event: UIEvent) {
        print("DEBUG_PRINT: likeボタンがタップされました。")
        
        //ここで振動させる
        
        
        // bookmarksを更新する
        if let myid = Auth.auth().currentUser?.uid {
            // 更新データを作成する
            var updateValue: FieldValue
            if postdata!.isBookmarked {
                // すでにいいねをしている場合は、いいね解除のためmyidを取り除く更新データを作成
                updateValue = FieldValue.arrayRemove([["uid": myid, "time": postdata!.bookmarkedTime]])
                postdata!.isBookmarked = false // falseにすべき
            } else {
                // 今回新たにブックマークを押した場合は、myidを追加する更新データを作成
                updateValue = FieldValue.arrayUnion([["uid": myid, "time": Date.timeIntervalSinceReferenceDate]])
                postdata!.isBookmarked = true // trueにすべき
            }
            // bookmarksに更新データを書き込む
            let postRef = Firestore.firestore().collection("posts").document(postdata!.id)
            postRef.updateData(["bookmarks": updateValue])
        }
    }
    
    // セル内のボタンがタップされた時に呼ばれるメソッド
    @objc func userProfileButton(_ sender: UIButton, forEvent event: UIEvent) {
        
        // 配列からタップされたインデックスのデータを取り出す
        let uid = postdata!.uid
        
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        
        let baseViewController = storyboard.instantiateViewController(identifier: "Profile") as! BaseViewController
        baseViewController.userID = uid
        baseViewController.type = "private"
        //コメント画面にPush遷移
        navigationController?.pushViewController(baseViewController, animated: true)
    }
    
    // セル内のボタンがタップされた時に呼ばれるメソッド
    @objc func userProfileButton2(_ sender: UIButton, forEvent event: UIEvent) {
        
        // 配列からタップされたインデックスのデータを取り出す
        let uid = postdata!.uid
        let communityUid = postdata!.community
        
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
    
    // セル内のボタンがタップされた時に呼ばれるメソッド
    @objc func userProfileButton3(_ sender: UIButton, forEvent event: UIEvent) {
        
        // タップされたセルのインデックスを求める
        let touch = event.allTouches?.first
        let point = touch!.location(in: self.chatRoomTableView)
        guard let indexPath = chatRoomTableView.indexPathForRow(at: point) else { return }
        let row = indexPath.row
        // 配列からタップされたインデックスのデータを取り出す
        let messageData = self.messageArray[row]
        let uid = messageData.uid
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let baseViewController = storyboard.instantiateViewController(identifier: "Profile") as! BaseViewController
        baseViewController.userID = uid
        baseViewController.type = "private"
        //コメント画面にPush遷移
        navigationController?.pushViewController(baseViewController, animated: true)
    }
    
    // セル内のボタンがタップされた時に呼ばれるメソッド
    @objc func userProfileButton4(_ sender: UIButton, forEvent event: UIEvent) {
       
        // タップされたセルのインデックスを求める
        let touch = event.allTouches?.first
        let point = touch!.location(in: self.chatRoomTableView)
        guard let indexPath = chatRoomTableView.indexPathForRow(at: point) else { return }
        let row = indexPath.row
        // 配列からタップされたインデックスのデータを取り出す
        let messageData = self.messageArray[row]
        let uid = messageData.replyName
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let baseViewController = storyboard.instantiateViewController(identifier: "Profile") as! BaseViewController
        baseViewController.userID = uid
        baseViewController.type = "private"
        //コメント画面にPush遷移
        navigationController?.pushViewController(baseViewController, animated: true)
    }
    
    //スレッドを作成した人がスレッドを削除するとき
    @objc func alertButton(_ sender: UIButton, forEvent event: UIEvent){
        print("アラートボタン")
        
        if self.isShown == true {
            let image = UIImage(named: "icons8-送信されました-24")
            let state = UIControl.State.normal
            self.chatInputAccessoryView.sendButton.setImage(image, for: state)
            self.chatInputAccessoryView.isHidden = true
            self.chatInputAccessoryView.removeText()
            self.chatInputAccessoryView.chatTextView.resignFirstResponder()
            self.isShown = false
        }
        
        // インスタンス生成　styleはActionSheet.
        let myAlert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        let myAction_1 = UIAlertAction(title: "詳細設定を変更する", style: UIAlertAction.Style.default, handler: {
            (action: UIAlertAction!) in
            let storyboard = UIStoryboard(name: "ChatRoom", bundle: Bundle.main)
            let nextView = storyboard.instantiateViewController(withIdentifier: "PostEdit")as! PostEditViewController
            nextView.documentID = self.postdata!.id
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
                    let postRef = Firestore.firestore().collection("posts").document(self.postdata!.id)
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
    
    //スレッドを作成した人以外がスレッドを通報するとき
    @objc func alertButton2(_ sender: UIButton, forEvent event: UIEvent){
        
        print("alert")
        
        if self.isShown == true {
            let image = UIImage(named: "icons8-送信されました-24")
            let state = UIControl.State.normal
            self.chatInputAccessoryView.sendButton.setImage(image, for: state)
            self.chatInputAccessoryView.isHidden = true
            self.chatInputAccessoryView.removeText()
            self.chatInputAccessoryView.chatTextView.resignFirstResponder()
            self.isShown = false
        }
        
        // インスタンス生成　styleはActionSheet.
        let myAlert = UIAlertController(title: "問題のある投稿", message: "あてはまるものをお選びください", preferredStyle: UIAlertController.Style.alert)
        // アクションを生成.
        let myAction_1 = UIAlertAction(title: "投稿を通報する", style: UIAlertAction.Style.default, handler: {
            (action: UIAlertAction!) in
            print("通報")
            
            let documentID = self.postdata?.id
            let documentUid = self.postdata!.uid
            let documentId:String = String(documentID!)
            let caption:String = String(self.postdata!.caption!)
            
            if let myid = Auth.auth().currentUser?.uid {
                // 更新データを作成する
                var updateValue: FieldValue
                
                //すでに通報している場合
                if self.postdata!.myReportExist {
                    let alertController:UIAlertController =
                        UIAlertController(title:"投稿の通報",
                                          message: "あてはまるものをお選びください",
                                          preferredStyle: .alert)
                    
                    
                    let action1:UIAlertAction =
                        UIAlertAction(title: "不審な内容またはスパム投稿である",
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
                    
                    print("新しいmyidを加えます")
                    
                    let alertController:UIAlertController =
                        UIAlertController(title:"投稿の通報",
                                          message: "あてはまるものをお選びください",
                                          preferredStyle: .alert)
                    
                    updateValue = FieldValue.arrayUnion([["uid": myid, "time": Date.timeIntervalSinceReferenceDate]])
                    let postRef = Firestore.firestore().collection("posts").document(self.postdata!.id)
                    
                    let action1:UIAlertAction =
                        UIAlertAction(title: "不審な内容またはスパム投稿である",
                                      style: .default,
                                      handler:{
                                        (action:UIAlertAction!) -> Void in
                                        // 処理
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
                
                if let myid = Auth.auth().currentUser?.uid {
                    // 更新データを作成する
                    var updateValue: FieldValue
                    print("新しいmyidを加えます")
                    updateValue = FieldValue.arrayUnion([["uid": myid, "time": Date.timeIntervalSinceReferenceDate]])
                    let postRef = Firestore.firestore().collection("posts").document(self.postdata!.id)
                    postRef.updateData(["blocks": updateValue])
                    
                    //遷移してから以下のコメントを出したい
                    let banner = NotificationBanner(title: "非表示にしました", leftView: nil, rightView: nil, style: .info, colors: nil)
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
        
        let myAction_3 = UIAlertAction(title: "ユーザーをブロックする", style: UIAlertAction.Style.default, handler: {
            (action: UIAlertAction!) in
            
            let alert: UIAlertController = UIAlertController(title: "よろしいですか？", message: "このユーザーの投稿は今後表示されなくなります。", preferredStyle:  UIAlertController.Style.alert)
            
            let defaultAction: UIAlertAction = UIAlertAction(title: "はい", style: UIAlertAction.Style.destructive, handler:{
                (action: UIAlertAction!) -> Void in
                
                print("ブロック")
                // 配列からタップされたインデックスのデータを取り出す
                
                if let myid = Auth.auth().currentUser?.uid {
                    
                    let time = Date.timeIntervalSinceReferenceDate
                    
                    let banner = NotificationBanner(title: "ブロックしました", leftView: nil, rightView: nil, style: .info, colors: nil)
                    banner.autoDismiss = false
                    banner.dismissOnTap = true
                    banner.show(queuePosition: .front, bannerPosition: .top, queue: .default, on: self.navigationController!)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.2, execute: {
                        banner.dismiss()
                        self.navigationController?.popViewController(animated: true)
                    })
                    
                    var updateValue1: FieldValue
                    var updateValue2: FieldValue
                    var updateValue3: FieldValue
                    var updateValue4: FieldValue
                    
                    updateValue1 = FieldValue.arrayUnion([["uid": myid, "time": time]])
                    updateValue2 = FieldValue.arrayUnion([self.postdata!.uid])
                    updateValue3 = FieldValue.arrayUnion([myid])
                    updateValue4 = FieldValue.arrayUnion([["uid": self.postdata!.uid, "time": time]])
                    
                    let userRef1 = Firestore.firestore().collection("users").document(self.postdata!.uid)
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
                    
                    let blockedRef = Firestore.firestore().collection("blockedUsers").document(self.postdata!.uid)
                    
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
    
    //自分のコメントを削除するとき
    @objc func alertButton3(_ sender: UIButton, forEvent event: UIEvent){
        
        if self.isShown == true {
            let image = UIImage(named: "icons8-送信されました-24")
            let state = UIControl.State.normal
            self.chatInputAccessoryView.sendButton.setImage(image, for: state)
            self.chatInputAccessoryView.isHidden = true
            self.chatInputAccessoryView.removeText()
            self.chatInputAccessoryView.chatTextView.resignFirstResponder()
            self.isShown = false
        }
        
        // タップされたセルのインデックスを求める
        let touch = event.allTouches?.first
        let point = touch!.location(in: self.chatRoomTableView)
        guard let indexPath = chatRoomTableView.indexPathForRow(at: point) else { return }
        let row = indexPath.row
        
        // インスタンス生成　styleはActionSheet.
        let myAlert = UIAlertController(title: "このコメントを削除しますか？", message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        // アクションを生成.
        let myAction_1 = UIAlertAction(title: "コメントを削除する", style: UIAlertAction.Style.destructive, handler: {
            (action: UIAlertAction!) in
            let alert: UIAlertController = UIAlertController(title: "コメントを削除", message: "本当にこのコメントを削除してよろしいですか？", preferredStyle:  UIAlertController.Style.alert)
            
            let defaultAction: UIAlertAction = UIAlertAction(title: "削除", style: UIAlertAction.Style.destructive, handler:{
                (action: UIAlertAction!) -> Void in
                
                //削除のコード
                //現在ログイン中のユーザーIDのみ取り出す
                let db = Firestore.firestore()
                db.collection("posts").document(self.postdata!.id).collection("messages").getDocuments() { (documents, err) in
                    if let err = err {
                        print("Error getting documents: \(err)")
                    }
                    
                    // 更新データを作成する
                    var updateValue: FieldValue
                    var updateValue2: FieldValue
                    var updateValue3: FieldValue
                    
                    let postRef = Firestore.firestore().collection("posts").document(self.postdata!.id)
                    
                    // 配列からタップされたインデックスのデータを取り出す
                    let messageData = self.messageArray[row]
                    let messageRef = Firestore.firestore().collection("posts").document(self.postdata!.id).collection("messages").document(messageData.id)
                    
                    updateValue = FieldValue.arrayRemove([["uid": messageData.uid, "time": messageData.time]])
                    postRef.updateData(["comments": updateValue])
                    
                    updateValue2 = FieldValue.arrayRemove([["uid": messageData.uid, "time": messageData.time]])
                    postRef.updateData(["allComments": updateValue2])
                    
                    updateValue3 = FieldValue.arrayUnion([["uid": messageData.uid, "time": Date.timeIntervalSinceReferenceDate]])
                    messageRef.updateData(["deletes2": updateValue3])
                    
                    let banner = NotificationBanner(title: "削除しました", leftView: nil, rightView: nil, style: .info, colors: nil)
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
        
        let myAction_2 = UIAlertAction(title: "キャンセル", style: UIAlertAction.Style.cancel, handler: {
            (action: UIAlertAction!) in
            print("キャンセル")
        })
        // アクションを追加.
        myAlert.addAction(myAction_1)
        myAlert.addAction(myAction_2)
        self.present(myAlert, animated: true, completion: nil)
    }
    
    //MOD(スレッドを作成した人)が自分以外のコメントを削除するとき
    @objc func alertButton3b(_ sender: UIButton, forEvent event: UIEvent){
        
        
        if self.isShown == true {
            let image = UIImage(named: "icons8-送信されました-24")
            let state = UIControl.State.normal
            self.chatInputAccessoryView.sendButton.setImage(image, for: state)
            self.chatInputAccessoryView.isHidden = true
            self.chatInputAccessoryView.removeText()
            self.chatInputAccessoryView.chatTextView.resignFirstResponder()
            self.isShown = false
        }
        // タップされたセルのインデックスを求める
        let touch = event.allTouches?.first
        let point = touch!.location(in: self.chatRoomTableView)
        guard let indexPath = chatRoomTableView.indexPathForRow(at: point) else { return }
        let row = indexPath.row
        
        // インスタンス生成　styleはActionSheet.
        let myAlert = UIAlertController(title: "問題のあるコメント", message: "あてはまるものをお選びください", preferredStyle: UIAlertController.Style.alert)
        // アクションを生成.
        let myAction_1 = UIAlertAction(title: "コメントを通報する", style: UIAlertAction.Style.default, handler: {
            (action: UIAlertAction!) in
            
            // 更新データを作成する
            var updateValue: FieldValue
            var updateValue2: FieldValue
            var updateValue3: FieldValue
            
            let postRef = Firestore.firestore().collection("posts").document(self.postdata!.id)
            
            // 配列からタップされたインデックスのデータを取り出す
            let messageData = self.messageArray[row]
            let documentId = messageData.id
            let documentUid = messageData.uid
            let caption:String = String(messageData.message)
            let messageRef = Firestore.firestore().collection("posts").document(self.postdata!.id).collection("messages").document(messageData.id)
            
            if let myid = Auth.auth().currentUser?.uid {
                
                //既に自分が通報している場合
                if messageData.myReportExist {
                    let alertController:UIAlertController =
                        UIAlertController(title:"コメントの通報",
                                          message: "あてはまるものをお選びください",
                                          preferredStyle: .alert)
                    
                    let action1:UIAlertAction =
                        UIAlertAction(title: "不審な内容またはスパム投稿である",
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
                    
                    //通報が既に99回されていて自分が初めて通報する場合(あと一回の通報で投稿非表示)
                    if messageData.reports2.count >= 99 {
                        print("この通報で削除になります。")
                        
                        updateValue = FieldValue.arrayRemove([["uid": messageData.uid, "time": messageData.time]])
                        updateValue2 = FieldValue.arrayRemove([["uid": messageData.uid, "time": messageData.time]])
                        updateValue3 = FieldValue.arrayUnion([["uid": myid, "time": Date.timeIntervalSinceReferenceDate]])
                        
                        let alertController:UIAlertController =
                            UIAlertController(title:"コメントの通報",
                                              message: "あてはまるものをお選びください",
                                              preferredStyle: .alert)
                        
                        let action1:UIAlertAction =
                            UIAlertAction(title: "不審な内容またはスパム投稿である",
                                          style: .default,
                                          handler:{
                                            (action:UIAlertAction!) -> Void in
                                            // 処理
                                            postRef.updateData(["comments": updateValue])
                                            postRef.updateData(["allComments": updateValue2])
                                            messageRef.updateData(["deletes2": updateValue3])
                                            
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
                                            postRef.updateData(["comments": updateValue])
                                            postRef.updateData(["allComments": updateValue2])
                                            messageRef.updateData(["deletes2": updateValue3])
                                            
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
                                            postRef.updateData(["comments": updateValue])
                                            postRef.updateData(["allComments": updateValue2])
                                            messageRef.updateData(["deletes2": updateValue3])
                                            
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
                                            postRef.updateData(["comments": updateValue])
                                            postRef.updateData(["allComments": updateValue2])
                                            messageRef.updateData(["deletes2": updateValue3])
                                            
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
                        
                        
                    }else {
                        print("通報が加わります")
                        print("新しいmyidを加えます")
                        var updateValue: FieldValue
                        updateValue = FieldValue.arrayUnion([["uid": myid, "time": Date.timeIntervalSinceReferenceDate]])
                        
                        
                        let alertController:UIAlertController =
                            UIAlertController(title:"コメントの通報",
                                              message: "あてはまるものをお選びください",
                                              preferredStyle: .alert)
                        
                        let action1:UIAlertAction =
                            UIAlertAction(title: "不審な内容またはスパム投稿である",
                                          style: .default,
                                          handler:{
                                            (action:UIAlertAction!) -> Void in
                                            // 処理
                                            messageRef.updateData(["reports2": updateValue])
                                            
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
                                            messageRef.updateData(["reports2": updateValue])
                                            
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
                                            messageRef.updateData(["reports2": updateValue])
                                            
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
                                            messageRef.updateData(["reports2": updateValue])
                                            
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
            }
        })
        
        let myAction_2 = UIAlertAction(title: "コメントを削除する", style: UIAlertAction.Style.default, handler: {
            (action: UIAlertAction!) in
            let alert: UIAlertController = UIAlertController(title: "本当にコメントを削除してよろしいでしょうか？", message: nil, preferredStyle:  UIAlertController.Style.alert)
            
            let defaultAction: UIAlertAction = UIAlertAction(title: "削除", style: UIAlertAction.Style.destructive, handler:{
                (action: UIAlertAction!) -> Void in
                //削除のコード
                
                let db = Firestore.firestore()
                db.collection("posts").document(self.postdata!.id).collection("messages").getDocuments() { (documents, err) in
                    if let err = err {
                        print("Error getting documents: \(err)")
                    }
                    
                    // 更新データを作成する
                    var updateValue: FieldValue
                    var updateValue2: FieldValue
                    
                    let postRef = Firestore.firestore().collection("posts").document(self.postdata!.id)
                    
                    // 配列からタップされたインデックスのデータを取り出す
                    let messageData = self.messageArray[row]
                    let messageRef = Firestore.firestore().collection("posts").document(self.postdata!.id).collection("messages").document(messageData.id)
                    
                    updateValue = FieldValue.arrayRemove([["uid": messageData.uid, "time": messageData.time]])
                    postRef.updateData(["allComments": updateValue])
                    
                    updateValue2 = FieldValue.arrayUnion([["uid": messageData.uid, "time": Date.timeIntervalSinceReferenceDate]])
                    messageRef.updateData(["deletes2": updateValue2])
                    
                    let banner = NotificationBanner(title: "削除しました", leftView: nil, rightView: nil, style: .info, colors: nil)
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
            
            let alert: UIAlertController = UIAlertController(title: "よろしいですか？", message: "このユーザーの投稿は今後表示されなくなります。", preferredStyle:  UIAlertController.Style.alert)
            
            let defaultAction: UIAlertAction = UIAlertAction(title: "はい", style: UIAlertAction.Style.destructive, handler:{
                (action: UIAlertAction!) -> Void in
                
                print("ブロック")
                // 配列からタップされたインデックスのデータを取り出す
                let messageData = self.messageArray[row]
                
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
                    updateValue2 = FieldValue.arrayUnion([messageData.uid])
                    updateValue3 = FieldValue.arrayUnion([myid])
                    updateValue4 = FieldValue.arrayUnion([["uid": messageData.uid, "time": time]])
                    
                    let userRef1 = Firestore.firestore().collection("users").document(messageData.uid)
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
                    
                    let blockedRef = Firestore.firestore().collection("blockedUsers").document(messageData.uid)
                    
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
                    
                    if self.postdata!.uid == messageData.uid {
                        self.navigationController?.popViewController(animated: true)
                    }
                    
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
    
    //コメントの通報 2回以上通報がたまるとそのコメントを非表示
    @objc func alertButton4(_ sender: UIButton, forEvent event: UIEvent){
        
        if self.isShown == true {
            let image = UIImage(named: "icons8-送信されました-24")
            let state = UIControl.State.normal
            self.chatInputAccessoryView.sendButton.setImage(image, for: state)
            self.chatInputAccessoryView.isHidden = true
            self.chatInputAccessoryView.removeText()
            self.chatInputAccessoryView.chatTextView.resignFirstResponder()
            self.isShown = false
        }
        
        // タップされたセルのインデックスを求める
        let touch = event.allTouches?.first
        let point = touch!.location(in: self.chatRoomTableView)
        guard let indexPath = chatRoomTableView.indexPathForRow(at: point) else { return }
        let row = indexPath.row
        
        print("alert")
        // インスタンス生成　styleはActionSheet.
        let myAlert = UIAlertController(title: "問題のあるコメント", message: "あてはまるものをお選びください", preferredStyle: UIAlertController.Style.alert)
        // アクションを生成.
        let myAction_1 = UIAlertAction(title: "コメントを通報する", style: UIAlertAction.Style.default, handler: {
            (action: UIAlertAction!) in
            print("YES")
            
            // 更新データを作成する
            var updateValue: FieldValue
            var updateValue2: FieldValue
            var updateValue3: FieldValue
            
            let postRef = Firestore.firestore().collection("posts").document(self.postdata!.id)
            
            // 配列からタップされたインデックスのデータを取り出す
            let messageData = self.messageArray[row]
            let documentId = messageData.id
            let documentUid = messageData.uid
            let caption:String = String(messageData.message)
            let messageRef = Firestore.firestore().collection("posts").document(self.postdata!.id).collection("messages").document(messageData.id)
            
            if let myid = Auth.auth().currentUser?.uid {
                
                //既に自分が通報している場合
                if messageData.myReportExist {
                    let alertController:UIAlertController =
                        UIAlertController(title:"コメントの通報",
                                          message: "あてはまるものをお選びください",
                                          preferredStyle: .alert)
                    
                    let action1:UIAlertAction =
                        UIAlertAction(title: "不審な内容またはスパム投稿である",
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
                }  else{
                    
                    //通報が既に99回されていて自分が初めて通報する場合(あと一回の通報で投稿非表示)
                    if messageData.reports2.count >= 99 {
                        print("この通報で削除になります。")
                        
                        updateValue = FieldValue.arrayRemove([["uid": messageData.uid, "time": messageData.time]])
                        updateValue2 = FieldValue.arrayRemove([["uid": messageData.uid, "time": messageData.time]])
                        updateValue3 = FieldValue.arrayUnion([["uid": myid, "time": Date.timeIntervalSinceReferenceDate]])
                        
                        let alertController:UIAlertController =
                            UIAlertController(title:"コメントの通報",
                                              message: "あてはまるものをお選びください",
                                              preferredStyle: .alert)
                        
                        let action1:UIAlertAction =
                            UIAlertAction(title: "不審な内容またはスパム投稿である",
                                          style: .default,
                                          handler:{
                                            (action:UIAlertAction!) -> Void in
                                            // 処理
                                            postRef.updateData(["comments": updateValue])
                                            postRef.updateData(["allComments": updateValue2])
                                            messageRef.updateData(["deletes2": updateValue3])
                                            
                                            
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
                                            postRef.updateData(["comments": updateValue])
                                            postRef.updateData(["allComments": updateValue2])
                                            messageRef.updateData(["deletes2": updateValue3])
                                            
                                            
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
                                            postRef.updateData(["comments": updateValue])
                                            postRef.updateData(["allComments": updateValue2])
                                            messageRef.updateData(["deletes2": updateValue3])
                                            
                                            
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
                                            postRef.updateData(["comments": updateValue])
                                            postRef.updateData(["allComments": updateValue2])
                                            messageRef.updateData(["deletes2": updateValue3])
                                            
                                            
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
                        
                        
                    }else {
                        print("通報が加わります")
                        print("新しいmyidを加えます")
                        var updateValue: FieldValue
                        updateValue = FieldValue.arrayUnion([["uid": myid, "time": Date.timeIntervalSinceReferenceDate]])
                        
                        
                        let alertController:UIAlertController =
                            UIAlertController(title:"コメントの通報",
                                              message: "あてはまるものをお選びください",
                                              preferredStyle: .alert)
                        
                        
                        let action1:UIAlertAction =
                            UIAlertAction(title: "不審な内容またはスパム投稿である",
                                          style: .default,
                                          handler:{
                                            (action:UIAlertAction!) -> Void in
                                            // 処理
                                            messageRef.updateData(["reports2": updateValue])
                                            
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
                                            messageRef.updateData(["reports2": updateValue])
                                            
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
                                            messageRef.updateData(["reports2": updateValue])
                                            
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
                                            messageRef.updateData(["reports2": updateValue])
                                            
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
            }
            
        })
        
        let myAction_2 = UIAlertAction(title: "コメントを非表示にする", style: UIAlertAction.Style.default, handler: {
            (action: UIAlertAction!) in
            
            let alert: UIAlertController = UIAlertController(title: "コメントを非表示", message: "本当にこのコメントを非表示にしてよろしいですか？", preferredStyle:  UIAlertController.Style.alert)
            
            let defaultAction: UIAlertAction = UIAlertAction(title: "非表示", style: UIAlertAction.Style.destructive, handler:{
                (action: UIAlertAction!) -> Void in
                
                print("非表示")
                
                if let myid = Auth.auth().currentUser?.uid {
                    // 更新データを作成する
                    var updateValue: FieldValue
                    print("新しいmyidを加えます")
                    updateValue = FieldValue.arrayUnion([["uid": myid, "time": Date.timeIntervalSinceReferenceDate]])
                    
                    let messageData = self.messageArray[row]
                    let messageRef = Firestore.firestore().collection("posts").document(self.postdata!.id).collection("messages").document(messageData.id)
                    messageRef.updateData(["blocks2": updateValue])
                    
                    //遷移してから以下のコメントを出したい
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
            
            let alert: UIAlertController = UIAlertController(title: "よろしいですか？", message: "このユーザーの投稿は今後表示されなくなります。", preferredStyle:  UIAlertController.Style.alert)
            
            let defaultAction: UIAlertAction = UIAlertAction(title: "はい", style: UIAlertAction.Style.destructive, handler:{
                (action: UIAlertAction!) -> Void in
                
                print("ブロック")
                // 配列からタップされたインデックスのデータを取り出す
                let messageData = self.messageArray[row]
                
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
                    updateValue2 = FieldValue.arrayUnion([messageData.uid])
                    updateValue3 = FieldValue.arrayUnion([myid])
                    updateValue4 = FieldValue.arrayUnion([["uid": messageData.uid, "time": time]])
                    
                    let userRef1 = Firestore.firestore().collection("users").document(messageData.uid)
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
                    
                    let blockedRef = Firestore.firestore().collection("blockedUsers").document(messageData.uid)
                    
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
                    if self.postdata!.uid == messageData.uid {
                        self.navigationController?.popViewController(animated: true)
                    }
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
}


