//
//  UserListViewController.swift
//  Nomad-App
//
//  Created by yuishii on 2021/02/23.
//  Copyright © 2021 Yu Ishii. All rights reserved.
//
// 新規登録直後で誰もフォローしていないときに、おすすめのユーザーを一覧で表示する画面

import UIKit
import SegementSlide
import Firebase
import NotificationBannerSwift
import SVProgressHUD

class UserListViewController: UIViewController,UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    // 表示するユーザーデータをmoderateUserArrayの順に格納する配列
    var userArray: [UserData] = []
    
    // Firestoreのリスナー
    var listener: ListenerRegistration!
    var listener1: ListenerRegistration!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
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
        let nib3 = UINib(nibName: "NotPostTableViewCell", bundle: nil)
        tableView.register(nib3, forCellReuseIdentifier: "NotPost")
        let marginNib = UINib(nibName: "Margin2TableViewCell", bundle: nil)
        tableView.register(marginNib, forCellReuseIdentifier: "Margin2")
        
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
        
        // NavigationBarを表示したい場合
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        
        let backBarButtonItem = UIBarButtonItem()
        backBarButtonItem.title = "Back"
        self.navigationItem.backBarButtonItem = backBarButtonItem
        self.navigationItem.title = "おすすめのユーザー"
        self.navigationController?.navigationBar.titleTextAttributes
            = [NSAttributedString.Key.font: UIFont(name: "Helvetica", size: 16)!]
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        self.tabBarController?.tabBar.barTintColor = UIColor.white
        self.navigationController?.navigationBar.tintColor = UIColor.black
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.black]
        
        
        if let currentUser = Auth.auth().currentUser {
            if listener == nil {
                let userRef = Firestore.firestore().collection("users").order(by: "date", descending: true).whereField("bePrivate", isEqualTo: "off").whereField("type", isEqualTo: "private")
                self.listener = userRef.addSnapshotListener() { [weak self] querySnapshot, error in
                    if let error = error {
                        print("DEBUG_PRINT: snapshotの取得が失敗しました。 \(error)")
                        return
                    } else {
                        self?.userArray = querySnapshot!.documents.compactMap { document in
                            print("DEBUG_PRINT: document取得 \(document.documentID)")
                            let userData = UserData(document: document)
                            if userData.uid != currentUser.uid {
                                return userData
                            } else {
                                return nil
                            }
                        }
                        self?.userArray.sort { $0.follower.count > $1.follower.count }
                        SVProgressHUD.dismiss()
                        self?.tableView.reloadData()
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
        print("テーブルビューを閉じます")
    }
    
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if self.userArray.count == 0 {
            return 1
        }else{
            //空白分カウント
            return 3
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if self.userArray.count == 0 {
            return 1
        }else{
            if section == 0 {
                return 1
            }else if section == 1 {
                if userArray.count >= 100 {
                    return 50
                }else{
                    return userArray.count
                }
            }else{
                return 1
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if self.userArray.count == 0 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "NotPost", for: indexPath) as! NotPostTableViewCell
            cell.label.text = "ユーザーとコミュニティはまだ作成されていません。"
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
