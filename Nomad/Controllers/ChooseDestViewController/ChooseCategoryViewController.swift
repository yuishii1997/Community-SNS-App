//
//  ChooseCategoryViewController.swift
//  Nomad-App
//
//  Created by yuishii on 2021/02/04.
//  Copyright © 2021 Yu Ishii. All rights reserved.
//
// 投稿先のカテゴリーを選択する画面

import UIKit
import Firebase
import MessageUI
import NotificationBannerSwift
import SVProgressHUD

class ChooseCategoryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    private var postdata: PostData?
    
    // ユーザーデータを格納する配列
    var userArray: [UserData] = []
    var userdata: UserData?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.separatorInset = .zero
        tableView.separatorStyle = .none
        self.tableView.backgroundColor = .white
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView(frame: .zero)
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
        
        let backBarButtonItem = UIBarButtonItem()
        backBarButtonItem.title = "Back"
        self.navigationItem.backBarButtonItem = backBarButtonItem
        self.navigationItem.title = "カテゴリーを追加"
        self.navigationController?.navigationBar.titleTextAttributes
            = [NSAttributedString.Key.font: UIFont(name: "Helvetica", size: 16)!]
        self.navigationController?.navigationBar.shadowImage = nil
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        self.tabBarController?.tabBar.barTintColor = UIColor.white
        self.navigationController?.navigationBar.tintColor = UIColor.black
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.black]
        let menuNib = UINib(nibName: "CategoryMenuTableViewCell3", bundle: nil)
        tableView.register(menuNib, forCellReuseIdentifier: "CategoryMenu3")
    }
    
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = .white
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 1
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 0
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 2123
        
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryMenu3", for: indexPath) as! CategoryMenuTableViewCell3
        cell.selectionStyle = .none
        
        cell.button.addTarget(self, action:#selector(chooseCategory(_:forEvent:)), for: .touchUpInside)
        cell.button1.addTarget(self, action:#selector(chooseCategory1(_:forEvent:)), for: .touchUpInside)
        cell.button2.addTarget(self, action:#selector(chooseCategory2(_:forEvent:)), for: .touchUpInside)
        cell.button3.addTarget(self, action:#selector(chooseCategory3(_:forEvent:)), for: .touchUpInside)
        cell.button4.addTarget(self, action:#selector(chooseCategory4(_:forEvent:)), for: .touchUpInside)
        cell.button5.addTarget(self, action:#selector(chooseCategory5(_:forEvent:)), for: .touchUpInside)
        cell.button6.addTarget(self, action:#selector(chooseCategory6(_:forEvent:)), for: .touchUpInside)
        cell.button7.addTarget(self, action:#selector(chooseCategory7(_:forEvent:)), for: .touchUpInside)
        cell.button8.addTarget(self, action:#selector(chooseCategory8(_:forEvent:)), for: .touchUpInside)
        cell.button9.addTarget(self, action:#selector(chooseCategory9(_:forEvent:)), for: .touchUpInside)
        cell.button10.addTarget(self, action:#selector(chooseCategory10(_:forEvent:)), for: .touchUpInside)
        cell.button11.addTarget(self, action:#selector(chooseCategory11(_:forEvent:)), for: .touchUpInside)
        cell.button12.addTarget(self, action:#selector(chooseCategory12(_:forEvent:)), for: .touchUpInside)
        cell.button13.addTarget(self, action:#selector(chooseCategory13(_:forEvent:)), for: .touchUpInside)
        cell.button14.addTarget(self, action:#selector(chooseCategory14(_:forEvent:)), for: .touchUpInside)
        cell.button15.addTarget(self, action:#selector(chooseCategory15(_:forEvent:)), for: .touchUpInside)
        cell.button16.addTarget(self, action:#selector(chooseCategory16(_:forEvent:)), for: .touchUpInside)
        cell.button17.addTarget(self, action:#selector(chooseCategory17(_:forEvent:)), for: .touchUpInside)
        cell.button18.addTarget(self, action:#selector(chooseCategory18(_:forEvent:)), for: .touchUpInside)
        cell.button19.addTarget(self, action:#selector(chooseCategory19(_:forEvent:)), for: .touchUpInside)
        cell.button20.addTarget(self, action:#selector(chooseCategory20(_:forEvent:)), for: .touchUpInside)
        cell.button21.addTarget(self, action:#selector(chooseCategory21(_:forEvent:)), for: .touchUpInside)
        cell.button22.addTarget(self, action:#selector(chooseCategory22(_:forEvent:)), for: .touchUpInside)
        cell.button23.addTarget(self, action:#selector(chooseCategory23(_:forEvent:)), for: .touchUpInside)
        cell.button24.addTarget(self, action:#selector(chooseCategory24(_:forEvent:)), for: .touchUpInside)
        cell.button25.addTarget(self, action:#selector(chooseCategory25(_:forEvent:)), for: .touchUpInside)
        cell.button26.addTarget(self, action:#selector(chooseCategory26(_:forEvent:)), for: .touchUpInside)
        cell.button27.addTarget(self, action:#selector(chooseCategory27(_:forEvent:)), for: .touchUpInside)
        cell.button28.addTarget(self, action:#selector(chooseCategory28(_:forEvent:)), for: .touchUpInside)
        cell.button29.addTarget(self, action:#selector(chooseCategory29(_:forEvent:)), for: .touchUpInside)
        cell.button30.addTarget(self, action:#selector(chooseCategory30(_:forEvent:)), for: .touchUpInside)
        cell.button31.addTarget(self, action:#selector(chooseCategory31(_:forEvent:)), for: .touchUpInside)
        cell.button32.addTarget(self, action:#selector(chooseCategory32(_:forEvent:)), for: .touchUpInside)
        cell.button33.addTarget(self, action:#selector(chooseCategory33(_:forEvent:)), for: .touchUpInside)
        cell.button34.addTarget(self, action:#selector(chooseCategory34(_:forEvent:)), for: .touchUpInside)
        cell.button35.addTarget(self, action:#selector(chooseCategory35(_:forEvent:)), for: .touchUpInside)
        cell.button36.addTarget(self, action:#selector(chooseCategory36(_:forEvent:)), for: .touchUpInside)
        cell.button37.addTarget(self, action:#selector(chooseCategory37(_:forEvent:)), for: .touchUpInside)
        cell.button38.addTarget(self, action:#selector(chooseCategory38(_:forEvent:)), for: .touchUpInside)
        
        return cell
    }
    
    // 画面から非表示になる直前に呼ばれます。
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // HUDを消す
        SVProgressHUD.dismiss()
    }
    
    // 「カテゴリーを設定しない」がタップされた時に呼ばれるメソッド
    @objc func chooseCategory(_ sender: UIButton, forEvent event: UIEvent) {
        
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
            ref.updateData(["category": "n"])
            
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    // 「ニュース」がタップされた時に呼ばれるメソッド
    @objc func chooseCategory1(_ sender: UIButton, forEvent event: UIEvent) {
        
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
            ref.updateData(["category": "news"])
            
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    // 「話題・トレンド」がタップされた時に呼ばれるメソッド
    @objc func chooseCategory2(_ sender: UIButton, forEvent event: UIEvent) {
        
        SVProgressHUD.setDefaultStyle(.custom)
        SVProgressHUD.setDefaultMaskType(.custom)
        SVProgressHUD.setForegroundColor(.black)
        SVProgressHUD.setBackgroundColor(.white)
        SVProgressHUD.setDefaultMaskType(.black)
        SVProgressHUD.show()
        
        if Auth.auth().currentUser != nil {
            let myid = Auth.auth().currentUser!.uid
            
            let ref = Firestore.firestore().collection("users").document(myid)
            ref.updateData(["category": "trend"])
            
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    // 「政治・社会」がタップされた時に呼ばれるメソッド
    @objc func chooseCategory3(_ sender: UIButton, forEvent event: UIEvent) {
        
        SVProgressHUD.setDefaultStyle(.custom)
        SVProgressHUD.setDefaultMaskType(.custom)
        SVProgressHUD.setForegroundColor(.black)
        SVProgressHUD.setBackgroundColor(.white)
        SVProgressHUD.setDefaultMaskType(.black)
        SVProgressHUD.show()
        
        if Auth.auth().currentUser != nil {
            let myid = Auth.auth().currentUser!.uid
            
            let ref = Firestore.firestore().collection("users").document(myid)
            ref.updateData(["category": "politics"])
            
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    // 「スポーツ」がタップされた時に呼ばれるメソッド
    @objc func chooseCategory4(_ sender: UIButton, forEvent event: UIEvent) {
        
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
            ref.updateData(["category": "sports"])
            
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    // 「音楽」がタップされた時に呼ばれるメソッド
    @objc func chooseCategory5(_ sender: UIButton, forEvent event: UIEvent) {
        
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
            ref.updateData(["category": "music"])
            
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    // 「おもしろ」がタップされた時に呼ばれるメソッド
    @objc func chooseCategory6(_ sender: UIButton, forEvent event: UIEvent) {
        
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
            ref.updateData(["category": "funny"])
            
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    // 「エンタメ」がタップされた時に呼ばれるメソッド
    @objc func chooseCategory7(_ sender: UIButton, forEvent event: UIEvent) {
        
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
            ref.updateData(["category": "entertainment"])
            
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    // 「TV・映画」がタップされた時に呼ばれるメソッド
    @objc func chooseCategory8(_ sender: UIButton, forEvent event: UIEvent) {
        
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
            ref.updateData(["category": "tv"])
            
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    // 「YouTube」がタップされた時に呼ばれるメソッド
    @objc func chooseCategory9(_ sender: UIButton, forEvent event: UIEvent) {
        
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
            ref.updateData(["category": "youtube"])
            
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    // 「経済・金融」がタップされた時に呼ばれるメソッド
    @objc func chooseCategory10(_ sender: UIButton, forEvent event: UIEvent) {
        
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
            ref.updateData(["category": "economics"])
            
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    // 「ビジネス」がタップされた時に呼ばれるメソッド
    @objc func chooseCategory11(_ sender: UIButton, forEvent event: UIEvent) {
        
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
            ref.updateData(["category": "business"])
            
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    // 「IT・テクノロジー」がタップされた時に呼ばれるメソッド
    @objc func chooseCategory12(_ sender: UIButton, forEvent event: UIEvent) {
        
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
            ref.updateData(["category": "it"])
            
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    // 「科学」がタップされた時に呼ばれるメソッド
    @objc func chooseCategory13(_ sender: UIButton, forEvent event: UIEvent) {
        
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
            ref.updateData(["category": "science"])
            
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    // 「健康・医療」がタップされた時に呼ばれるメソッド
    @objc func chooseCategory14(_ sender: UIButton, forEvent event: UIEvent) {
        
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
            ref.updateData(["category": "health"])
            
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    // 「美容」がタップされた時に呼ばれるメソッド
    @objc func chooseCategory15(_ sender: UIButton, forEvent event: UIEvent) {
        
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
            ref.updateData(["category": "beauty"])
            
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    // 「ファッション」がタップされた時に呼ばれるメソッド
    @objc func chooseCategory16(_ sender: UIButton, forEvent event: UIEvent) {
        
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
            ref.updateData(["category": "fashion"])
            
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    // 「仕事」がタップされた時に呼ばれるメソッド
    @objc func chooseCategory17(_ sender: UIButton, forEvent event: UIEvent) {
        
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
            ref.updateData(["category": "job"])
            
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    // 「学校」がタップされた時に呼ばれるメソッド
    @objc func chooseCategory18(_ sender: UIButton, forEvent event: UIEvent) {
        
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
            ref.updateData(["category": "school"])
            
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    // 「趣味」がタップされた時に呼ばれるメソッド
    @objc func chooseCategory19(_ sender: UIButton, forEvent event: UIEvent) {
        
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
            ref.updateData(["category": "hobby"])
            
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    // 「文化・芸術」がタップされた時に呼ばれるメソッド
    @objc func chooseCategory20(_ sender: UIButton, forEvent event: UIEvent) {
        
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
            ref.updateData(["category": "art"])
            
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    // 「漫画・アニメ」がタップされた時に呼ばれるメソッド
    @objc func chooseCategory21(_ sender: UIButton, forEvent event: UIEvent) {
        
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
            ref.updateData(["category": "manga"])
            
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    // 「ゲーム」がタップされた時に呼ばれるメソッド
    @objc func chooseCategory22(_ sender: UIButton, forEvent event: UIEvent) {
        
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
            ref.updateData(["category": "game"])
            
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    // 「暮らし・生活」がタップされた時に呼ばれるメソッド
    @objc func chooseCategory23(_ sender: UIButton, forEvent event: UIEvent) {
        
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
            ref.updateData(["category": "life"])
            
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    // 「家族」がタップされた時に呼ばれるメソッド
    @objc func chooseCategory24(_ sender: UIButton, forEvent event: UIEvent) {
        
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
            ref.updateData(["category": "family"])
            
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    // 「結婚・恋愛」がタップされた時に呼ばれるメソッド
    @objc func chooseCategory25(_ sender: UIButton, forEvent event: UIEvent) {
        
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
            ref.updateData(["category": "love"])
            
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    // 「子育て・教育」がタップされた時に呼ばれるメソッド
    @objc func chooseCategory26(_ sender: UIButton, forEvent event: UIEvent) {
        
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
            ref.updateData(["category": "parenting"])
            
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    // 「グルメ・レシピ」がタップされた時に呼ばれるメソッド
    @objc func chooseCategory27(_ sender: UIButton, forEvent event: UIEvent) {
        
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
            ref.updateData(["category": "recipe"])
            
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    // 「勉強・学問」がタップされた時に呼ばれるメソッド
    @objc func chooseCategory28(_ sender: UIButton, forEvent event: UIEvent) {
        
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
            ref.updateData(["category": "study"])
            
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    // 「質問・相談」がタップされた時に呼ばれるメソッド
    @objc func chooseCategory29(_ sender: UIButton, forEvent event: UIEvent) {
        
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
            ref.updateData(["category": "question"])
            
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    // 「不思議・謎」がタップされた時に呼ばれるメソッド
    @objc func chooseCategory30(_ sender: UIButton, forEvent event: UIEvent) {
        
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
            ref.updateData(["category": "mystery"])
            
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    // 「都道府県」がタップされた時に呼ばれるメソッド
    @objc func chooseCategory31(_ sender: UIButton, forEvent event: UIEvent) {
        
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
            ref.updateData(["category": "prefectures"])
            
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    // 「海外」がタップされた時に呼ばれるメソッド
    @objc func chooseCategory32(_ sender: UIButton, forEvent event: UIEvent) {
        
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
            ref.updateData(["category": "world"])
            
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    // 「旅行」がタップされた時に呼ばれるメソッド
    @objc func chooseCategory33(_ sender: UIButton, forEvent event: UIEvent) {
        
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
            ref.updateData(["category": "travel"])
            
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    // 「プロモーション」がタップされた時に呼ばれるメソッド
    @objc func chooseCategory34(_ sender: UIButton, forEvent event: UIEvent) {
        
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
            ref.updateData(["category": "pr"])
            
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    // 「自転車・乗り物」がタップされた時に呼ばれるメソッド
    @objc func chooseCategory35(_ sender: UIButton, forEvent event: UIEvent) {
        
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
            ref.updateData(["category": "car"])
            
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    // 「ペット・動物」がタップされた時に呼ばれるメソッド
    @objc func chooseCategory36(_ sender: UIButton, forEvent event: UIEvent) {
        
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
            ref.updateData(["category": "pet"])
            
            self.navigationController?.popViewController(animated: true)
        }
        
    }
    
    // 「雑談・ネタ」がタップされた時に呼ばれるメソッド
    @objc func chooseCategory37(_ sender: UIButton, forEvent event: UIEvent) {
        
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
            ref.updateData(["category": "chat"])
            
            self.navigationController?.popViewController(animated: true)
        }
        
    }
    
    // 「その他」がタップされた時に呼ばれるメソッド
    @objc func chooseCategory38(_ sender: UIButton, forEvent event: UIEvent) {
        
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
            ref.updateData(["category": "other"])
            
            self.navigationController?.popViewController(animated: true)
        }
        
    }
}

