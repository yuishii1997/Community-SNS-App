//
//  ChooseDestViewController.swift
//  Nomad-App
//
//  Created by yuishii on 2020/12/21.
//  Copyright © 2020 Yu Ishii. All rights reserved.
//
// 投稿先を選択する画面

import UIKit
import Firebase
import MessageUI
import NotificationBannerSwift
import SVProgressHUD

class ChooseDestViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    // 投稿データを格納する配列
    var userArray: [UserData] = []
    var userdata: UserData?
    
    var userID: String = ""
    var userName: String = ""
    
    // Firestoreのリスナー
    var listener: ListenerRegistration!
    var listener2: ListenerRegistration!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //空セルのseparator(しきり線)を消す
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.separatorStyle = .none
        
        //テーブルビューの仕切り線を左端までつける
        tableView.separatorInset = .zero
        
        self.tableView.backgroundColor = .tertiarySystemGroupedBackground
        
        tableView.delegate = self
        tableView.dataSource = self
        
        
        let nib1 = UINib(nibName: "Following3TableViewCell", bundle: nil)
        tableView.register(nib1, forCellReuseIdentifier: "Following3")
        
        let nib2 = UINib(nibName: "Following4TableViewCell", bundle: nil)
        tableView.register(nib2, forCellReuseIdentifier: "Following4")
        
        let noneNib = UINib(nibName: "NoneDestTableViewCell", bundle: nil)
        tableView.register(noneNib, forCellReuseIdentifier: "NoneDest")
        
        let section1 = UINib(nibName: "ChooseDest1TableViewCell", bundle: nil)
        tableView.register(section1, forCellReuseIdentifier: "ChooseDest1")
        let section2 = UINib(nibName: "ChooseDest2TableViewCell", bundle: nil)
        tableView.register(section2, forCellReuseIdentifier: "ChooseDest2")
        let section3 = UINib(nibName: "ChooseDest3TableViewCell", bundle: nil)
        tableView.register(section3, forCellReuseIdentifier: "ChooseDest3")
        
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        self.tabBarController?.tabBar.barTintColor = UIColor.white
        self.navigationController?.navigationBar.tintColor = UIColor.black
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.black]
        
        SVProgressHUD.setDefaultStyle(.custom)
        SVProgressHUD.setDefaultMaskType(.none)
        SVProgressHUD.setForegroundColor(.gray)
        SVProgressHUD.setBackgroundColor(.clear)
        SVProgressHUD.setBackgroundLayerColor(.clear)
        SVProgressHUD.show()
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
        self.navigationItem.title = "投稿先を選択"
        self.navigationController?.navigationBar.titleTextAttributes
            = [NSAttributedString.Key.font: UIFont(name: "Helvetica", size: 16)!]
        self.navigationController?.navigationBar.shadowImage = nil
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        self.tabBarController?.tabBar.barTintColor = UIColor.white
        self.navigationController?.navigationBar.tintColor = UIColor.black
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.black]
        

        if Auth.auth().currentUser != nil {
            
            fetchUser() //自分の情報を取得
            fetchCommunity() //フォローしているコミュニティを取得
            
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
        
        SVProgressHUD.dismiss()
        
        if ( self.listener != nil ){
            listener.remove()
            listener = nil
        }
        
        if ( self.listener2 != nil ){
            listener2.remove()
            listener2 = nil
        }
        
    }
    
    //自分の情報を取得
    private func fetchUser() {
        
        let myid = Auth.auth().currentUser!.uid
        if ( self.listener2 == nil ) {
            let userRef = Firestore.firestore().collection("users").document(myid)
            self.listener2 = userRef.addSnapshotListener() { (documentSnapshot, error) in
                guard let document = documentSnapshot else {
                    print("Error fetching document: \(error!)")
                    return
                }
                self.userdata  = UserData(document: document)
                self.tableView.reloadData()
            }
        }
    }
    
    //フォローしているコミュニティを取得
    private func fetchCommunity() {
        
        if listener == nil {
            let userRef = Firestore.firestore().collection("users").whereField("type", isEqualTo: "community")
            self.listener = userRef.addSnapshotListener() { [weak self] querySnapshot, error in
                if let error = error {
                    print("DEBUG_PRINT: snapshotの取得が失敗しました。 \(error)")
                    return
                } else {
                    self?.userArray = querySnapshot!.documents.compactMap { document in
                        print("DEBUG_PRINT: document取得 \(document.documentID)")
                        let userData = UserData(document: document)
                        if userData.isFollowed == true {
                            return userData
                        } else {
                            return nil
                        }
                    }
                    self?.userArray.sort { $0.followedTime > $1.followedTime }
                    SVProgressHUD.dismiss()
                    self?.tableView.reloadData()
                }
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        view.tintColor = .white
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0{
            return 1
        }else if section == 1 {
            return 1
        }else if section == 2 {
            return 1
        }else if section == 3 {
            if self.userArray.count == 0 {
                return 1
            }else{
                return self.userArray.count
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
        
        if indexPath.section == 0 {
            print("section0")
        }else if indexPath.section == 1 {
            print("section1")
            
        }else if indexPath.section == 2 {
            print("section2")
        }else if indexPath.section == 3 {
            if self.userArray.count == 0 {
                print("フォローしているコミュニティーがありません")
            }else{
                print("フォローしているコミュニティーがあります")
            }
        }else{
            print("section4")
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ChooseDest1", for: indexPath) as! ChooseDest1TableViewCell
            cell.selectionStyle = .none
            return cell
        }else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Following3", for: indexPath) as! Following3TableViewCell
            cell.userdata = userdata
            cell.selectionStyle = .none
            cell.chooseButton.addTarget(self, action:#selector(handleButton1(_:forEvent:)), for: .touchUpInside)
            return cell
        }else if indexPath.section == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ChooseDest2", for: indexPath) as! ChooseDest2TableViewCell
            cell.selectionStyle = .none
            return cell
        }else if indexPath.section == 3 {
            if self.userArray.count == 0 {
                print("フォローしているコミュニティーがありません")
                let cell = tableView.dequeueReusableCell(withIdentifier: "NoneDest", for: indexPath) as! NoneDestTableViewCell
                cell.selectionStyle = .none
                return cell
            }else{
                print("フォローしているコミュニティーがあります")
                let cell = tableView.dequeueReusableCell(withIdentifier: "Following4", for: indexPath) as! Following4TableViewCell
                cell.setUserData(self.userArray[indexPath.row])
                cell.selectionStyle = .none
                cell.chooseButton.addTarget(self, action:#selector(handleButton2(_:forEvent:)), for: .touchUpInside)
                return cell
            }
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "ChooseDest3", for: indexPath) as! ChooseDest3TableViewCell
            cell.selectionStyle = .none
            return cell
        }
    }
    
    // 自分のセルがタップされた時に呼ばれるメソッド
    @objc func handleButton1(_ sender: UIButton, forEvent event: UIEvent) {
        
        print("handleButton1")
        
        SVProgressHUD.setDefaultStyle(.custom)
        SVProgressHUD.setDefaultMaskType(.custom)
        SVProgressHUD.setForegroundColor(.black)
        SVProgressHUD.setBackgroundColor(.white)
        SVProgressHUD.setDefaultMaskType(.black)
        //HUD.show(.progress, onView: view)
        SVProgressHUD.show()
        
        if Auth.auth().currentUser != nil {
            let myid = Auth.auth().currentUser!.uid
            let name = Auth.auth().currentUser!.displayName
            let ref = Firestore.firestore().collection("users").document(myid)
            ref.updateData(["destID": myid])
            
            let ref2 = Firestore.firestore().collection("users").document(myid)
            ref2.updateData(["destName": name])
            
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    // フォローしているコミュニティのセルがタップされた時に呼ばれるメソッド
    @objc func handleButton2(_ sender: UIButton, forEvent event: UIEvent) {
        
        print("handleButton2")
        
        // タップされたセルのインデックスを求める
        let touch = event.allTouches?.first
        let point = touch!.location(in: self.tableView)
        guard let indexPath = tableView.indexPathForRow(at: point) else { return }
        
        // 配列からタップされたインデックスのデータを取り出す
        let userData = userArray[indexPath.row]
        let uid = userData.uid
        let name = userData.name
        
        SVProgressHUD.setDefaultStyle(.custom)
        SVProgressHUD.setDefaultMaskType(.custom)
        SVProgressHUD.setForegroundColor(.black)
        SVProgressHUD.setBackgroundColor(.white)
        SVProgressHUD.setDefaultMaskType(.black)
        //HUD.show(.progress, onView: view)
        SVProgressHUD.show()
        
        if Auth.auth().currentUser != nil {
            let myid = Auth.auth().currentUser!.uid
            let ref = Firestore.firestore().collection("users").document(myid)
            ref.updateData(["destID": uid])
            ref.updateData(["commentOff": "off"])
            ref.updateData(["bePrivate": "off"])
            
            let ref2 = Firestore.firestore().collection("users").document(myid)
            ref2.updateData(["destName": name])
            
            self.navigationController?.popViewController(animated: true)
        }
    }
}
