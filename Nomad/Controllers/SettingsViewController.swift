//
//  SettingsViewController.swift
//  Nomad-App
//
//  Created by yuishii on 2021/02/08.
//  Copyright © 2021 Yu Ishii. All rights reserved.
//
// 「設定」画面

import UIKit
import Firebase
import NotificationBannerSwift
import SVProgressHUD


class SettingsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var listener: ListenerRegistration!
    
    var userdata: UserData?
    
    @IBOutlet var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.separatorStyle = .none
        self.tableView.backgroundColor = .white
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(CollectionTableViewCell13.nib(), forCellReuseIdentifier: CollectionTableViewCell13.identifier)
        let nib = UINib(nibName: "AccountTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "Account")
        let nib2 = UINib(nibName: "PrivacyTableViewCell", bundle: nil)
        tableView.register(nib2, forCellReuseIdentifier: "Privacy")
        let nib3 = UINib(nibName: "SecurityTableViewCell", bundle: nil)
        tableView.register(nib3, forCellReuseIdentifier: "Security")
        let nib4 = UINib(nibName: "BasicDataTableViewCell", bundle: nil)
        tableView.register(nib4, forCellReuseIdentifier: "BasicData")
        let nib5 = UINib(nibName: "HelpTableViewCell", bundle: nil)
        tableView.register(nib5, forCellReuseIdentifier: "Help")
        let nib6 = UINib(nibName: "LogoutTableViewCell", bundle: nil)
        tableView.register(nib6, forCellReuseIdentifier: "Logout")
        let section = UINib(nibName: "SettingsSectionTableViewCell", bundle: nil)
        tableView.register(section, forCellReuseIdentifier: "SettingsSection")
        let section2 = UINib(nibName: "SettingsSectionTableViewCell2", bundle: nil)
        tableView.register(section2, forCellReuseIdentifier: "SettingsSection2")
        let section3 = UINib(nibName: "SettingsSectionTableViewCell3", bundle: nil)
        tableView.register(section3, forCellReuseIdentifier: "SettingsSection3")
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
        self.navigationItem.title = "設定"
        self.navigationController?.navigationBar.titleTextAttributes
            = [NSAttributedString.Key.font: UIFont(name: "Helvetica", size: 16)!]
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        self.tabBarController?.tabBar.barTintColor = UIColor.white
        self.navigationController?.navigationBar.tintColor = UIColor.black
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.black]
        
        fetchUser()
        
    }
    
    // 画面から非表示になる直前に呼ばれます。
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        SVProgressHUD.dismiss()
        print("viewWillDisappear")
    }
    
    
    private func fetchUser() {
        
        let myid = Auth.auth().currentUser?.uid
        if ( self.listener == nil ) {
            let postsRef = Firestore.firestore().collection("users").document(myid!)
            listener = postsRef.addSnapshotListener() { (documentSnapshot, error) in
                guard let document = documentSnapshot else {
                    print("Error fetching document: \(error!)")
                    return
                }
                self.userdata  = UserData(document: document)
                self.tableView.reloadData()
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 11
        
    }
    
    //何行か
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 1
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsSection", for: indexPath) as! SettingsSectionTableViewCell
            //セル押下時のハイライト(色が濃くなる)を無効
            cell.selectionStyle = .none
            cell.sectionTitleLabel.text = "アカウント"
            return cell
            
        }else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Account", for: indexPath) as! AccountTableViewCell
            //セル押下時のハイライト(色が濃くなる)を無効
            cell.selectionStyle = .none
            cell.button1.addTarget(self, action:#selector(toMenu1(_:forEvent:)), for: .touchUpInside)
            cell.button2.addTarget(self, action:#selector(toMenu2(_:forEvent:)), for: .touchUpInside)
            cell.button3.addTarget(self, action:#selector(toMenu3(_:forEvent:)), for: .touchUpInside)
            cell.button4.addTarget(self, action:#selector(toMenu4(_:forEvent:)), for: .touchUpInside)
            cell.button5.addTarget(self, action:#selector(toMenu5(_:forEvent:)), for: .touchUpInside)
            return cell
        }else if indexPath.section == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsSection2", for: indexPath) as! SettingsSectionTableViewCell2
            //セル押下時のハイライト(色が濃くなる)を無効
            cell.selectionStyle = .none
            cell.sectionTitleLabel.text = "プライバシー"
            return cell
        }else if indexPath.section == 3 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Privacy", for: indexPath) as! PrivacyTableViewCell
            //セル押下時のハイライト(色が濃くなる)を無効
            cell.selectionStyle = .none
            cell.userdata = self.userdata
            cell.button1.addTarget(self, action:#selector(toMenu6(_:forEvent:)), for: .touchUpInside)
            return cell
        }else if indexPath.section == 4 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsSection2", for: indexPath) as! SettingsSectionTableViewCell2
            //セル押下時のハイライト(色が濃くなる)を無効
            cell.selectionStyle = .none
            cell.sectionTitleLabel.text = "セキュリティ"
            return cell
        }else if indexPath.section == 5 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Security", for: indexPath) as! SecurityTableViewCell
            //セル押下時のハイライト(色が濃くなる)を無効
            cell.selectionStyle = .none
            cell.button1.addTarget(self, action:#selector(toMenu7(_:forEvent:)), for: .touchUpInside)
            cell.button2.addTarget(self, action:#selector(toMenu8(_:forEvent:)), for: .touchUpInside)
            return cell
        }else if indexPath.section == 6 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsSection2", for: indexPath) as! SettingsSectionTableViewCell2
            //セル押下時のハイライト(色が濃くなる)を無効
            cell.selectionStyle = .none
            cell.sectionTitleLabel.text = "基本データ"
            return cell
        }else if indexPath.section == 7 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "BasicData", for: indexPath) as! BasicDataTableViewCell
            //セル押下時のハイライト(色が濃くなる)を無効
            cell.selectionStyle = .none
            cell.button1.addTarget(self, action:#selector(toMenu9(_:forEvent:)), for: .touchUpInside)
            cell.button2.addTarget(self, action:#selector(toMenu10(_:forEvent:)), for: .touchUpInside)
            return cell
        }else if indexPath.section == 8 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsSection2", for: indexPath) as! SettingsSectionTableViewCell2
            //セル押下時のハイライト(色が濃くなる)を無効
            cell.selectionStyle = .none
            cell.sectionTitleLabel.text = "ヘルプ"
            return cell
        }else if indexPath.section == 9 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Help", for: indexPath) as! HelpTableViewCell
            //セル押下時のハイライト(色が濃くなる)を無効
            cell.selectionStyle = .none
            cell.button1.addTarget(self, action:#selector(toMenu11(_:forEvent:)), for: .touchUpInside)
            cell.button2.addTarget(self, action:#selector(toMenu12(_:forEvent:)), for: .touchUpInside)
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "Logout", for: indexPath) as! LogoutTableViewCell
            //セル押下時のハイライト(色が濃くなる)を無効
            cell.selectionStyle = .none
            cell.button1.addTarget(self, action:#selector(toMenu13(_:forEvent:)), for: .touchUpInside)
            cell.button2.addTarget(self, action:#selector(Logout(_:forEvent:)), for: .touchUpInside)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 42
        }else if indexPath.section == 1 {
            return 313.5
        }else if indexPath.section == 2 {
            return 39
        }else if indexPath.section == 3 {
            return 161
        }else if indexPath.section == 4 {
            return 42
        }else if indexPath.section == 5 {
            return 102
        }else if indexPath.section == 6 {
            return 42
        }else if indexPath.section == 7 {
            return 145
        }else if indexPath.section == 8 {
            return 42
        }else if indexPath.section == 9 {
            return 102
        }else{
            return 150
        }
    }
    
    @objc func Logout(_ sender: UIButton, forEvent event: UIEvent) {
        let alert: UIAlertController = UIAlertController.init(title: "ログアウトします。よろしいでしょうか？", message: nil,
                                                              preferredStyle: UIAlertController.Style.actionSheet)
        let cancelAction: UIAlertAction = UIAlertAction.init(title: "キャンセル", style: UIAlertAction.Style.cancel,
                                                             handler: { (UIAlertAction) in
                                                                print("キャンセルが選択されました。")
                                                                alert.dismiss(animated: true, completion: nil)
                                                             })
        alert.addAction(cancelAction)
        let okAction: UIAlertAction = UIAlertAction.init(title: "ログアウト", style: UIAlertAction.Style.destructive,
                                                         handler: { (UIAlertAction) in
                                                            print("OKが選択されました。")
                                                            SVProgressHUD.setDefaultStyle(.custom)
                                                            SVProgressHUD.setDefaultMaskType(.custom)
                                                            SVProgressHUD.setForegroundColor(.gray)
                                                            SVProgressHUD.setBackgroundColor(.clear)
                                                            SVProgressHUD.setBackgroundLayerColor(.clear)
                                                            SVProgressHUD.show()
                                                            // ログアウトする
                                                            try! Auth.auth().signOut()
                                                            
                                                            self.navigationController?.popViewController(animated: false)
                                                            
                                                         })
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
    
    @objc func toMenu1(_ sender: UIButton, forEvent event: UIEvent) {
        
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(identifier: "ProfileEditViewController") as! ProfileEditViewController
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    @objc func toMenu2(_ sender: UIButton, forEvent event: UIEvent) {
        
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(identifier: "Personal") as! PersonalViewController
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    @objc func toMenu3(_ sender: UIButton, forEvent event: UIEvent) {
        
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(identifier: "Like") as! LikeViewController
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    @objc func toMenu4(_ sender: UIButton, forEvent event: UIEvent) {
        
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(identifier: "Following") as! FollowingViewController
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    @objc func toMenu5(_ sender: UIButton, forEvent event: UIEvent) {
        
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(identifier: "Block") as! BlockViewController
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    @objc func toMenu6(_ sender: UIButton, forEvent event: UIEvent) {
        
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(identifier: "Activity") as! ActivityViewController
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    @objc func toMenu7(_ sender: UIButton, forEvent event: UIEvent) {
        
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(identifier: "PasswordReset2") as! PasswordReset2ViewController
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    @objc func toMenu8(_ sender: UIButton, forEvent event: UIEvent) {
        
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(identifier: "Notice") as! NoticeViewController
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    @objc func toMenu9(_ sender: UIButton, forEvent event: UIEvent) {
        
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(identifier: "Terms2") as! Terms2ViewController
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    @objc func toMenu10(_ sender: UIButton, forEvent event: UIEvent) {
        
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(identifier: "PrivacyPolicy2") as! PrivacyPolicy2ViewController
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    @objc func toMenu11(_ sender: UIButton, forEvent event: UIEvent) {
        
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(identifier: "ContactUs") as! ContactUsViewController
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    @objc func toMenu12(_ sender: UIButton, forEvent event: UIEvent) {
        
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(identifier: "HowToUse") as! HowToUseViewController
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    @objc func toMenu13(_ sender: UIButton, forEvent event: UIEvent) {
        
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(identifier: "Delete") as! DeleteViewController
        navigationController?.pushViewController(viewController, animated: true)
    }
    
}
