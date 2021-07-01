//
//  Page4ComViewController.swift
//  Nomad-App
//
//  Created by yuishii on 2020/12/15.
//  Copyright © 2020 Yu Ishii. All rights reserved.
//
// プロフィール画面の4ページ目

import UIKit
import SegementSlide
import Firebase
import NotificationBannerSwift
import GoogleMobileAds
import SVProgressHUD

class Page4ComViewController: UITableViewController,SegementSlideContentScrollViewDelegate {
    
    var userID: String = ""
    
    var postdata: PostData?
    
    // 投稿データを格納する配列
    var postArray: [PostData] = []
    // ブロックユーザーデータを格納する配列
    var blockUserArray: [String] = []
    
    var listener1: ListenerRegistration!
    
    // ユーザーデータを格納する配列
    var userArray: [UserData] = []
    var userdata: UserData?
    var userdata2: UserData?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let backBarButtonItem = UIBarButtonItem()
        backBarButtonItem.title = "Back"
        self.navigationItem.backBarButtonItem = backBarButtonItem
        
        print("Page1ViewController-Page1userID:\(userID)")
        
        // カスタムセルを登録する
        let nib1 = UINib(nibName: "OverViewTableViewCell", bundle: nil)
        tableView.register(nib1, forCellReuseIdentifier: "OverView")
        
        let nib2 = UINib(nibName: "NotP6PostsTableViewCell", bundle: nil)
        tableView.register(nib2, forCellReuseIdentifier: "NotP6Posts")
        
        //空セルのseparator(しきり線)を消す
        tableView.tableFooterView = UIView(frame: .zero)
        //テーブルビューの仕切り線を左端までつける
        tableView.separatorInset = .zero
        tableView.separatorStyle = .none
        self.tableView.backgroundColor = .white
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
        
    }
    
    private func fetchUser() {
        
        let userRef = Firestore.firestore().collection("users").document(userID)
        self.listener1 = userRef.addSnapshotListener() { (documentSnapshot, error) in
            guard let document = documentSnapshot else {
                print("Error fetching document: \(error!)")
                return
            }
            self.userdata  = UserData(document: document)
            self.tableView.reloadData()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        SVProgressHUD.dismiss()
        
        if ( self.listener1 != nil ){
            listener1.remove()
            listener1 = nil
        }
    }
    
    
    @objc var scrollView: UIScrollView! {
        return tableView
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        // セクションの背景色を変更する
        view.tintColor = .white
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 1
        
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 0
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        print("タップされました")
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //概要がある場合
        if userdata?.overView != nil {
            
            print("userdata?.overView != nil")
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "OverView", for: indexPath) as! OverViewTableViewCell
            cell.userdata = userdata
            
            //セル押下時のハイライト(色が濃くなる)を無効
            cell.selectionStyle = .none
            
            return cell
            //説明がない場合
        }else{
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "NotP6Posts", for: indexPath) as! NotP6PostsTableViewCell
            
            print("userdata?.overView == nil")
            
            //セル押下時のハイライト(色が濃くなる)を無効
            cell.selectionStyle = .none
            
            cell.label.text = "このコミュニティは概要を設定していません。"
            
            return cell
        }
    }
    
}




