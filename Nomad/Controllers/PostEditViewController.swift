//
//  PostEditViewController.swift
//  Nomad-App
//
//  Created by yuishii on 2021/02/21.
//  Copyright © 2021 Yu Ishii. All rights reserved.
//
// 投稿を編集する画面

import UIKit
import Firebase

class PostEditViewController: UIViewController, UINavigationControllerDelegate {
    
    var documentID: String = ""
    var postdata: PostData?
    
    var listener: ListenerRegistration!
    
    @IBOutlet weak var captionLabel: UILabel!
    @IBOutlet weak var switch1: UISwitch!
    @IBOutlet weak var switch2: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
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
        self.navigationItem.title = "詳細設定"
        self.navigationController?.navigationBar.titleTextAttributes
            = [NSAttributedString.Key.font: UIFont(name: "Helvetica", size: 16)!]
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        self.tabBarController?.tabBar.barTintColor = UIColor.white
        self.navigationController?.navigationBar.tintColor = UIColor.black
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.black]
        
        fetchPosts()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if ( self.listener != nil ){
            listener.remove()
            listener = nil
        }
    }
    
    func fetchPosts() {
        if ( self.listener == nil ) {
            let postsRef = Firestore.firestore().collection("posts").document(documentID)
            listener = postsRef.addSnapshotListener() { (documentSnapshot, error) in
                guard let document = documentSnapshot else {
                    print("Error fetching document: \(error!)")
                    return
                }
                self.postdata  = PostData(document: document)
                self.captionLabel.text = self.postdata?.caption
                if self.postdata?.commentOff == "on" {
                    self.switch1.isOn = true
                    self.switch1.onTintColor = UIColor.rgb(red: 74, green: 162, blue: 235)
                }else{
                    self.switch1.isOn = false
                }
                if self.postdata?.bePrivate == "on" {
                    self.switch2.isOn = true
                    self.switch2.onTintColor = UIColor.rgb(red: 74, green: 162, blue: 235)
                }else{
                    self.switch2.isOn = false
                }
            }
        }
    }
    
    //コメントをオフにするかどうか
    @IBAction func switch1(sender: UISwitch) {
        //オンのとき
        if ( sender.isOn ) {
            print("コメントオフ1")
            let ref = Firestore.firestore().collection("posts").document(self.postdata!.id)
            ref.updateData(["commentOff": "on"])
        } else {
            let ref = Firestore.firestore().collection("posts").document(self.postdata!.id)
            ref.updateData(["commentOff": "off"])
        }
    }
    
    //スレッドを限定公開にするかどうか
    @IBAction func switch2(sender: UISwitch) {
        //オンのとき
        if ( sender.isOn ) {
            print("コメントオフ1")
            let ref = Firestore.firestore().collection("posts").document(self.postdata!.id)
            ref.updateData(["bePrivate": "on"])
        } else {
            let ref = Firestore.firestore().collection("posts").document(self.postdata!.id)
            ref.updateData(["bePrivate": "off"])
        }
    }
    
    
}
