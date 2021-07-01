//
//  Post2ViewController.swift
//  Nomad-App
//
//  Created by yuishii on 2020/12/04.
//  Copyright © 2020 Yu Ishii. All rights reserved.
//
// コミュニティー新規投稿画面

import UIKit
import Firebase
import CropViewController
import SVProgressHUD
import NotificationBannerSwift
import KMPlaceholderTextView

class Post2ViewController: UIViewController, UITextViewDelegate,UITextFieldDelegate,CropViewControllerDelegate, APTextViewDelegate {
    
    var userdata: UserData?
    
    var name: String = ""
    var caption: String = ""
    var overView: String = ""
    var web: String = ""
    
    var listener: ListenerRegistration!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var captionLabel: UILabel!
    @IBOutlet weak var overViewLabel: UILabel!
    @IBOutlet weak var webLabel: UILabel!
    @IBOutlet weak var headerImageView: UIImageView!
    @IBOutlet weak var iconImageView: UIImageView! {
        didSet {
            //            iconImageView.layer.shadowColor = UIColor.white.cgColor
            //            iconImageView.layer.borderColor = UIColor.white.cgColor
            //            iconImageView.layer.borderWidth = 8
            iconImageView.layer.cornerRadius = iconImageView.frame.height / 2
        }
    }
    @IBOutlet weak var iconBack: UIView! {
        didSet {
            iconBack.backgroundColor = UIColor.rgb(red: 193, green: 198, blue: 202)
            iconBack.layer.cornerRadius = iconBack.frame.height / 2
        }
    }
    
    @IBOutlet weak var iconView: UIView! {
        didSet {
            iconView.layer.shadowColor = UIColor.white.cgColor
            iconView.layer.cornerRadius = iconView.frame.height / 2
            iconView.backgroundColor = UIColor.white
        }
    }
    @IBOutlet weak var postButton: UIBarButtonItem!
    @IBOutlet weak var headerView: UIView! {
        didSet {
            headerView.backgroundColor = UIColor.rgb(red: 198, green: 205, blue: 224)
        }
    }
    
    var selectedImage1: UIImage!
    var selectedImage2: UIImage!
    var selectingHeader: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        headerImageView.isUserInteractionEnabled = true
        headerImageView.tag = 0
        iconImageView.isUserInteractionEnabled = true
        iconImageView.tag = 1
        
        //ナビゲーションバーの色
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.tintColor = UIColor.black
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.black]
        
        let backBarButtonItem = UIBarButtonItem()
        backBarButtonItem.title = "Back"
        self.navigationItem.backBarButtonItem = backBarButtonItem
        
        postButton.isEnabled = false
        postButton.tintColor = .link
        
        let tapGesture1 = UITapGestureRecognizer(target: self, action: #selector(self.selectImageView))
        headerImageView.addGestureRecognizer(tapGesture1)
        headerImageView.isUserInteractionEnabled = true
        
        let tapGesture2 = UITapGestureRecognizer(target: self, action: #selector(self.selectImageView))
        iconImageView.addGestureRecognizer(tapGesture2)
        iconImageView.isUserInteractionEnabled = true
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
        
        print("Post2 documentIDあり")
        
        if Auth.auth().currentUser != nil {
            let myid = Auth.auth().currentUser!.uid
            
            if ( self.listener == nil ) {
                let userRef = Firestore.firestore().collection("users").document(myid)
                self.listener = userRef.addSnapshotListener() { (documentSnapshot, error) in
                    guard let document = documentSnapshot else {
                        print("Error fetching document: \(error!)")
                        return
                    }
                    self.userdata  = UserData(document: document)
                    
                    if self.userdata?.communityName != nil {
                        self.nameLabel.text = self.userdata?.communityName
                        self.nameLabel.textColor = .black
                    }else{
                        self.nameLabel.text = "コミュニティ名を入力(必須)"
                        self.nameLabel.textColor = .gray
                    }
                    
                    if self.userdata?.communityCaption != nil {
                        self.captionLabel.text = self.userdata?.communityCaption
                        self.captionLabel.textColor = .black
                    }else{
                        self.captionLabel.text = "説明を追加"
                        self.captionLabel.textColor = .gray
                    }
                    
                    if self.userdata?.communityOverView != nil {
                        self.overViewLabel.text = self.userdata?.communityOverView
                        self.overViewLabel.textColor = .black
                    }else{
                        self.overViewLabel.text = "概要を追加"
                        self.overViewLabel.textColor = .gray
                    }
                    
                    if self.userdata?.communityWeb != nil {
                        self.webLabel.text = self.userdata?.communityWeb
                        self.webLabel.textColor = .black
                    }else{
                        self.webLabel.text = "Webを追加"
                        self.webLabel.textColor = .gray
                    }
                    
                    if  self.iconImageView.image != nil && self.headerImageView.image != nil && self.userdata?.communityName != nil {
                        print("1")
                        self.postButton.isEnabled = true
                        self.postButton.tintColor = .link
                    }else{
                        print("2")
                        self.postButton.isEnabled = false
                    }
                }
            }
        }
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        for touch: UITouch in touches {
            let tag = touch.view!.tag
            switch tag {
            case 0:
                print("ヘッダーをタップしました。")
                selectingHeader = true
            case 1:
                print("アイコンをタップしました。")
                selectingHeader = false
            default:
                break
            }
        }
        // キーボードを閉じる
        view.endEditing(true)
    }
    
    // 画面が閉じる直前に呼ばれる
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
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
    
    @IBAction func unwind(_ segue: UIStoryboardSegue) {
    }
}

extension Post2ViewController {
    
    
    // 投稿ボタンをタップしたときに呼ばれるメソッド
    @IBAction func postButton(_ sender: Any) {
        
        
        guard let myid = Auth.auth().currentUser?.uid else { return }
        
        SVProgressHUD.setDefaultStyle(.custom)
        SVProgressHUD.setDefaultMaskType(.custom)
        SVProgressHUD.setForegroundColor(.black)
        SVProgressHUD.setBackgroundColor(.white)
        SVProgressHUD.setDefaultMaskType(.black)
        SVProgressHUD.show()
        
        
        // 画像をJPEG形式に変換し、compressionQualityで0.3に圧縮する(1.0が圧縮していない状態)
        if selectedImage1 != nil && selectedImage2 != nil{
            
            print("画像が設定されていません")
            let imageData1 = selectedImage1.jpegData(compressionQuality: 0.3)
            let imageData2 = selectedImage2.jpegData(compressionQuality: 0.3)
            
            let ref = Firestore.firestore().collection("users").document()
            let documentID = ref.documentID
            
            let number: Int = 0
            let numberString: String = "0"
            
            let imageRef1 = Storage.storage().reference().child("headerImages").child(ref.documentID + numberString + ".jpg")
            let imageRef2 = Storage.storage().reference().child("iconImages").child(ref.documentID + numberString + ".jpg")
            
            // Storageに画像をアップロードする
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"
            
            imageRef1.putData(imageData1!, metadata: metadata) { (metadata, error) in
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
                imageRef2.putData(imageData2!, metadata: metadata) { (metadata, error) in
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
                    
                    let time = Date.timeIntervalSinceReferenceDate
                    
                    // FireStoreに投稿データを保存する
                    let locale = NSLocale.current
                    let country = locale.regionCode
                    let language = locale.languageCode
                    
                    print("countryCode:\(country)")
                    print("languageCode:\(language)")
                    
                    if self.userdata?.communityName != nil {
                        self.name = (self.userdata?.communityName)!
                    }else{
                        self.name = ""
                    }
                    
                    if self.userdata?.communityCaption != nil {
                        self.caption = (self.userdata?.communityCaption)!
                    }else{
                        self.caption = ""
                    }
                    
                    if self.userdata?.communityOverView != nil {
                        self.overView = (self.userdata?.communityOverView)!
                    }else{
                        self.overView = ""
                    }
                    
                    if self.userdata?.communityWeb != nil {
                        self.web = (self.userdata?.communityWeb)!
                    }else{
                        self.web = ""
                    }
                    
                    let caption = self.userdata?.communityCaption
                    let overView = self.userdata?.communityOverView
                    let web = self.userdata?.communityWeb
                    
                    let userDic = [
                        "name": self.name,
                        "bePrivate": "off",
                        "caption": caption,
                        "type": "community",
                        "uid": documentID,
                        "date": FieldValue.serverTimestamp(),
                        "country": country,
                        "overView": overView,
                        "web": web,
                        "language": language,
                        "with_iconImage" : "exist",
                        "with_headerImage" : "exist",
                        "imageNo": number,
                        "headerNo": number,
                        "deleted": "no",
                    ] as [String : Any]
                    ref.setData(userDic)
                    
                    // 更新データを作成する
                    var updateValue: FieldValue
                    var updateValue2: FieldValue
                    var updateValue3: FieldValue
                    var updateValue4: FieldValue
                    
                    updateValue = FieldValue.arrayUnion([["uid": myid, "time": time]])
                    updateValue2 = FieldValue.arrayUnion([documentID])
                    updateValue3 = FieldValue.arrayUnion([myid])
                    updateValue4 = FieldValue.arrayUnion([["uid": documentID, "time": time]])
                    
                    let userRef = Firestore.firestore().collection("users").document(documentID)
                    userRef.updateData(["moderator": updateValue])
                    let userRef2 = Firestore.firestore().collection("users").document(myid)
                    userRef2.updateData(["moderate": updateValue4])
                    
                    let userRef3 = Firestore.firestore().collection("users").document(documentID)
                    userRef3.updateData(["follower": updateValue])
                    let userRef4 = Firestore.firestore().collection("users").document(myid)
                    userRef4.updateData(["follow": updateValue4])
                    
                    
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
                    
                    let followedRef = Firestore.firestore().collection("followers").document(documentID)
                    
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
                    
                    let moderatedRef = Firestore.firestore().collection("moderator").document(documentID)
                    
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
                        
                        let ref2 = Firestore.firestore().collection("users").document(myid)
                        
                        ref2.updateData(["communityName": FieldValue.delete(),]){ err in
                            if let err = err{
                                print("Error updating document: \(err)")
                            }else{
                                print("Document successfully updated")
                                
                            }
                        }
                        
                        ref2.updateData(["communityCaption": FieldValue.delete(),]){ err in
                            if let err = err{
                                print("Error updating document: \(err)")
                            }else{
                                print("Document successfully updated")
                                
                            }
                        }
                        
                        ref2.updateData(["communityOverView": FieldValue.delete(),]){ err in
                            if let err = err{
                                print("Error updating document: \(err)")
                            }else{
                                print("Document successfully updated")
                                
                            }
                        }
                        
                        ref2.updateData(["communityWeb": FieldValue.delete(),]){ err in
                            if let err = err{
                                print("Error updating document: \(err)")
                            }else{
                                print("Document successfully updated")
                                
                            }
                        }
                        
                        SVProgressHUD.setDefaultStyle(.custom)
                        SVProgressHUD.setDefaultMaskType(.custom)
                        SVProgressHUD.setForegroundColor(.black)
                        SVProgressHUD.setBackgroundColor(.white)
                        SVProgressHUD.setDefaultMaskType(.black)
                        //withDelayにIntを設定
                        SVProgressHUD.dismiss()
                        NotificationCenter.default.post(name: .success2, object: nil)
                    }
                    )}
            }
        }
    }
    
    @IBAction func toName(_ sender: Any) {
        
        performSegue(withIdentifier: "toName", sender: nil)
        
    }
    @IBAction func toCaption(_ sender: Any) {
        
        performSegue(withIdentifier: "toCaption", sender: nil)
    }
    @IBAction func toOverView(_ sender: Any) {
        
        performSegue(withIdentifier: "toOverView", sender: nil)
    }
    @IBAction func toWeb(_ sender: Any) {
        
        performSegue(withIdentifier: "toWeb", sender: nil)
    }
    
    @IBAction func handleCancelButton(_ sender: Any) {
        
        // キーボードを閉じる
        view.endEditing(true)
        // 画面を閉じる
        self.dismiss(animated: true, completion: {
            
            if Auth.auth().currentUser != nil {
                let myid = Auth.auth().currentUser!.uid
                
                let ref = Firestore.firestore().collection("users").document(myid)
                
                ref.updateData(["communityName": FieldValue.delete(),]){ err in
                    if let err = err{
                        print("Error updating document: \(err)")
                    }else{
                        print("Document successfully updated")
                        
                    }
                }
                
                ref.updateData(["communityCaption": FieldValue.delete(),]){ err in
                    if let err = err{
                        print("Error updating document: \(err)")
                    }else{
                        print("Document successfully updated")
                        
                    }
                }
                
                ref.updateData(["communityOverView": FieldValue.delete(),]){ err in
                    if let err = err{
                        print("Error updating document: \(err)")
                    }else{
                        print("Document successfully updated")
                    }
                }
                
                ref.updateData(["communityWeb": FieldValue.delete(),]){ err in
                    if let err = err{
                        print("Error updating document: \(err)")
                    }else{
                        print("Document successfully updated")
                        
                    }
                }
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
        
        //iconImageViewを変える時
        if self.selectingHeader == false {
            selectedImage2 = image
            iconImageView.image = image
            
            if  iconImageView.image != nil && headerImageView.image != nil && userdata?.communityName != nil {
                print("true1")
                postButton.isEnabled = true
            }else{
                print("false1")
                postButton.isEnabled = false
            }
            cropViewController.dismiss(animated: true, completion: nil)
            
        }else{
            //headerImageView.imageにcropを適用
            selectedImage1 = image
            headerImageView.image = image
            
            if  iconImageView.image != nil && headerImageView.image != nil && userdata?.communityName != nil {
                print("true1")
                postButton.isEnabled = true
            }else{
                print("false1")
                postButton.isEnabled = false
            }
            
            cropViewController.dismiss(animated: true, completion: nil)
        }
    }
}

extension Notification.Name {
    static let success2 = Notification.Name("success2")
}

extension Post2ViewController: UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if info[.originalImage] != nil {
            guard let pickerImage = (info[UIImagePickerController.InfoKey.originalImage] as? UIImage) else { return }
            
            //iconImageViewを変える時
            if self.selectingHeader == false {
                let cropController = CropViewController(croppingStyle: .default, image: pickerImage)
                cropController.delegate = self
                cropController.customAspectRatio = CGSize(width: 100, height: 100)
                
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
                //headerImageViewを変える時
            } else {
                let cropController = CropViewController(croppingStyle: .default, image: pickerImage)
                cropController.delegate = self
                cropController.customAspectRatio = CGSize(width: 400, height: 100)
                
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
        dismiss(animated: true, completion: nil)
    }
}


