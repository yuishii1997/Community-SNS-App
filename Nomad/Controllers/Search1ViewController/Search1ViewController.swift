//
//  Search1ViewController.swift
//  Nomad-App
//
//  Created by yuishii on 2021/02/02.
//  Copyright © 2021 Yu Ishii. All rights reserved.
//
// 検索画面(最初)

import UIKit
import Firebase
import NotificationBannerSwift
import SVProgressHUD

class Search1ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate,UISearchBarDelegate {
    
    
    @IBOutlet weak var tableView: UITableView!
    
    //検索バーの宣言
    var searchBar: UISearchBar!
    // UISearchControllerの変数を作成
    var searchController: UISearchController!
    
    private var refreshControl = UIRefreshControl()
    
    private var postdata: PostData?
    
    var listener: ListenerRegistration!
    
    //フラグ
    var categoryIsTapped = false
    var userIsTapped = false
    
    // ユーザーデータを格納する配列
    var userArray: [UserData] = []
    var userdata: UserData?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SVProgressHUD.setDefaultStyle(.custom)
        SVProgressHUD.setDefaultMaskType(.none)
        SVProgressHUD.setForegroundColor(.gray)
        SVProgressHUD.setBackgroundColor(.clear)
        SVProgressHUD.setBackgroundLayerColor(.clear)
        SVProgressHUD.show()
        
        //空セルのseparator(しきり線)を消す
        tableView.tableFooterView = UIView(frame: .zero)
        
        //テーブルビューの仕切り線を左端までつける
        tableView.separatorInset = .zero
        tableView.separatorStyle = .none
        
        self.tableView.backgroundColor = .white
        
        tableView.delegate = self
        tableView.dataSource = self
        
        let nib1 = UINib(nibName: "Title1TableViewCell", bundle: nil)
        tableView.register(nib1, forCellReuseIdentifier: "title1")
        let nib2 = UINib(nibName: "CategoryMenuTableViewCell", bundle: nil)
        tableView.register(nib2, forCellReuseIdentifier: "CategoryMenu")
        let nib3 = UINib(nibName: "MyCommunityListTableViewCell", bundle: nil)
        tableView.register(nib3, forCellReuseIdentifier: "MyCommunityList")
        let nib4 = UINib(nibName: "Following5TableViewCell", bundle: nil)
        tableView.register(nib4, forCellReuseIdentifier: "Following5")
        let nib5 = UINib(nibName: "Following6TableViewCell", bundle: nil)
        tableView.register(nib5, forCellReuseIdentifier: "Following6")
        let nib6 = UINib(nibName: "MarginTableViewCell", bundle: nil)
        tableView.register(nib6, forCellReuseIdentifier: "Margin")
        
        //空セルのseparator(しきり線)を消す
        tableView.tableFooterView = UIView(frame: .zero)
        extendedLayoutIncludesOpaqueBars = true
        
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(self.refresh(sender:)), for: .valueChanged)
        
        //結果表示用のビューコントローラーをサーチコントローラーに設定する。
        let resultController = Search2ViewController()
        resultController.navigationDelegate = self
        searchController = UISearchController(searchResultsController: resultController)
        resultController.searchController = searchController
        searchController.searchResultsUpdater = resultController as? UISearchResultsUpdating
        searchController.searchBar.placeholder = "検索"
        searchController.showsSearchResultsController = true
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        
        if #available(iOS 9.0, *){
            resultController.forceTouch = self.traitCollection.forceTouchCapability
            if self.traitCollection.forceTouchCapability == .available{
                self.registerForPreviewing(with: self, sourceView: self.view)
            }
        }
        
    }
    
    // iOS13でuisearchbarをnavigationItem.titleViewに置き換えるとheightが56になってしまう課題の対処
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("viewWillDisappear")
        
        if self.categoryIsTapped {
            self.navigationController?.navigationBar.barTintColor = .white
            categoryIsTapped = false
        }else if self.userIsTapped {
            self.navigationController?.navigationBar.barTintColor = UIColor.rgb(red: 66, green: 80, blue: 109)
            userIsTapped = false
        }
        
        if ( self.listener != nil ){
            listener.remove()
            listener = nil
        }
        navigationController?.view.setNeedsLayout() // force update layout
        navigationController?.view.layoutIfNeeded() // to fix height of the navigation bar
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("DEBUG_PRINT: viewWillAppear")
        
        if Auth.auth().currentUser != nil {
            if Auth.auth().currentUser?.isEmailVerified == true {
                print("メール認証が完了しています。")
            } else {
                print("メール認証が完了していません")
                let rootViewController = self.storyboard?.instantiateViewController(withIdentifier: "EmailVerification")
                self.present(rootViewController!, animated: false, completion: nil)
            }
        }else {
            let loginViewController = self.storyboard?.instantiateViewController(withIdentifier: "LoginNavi")
            self.present(loginViewController!, animated: false, completion: nil)
        }
        
        let backBarButtonItem = UIBarButtonItem()
        backBarButtonItem.title = "Back"
        self.navigationItem.backBarButtonItem = backBarButtonItem
        self.navigationItem.title = "みつける"
        self.navigationController?.navigationBar.titleTextAttributes
            = [NSAttributedString.Key.font: UIFont(name: "Helvetica", size: 16)!]
        // ナビゲーションバーの下部ボーダーを消す
        self.navigationController?.navigationBar.shadowImage = nil
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        self.tabBarController?.tabBar.barTintColor = UIColor.white
        self.navigationController?.navigationBar.tintColor = UIColor.black
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.black]
        
        if ( self.listener == nil ) {
            fetchUser()
        }
    }
    
    
    @objc func refresh(sender: UIRefreshControl?) {
        
        fetchUser()
        sender?.endRefreshing()
        
    }
    
    func didSelectedCell(view: BaseViewController) {
        self.navigationController?.pushViewController(view, animated: true)
    }
    
    private func fetchUser() {
        
        let userRef = Firestore.firestore().collection("users").whereField("type", isEqualTo: "community").whereField("deleted", isEqualTo: "no")
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
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        // セクションの背景色を変更する
        view.tintColor = .white
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
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
        
        if section == 0{
            return 0
        }else if section == 1 {
            return 0
        }else{
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 46
        }else if indexPath.section == 1 {
            return 280
        }else if indexPath.section == 2 {
            return 42
        }else if indexPath.section == 3 {
            if self.userArray.count == 0 {
                return 49.5
            }else{
                return 49.5
            }
        }else{
            return 72
        }
    }
    
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 0 {
            print("タップされました。")
        } else {
            print("タップされました。")
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "title1", for: indexPath) as! Title1TableViewCell
            cell.button.addTarget(self, action:#selector(toCategoryMenuButton(_:forEvent:)), for: .touchUpInside)
            //セル押下時のハイライト(色が濃くなる)を無効
            cell.selectionStyle = .none
            return cell
        }else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryMenu", for: indexPath) as! CategoryMenuTableViewCell
            cell.button1.addTarget(self, action:#selector(toCategory1(_:forEvent:)), for: .touchUpInside)
            cell.button2.addTarget(self, action:#selector(toCategory2(_:forEvent:)), for: .touchUpInside)
            cell.button3.addTarget(self, action:#selector(toCategory3(_:forEvent:)), for: .touchUpInside)
            cell.button4.addTarget(self, action:#selector(toCategory4(_:forEvent:)), for: .touchUpInside)
            cell.button5.addTarget(self, action:#selector(toCategory5(_:forEvent:)), for: .touchUpInside)
            cell.selectionStyle = .none
            return cell
            
        }else if indexPath.section == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MyCommunityList", for: indexPath) as! MyCommunityListTableViewCell
            //セル押下時のハイライト(色が濃くなる)を無効
            cell.selectionStyle = .none
            return cell
        }else if indexPath.section == 3 {
            if self.userArray.count == 0 {
                print("フォローしているコミュニティーがありません")
                let cell = tableView.dequeueReusableCell(withIdentifier: "Following6", for: indexPath) as! Following6TableViewCell
                //セル押下時のハイライト(色が濃くなる)を無効
                cell.selectionStyle = .none
                return cell
            }else{
                print("フォローしているコミュニティーがあります")
                let cell = tableView.dequeueReusableCell(withIdentifier: "Following5", for: indexPath) as! Following5TableViewCell
                userdata = self.userArray[indexPath.row]
                cell.userdata = userdata
                cell.setUserData(self.userArray[indexPath.row])
                cell.chooseButton.addTarget(self, action:#selector(userProfileButton2(_:forEvent:)), for: .touchUpInside)
                //セル押下時のハイライト(色が濃くなる)を無効
                cell.selectionStyle = .none
                return cell
            }
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "Margin", for: indexPath) as! MarginTableViewCell
            //セル押下時のハイライト(色が濃くなる)を無効
            cell.selectionStyle = .none
            return cell
        }
    }
    
    // セル内のボタンがタップされた時に呼ばれるメソッド
    @objc func toCategoryMenuButton(_ sender: UIButton, forEvent event: UIEvent) {
        
        categoryIsTapped = true
        
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let categoryMenuViewController = storyboard.instantiateViewController(identifier: "CategoryMenu") as! CategoryMenuViewController
        navigationController?.pushViewController(categoryMenuViewController, animated: true)
    }
    
    // セル内のボタンがタップされた時に呼ばれるメソッド
    @objc func userProfileButton(_ sender: UIButton, forEvent event: UIEvent) {
        
        userIsTapped = true
        
        let myid = Auth.auth().currentUser?.uid
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let baseViewController = storyboard.instantiateViewController(identifier: "Profile") as! BaseViewController
        baseViewController.userID = myid!
        baseViewController.type = "private"
        
        navigationController?.pushViewController(baseViewController, animated: true)
    }
    
    // セル内のボタンがタップされた時に呼ばれるメソッド
    @objc func userProfileButton2(_ sender: UIButton, forEvent event: UIEvent) {
        
        userIsTapped = true
        
        // タップされたセルのインデックスを求める
        let touch = event.allTouches?.first
        let point = touch!.location(in: self.tableView)
        guard let indexPath = tableView.indexPathForRow(at: point) else { return }
        
        // 配列からタップされたインデックスのデータを取り出す
        let userData = userArray[indexPath.row]
        let uid = userData.uid
        
        print("MyNomad uid:\(uid)")
        
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        
        let baseViewController = storyboard.instantiateViewController(identifier: "Profile") as! BaseViewController
        baseViewController.userID = uid
        baseViewController.type = "community"
        
        navigationController?.pushViewController(baseViewController, animated: true)
        
    }
    
    @objc func toCategory1(_ sender: UIButton, forEvent event: UIEvent) {
        
        categoryIsTapped = true
        
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let categoryPostsViewController = storyboard.instantiateViewController(identifier: "CategoryPosts") as! CategoryPostsViewController
        categoryPostsViewController.category = "news"
        categoryPostsViewController.titleName = "ニュース"
        navigationController?.pushViewController(categoryPostsViewController, animated: true)
    }
    
    @objc func toCategory2(_ sender: UIButton, forEvent event: UIEvent) {
        
        categoryIsTapped = true
        
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let categoryPostsViewController = storyboard.instantiateViewController(identifier: "CategoryPosts") as! CategoryPostsViewController
        categoryPostsViewController.category = "trend"
        categoryPostsViewController.titleName = "話題・トレンド"
        navigationController?.pushViewController(categoryPostsViewController, animated: true)
    }
    
    @objc func toCategory3(_ sender: UIButton, forEvent event: UIEvent) {
        
        categoryIsTapped = true
        
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let categoryPostsViewController = storyboard.instantiateViewController(identifier: "CategoryPosts") as! CategoryPostsViewController
        categoryPostsViewController.category = "politics"
        categoryPostsViewController.titleName = "政治・社会"
        navigationController?.pushViewController(categoryPostsViewController, animated: true)
    }
    
    @objc func toCategory4(_ sender: UIButton, forEvent event: UIEvent) {
        
        categoryIsTapped = true
        
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let categoryPostsViewController = storyboard.instantiateViewController(identifier: "CategoryPosts") as! CategoryPostsViewController
        categoryPostsViewController.category = "sports"
        categoryPostsViewController.titleName = "スポーツ"
        navigationController?.pushViewController(categoryPostsViewController, animated: true)
    }
    
    @objc func toCategory5(_ sender: UIButton, forEvent event: UIEvent) {
        
        categoryIsTapped = true
        
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let categoryPostsViewController = storyboard.instantiateViewController(identifier: "CategoryPosts") as! CategoryPostsViewController
        categoryPostsViewController.category = "music"
        categoryPostsViewController.titleName = "音楽"
        navigationController?.pushViewController(categoryPostsViewController, animated: true)
    }
    
}


extension Search1ViewController: NavigateFromSearchResultProtocol{
    
    func navigationControllerPush(fromSearchResult viewController: BaseViewController) {
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func previewingContext(fromSearchResult previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        if #available(iOS 9.0, *) {
            self.previewingContext(fromSearchResult: previewingContext, commit: viewControllerToCommit)
        } else {
            // Fallback on earlier versions
        }
    }
}

@available(iOS 9.0, *)
extension Search1ViewController: UIViewControllerPreviewingDelegate{
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        print("peek")
        return nil
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        self.navigationController?.pushViewController(viewControllerToCommit, animated: true)
    }
    
}
