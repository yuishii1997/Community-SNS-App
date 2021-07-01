//
//  PostViewControlle.swift
//  Nomad-App
//
//  Created by yuishii on 2020/07/13.
//  Copyright © 2020 Yu Ishii. All rights reserved.
//
// スレッド新規投稿画面

import UIKit
import Firebase
import CropViewController
import SVProgressHUD
import NotificationBannerSwift
import KMPlaceholderTextView
import SDWebImage
import Darwin


class PostViewController: UIViewController, UITextViewDelegate,UITextFieldDelegate,CropViewControllerDelegate, APTextViewDelegate{
    
    var userdata: UserData?
    var userdata2: UserData?
    var userArray: [UserData] = []
    var userID: String = ""
    
    var listener1: ListenerRegistration!
    var listener2: ListenerRegistration!
    var listener3: ListenerRegistration!
    
    @IBOutlet weak var textView: KMPlaceholderTextView!
    @IBOutlet weak var postButton: UIBarButtonItem!
    
    @IBOutlet weak var photo: UIImageView!{
        didSet {
            photo.contentMode =  UIView.ContentMode.scaleAspectFill
            photo.clipsToBounds = true
            photo.layer.cornerRadius = 4.0
        }
    }
    
    @IBOutlet weak var photoBackView: UIView! {
        didSet {
            photoBackView.layer.cornerRadius = 4.0
        }
    }
    
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
    
    @IBOutlet weak var chooseLabel: UILabel!
    @IBOutlet weak var caption2Label: UILabel!
    
    
    @IBOutlet weak var iconView: UIView! {
        didSet {
            iconView.backgroundColor = UIColor.rgb(red: 248, green: 248, blue: 248)
            iconView.layer.cornerRadius = iconView.frame.height / 2
        }
    }
    
    @IBOutlet weak var unfocusBtn: UIButton!
    
    @IBOutlet weak var offSwitch: UISwitch! {
        didSet {
            offSwitch.isOn = false
            //            offSwitch.backgroundColor = .systemGray4
            //offSwitch.layer.cornerRadius = offSwitch.frame.height / 2
            offSwitch.onTintColor = UIColor.rgb(red: 74, green: 162, blue: 235)
        }
    }
    
    @IBOutlet weak var privateSwitch: UISwitch!{
        didSet {
            privateSwitch.isOn = false
            //            privateSwitch.backgroundColor = .systemGray4
            //            privateSwitch.layer.cornerRadius = privateSwitch.frame.height / 2
            privateSwitch.onTintColor = UIColor.rgb(red: 74, green: 162, blue: 235)
        }
    }
    
    @IBOutlet weak var commentOffLabel: UILabel!
    
    @IBOutlet weak var offCaption: UILabel! {
        didSet {
            offCaption.textColor = .black
        }
    }
    
    @IBOutlet weak var privateLabel: UILabel!
    
    @IBOutlet weak var privateCaption: UILabel!{
        didSet {
            privateCaption.textColor = .black
        }
    }
    
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    
    var selectedImage: UIImage!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //ナビゲーションバーの色
        //self.navigationController?.navigationBar.barTintColor = UIColor.black
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.tintColor = UIColor.black
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.black]
        
        //ナビゲーションバーの色
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        
        postButton.isEnabled = false
        postButton.tintColor = .link
        
        textView.delegate = self
        
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.selectImageView))
        photo.addGestureRecognizer(tapGesture)
        photo.isUserInteractionEnabled = true
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
        let backBarButtonItem = UIBarButtonItem()
        backBarButtonItem.title = "Back"
        self.navigationItem.backBarButtonItem = backBarButtonItem
    }
    
    // 画面が閉じる直前に呼ばれる
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        SVProgressHUD.setDefaultStyle(.custom)
        SVProgressHUD.setDefaultMaskType(.custom)
        SVProgressHUD.setForegroundColor(.black)
        SVProgressHUD.setBackgroundColor(.white)
        SVProgressHUD.setDefaultMaskType(.black)
        //withDelayにIntを設定
        SVProgressHUD.dismiss(withDelay: 1.7)
        
        if ( self.listener1 != nil ){
            listener1.remove()
            listener1 = nil
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
        
        if Auth.auth().currentUser != nil {
            let myid = Auth.auth().currentUser!.uid
            
            if ( self.listener1 == nil ) {
                let userRef = Firestore.firestore().collection("users").document(myid)
                self.listener1 = userRef.addSnapshotListener() { (documentSnapshot, error) in
                    guard let document = documentSnapshot else {
                        print("Error fetching document: \(error!)")
                        return
                    }
                    self.userdata  = UserData(document: document)
                    
                    let myid = self.userdata?.uid
                    
                    if self.userdata?.postCaption != nil {
                        self.caption2Label.text = self.userdata?.postCaption
                        self.caption2Label.textColor = .black
                    }else{
                        self.caption2Label.text = "説明を追加"
                        self.caption2Label.textColor = .black
                    }
                    
                    if self.userdata?.category == nil || self.userdata?.category == "n"{
                        self.categoryLabel.text = "カテゴリーを追加"
                        self.categoryLabel.textColor = .black
                    }else{
                        self.categoryLabel.textColor = .black
                        if self.userdata?.category == "news" {
                            self.categoryLabel.text = "ニュース"
                        }else if self.userdata?.category == "trend" {
                            self.categoryLabel.text = "話題・トレンド"
                        }else if self.userdata?.category == "politics" {
                            self.categoryLabel.text = "政治・社会"
                        }else if self.userdata?.category == "sports" {
                            self.categoryLabel.text = "スポーツ"
                        }else if self.userdata?.category == "music" {
                            self.categoryLabel.text = "音楽"
                        }else if self.userdata?.category == "funny" {
                            self.categoryLabel.text = "おもしろ"
                        }else if self.userdata?.category == "entertainment" {
                            self.categoryLabel.text = "エンタメ"
                        }else if self.userdata?.category == "tv" {
                            self.categoryLabel.text = "TV・映画"
                        }else if self.userdata?.category == "youtube" {
                            self.categoryLabel.text = "YouTube"
                        }else if self.userdata?.category == "economics" {
                            self.categoryLabel.text = "経済・金融"
                        }else if self.userdata?.category == "business" {
                            self.categoryLabel.text = "ビジネス"
                        }else if self.userdata?.category == "it" {
                            self.categoryLabel.text = "IT・テクノロジー"
                        }else if self.userdata?.category == "science" {
                            self.categoryLabel.text = "科学"
                        }else if self.userdata?.category == "health" {
                            self.categoryLabel.text = "健康・医療"
                        }else if self.userdata?.category == "beauty" {
                            self.categoryLabel.text = "美容"
                        }else if self.userdata?.category == "fashion" {
                            self.categoryLabel.text = "ファッション"
                        }else if self.userdata?.category == "job" {
                            self.categoryLabel.text = "仕事"
                        }else if self.userdata?.category == "school" {
                            self.categoryLabel.text = "学校"
                        }else if self.userdata?.category == "hobby" {
                            self.categoryLabel.text = "趣味"
                        }else if self.userdata?.category == "art" {
                            self.categoryLabel.text = "文化・芸術"
                        }else if self.userdata?.category == "manga" {
                            self.categoryLabel.text = "漫画・アニメ"
                        }else if self.userdata?.category == "game" {
                            self.categoryLabel.text = "ゲーム"
                        }else if self.userdata?.category == "life" {
                            self.categoryLabel.text = "暮らし・生活"
                        }else if self.userdata?.category == "family" {
                            self.categoryLabel.text = "家族"
                        }else if self.userdata?.category == "love" {
                            self.categoryLabel.text = "結婚・恋愛"
                        }else if self.userdata?.category == "parenting" {
                            self.categoryLabel.text = "子育て・教育"
                        }else if self.userdata?.category == "recipe" {
                            self.categoryLabel.text = "グルメ・レシピ"
                        }else if self.userdata?.category == "study" {
                            self.categoryLabel.text = "勉強・学問"
                        }else if self.userdata?.category == "question" {
                            self.categoryLabel.text = "質問・相談"
                        }else if self.userdata?.category == "mystery" {
                            self.categoryLabel.text = "不思議・謎"
                        }else if self.userdata?.category == "prefectures" {
                            self.categoryLabel.text = "都道府県"
                        }else if self.userdata?.category == "world" {
                            self.categoryLabel.text = "海外"
                        }else if self.userdata?.category == "travel" {
                            self.categoryLabel.text = "旅行"
                        }else if self.userdata?.category == "pr" {
                            self.categoryLabel.text = "プロモーション"
                        }else if self.userdata?.category == "car" {
                            self.categoryLabel.text = "自動車・乗り物"
                        }else if self.userdata?.category == "pet" {
                            self.categoryLabel.text = "ペット・動物"
                        }else if self.userdata?.category == "chat" {
                            self.categoryLabel.text = "雑談・ネタ"
                        }else if self.userdata?.category == "other" {
                            self.categoryLabel.text = "その他"
                        }
                    }
                    
                    
                    if self.userdata?.destID != nil && self.userdata?.destID != myid && self.userdata?.destID != "n" {
                        
                        //コミュニティーを選択している場合
                        
                        self.commentOffLabel.textColor = .systemGray2
                        self.offCaption.textColor = .systemGray2
                        self.offSwitch.isEnabled = false
                        self.offSwitch.isOn = false
                        self.privateLabel.textColor = .systemGray2
                        self.privateCaption.textColor = .systemGray2
                        self.descriptionLabel.textColor = .systemGray2
                        self.privateSwitch.isEnabled = false
                        self.privateSwitch.isOn = false
                        
                        
                        print("確認3")
                        
                        self.chooseLabel.text = self.userdata?.destName
                        self.chooseLabel.textColor = .black
                        
                        let userRef = Firestore.firestore().collection("users").document(self.userdata!.destID!)
                        userRef.addSnapshotListener() { (documentSnapshot, error) in
                            guard let document = documentSnapshot else {
                                print("Error fetching document: \(error!)")
                                return
                            }
                            self.userdata2  = UserData(document: document)
                            
                            if self.userdata2!.with_iconImage == "exist" {
                                print("exist1")
                                self.iconView.isHidden = false
                                let imageNo = self.userdata2!.imageNo!
                                let imageNoString: String = "\(imageNo)"
                                print("imageNo\(imageNo)")
                                
                                let iconRef = Storage.storage().reference().child("iconImages").child(self.userdata!.destID! + imageNoString + ".jpg")
                                self.iconImageView.isHidden = true
                                self.iconImageView2.isHidden = false
                                self.iconImageView2.sd_setImage(with: iconRef)
                            }else{
                                print("notExist1")
                                //self.iconView.isHidden = true
                                self.iconImageView.isHidden = false
                                self.iconImageView2.isHidden = true
                                self.iconImageView.image = UIImage(named: "icons8-男性ユーザ-80")
                            }
                        }
                    }else if self.userdata?.destID == myid {
                        
                        self.commentOffLabel.textColor = .black
                        self.offCaption.textColor = .black
                        self.offSwitch.isEnabled = true
                        self.privateLabel.textColor = .black
                        self.privateCaption.textColor = .black
                        self.privateSwitch.isEnabled = true
                        self.descriptionLabel.textColor = .black
                        
                        print("確認4")
                        
                        self.chooseLabel.text = self.userdata?.name
                        self.chooseLabel.textColor = .black
                        
                        let userRef = Firestore.firestore().collection("users").document(myid!)
                        userRef.addSnapshotListener() { (documentSnapshot, error) in
                            guard let document = documentSnapshot else {
                                print("Error fetching document: \(error!)")
                                return
                            }
                            self.userdata2  = UserData(document: document)
                            
                            if self.userdata2!.with_iconImage == "exist" {
                                print("exist2")
                                self.iconView.isHidden = false
                                let imageNo = self.userdata2!.imageNo!
                                let imageNoString: String = "\(imageNo)"
                                print("imageNo\(imageNo)")
                                let iconRef = Storage.storage().reference().child("iconImages").child(myid! + imageNoString + ".jpg")
                                
                                self.iconImageView.isHidden = true
                                self.iconImageView2.isHidden = false
                                self.iconImageView2.sd_setImage(with: iconRef)
                            }else{
                                print("notExist2")
                                //self.iconView.isHidden = true
                                self.iconImageView.isHidden = false
                                self.iconImageView2.isHidden = true
                                self.iconImageView.image = UIImage(named: "icons8-男性ユーザ-80")
                            }
                        }
                    }else{
                        
                        self.commentOffLabel.textColor = .black
                        self.offCaption.textColor = .black
                        self.offSwitch.isEnabled = true
                        self.privateLabel.textColor = .black
                        self.privateCaption.textColor = .black
                        self.privateSwitch.isEnabled = true
                        self.descriptionLabel.textColor = .black
                        
                        print("確認5")
                        
                        self.chooseLabel.text = self.userdata?.name
                        self.chooseLabel.textColor = .black
                        
                        if self.userdata!.with_iconImage == "exist" {
                            print("exist3")
                            self.iconView.isHidden = false
                            let imageNo = self.userdata!.imageNo!
                            let imageNoString: String = "\(imageNo)"
                            print("imageNo\(imageNo)")
                            let iconRef = Storage.storage().reference().child("iconImages").child(myid! + imageNoString + ".jpg")
                            
                            self.iconImageView.isHidden = true
                            self.iconImageView2.isHidden = false
                            self.iconImageView2.sd_setImage(with: iconRef)
                        }else{
                            print("notExist3")
                            //self.iconView.isHidden = true
                            self.iconImageView.isHidden = false
                            self.iconImageView2.isHidden = true
                            self.iconImageView.image = UIImage(named: "icons8-男性ユーザ-80")
                        }
                    }
                }
                
                if self.selectedImage != nil{
                    self.photo.image = selectedImage
                }else{
                    print("画像は選択されていません")
                }
                
                unfocusBtn.backgroundColor = UIColor.darkGray.withAlphaComponent(0.5)
            }
        }
    }
    
    @objc func keyboardWillChange(notification: Notification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        if notification.name == UIResponder.keyboardWillChangeFrameNotification || notification.name == UIResponder.keyboardWillShowNotification {
            if ( keyboardSize.height > 100 ) {
                print("self.view.bringSubviewToFront")
                self.view.bringSubviewToFront(unfocusBtn)
            }
        }
        else if notification.name == UIResponder.keyboardWillHideNotification {
            print("self.view.sendSubviewToBack")
            self.view.sendSubviewToBack(unfocusBtn)
        }
    }
    
    
    @IBAction func commentOff(sender: UISwitch) {
        //オンのとき
        if ( sender.isOn ) {
            print("コメントオフ1")
            if Auth.auth().currentUser != nil {
                let myid = Auth.auth().currentUser!.uid
                let ref = Firestore.firestore().collection("users").document(myid)
                ref.updateData(["commentOff": "on"])
            }
        } else {
            if Auth.auth().currentUser != nil {
                let myid = Auth.auth().currentUser!.uid
                let ref = Firestore.firestore().collection("users").document(myid)
                ref.updateData(["commentOff": "off"])
            }
        }
    }
    
    @IBAction func bePrivate(sender: UISwitch) {
        //オンのとき
        if ( sender.isOn ) {
            print("コメントオフ1")
            if Auth.auth().currentUser != nil {
                let myid = Auth.auth().currentUser!.uid
                let ref = Firestore.firestore().collection("users").document(myid)
                ref.updateData(["bePrivate": "on"])
            }
        } else {
            if Auth.auth().currentUser != nil {
                let myid = Auth.auth().currentUser!.uid
                let ref = Firestore.firestore().collection("users").document(myid)
                ref.updateData(["bePrivate": "off"])
            }
        }
    }
    
    
    @IBAction func unfocus(_ sender: Any) {
        //入力欄を表示しているときに入力欄以外をタップすると入力欄を閉じるようにする
        self.textView.resignFirstResponder()
    }
    
    @objc func selectImageView(){
        // ライブラリ（カメラロール）を指定してピッカーを開く
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let pickerController = UIImagePickerController()
            pickerController.delegate = self
            pickerController.sourceType = .photoLibrary
            self.present(pickerController, animated: true, completion: nil)
        }
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // キーボードを閉じる
        view.endEditing(true)
    }
    
    //テキストビューを入力し終わったときのボタンの有効化/無効化
    func textViewDidChange(_ textView: UITextView) {
        
        //不要な改行削除
        let msg = self.textView.text!.replace("\n", "")
        //テキストの半角空白文字削除
        let trimmedString = msg.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmedString.count > 160{
            textView.textColor = .red
        } else {
            textView.textColor = .black
        }
        
        if trimmedString != "" && trimmedString.count <= 160 {
            postButton.isEnabled = true
            print("有効化1")
        }else{
            postButton.isEnabled = false
            print("無効化1")
        }
    }
    
    //テキストフィールドを入力し終わった後のボタンの有効化/無効化
    func textFieldDidEndEditing(_ textField:UITextField){
        
        //不要な改行削除
        let msg = self.textView.text!.replace("\n", "")
        //テキストの半角空白文字削除
        let trimmedString = msg.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmedString.count > 160{
            textView.textColor = .red
        } else {
            textView.textColor = .black
        }
        
        if textField.text != "" && trimmedString != "" && trimmedString.count <= 160 {
            postButton.isEnabled = true
            print("有効化2")
        }else{
            postButton.isEnabled = false
            print("無効化2")
        }
    }
    
    
    // 投稿ボタンをタップしたときに呼ばれるメソッド
    @IBAction func postButton(_ sender: Any) {
        
        if Auth.auth().currentUser?.uid != nil {
            
            // キーボードを閉じる
            textView.endEditing(true)
            
            let myid = Auth.auth().currentUser!.uid
            //不要な改行削除
            let msg = self.textView.text!.replace("\n", "")
            //テキストの半角空白文字削除
            let trimmedString = msg.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmedString.count > 160{
                print("DEBUG_PRINT: タイトルが151文字以上です")
                //HUD.flash(.labeledError(title: "エラー", subtitle: "タイトルは160文字以下にしてください"), delay: 1.4)
                SVProgressHUD.setDefaultStyle(.custom)
                SVProgressHUD.setDefaultMaskType(.custom)
                SVProgressHUD.setForegroundColor(.black)
                SVProgressHUD.setBackgroundColor(.white)
                SVProgressHUD.setDefaultMaskType(.black)
                SVProgressHUD.showError(withStatus: "タイトルは160文字以下にしてください")
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
            
            // 画像と投稿データの保存場所を定義する
            let postRef = Firestore.firestore().collection("posts").document()
            
            // FireStoreに投稿データを保存する
            let name = Auth.auth().currentUser?.displayName
            let email = Auth.auth().currentUser?.email
            let community = userdata?.destID
            let overView = userdata?.postCaption
            let commentOff = userdata?.commentOff
            let bePrivate = userdata?.bePrivate
            let category = userdata?.category
            
            if photo.image == nil {
                
                if community == nil || community == "n" || community == myid {
                    print("画像なし communityなしの投稿")
                    let postDic = [
                        "name": name!,
                        "email": email!,
                        "type": "private",
                        "category": category,
                        "uid": myid,
                        "caption": trimmedString2,
                        "overView": overView,
                        "commentOff": commentOff,
                        "bePrivate": bePrivate,
                        "date": FieldValue.serverTimestamp(),
                        "with_image" : false,
                        "deleted": "no",
                    ] as [String : Any]
                    postRef.setData(postDic)
                    
                }else{
                    
                    print("画像なし communityありの投稿")
                    let postDic = [
                        "name": name!,
                        "email": email!,
                        "type": "community",
                        "category": category,
                        "uid": myid,
                        "community": community,
                        "caption": trimmedString2,
                        "overView": overView,
                        "commentOff": commentOff,
                        "bePrivate": bePrivate,
                        "date": FieldValue.serverTimestamp(),
                        "with_image" : false,
                        "deleted": "no",
                    ] as [String : Any]
                    postRef.setData(postDic)
                    
                }
                
                // まずは親の(後ろの)タブバーのインスタンスを取得
                if let tabvc = UIApplication.shared.keyWindow?.rootViewController as? UITabBarController  {
                    //左から0番目のタブアイコンを選択状態にする(0が一番左)
                    DispatchQueue.main.async {
                        tabvc.selectedIndex = 0
                        if let naviViewController = tabvc.selectedViewController as? UINavigationController {
                            
                            naviViewController.popToRootViewController(animated: true)
                            
                            if let homeViewController = naviViewController.viewControllers.first as? HomeViewController {
                                print("homeViewController:\(homeViewController)")
                                
                                //一番最初のViewControllerに戻る
                                homeViewController.tableView.setContentOffset(.zero, animated: false)
                                homeViewController.tableView.layoutIfNeeded()
                            }
                        }
                    }
                }
                
                //移動先ViewControllerのインスタンスを取得（storyboard id: MainTabBarController）
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let toTop = storyboard.instantiateViewController(withIdentifier: "RootTabBarController")
                self.tabBarController?.navigationController?.present(toTop, animated: true, completion: nil)
                
                //遷移実行したら投稿画面を閉じる
                self.dismiss(animated: true, completion: {
                    
                    if Auth.auth().currentUser != nil {
                        let myid = Auth.auth().currentUser!.uid
                        
                        let userRef = Firestore.firestore().collection("users").document(myid)
                        userRef.updateData(["destID": "n"])
                        userRef.updateData(["destName": "n"])
                        userRef.updateData(["postCaption": "n"])
                        userRef.updateData(["commentOff": "off"])
                        userRef.updateData(["bePrivate": "off"])
                        
                        SVProgressHUD.setDefaultStyle(.custom)
                        SVProgressHUD.setDefaultMaskType(.custom)
                        SVProgressHUD.setForegroundColor(.black)
                        SVProgressHUD.setBackgroundColor(.white)
                        SVProgressHUD.setDefaultMaskType(.black)
                        //withDelayにIntを設定
                        SVProgressHUD.dismiss()
                        NotificationCenter.default.post(name: .success, object: nil)
                    }
                }
                )} else{
                    
                    // 画像をJPEG形式に変換し、compressionQualityで0.3に圧縮する(1.0が圧縮していない状態)
                    if selectedImage != nil{
                        let imageData = selectedImage.jpegData(compressionQuality: 0.3)
                        let imageRef = Storage.storage().reference().child("images").child(postRef.documentID + ".jpg")
                        // Storageに画像をアップロードする
                        let metadata = StorageMetadata()
                        metadata.contentType = "image/jpeg"
                        imageRef.putData(imageData!, metadata: metadata) { (metadata, error) in
                            if error != nil {
                                // 画像のアップロード失敗
                                print(error!)
                                //HUD.flash(.labeledError(title: "エラー", subtitle: "再度お試しください"), delay: 1.4)
                                SVProgressHUD.setDefaultStyle(.custom)
                                SVProgressHUD.setDefaultMaskType(.custom)
                                SVProgressHUD.setForegroundColor(.black)
                                SVProgressHUD.setBackgroundColor(.white)
                                SVProgressHUD.setDefaultMaskType(.black)
                                SVProgressHUD.showError(withStatus: "再度お試しください")
                                //withDelayにIntを設定
                                SVProgressHUD.dismiss(withDelay: 1.7)
                                // 投稿処理をキャンセルし、先頭画面に戻る
                                UIApplication.shared.windows.first{ $0.isKeyWindow }?.rootViewController?.dismiss(animated: true, completion: nil)
                                return
                            }
                            
                            if community == nil || community == "n" || community == myid {
                                
                                print("画像あり communityなしの投稿")
                                let postDic = [
                                    "name": name!,
                                    "type": "private",
                                    "category": category,
                                    "uid": myid,
                                    "caption": trimmedString2,
                                    "overView": overView,
                                    "commentOff": commentOff,
                                    "bePrivate": bePrivate,
                                    "date": FieldValue.serverTimestamp(),
                                    "with_image" : true,
                                    "deleted": "no",
                                ] as [String : Any]
                                postRef.setData(postDic)
                                
                            }else{
                                print("画像あり communityありの投稿")
                                let postDic = [
                                    "name": name!,
                                    "type": "community",
                                    "category": category,
                                    "uid": myid,
                                    "community": community,
                                    "caption": trimmedString2,
                                    "overView": overView,
                                    "commentOff": commentOff,
                                    "bePrivate": bePrivate,
                                    "date": FieldValue.serverTimestamp(),
                                    "with_image" : true,
                                    "deleted": "no",
                                ] as [String : Any]
                                postRef.setData(postDic)
                                
                            }
                            
                            // まずは親の(後ろの)タブバーのインスタンスを取得
                            if let tabvc = UIApplication.shared.keyWindow?.rootViewController as? UITabBarController  {
                                //左から0番目のタブアイコンを選択状態にする(0が一番左)
                                DispatchQueue.main.async {
                                    tabvc.selectedIndex = 0
                                    if let naviViewController = tabvc.selectedViewController as? UINavigationController {
                                        
                                        naviViewController.popToRootViewController(animated: true)
                                        
                                        if let homeViewController = naviViewController.viewControllers.first as? HomeViewController {
                                            print("homeViewController:\(homeViewController)")
                                            
                                            //一番最初のViewControllerに戻る
                                            homeViewController.tableView.setContentOffset(.zero, animated: false)
                                            homeViewController.tableView.layoutIfNeeded()
                                        }
                                    }
                                }
                            }
                            
                            //移動先ViewControllerのインスタンスを取得（storyboard id: MainTabBarController）
                            let storyboard = UIStoryboard(name: "Main", bundle: nil)
                            let toTop = storyboard.instantiateViewController(withIdentifier: "RootTabBarController")
                            self.tabBarController?.navigationController?.present(toTop, animated: true, completion: nil)
                            //遷移実行したら投稿画面を閉じる
                            self.dismiss(animated: true, completion: {
                                
                                if Auth.auth().currentUser != nil {
                                    
                                    let myid = Auth.auth().currentUser!.uid
                                    
                                    let userRef = Firestore.firestore().collection("users").document(myid)
                                    userRef.updateData(["destID": "n"])
                                    userRef.updateData(["destName": "n"])
                                    userRef.updateData(["postCaption": "n"])
                                    userRef.updateData(["commentOff": "off"])
                                    userRef.updateData(["bePrivate": "off"])
                                    
                                    SVProgressHUD.setDefaultStyle(.custom)
                                    SVProgressHUD.setDefaultMaskType(.custom)
                                    SVProgressHUD.setForegroundColor(.black)
                                    SVProgressHUD.setBackgroundColor(.white)
                                    SVProgressHUD.setDefaultMaskType(.black)
                                    //withDelayにIntを設定
                                    SVProgressHUD.dismiss()
                                    NotificationCenter.default.post(name: .success, object: nil)
                                }
                            }
                            )}
                    }
                }
        }
    }
    
    @IBAction func handleCancelButton(_ sender: Any) {
        
        // キーボードを閉じる
        view.endEditing(true)
        // 画面を閉じる
        self.dismiss(animated: true, completion: {
            
            if Auth.auth().currentUser != nil {
                let myid = Auth.auth().currentUser!.uid
                let ref = Firestore.firestore().collection("users").document(myid)
                
                ref.updateData(["commentOff": "off"])
                ref.updateData(["bePrivate": "off"])
                ref.updateData(["destID": "n"])
                ref.updateData(["destName": "n"])
                ref.updateData(["postCaption": "n"])
                ref.updateData(["category": "n"])
            }
        })
    }
    
    func setImagePicker(){
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) {
            setImagePicker()
        }
        present(picker, animated: true, completion: nil)
    }
    
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        updateImageViewWithImage(image, fromCropViewController: cropViewController)
    }
    
    func updateImageViewWithImage(_ image: UIImage, fromCropViewController cropViewController: CropViewController) {
        photoBackView.backgroundColor = .white
        selectedImage = image
        photo.image = image
        cropViewController.dismiss(animated: true, completion: nil)
    }
}

extension String {
    func replace(_ from: String,_ to: String) -> String {
        var replacedString = self
        while((replacedString.range(of: from)) != nil){
            if let range = replacedString.range(of: from) {
                replacedString.replaceSubrange(range, with: to)
            }
        }
        return replacedString
    }
}

extension PostViewController: UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if info[.originalImage] != nil {
            
            guard let pickerImage = (info[UIImagePickerController.InfoKey.originalImage] as? UIImage) else { return }
            
            let cropController = CropViewController(croppingStyle: .default, image: pickerImage)
            cropController.delegate = self
            cropController.customAspectRatio = CGSize(width: 160, height: 90)
            
            //今回は使わないボタン等を非表示にする。
            cropController.aspectRatioPickerButtonHidden = true
            cropController.resetAspectRatioEnabled = false
            cropController.rotateButtonsHidden = true
            
            //cropBoxのサイズを固定する。
            cropController.cropView.cropBoxResizeEnabled = false
            //pickerを閉じたら、cropControllerを表示する。
            picker.dismiss(animated: true) {
                self.present(cropController, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func unwind(_ segue: UIStoryboardSegue) {
    }
    
}


extension Notification.Name {
    static let success = Notification.Name("success")
}



extension UIImage {
    //データサイズを変更する
    func resized(withPercentage percentage: CGFloat) -> UIImage? {
        let canvas = CGSize(width: size.width * percentage, height: size.height * percentage)
        return UIGraphicsImageRenderer(size: canvas, format: imageRendererFormat).image {
            _ in draw(in: CGRect(origin: .zero, size: canvas))
        }
    }
}
