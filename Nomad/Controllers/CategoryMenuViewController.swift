//
//  CategoryMenuViewController.swift
//  Nomad-App
//
//  Created by yuishii on 2021/01/29.
//  Copyright © 2021 Yu Ishii. All rights reserved.
//
// カテゴリー一覧画面

import UIKit
import Firebase

class CategoryMenuViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    private var postdata: PostData?
    
    // ユーザーデータを格納する配列
    var userArray: [UserData] = []
    var userdata: UserData?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //空セルのseparator(しきり線)を消す
        tableView.tableFooterView = UIView(frame: .zero)
        
        //テーブルビューの仕切り線を左端までつける
        tableView.separatorInset = .zero
        tableView.separatorStyle = .none
        
        self.tableView.backgroundColor = .white
        
        tableView.delegate = self
        tableView.dataSource = self
        
        //空セルのseparator(しきり線)を消す
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
        self.navigationItem.title = "カテゴリー"
        self.navigationController?.navigationBar.titleTextAttributes
            = [NSAttributedString.Key.font: UIFont(name: "Helvetica", size: 16)!]
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        self.tabBarController?.tabBar.barTintColor = UIColor.white
        self.navigationController?.navigationBar.tintColor = UIColor.black
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.black]
        
        let menuNib = UINib(nibName: "CategoryMenuTableViewCell2", bundle: nil)
        tableView.register(menuNib, forCellReuseIdentifier: "CategoryMenu2")
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        // セクションの背景色を変更する
        view.tintColor = .white
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 1
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 0
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 2048
        
    }
    
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        print("急上昇タイトルがタップされました。")
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryMenu2", for: indexPath) as! CategoryMenuTableViewCell2
        cell.button1.addTarget(self, action:#selector(toCategory1(_:forEvent:)), for: .touchUpInside)
        cell.button2.addTarget(self, action:#selector(toCategory2(_:forEvent:)), for: .touchUpInside)
        cell.button3.addTarget(self, action:#selector(toCategory3(_:forEvent:)), for: .touchUpInside)
        cell.button4.addTarget(self, action:#selector(toCategory4(_:forEvent:)), for: .touchUpInside)
        cell.button5.addTarget(self, action:#selector(toCategory5(_:forEvent:)), for: .touchUpInside)
        cell.button6.addTarget(self, action:#selector(toCategory6(_:forEvent:)), for: .touchUpInside)
        cell.button7.addTarget(self, action:#selector(toCategory7(_:forEvent:)), for: .touchUpInside)
        cell.button8.addTarget(self, action:#selector(toCategory8(_:forEvent:)), for: .touchUpInside)
        cell.button9.addTarget(self, action:#selector(toCategory9(_:forEvent:)), for: .touchUpInside)
        cell.button10.addTarget(self, action:#selector(toCategory10(_:forEvent:)), for: .touchUpInside)
        cell.button11.addTarget(self, action:#selector(toCategory11(_:forEvent:)), for: .touchUpInside)
        cell.button12.addTarget(self, action:#selector(toCategory12(_:forEvent:)), for: .touchUpInside)
        cell.button13.addTarget(self, action:#selector(toCategory13(_:forEvent:)), for: .touchUpInside)
        cell.button14.addTarget(self, action:#selector(toCategory14(_:forEvent:)), for: .touchUpInside)
        cell.button15.addTarget(self, action:#selector(toCategory15(_:forEvent:)), for: .touchUpInside)
        cell.button16.addTarget(self, action:#selector(toCategory16(_:forEvent:)), for: .touchUpInside)
        cell.button17.addTarget(self, action:#selector(toCategory17(_:forEvent:)), for: .touchUpInside)
        cell.button18.addTarget(self, action:#selector(toCategory18(_:forEvent:)), for: .touchUpInside)
        cell.button19.addTarget(self, action:#selector(toCategory19(_:forEvent:)), for: .touchUpInside)
        cell.button20.addTarget(self, action:#selector(toCategory20(_:forEvent:)), for: .touchUpInside)
        cell.button21.addTarget(self, action:#selector(toCategory21(_:forEvent:)), for: .touchUpInside)
        cell.button22.addTarget(self, action:#selector(toCategory22(_:forEvent:)), for: .touchUpInside)
        cell.button23.addTarget(self, action:#selector(toCategory23(_:forEvent:)), for: .touchUpInside)
        cell.button24.addTarget(self, action:#selector(toCategory24(_:forEvent:)), for: .touchUpInside)
        cell.button25.addTarget(self, action:#selector(toCategory25(_:forEvent:)), for: .touchUpInside)
        cell.button26.addTarget(self, action:#selector(toCategory26(_:forEvent:)), for: .touchUpInside)
        cell.button27.addTarget(self, action:#selector(toCategory27(_:forEvent:)), for: .touchUpInside)
        cell.button28.addTarget(self, action:#selector(toCategory28(_:forEvent:)), for: .touchUpInside)
        cell.button29.addTarget(self, action:#selector(toCategory29(_:forEvent:)), for: .touchUpInside)
        cell.button30.addTarget(self, action:#selector(toCategory30(_:forEvent:)), for: .touchUpInside)
        cell.button31.addTarget(self, action:#selector(toCategory31(_:forEvent:)), for: .touchUpInside)
        cell.button32.addTarget(self, action:#selector(toCategory32(_:forEvent:)), for: .touchUpInside)
        cell.button33.addTarget(self, action:#selector(toCategory33(_:forEvent:)), for: .touchUpInside)
        cell.button34.addTarget(self, action:#selector(toCategory34(_:forEvent:)), for: .touchUpInside)
        cell.button35.addTarget(self, action:#selector(toCategory35(_:forEvent:)), for: .touchUpInside)
        cell.button36.addTarget(self, action:#selector(toCategory36(_:forEvent:)), for: .touchUpInside)
        cell.button37.addTarget(self, action:#selector(toCategory37(_:forEvent:)), for: .touchUpInside)
        cell.button38.addTarget(self, action:#selector(toCategory38(_:forEvent:)), for: .touchUpInside)
        cell.selectionStyle = .none
        return cell
        
    }
    
    @objc func toCategory1(_ sender: UIButton, forEvent event: UIEvent) {
        
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let categoryPostsViewController = storyboard.instantiateViewController(identifier: "CategoryPosts") as! CategoryPostsViewController
        categoryPostsViewController.category = "news"
        categoryPostsViewController.titleName = "ニュース"
        navigationController?.pushViewController(categoryPostsViewController, animated: true)
    }
    
    @objc func toCategory2(_ sender: UIButton, forEvent event: UIEvent) {
        
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let categoryPostsViewController = storyboard.instantiateViewController(identifier: "CategoryPosts") as! CategoryPostsViewController
        categoryPostsViewController.category = "trend"
        categoryPostsViewController.titleName = "話題・トレンド"
        navigationController?.pushViewController(categoryPostsViewController, animated: true)
    }
    
    @objc func toCategory3(_ sender: UIButton, forEvent event: UIEvent) {
        
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let categoryPostsViewController = storyboard.instantiateViewController(identifier: "CategoryPosts") as! CategoryPostsViewController
        categoryPostsViewController.category = "politics"
        categoryPostsViewController.titleName = "政治・社会"
        navigationController?.pushViewController(categoryPostsViewController, animated: true)
    }
    
    @objc func toCategory4(_ sender: UIButton, forEvent event: UIEvent) {
        
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let categoryPostsViewController = storyboard.instantiateViewController(identifier: "CategoryPosts") as! CategoryPostsViewController
        categoryPostsViewController.category = "sports"
        categoryPostsViewController.titleName = "スポーツ"
        navigationController?.pushViewController(categoryPostsViewController, animated: true)
    }
    
    @objc func toCategory5(_ sender: UIButton, forEvent event: UIEvent) {
        
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let categoryPostsViewController = storyboard.instantiateViewController(identifier: "CategoryPosts") as! CategoryPostsViewController
        categoryPostsViewController.category = "music"
        categoryPostsViewController.titleName = "音楽"
        navigationController?.pushViewController(categoryPostsViewController, animated: true)
    }
    
    @objc func toCategory6(_ sender: UIButton, forEvent event: UIEvent) {
        
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let categoryPostsViewController = storyboard.instantiateViewController(identifier: "CategoryPosts") as! CategoryPostsViewController
        categoryPostsViewController.category = "funny"
        categoryPostsViewController.titleName = "おもしろ"
        navigationController?.pushViewController(categoryPostsViewController, animated: true)
    }
    
    @objc func toCategory7(_ sender: UIButton, forEvent event: UIEvent) {
        
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let categoryPostsViewController = storyboard.instantiateViewController(identifier: "CategoryPosts") as! CategoryPostsViewController
        categoryPostsViewController.category = "entertainment"
        categoryPostsViewController.titleName = "エンタメ"
        navigationController?.pushViewController(categoryPostsViewController, animated: true)
    }
    
    @objc func toCategory8(_ sender: UIButton, forEvent event: UIEvent) {
        
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let categoryPostsViewController = storyboard.instantiateViewController(identifier: "CategoryPosts") as! CategoryPostsViewController
        categoryPostsViewController.category = "tv"
        categoryPostsViewController.titleName = "TV・映画"
        navigationController?.pushViewController(categoryPostsViewController, animated: true)
    }
    
    @objc func toCategory9(_ sender: UIButton, forEvent event: UIEvent) {
        
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let categoryPostsViewController = storyboard.instantiateViewController(identifier: "CategoryPosts") as! CategoryPostsViewController
        categoryPostsViewController.category = "youtube"
        categoryPostsViewController.titleName = "YouTube"
        navigationController?.pushViewController(categoryPostsViewController, animated: true)
    }
    
    @objc func toCategory10(_ sender: UIButton, forEvent event: UIEvent) {
        
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let categoryPostsViewController = storyboard.instantiateViewController(identifier: "CategoryPosts") as! CategoryPostsViewController
        categoryPostsViewController.category = "economics"
        categoryPostsViewController.titleName = "経済・金融"
        navigationController?.pushViewController(categoryPostsViewController, animated: true)
    }
    
    @objc func toCategory11(_ sender: UIButton, forEvent event: UIEvent) {
        
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let categoryPostsViewController = storyboard.instantiateViewController(identifier: "CategoryPosts") as! CategoryPostsViewController
        categoryPostsViewController.category = "business"
        categoryPostsViewController.titleName = "ビジネス"
        navigationController?.pushViewController(categoryPostsViewController, animated: true)
    }
    
    @objc func toCategory12(_ sender: UIButton, forEvent event: UIEvent) {
        
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let categoryPostsViewController = storyboard.instantiateViewController(identifier: "CategoryPosts") as! CategoryPostsViewController
        categoryPostsViewController.category = "it"
        categoryPostsViewController.titleName = "IT・テクノロジー"
        navigationController?.pushViewController(categoryPostsViewController, animated: true)
    }
    
    @objc func toCategory13(_ sender: UIButton, forEvent event: UIEvent) {
        
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let categoryPostsViewController = storyboard.instantiateViewController(identifier: "CategoryPosts") as! CategoryPostsViewController
        categoryPostsViewController.category = "science"
        categoryPostsViewController.titleName = "科学"
        navigationController?.pushViewController(categoryPostsViewController, animated: true)
    }
    
    @objc func toCategory14(_ sender: UIButton, forEvent event: UIEvent) {
        
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let categoryPostsViewController = storyboard.instantiateViewController(identifier: "CategoryPosts") as! CategoryPostsViewController
        categoryPostsViewController.category = "health"
        categoryPostsViewController.titleName = "健康・医療"
        navigationController?.pushViewController(categoryPostsViewController, animated: true)
    }
    
    @objc func toCategory15(_ sender: UIButton, forEvent event: UIEvent) {
        
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let categoryPostsViewController = storyboard.instantiateViewController(identifier: "CategoryPosts") as! CategoryPostsViewController
        categoryPostsViewController.category = "beauty"
        categoryPostsViewController.titleName = "美容"
        navigationController?.pushViewController(categoryPostsViewController, animated: true)
    }
    
    @objc func toCategory16(_ sender: UIButton, forEvent event: UIEvent) {
        
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let categoryPostsViewController = storyboard.instantiateViewController(identifier: "CategoryPosts") as! CategoryPostsViewController
        categoryPostsViewController.category = "fashion"
        categoryPostsViewController.titleName = "ファッション"
        navigationController?.pushViewController(categoryPostsViewController, animated: true)
    }
    
    @objc func toCategory17(_ sender: UIButton, forEvent event: UIEvent) {
        
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let categoryPostsViewController = storyboard.instantiateViewController(identifier: "CategoryPosts") as! CategoryPostsViewController
        categoryPostsViewController.category = "job"
        categoryPostsViewController.titleName = "仕事"
        navigationController?.pushViewController(categoryPostsViewController, animated: true)
    }
    
    @objc func toCategory18(_ sender: UIButton, forEvent event: UIEvent) {
        
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let categoryPostsViewController = storyboard.instantiateViewController(identifier: "CategoryPosts") as! CategoryPostsViewController
        categoryPostsViewController.category = "school"
        categoryPostsViewController.titleName = "学校"
        navigationController?.pushViewController(categoryPostsViewController, animated: true)
    }
    
    @objc func toCategory19(_ sender: UIButton, forEvent event: UIEvent) {
        
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let categoryPostsViewController = storyboard.instantiateViewController(identifier: "CategoryPosts") as! CategoryPostsViewController
        categoryPostsViewController.category = "hobby"
        categoryPostsViewController.titleName = "趣味"
        navigationController?.pushViewController(categoryPostsViewController, animated: true)
    }
    
    @objc func toCategory20(_ sender: UIButton, forEvent event: UIEvent) {
        
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let categoryPostsViewController = storyboard.instantiateViewController(identifier: "CategoryPosts") as! CategoryPostsViewController
        categoryPostsViewController.category = "art"
        categoryPostsViewController.titleName = "文化・芸術"
        navigationController?.pushViewController(categoryPostsViewController, animated: true)
    }
    
    @objc func toCategory21(_ sender: UIButton, forEvent event: UIEvent) {
        
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let categoryPostsViewController = storyboard.instantiateViewController(identifier: "CategoryPosts") as! CategoryPostsViewController
        categoryPostsViewController.category = "manga"
        categoryPostsViewController.titleName = "漫画・アニメ"
        navigationController?.pushViewController(categoryPostsViewController, animated: true)
    }
    
    @objc func toCategory22(_ sender: UIButton, forEvent event: UIEvent) {
        
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let categoryPostsViewController = storyboard.instantiateViewController(identifier: "CategoryPosts") as! CategoryPostsViewController
        categoryPostsViewController.category = "game"
        categoryPostsViewController.titleName = "ゲーム"
        navigationController?.pushViewController(categoryPostsViewController, animated: true)
    }
    
    @objc func toCategory23(_ sender: UIButton, forEvent event: UIEvent) {
        
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let categoryPostsViewController = storyboard.instantiateViewController(identifier: "CategoryPosts") as! CategoryPostsViewController
        categoryPostsViewController.category = "life"
        categoryPostsViewController.titleName = "暮らし・生活"
        navigationController?.pushViewController(categoryPostsViewController, animated: true)
    }
    
    @objc func toCategory24(_ sender: UIButton, forEvent event: UIEvent) {
        
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let categoryPostsViewController = storyboard.instantiateViewController(identifier: "CategoryPosts") as! CategoryPostsViewController
        categoryPostsViewController.category = "family"
        categoryPostsViewController.titleName = "家族"
        navigationController?.pushViewController(categoryPostsViewController, animated: true)
    }
    
    @objc func toCategory25(_ sender: UIButton, forEvent event: UIEvent) {
        
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let categoryPostsViewController = storyboard.instantiateViewController(identifier: "CategoryPosts") as! CategoryPostsViewController
        categoryPostsViewController.category = "love"
        categoryPostsViewController.titleName = "結婚・恋愛"
        navigationController?.pushViewController(categoryPostsViewController, animated: true)
    }
    
    @objc func toCategory26(_ sender: UIButton, forEvent event: UIEvent) {
        
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let categoryPostsViewController = storyboard.instantiateViewController(identifier: "CategoryPosts") as! CategoryPostsViewController
        categoryPostsViewController.category = "parenting"
        categoryPostsViewController.titleName = "子育て・教育"
        navigationController?.pushViewController(categoryPostsViewController, animated: true)
    }
    
    @objc func toCategory27(_ sender: UIButton, forEvent event: UIEvent) {
        
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let categoryPostsViewController = storyboard.instantiateViewController(identifier: "CategoryPosts") as! CategoryPostsViewController
        categoryPostsViewController.category = "recipe"
        categoryPostsViewController.titleName = "グルメ・レシピ"
        navigationController?.pushViewController(categoryPostsViewController, animated: true)
    }
    
    @objc func toCategory28(_ sender: UIButton, forEvent event: UIEvent) {
        
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let categoryPostsViewController = storyboard.instantiateViewController(identifier: "CategoryPosts") as! CategoryPostsViewController
        categoryPostsViewController.category = "study"
        categoryPostsViewController.titleName = "勉強・学問"
        navigationController?.pushViewController(categoryPostsViewController, animated: true)
    }
    
    @objc func toCategory29(_ sender: UIButton, forEvent event: UIEvent) {
        
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let categoryPostsViewController = storyboard.instantiateViewController(identifier: "CategoryPosts") as! CategoryPostsViewController
        categoryPostsViewController.category = "question"
        categoryPostsViewController.titleName = "質問・相談"
        navigationController?.pushViewController(categoryPostsViewController, animated: true)
    }
    
    @objc func toCategory30(_ sender: UIButton, forEvent event: UIEvent) {
        
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let categoryPostsViewController = storyboard.instantiateViewController(identifier: "CategoryPosts") as! CategoryPostsViewController
        categoryPostsViewController.category = "mystery"
        categoryPostsViewController.titleName = "不思議・謎"
        navigationController?.pushViewController(categoryPostsViewController, animated: true)
    }
    
    @objc func toCategory31(_ sender: UIButton, forEvent event: UIEvent) {
        
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let categoryPostsViewController = storyboard.instantiateViewController(identifier: "CategoryPosts") as! CategoryPostsViewController
        categoryPostsViewController.category = "prefectures"
        categoryPostsViewController.titleName = "都道府県"
        navigationController?.pushViewController(categoryPostsViewController, animated: true)
    }
    
    @objc func toCategory32(_ sender: UIButton, forEvent event: UIEvent) {
        
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let categoryPostsViewController = storyboard.instantiateViewController(identifier: "CategoryPosts") as! CategoryPostsViewController
        categoryPostsViewController.category = "world"
        categoryPostsViewController.titleName = "海外"
        navigationController?.pushViewController(categoryPostsViewController, animated: true)
    }
    
    @objc func toCategory33(_ sender: UIButton, forEvent event: UIEvent) {
        
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let categoryPostsViewController = storyboard.instantiateViewController(identifier: "CategoryPosts") as! CategoryPostsViewController
        categoryPostsViewController.category = "travel"
        categoryPostsViewController.titleName = "旅行"
        navigationController?.pushViewController(categoryPostsViewController, animated: true)
    }
    
    @objc func toCategory34(_ sender: UIButton, forEvent event: UIEvent) {
        
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let categoryPostsViewController = storyboard.instantiateViewController(identifier: "CategoryPosts") as! CategoryPostsViewController
        categoryPostsViewController.category = "pr"
        categoryPostsViewController.titleName = "プロモーション"
        navigationController?.pushViewController(categoryPostsViewController, animated: true)
    }
    
    @objc func toCategory35(_ sender: UIButton, forEvent event: UIEvent) {
        
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let categoryPostsViewController = storyboard.instantiateViewController(identifier: "CategoryPosts") as! CategoryPostsViewController
        categoryPostsViewController.category = "car"
        categoryPostsViewController.titleName = "自動車・乗り物"
        navigationController?.pushViewController(categoryPostsViewController, animated: true)
    }
    
    @objc func toCategory36(_ sender: UIButton, forEvent event: UIEvent) {
        
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let categoryPostsViewController = storyboard.instantiateViewController(identifier: "CategoryPosts") as! CategoryPostsViewController
        categoryPostsViewController.category = "pet"
        categoryPostsViewController.titleName = "ペット・動物"
        navigationController?.pushViewController(categoryPostsViewController, animated: true)
    }
    
    @objc func toCategory37(_ sender: UIButton, forEvent event: UIEvent) {
        
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let categoryPostsViewController = storyboard.instantiateViewController(identifier: "CategoryPosts") as! CategoryPostsViewController
        categoryPostsViewController.category = "chat"
        categoryPostsViewController.titleName = "雑談・ネタ"
        navigationController?.pushViewController(categoryPostsViewController, animated: true)
    }
    
    @objc func toCategory38(_ sender: UIButton, forEvent event: UIEvent) {
        
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let categoryPostsViewController = storyboard.instantiateViewController(identifier: "CategoryPosts") as! CategoryPostsViewController
        categoryPostsViewController.category = "other"
        categoryPostsViewController.titleName = "その他"
        navigationController?.pushViewController(categoryPostsViewController, animated: true)
    }
    
}


