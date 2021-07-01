//
//  ProfileEditViewController.swift
//  Nomad-App
//
//  Created by yuishii on 2020/07/13.
//  Copyright © 2020 Yu Ishii. All rights reserved.
//
// プロフィール編集画面

import UIKit
import Firebase
import FirebaseUI
import SVProgressHUD
import CropViewController
import NotificationBannerSwift
import KMPlaceholderTextView

class ProfileEditViewController: UIViewController, CropViewControllerDelegate{
    
    var pickerView: UIPickerView = UIPickerView()
    
    var listener1: ListenerRegistration!
    var listener2: ListenerRegistration!
    var listener_user: ListenerRegistration!
    var userdata: UserData?
    var userdata2: UserData?
    
    @IBOutlet weak var iconBack: UIView! {
        didSet {
            iconBack.layer.cornerRadius = iconBack.frame.height / 2
        }
    }
    @IBOutlet weak var headerBack: UIView! {
        didSet {
            headerBack.layer.cornerRadius = headerBack.frame.height / 2
        }
    }
    
    @IBOutlet weak var headerView: UIView! {
        didSet {
            headerView.backgroundColor = UIColor.rgb(red: 198, green: 205, blue: 224)
        }
    }
    @IBOutlet weak var iconImageView: UIImageView! {
        didSet {
            iconImageView?.contentMode = .scaleToFill
            iconImageView?.clipsToBounds = true
            iconImageView.isUserInteractionEnabled = true
            iconImageView.layer.cornerRadius = iconImageView.frame.height / 2
        }
    }
    
    //これが一番上
    @IBOutlet weak var iconImageView2: UIImageView! {
        didSet {
            iconImageView2?.contentMode = .scaleToFill
            iconImageView2?.clipsToBounds = true
            iconImageView2.isUserInteractionEnabled = true
            iconImageView2.layer.cornerRadius = iconImageView2.frame.height / 2
            iconImageView.layer.borderColor = UIColor.white.cgColor
            iconImageView.layer.borderWidth = 8.0
            iconImageView.layer.shadowColor = UIColor.white.cgColor
        }
    }
    
    @IBOutlet weak var iconImageView3: UIImageView! {
        didSet {
            iconImageView3?.contentMode = .scaleToFill
            iconImageView3?.clipsToBounds = true
            iconImageView3.isUserInteractionEnabled = true
            iconImageView3.layer.cornerRadius = iconImageView3.frame.height / 2
        }
    }
    
    @IBOutlet weak var iconView: UIView! {
        didSet {
            iconView.backgroundColor = UIColor.rgb(red: 248, green: 248, blue: 248)
            iconView.layer.cornerRadius = iconView.frame.height / 2
            iconView.layer.borderColor = UIColor.white.cgColor
            iconView.layer.borderWidth = 8.0
            iconView.layer.shadowColor = UIColor.white.cgColor
        }
    }
    @IBOutlet weak var headerImageView: UIImageView!{
        didSet {
            headerImageView?.contentMode = .scaleToFill
            headerImageView?.clipsToBounds = true
        }
    }
    
    //一番上
    @IBOutlet weak var headerImageView2: UIImageView!{
        didSet {
            headerImageView2?.contentMode = .scaleToFill
            headerImageView2?.clipsToBounds = true
        }
    }
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var captionLabel: UILabel!
    @IBOutlet weak var overViewLabel: UILabel!
    @IBOutlet weak var webLabel: UILabel!
    @IBOutlet weak var addImage: UIImageView!
    @IBOutlet weak var addImage2: UIImageView!
    
    let icon: UIImage? = nil
    private let storageRef = Storage.storage().reference()
    private var picker = UIImagePickerController()
    
    var selectedImage1: UIImage!
    var selectedImage2: UIImage!
    var selectingHeader: Bool = false
    
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
        
        let backBarButtonItem = UIBarButtonItem()
        backBarButtonItem.title = "Back"
        self.navigationItem.backBarButtonItem = backBarButtonItem
        
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        self.tabBarController?.tabBar.barTintColor = UIColor.white
        self.navigationController?.navigationBar.tintColor = UIColor.black
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.black]
        
        fetchUser()
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBarController?.tabBar.isHidden = true
        
        headerImageView.isUserInteractionEnabled = true
        headerImageView.tag = 0
        iconImageView.isUserInteractionEnabled = true
        iconImageView.tag = 1
        iconImageView2.isUserInteractionEnabled = true
        iconImageView2.tag = 2
        iconImageView3.isUserInteractionEnabled = true
        iconImageView3.tag = 3
        addImage.isUserInteractionEnabled = true
        addImage.tag = 4
        addImage2.isUserInteractionEnabled = true
        addImage2.tag = 5
        iconBack.isUserInteractionEnabled = true
        iconBack.tag = 6
        headerBack.isUserInteractionEnabled = true
        headerBack.tag = 7
        
        
        saveButton.isEnabled = false
        saveButton.tintColor = .link
        
        let tapGesture1 = UITapGestureRecognizer(target: self, action: #selector(self.selectImageView))
        headerImageView.addGestureRecognizer(tapGesture1)
        headerImageView.isUserInteractionEnabled = true
        
        let tapGesture2 = UITapGestureRecognizer(target: self, action: #selector(self.selectImageView))
        iconImageView.addGestureRecognizer(tapGesture2)
        iconImageView.isUserInteractionEnabled = true
        
        let tapGesture3 = UITapGestureRecognizer(target: self, action: #selector(self.selectImageView))
        iconImageView2.addGestureRecognizer(tapGesture3)
        iconImageView2.isUserInteractionEnabled = true
        
        let tapGesture4 = UITapGestureRecognizer(target: self, action: #selector(self.selectImageView))
        iconImageView3.addGestureRecognizer(tapGesture4)
        iconImageView3.isUserInteractionEnabled = true
        
        let tapGesture5 = UITapGestureRecognizer(target: self, action: #selector(self.selectImageView))
        addImage.addGestureRecognizer(tapGesture5)
        addImage.isUserInteractionEnabled = true
        
        let tapGesture6 = UITapGestureRecognizer(target: self, action: #selector(self.selectImageView))
        addImage2.addGestureRecognizer(tapGesture6)
        addImage2.isUserInteractionEnabled = true
        
        let tapGesture7 = UITapGestureRecognizer(target: self, action: #selector(self.selectImageView))
        iconBack.addGestureRecognizer(tapGesture7)
        iconBack.isUserInteractionEnabled = true
        
        let tapGesture8 = UITapGestureRecognizer(target: self, action: #selector(self.selectImageView))
        headerBack.addGestureRecognizer(tapGesture8)
        headerBack.isUserInteractionEnabled = true
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
            case 2:
                print("アイコンをタップしました。")
                selectingHeader = false
            case 3:
                print("アイコンをタップしました。")
                selectingHeader = false
            case 4:
                print("ヘッダーをタップしました。")
                selectingHeader = true
            case 5:
                print("アイコンをタップしました。")
                selectingHeader = false
            case 6:
                print("アイコンをタップしました。")
                selectingHeader = false
            case 7:
                print("アイコンをタップしました。")
                selectingHeader = true
            default:
                break
            }
        }
        // キーボードを閉じる
        view.endEditing(true)
    }
    
    
    private func fetchUser() {
        
        
        print("self.userdata?.editID != nil")
        
        if Auth.auth().currentUser != nil {
            let myid = Auth.auth().currentUser!.uid
            
            if ( self.listener1 == nil ) {
                let userRef1 = Firestore.firestore().collection("users").document(myid)
                self.listener1 = userRef1.addSnapshotListener() { (documentSnapshot, error) in
                    guard let document = documentSnapshot else {
                        print("Error fetching document: \(error!)")
                        return
                    }
                    self.userdata  = UserData(document: document)
                    
                    if self.userdata?.editID != nil {
                        
                        if ( self.listener2 == nil ) {
                            let userRef2 = Firestore.firestore().collection("users").document(self.userdata!.editID!)
                            self.listener2 = userRef2.addSnapshotListener() { (documentSnapshot, error) in
                                guard let document = documentSnapshot else {
                                    print("Error fetching document: \(error!)")
                                    return
                                }
                                self.userdata2  = UserData(document: document)
                                
                                if self.userdata2?.with_iconImage == "exist" {
                                    print("exist")
                                    
                                    let imageNo = self.userdata2!.imageNo!
                                    let imageNoString: String = "\(imageNo)"
                                    let iconRef = Storage.storage().reference().child("iconImages").child(self.userdata!.editID! + imageNoString + ".jpg")
                                    self.iconImageView2.sd_setImage(with: iconRef)
                                }else{
                                    print("notExist")
                                    self.iconImageView.image = UIImage(named: "icons8-男性ユーザ-80")
                                }
                                
                                if self.userdata2?.with_headerImage == "exist" {
                                    print("exist")
                                    
                                    let headerNo = self.userdata2!.headerNo!
                                    let headerNoString: String = "\(headerNo)"
                                    let headerRef = Storage.storage().reference().child("headerImages").child(self.userdata!.editID! + headerNoString + ".jpg")
                                    
                                    self.headerView.backgroundColor = .white
                                    self.headerImageView2.sd_setImage(with: headerRef)
                                }else{
                                    print("notExist")
                                }
                                
                                if self.userdata2!.name != nil {
                                    print("self.userdata!.name1:\(self.userdata2!.name)")
                                    self.nameLabel.textColor = .black
                                    self.nameLabel.text = self.userdata2!.name
                                }else{
                                    print("self.userdata!.name2:\(self.userdata2!.name)")
                                    self.nameLabel.textColor = .gray
                                    self.nameLabel.text = "名前を入力"
                                }
                                
                                if self.userdata2!.caption != nil {
                                    print("self.userdata!.caption1:\(self.userdata2!.caption)")
                                    self.captionLabel.textColor = .black
                                    self.captionLabel.text = self.userdata2!.caption
                                }else{
                                    print("self.userdata!.caption2:\(self.userdata2!.caption)")
                                    self.captionLabel.textColor = .gray
                                    self.captionLabel.text = "自己紹介を追加"
                                }
                                
                                if self.userdata2!.overView != nil {
                                    print("self.userdata!.overView1:\(self.userdata2!.overView)")
                                    self.overViewLabel.textColor = .black
                                    self.overViewLabel.text = self.userdata2!.overView
                                }else{
                                    print("self.userdata!.overView1:\(self.userdata2!.overView)")
                                    self.overViewLabel.textColor = .gray
                                    self.overViewLabel.text = "概要を追加"
                                }
                                
                                if self.userdata2!.web != nil {
                                    print("self.userdata!.web1:\(self.userdata2!.web)")
                                    self.webLabel.textColor = .black
                                    self.webLabel.text = self.userdata2!.web
                                }else{
                                    print("self.userdata!.web2:\(self.userdata2!.web)")
                                    self.webLabel.textColor = .gray
                                    self.webLabel.text = "Webを追加"
                                }
                            }
                        }
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
    
    
    @objc func selectImageView(){
        // ライブラリ（カメラロール）を指定してピッカーを開く
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let pickerController = UIImagePickerController()
            pickerController.delegate = self
            pickerController.sourceType = .photoLibrary
            self.present(pickerController, animated: true, completion: nil)
        }
    }
    
    
    @IBAction func didTapSaveButton(_ sender: Any) {
        print("didTapSaveButton")
        
        //HUD.show(.progress, onView: view)
        SVProgressHUD.setDefaultStyle(.custom)
        SVProgressHUD.setDefaultMaskType(.custom)
        SVProgressHUD.setForegroundColor(.black)
        SVProgressHUD.setBackgroundColor(.white)
        SVProgressHUD.setDefaultMaskType(.black)
        // HUDで処理中を表示
        SVProgressHUD.show()
        
        // Storageに画像をアップロードする
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        if self.userdata?.editID != nil {
            
            //アイコンだけ変更した場合
            if selectedImage2 != nil && selectedImage1 == nil {
                
                let imageNo = self.userdata2!.imageNo!
                let imageNoString1: String = "\(imageNo)"
                let imageNoString2: String = "\(imageNo + 1)"
                
                print("確認1-アイコンだけ変更")
                
                let imageData2 = selectedImage2.jpegData(compressionQuality: 0.3)
                let imageRef2 = Storage.storage().reference().child("iconImages").child(self.userdata!.editID! + imageNoString1 + ".jpg")
                
                imageRef2.delete { error in
                    if let error = error {
                        let nsError = error as NSError
                        if nsError.domain == StorageErrorDomain &&
                            nsError.code == StorageErrorCode.objectNotFound.rawValue {
                            print("目的の参照にオブジェクトが存在しません1")
                            
                            let imageRef3 = Storage.storage().reference().child("iconImages").child(self.userdata!.editID! + imageNoString2 + ".jpg")
                            
                            imageRef3.putData(imageData2!, metadata: metadata) { (metadata, error) in
                                if error != nil {
                                    // 画像のアップロード失敗
                                    print("アップロード失敗1")
                                    //HUD.flash(.labeledError(title: "エラー", subtitle: "再度お試しください"), delay: 1.4)
                                    SVProgressHUD.setDefaultStyle(.custom)
                                    SVProgressHUD.setDefaultMaskType(.custom)
                                    SVProgressHUD.setForegroundColor(.black)
                                    SVProgressHUD.setBackgroundColor(.white)
                                    SVProgressHUD.setDefaultMaskType(.black)
                                    SVProgressHUD.showError(withStatus: "再度お試しください")
                                    //withDelayにIntを設定
                                    SVProgressHUD.dismiss()
                                    return
                                }else {
                                    print("アップロード成功1")
                                    //imageNoを1増やしたimageNoを新しい画像の保存先として使う
                                    let ref = Firestore.firestore().collection("users").document(self.userdata!.editID!)
                                    ref.updateData(["imageNo": FieldValue.increment(1.0)])
                                    ref.updateData(["with_iconImage": "exist"])
                                    
                                    //withDelayにIntを設定
                                    SVProgressHUD.dismiss()
                                    //遷移元に戻る
                                    self.navigationController?.popViewController(animated: true)
                                }
                            }
                            
                        }
                    } else {
                        print("delete success!!1")
                        
                        let imageRef3 = Storage.storage().reference().child("iconImages").child(self.userdata!.editID! + imageNoString2 + ".jpg")
                        
                        imageRef3.putData(imageData2!, metadata: metadata) { (metadata, error) in
                            if error != nil {
                                // 画像のアップロード失敗
                                print("アップロード失敗2")
                                //HUD.flash(.labeledError(title: "エラー", subtitle: "再度お試しください"), delay: 1.4)
                                SVProgressHUD.setDefaultStyle(.custom)
                                SVProgressHUD.setDefaultMaskType(.custom)
                                SVProgressHUD.setForegroundColor(.black)
                                SVProgressHUD.setBackgroundColor(.white)
                                SVProgressHUD.setDefaultMaskType(.black)
                                SVProgressHUD.showError(withStatus: "再度お試しください")
                                //withDelayにIntを設定
                                SVProgressHUD.dismiss()
                                return
                            }else {
                                print("アップロード成功2")
                                
                                //imageNoを1増やしたimageNoを新しい画像の保存先として使う
                                let ref = Firestore.firestore().collection("users").document(self.userdata!.editID!)
                                ref.updateData(["imageNo": FieldValue.increment(1.0)])
                                ref.updateData(["with_iconImage": "exist"])
                                //withDelayにIntを設定
                                SVProgressHUD.dismiss()
                                //遷移元に戻る
                                self.navigationController?.popViewController(animated: true)
                            }
                        }
                        
                    }
                }
                
                //ヘッダーだけ変更した場合
            }else if selectedImage2 == nil && selectedImage1 != nil {
                
                let headerNo = self.userdata2!.headerNo!
                let headerNoString1: String = "\(headerNo)"
                let headerNoString2: String = "\(headerNo + 1)"
                
                print("確認2-ヘッダーだけ変更")
                
                let imageData1 = selectedImage1.jpegData(compressionQuality: 0.3)
                let imageRef1 = Storage.storage().reference().child("headerImages").child(self.userdata!.editID! + headerNoString1 + ".jpg")
                
                imageRef1.delete { error in
                    if let error = error {
                        let nsError = error as NSError
                        if nsError.domain == StorageErrorDomain &&
                            nsError.code == StorageErrorCode.objectNotFound.rawValue {
                            print("目的の参照にオブジェクトが存在しません2")
                            
                            let imageRef3 = Storage.storage().reference().child("headerImages").child(self.userdata!.editID! + headerNoString2 + ".jpg")
                            
                            imageRef3.putData(imageData1!, metadata: metadata) { (metadata, error) in
                                if error != nil {
                                    // 画像のアップロード失敗
                                    print("アップロード失敗3")
                                    //HUD.flash(.labeledError(title: "エラー", subtitle: "再度お試しください"), delay: 1.4)
                                    SVProgressHUD.setDefaultStyle(.custom)
                                    SVProgressHUD.setDefaultMaskType(.custom)
                                    SVProgressHUD.setForegroundColor(.black)
                                    SVProgressHUD.setBackgroundColor(.white)
                                    SVProgressHUD.setDefaultMaskType(.black)
                                    SVProgressHUD.showError(withStatus: "再度お試しください")
                                    //withDelayにIntを設定
                                    SVProgressHUD.dismiss()
                                    return
                                }else{
                                    print("アップロード成功3")
                                    
                                    //imageNoを1増やしたimageNoを新しい画像の保存先として使う
                                    let ref = Firestore.firestore().collection("users").document(self.userdata!.editID!)
                                    ref.updateData(["headerNo": FieldValue.increment(1.0)])
                                    ref.updateData(["with_headerImage": "exist"])
                                    //withDelayにIntを設定
                                    SVProgressHUD.dismiss()
                                    //遷移元に戻る
                                    self.navigationController?.popViewController(animated: true)
                                }
                            }
                        }
                    } else {
                        print("delete success!!2")
                        
                        let imageRef3 = Storage.storage().reference().child("headerImages").child(self.userdata!.editID! + headerNoString2 + ".jpg")
                        
                        imageRef3.putData(imageData1!, metadata: metadata) { (metadata, error) in
                            if error != nil {
                                // 画像のアップロード失敗
                                print("アップロード失敗4")
                                //HUD.flash(.labeledError(title: "エラー", subtitle: "再度お試しください"), delay: 1.4)
                                SVProgressHUD.setDefaultStyle(.custom)
                                SVProgressHUD.setDefaultMaskType(.custom)
                                SVProgressHUD.setForegroundColor(.black)
                                SVProgressHUD.setBackgroundColor(.white)
                                SVProgressHUD.setDefaultMaskType(.black)
                                SVProgressHUD.showError(withStatus: "再度お試しください")
                                //withDelayにIntを設定
                                SVProgressHUD.dismiss()
                                return
                            }else{
                                print("アップロード成功4")
                                
                                //imageNoを1増やしたimageNoを新しい画像の保存先として使う
                                let ref = Firestore.firestore().collection("users").document(self.userdata!.editID!)
                                ref.updateData(["with_headerImage": "exist"])
                                ref.updateData(["headerNo": FieldValue.increment(1.0)])
                                //withDelayにIntを設定
                                SVProgressHUD.dismiss()
                                //遷移元に戻る
                                self.navigationController?.popViewController(animated: true)
                            }
                        }
                        
                    }
                }
                //両方写真変更した場合
            } else if selectedImage2 != nil && selectedImage1 != nil{
                
                let imageNo = self.userdata2!.imageNo!
                let imageNoString1: String = "\(imageNo)"
                let imageNoString2: String = "\(imageNo + 1)"
                let headerNo = self.userdata2!.headerNo!
                let headerNoString1: String = "\(headerNo)"
                let headerNoString2: String = "\(headerNo + 1)"
                
                print("確認3-両方変更")
                
                let imageData1 = selectedImage1.jpegData(compressionQuality: 0.3)
                let imageData2 = selectedImage2.jpegData(compressionQuality: 0.3)
                
                let imageRef1 = Storage.storage().reference().child("iconImages").child(self.userdata!.editID! + imageNoString1 + ".jpg")
                let imageRef2 = Storage.storage().reference().child("headerImages").child(self.userdata!.editID! + headerNoString1 + ".jpg")
                
                imageRef1.delete { error in
                    if let error = error {
                        let nsError = error as NSError
                        if nsError.domain == StorageErrorDomain &&
                            nsError.code == StorageErrorCode.objectNotFound.rawValue {
                            print("目的の参照にオブジェクトが存在しません3")
                            
                            let imageRef3 = Storage.storage().reference().child("iconImages").child(self.userdata!.editID! + imageNoString2 + ".jpg")
                            
                            imageRef3.putData(imageData2!, metadata: metadata) { (metadata, error) in
                                if error != nil {
                                    // 画像のアップロード失敗
                                    print("アップロード失敗5")
                                    //HUD.flash(.labeledError(title: "エラー", subtitle: "再度お試しください"), delay: 1.4)
                                    SVProgressHUD.setDefaultStyle(.custom)
                                    SVProgressHUD.setDefaultMaskType(.custom)
                                    SVProgressHUD.setForegroundColor(.black)
                                    SVProgressHUD.setBackgroundColor(.white)
                                    SVProgressHUD.setDefaultMaskType(.black)
                                    SVProgressHUD.showError(withStatus: "再度お試しください")
                                    //withDelayにIntを設定
                                    SVProgressHUD.dismiss()
                                    return
                                }else{
                                    print("アップロード成功5")
                                    
                                    //imageNoを1増やしたimageNoを新しい画像の保存先として使う
                                    let ref = Firestore.firestore().collection("users").document(self.userdata!.editID!)
                                    ref.updateData(["imageNo": FieldValue.increment(1.0)])
                                    ref.updateData(["with_iconImage": "exist"])
                                    //withDelayにIntを設定
                                    SVProgressHUD.dismiss()
                                    //遷移元に戻る
                                    self.navigationController?.popViewController(animated: true)
                                }
                            }
                        }
                    } else {
                        print("delete success!!3")
                        
                        let imageRef3 = Storage.storage().reference().child("iconImages").child(self.userdata!.editID! + imageNoString2 + ".jpg")
                        
                        imageRef3.putData(imageData2!, metadata: metadata) { (metadata, error) in
                            if error != nil {
                                // 画像のアップロード失敗
                                print("アップロード失敗6")
                                //HUD.flash(.labeledError(title: "エラー", subtitle: "再度お試しください"), delay: 1.4)
                                SVProgressHUD.setDefaultStyle(.custom)
                                SVProgressHUD.setDefaultMaskType(.custom)
                                SVProgressHUD.setForegroundColor(.black)
                                SVProgressHUD.setBackgroundColor(.white)
                                SVProgressHUD.setDefaultMaskType(.black)
                                SVProgressHUD.showError(withStatus: "再度お試しください")
                                //withDelayにIntを設定
                                SVProgressHUD.dismiss()
                                return
                            }else{
                                print("アップロード成功6")
                                
                                //imageNoを1増やしたimageNoを新しい画像の保存先として使う
                                let ref = Firestore.firestore().collection("users").document(self.userdata!.editID!)
                                ref.updateData(["imageNo": FieldValue.increment(1.0)])
                                ref.updateData(["with_iconImage": "exist"])
                                //withDelayにIntを設定
                                SVProgressHUD.dismiss()
                                //遷移元に戻る
                                self.navigationController?.popViewController(animated: true)
                            }
                        }
                    }
                }
                imageRef2.delete { error in
                    if let error = error {
                        let nsError = error as NSError
                        if nsError.domain == StorageErrorDomain &&
                            nsError.code == StorageErrorCode.objectNotFound.rawValue {
                            print("目的の参照にオブジェクトが存在しません4")
                            
                            let imageRef4 = Storage.storage().reference().child("headerImages").child(self.userdata!.editID! + headerNoString2 + ".jpg")
                            
                            imageRef4.putData(imageData1!, metadata: metadata) { (metadata, error) in
                                if error != nil {
                                    // 画像のアップロード失敗
                                    print("アップロード失敗7")
                                    //HUD.flash(.labeledError(title: "エラー", subtitle: "再度お試しください"), delay: 1.4)
                                    SVProgressHUD.setDefaultStyle(.custom)
                                    SVProgressHUD.setDefaultMaskType(.custom)
                                    SVProgressHUD.setForegroundColor(.black)
                                    SVProgressHUD.setBackgroundColor(.white)
                                    SVProgressHUD.setDefaultMaskType(.black)
                                    SVProgressHUD.showError(withStatus: "再度お試しください")
                                    //withDelayにIntを設定
                                    SVProgressHUD.dismiss()
                                    return
                                }else{
                                    print("アップロード成功7")
                                    
                                    //imageNoを1増やしたimageNoを新しい画像の保存先として使う
                                    let ref2 = Firestore.firestore().collection("users").document(self.userdata!.editID!)
                                    ref2.updateData(["headerNo": FieldValue.increment(1.0)])
                                    ref2.updateData(["with_headerImage": "exist"])
                                    //withDelayにIntを設定
                                    SVProgressHUD.dismiss()
                                    //遷移元に戻る
                                    self.navigationController?.popViewController(animated: true)
                                }
                            }
                            
                        }
                    } else {
                        print("delete success!!4")
                        
                        let imageRef4 = Storage.storage().reference().child("headerImages").child(self.userdata!.editID! + headerNoString2 + ".jpg")
                        
                        imageRef4.putData(imageData1!, metadata: metadata) { (metadata, error) in
                            if error != nil {
                                // 画像のアップロード失敗
                                print("アップロード失敗8")
                                //HUD.flash(.labeledError(title: "エラー", subtitle: "再度お試しください"), delay: 1.4)
                                SVProgressHUD.setDefaultStyle(.custom)
                                SVProgressHUD.setDefaultMaskType(.custom)
                                SVProgressHUD.setForegroundColor(.black)
                                SVProgressHUD.setBackgroundColor(.white)
                                SVProgressHUD.setDefaultMaskType(.black)
                                SVProgressHUD.showError(withStatus: "再度お試しください")
                                //withDelayにIntを設定
                                SVProgressHUD.dismiss()
                                return
                            }else{
                                print("アップロード成功8")
                                
                                //imageNoを1増やしたimageNoを新しい画像の保存先として使う
                                let ref2 = Firestore.firestore().collection("users").document(self.userdata!.editID!)
                                ref2.updateData(["headerNo": FieldValue.increment(1.0)])
                                ref2.updateData(["with_headerImage": "exist"])
                                //withDelayにIntを設定
                                SVProgressHUD.dismiss()
                                //遷移元に戻る
                                self.navigationController?.popViewController(animated: true)
                            }
                        }
                    }
                }
            }
        }
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
        
        //iconを変更するとき
        if self.selectingHeader == false {
            selectedImage2 = image
            iconImageView3.image = image
            self.iconImageView.isHidden = true
            self.iconImageView2.isHidden = true
            addImage2.isHidden = true
            iconBack.isHidden = true
            saveButton.isEnabled = true
        }else{
            selectedImage1 = image
            headerImageView.image = image
            self.headerImageView2.isHidden = true
            addImage.isHidden = true
            headerBack.isHidden = true
            saveButton.isEnabled = true
        }
        cropViewController.dismiss(animated: true, completion: nil)
    }
}

extension ProfileEditViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if info[.originalImage] != nil {
            guard let pickerImage = (info[UIImagePickerController.InfoKey.originalImage] as? UIImage) else { return }
            
            //iconを変更するとき
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

extension UIView {
    func addoverlay(color: UIColor = .gray,alpha : CGFloat = 0.6) {
        let overlay = UIView()
        overlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        overlay.frame = bounds
        overlay.backgroundColor = color
        overlay.alpha = alpha
        addSubview(overlay)
    }
    //This function will add a layer on any `UIView` to make that `UIView` look darkened
}

