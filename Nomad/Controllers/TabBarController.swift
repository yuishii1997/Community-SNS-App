//
//  TabBarController.swift
//  Nomad-App
//
//  Created by yuishii on 2020/07/13.
//  Copyright © 2020 Yu Ishii. All rights reserved.
//
// タブバーコントローラー

import UIKit
import Firebase

class TabBarController: UITabBarController, UITabBarControllerDelegate {
    
    var transparentView = UIView()
    var tableView = UITableView()
    
    let height: CGFloat = 155
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        // カスタムセルを登録する
        let nib = UINib(nibName: "CustomTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "Cell")
        
        //0番目のtabの非選択時の画像を設定
        //        tabBar.items![0].image = UIImage(named: "Home-1")!.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        
        //0番目のtabの選択時の画像を設定
        tabBar.items![0].selectedImage = UIImage(named: "Home_Selected")!.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        
        //1番目のtabの非選択時の画像を設定
        //        tabBar.items![1].image = UIImage(named: "Search-1")!.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        
        //1番目のtabの選択時の画像を設定
        tabBar.items![1].selectedImage = UIImage(named: "Search_Selected")!.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        
        //2番目のtabの非選択時の画像を設定
        //        tabBar.items![2].image = UIImage(named: "icons8-プラス記号-32")!.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        
        //3番目のtabの非選択時の画像を設定
        //        tabBar.items![3].image = UIImage(named: "icons8-four-squares-26")!.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        
        //3番目のtabの選択時の画像を設定
        tabBar.items![3].selectedImage = UIImage(named: "icons8-four-squares-26-2")!.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        
        //4番目のtabの非選択時の画像を設定
        //        tabBar.items![4].image = UIImage(named: "Profile-1")!.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        
        //4番目のtabの選択時の画像を設定
        tabBar.items![4].selectedImage = UIImage(named: "Profile_Selected")!.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        
        
        // 文字の選択時・未選択時の色・フォントを指定（フォントは最初に指定したものが優先される）
        UITabBarItem.appearance().setTitleTextAttributes( [ .font : UIFont.init(name: "HelveticaNeue", size: 9),
                                                            .foregroundColor : UIColor.black ],
                                                          for: .normal)
        UITabBarItem.appearance().setTitleTextAttributes( [ .font : UIFont.init(name: "HelveticaNeue", size: 9),
                                                            .foregroundColor : UIColor.black],
                                                          for: .selected)
        
        UITabBar.appearance().tintColor = UIColor.black
        
        // UITabBarControllerDelegateプロトコルのメソッドをこのクラスで処理する。
        self.delegate = self
        
    }
    
    @objc func onClickTransparentView() {
        let screenSize = UIScreen.main.bounds.size
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseInOut, animations: {
            self.transparentView.alpha = 0
            self.tableView.frame = CGRect(x: 0, y: screenSize.height, width: screenSize.width, height: self.height)
        }, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if Auth.auth().currentUser != nil {
            if Auth.auth().currentUser?.isEmailVerified == true {
                print("メール認証が完了しています。")
            } else {
                print("メール認証が完了していません")
                let rootViewController = self.storyboard?.instantiateViewController(withIdentifier: "EmailVerification")
                self.present(rootViewController!, animated: true, completion: nil)
            }
        }else {
            let loginViewController = self.storyboard?.instantiateViewController(withIdentifier: "LoginNavi")
            self.present(loginViewController!, animated: true, completion: nil)
        }
    }
    
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        print("tabBar didSelect item.tag: \(item.tag) selectedIndex: \(self.selectedIndex)")
        if item.tag == self.selectedIndex {
            switch item.tag {
            case 0:
                print("ホームタブを押しました。")
                
                if let topController = UIApplication.topViewController()  {
                    //今表示しているViewControllerがHomeViewControllerのとき
                    if topController.className == "HomeViewController" {
                        let navigationController = self.viewControllers?[0] as! UINavigationController
                        let homeViewController = navigationController.topViewController as! HomeViewController
                        if homeViewController.postArray.count == 0 {
                            print("投稿がありません")
                        }else{
                            homeViewController.tableView?.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
                        }
                        //今表示しているViewControllerがHomeViewControllerから遷移している時
                    }else{
                        //一番最初のViewControllerに戻る
                        navigationController?.popToRootViewController(animated: true)
                    }
                }
                
                
            case 1:
                print("急上昇タブを押しました。")
                //今表示しているViewControllerがTrendingViewControllerのとき
                if let topController = UIApplication.topViewController()  {
                    if topController.className == "Search1ViewController" {
                        let navigationController = self.viewControllers?[1] as! UINavigationController
                        let search1ViewController = navigationController.topViewController as! Search1ViewController
                        
                        search1ViewController.tableView?.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
                        
                        //今表示しているViewControllerがHomeViewControllerから遷移している時
                    }else{
                        //一番最初のViewControllerに戻る
                        navigationController?.popToRootViewController(animated: true)
                    }
                }
            case 3:
                print("カテゴリータブを押しました。")
                //今表示しているViewControllerがTrendingViewControllerのとき
                if let topController = UIApplication.topViewController()  {
                    if topController.className == "CategoryViewController" {
                        let navigationController = self.viewControllers?[3] as! UINavigationController
                        let categoryViewController = navigationController.topViewController as! CategoryViewController
                        categoryViewController.tableView?.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
                        //今表示しているViewControllerがHomeViewControllerから遷移している時
                    }else{
                        //一番最初のViewControllerに戻る
                        navigationController?.popToRootViewController(animated: true)
                    }
                }
            case 4:
                print("マイノマドタブを押しました。")
                //今表示しているViewControllerがTrendingViewControllerのとき
                if let topController = UIApplication.topViewController()  {
                    if topController.className == "MyNomadViewController" {
                        let navigationController = self.viewControllers?[4] as! UINavigationController
                        let myNomadViewController = navigationController.topViewController as! MyNomadViewController
                        myNomadViewController.tableView?.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
                        //今表示しているViewControllerがHomeViewControllerから遷移している時
                    }else{
                        //一番最初のViewControllerに戻る
                        navigationController?.popToRootViewController(animated: true)
                    }
                }
            default: break
            }
        }
    }
    
    // タブバーのアイコンがタップされた時に呼ばれるdelegateメソッドを処理する。
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if viewController is UINavigationController {
            let navigationController = viewController as! UINavigationController
            if navigationController.topViewController! is PostViewController {
                
                let window = UIApplication.shared.keyWindow
                transparentView.backgroundColor = UIColor.black.withAlphaComponent(0.9)
                transparentView.frame = self.view.frame
                window?.addSubview(transparentView)
                
                let screenSize = UIScreen.main.bounds.size
                tableView.frame = CGRect(x: 0, y: screenSize.height, width: screenSize.width, height: height)
                window?.addSubview(tableView)
                
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onClickTransparentView))
                transparentView.addGestureRecognizer(tapGesture)
                
                transparentView.alpha = 0
                
                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseInOut, animations: {
                    self.transparentView.alpha = 0.5
                    self.tableView.frame = CGRect(x: 0, y: screenSize.height - self.height, width: screenSize.width, height: self.height)
                }, completion: nil)
                
                return false
            } else {
                // その他のViewControllerは通常のタブ切り替えを実施
                return true
            }
        }
        return true
    }
}


extension Notification.Name {
    static let profileTop = Notification.Name("profileTop")
}


extension TabBarController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomTableViewCell
        cell.postButton1.addTarget(self, action:#selector(handleButton1(_:forEvent:)), for: .touchUpInside)
        cell.postButton2.addTarget(self, action:#selector(handleButton2(_:forEvent:)), for: .touchUpInside)
        cell.closeButton.addTarget(self, action:#selector(closeButton(_:forEvent:)), for: .touchUpInside)
        return cell
    }
    
    @objc func handleButton1(_ sender: UIButton, forEvent event: UIEvent) {
        print("スレッド作成画面に遷移します")
        let screenSize = UIScreen.main.bounds.size
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseInOut, animations: {
            self.transparentView.alpha = 0
            self.tableView.frame = CGRect(x: 0, y: screenSize.height, width: screenSize.width, height: self.height)
        }, completion: {_ in
            
            if Auth.auth().currentUser != nil {
                let myid = Auth.auth().currentUser!.uid
                
                
                let ref = Firestore.firestore().collection("users").document(myid)
                
                ref.updateData(["commentOff": "off"])
                ref.updateData(["bePrivate": "off"])
                
                ref.updateData(["destID": FieldValue.delete(),]){ err in
                    if let err = err{
                        print("Error updating document: \(err)")
                        ref.updateData(["destID": "n"])
                    }else{
                        print("Document successfully updated 4")
                        
                    }
                }
                
                ref.updateData(["destName": FieldValue.delete(),]){ err in
                    if let err = err{
                        print("Error updating document: \(err)")
                        ref.updateData(["destName": "n"])
                    }else{
                        print("Document successfully updated 5")
                        
                    }
                }
                
                ref.updateData(["postCaption": FieldValue.delete(),]){ err in
                    if let err = err{
                        print("Error updating document: \(err)")
                        ref.updateData(["postCaption": "n"])
                    }else{
                        print("Document successfully updated 6")
                        
                    }
                }
                
                ref.updateData(["category": FieldValue.delete(),]){ err in
                    if let err = err{
                        print("Error updating document: \(err)")
                        ref.updateData(["category": "n"])
                    }else{
                        print("Document successfully updated 7")
                        
                    }
                }
                
                let PostViewController = self.storyboard!.instantiateViewController(withIdentifier: "Post")
                self.present(PostViewController, animated: true)
            }
        })
    }
    
    @objc func handleButton2(_ sender: UIButton, forEvent event: UIEvent) {
        print("コミュニティ作成画面に遷移します")
        let screenSize = UIScreen.main.bounds.size
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseInOut, animations: {
            self.transparentView.alpha = 0
            self.tableView.frame = CGRect(x: 0, y: screenSize.height, width: screenSize.width, height: self.height)
        }, completion: {_ in
            
            if Auth.auth().currentUser != nil {
                let myid = Auth.auth().currentUser!.uid
                
                let ref = Firestore.firestore().collection("users").document(myid)
                
                ref.updateData(["commentOff": "off"])
                ref.updateData(["bePrivate": "off"])
                
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
                
                
                let Post2ViewController = self.storyboard!.instantiateViewController(withIdentifier: "Post2")
                self.present(Post2ViewController, animated: true)
            }
        })
    }
    
    @objc func closeButton(_ sender: UIButton, forEvent event: UIEvent) {
        print("テーブルビューを閉じます")
        let screenSize = UIScreen.main.bounds.size
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseInOut, animations: {
            self.transparentView.alpha = 0
            self.tableView.frame = CGRect(x: 0, y: screenSize.height, width: screenSize.width, height: self.height)
        }, completion: nil)
    }
    
}


extension UIViewController {
    var className: String {
        return String(describing: type(of: self))
    }
}

extension UIApplication {
    class func topViewController(controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        return controller
    }
}
