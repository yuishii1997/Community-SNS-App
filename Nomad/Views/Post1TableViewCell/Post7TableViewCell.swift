//
//  Post7TableViewCell.swift
//  Nomad-App
//
//  Created by yuishii on 2021/01/06.
//  Copyright © 2021 Yu Ishii. All rights reserved.
//
// コメント欄の画像なしの投稿のセル(ボーダーあり)

import UIKit
import FirebaseUI
import Firebase
import LBTAComponents
import SDWebImage

class Post7TableViewCell: UITableViewCell {
    
    var postdata: PostData?
    var message: Message?
    
    @IBOutlet weak var iconImageView: UIImageView!{
        didSet {
            iconImageView.contentMode = .scaleToFill
            iconImageView.clipsToBounds = true
            iconImageView.layer.cornerRadius = iconImageView.frame.height / 2
        }
    }
    
    @IBOutlet weak var iconImageView2: UIImageView! {
        didSet {
            iconImageView2.contentMode = .scaleToFill
            iconImageView2.clipsToBounds = true
            iconImageView2.layer.cornerRadius = iconImageView2.frame.height / 2
        }
    }
    
    @IBOutlet weak var iconButton: UIButton! {
        didSet {
            iconButton.layer.cornerRadius = iconButton.frame.height / 2
        }
    }
    
    @IBOutlet weak var captionLabel: UILabel!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var likeLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var communityLabel: UILabel!
    @IBOutlet weak var communityButton: UIButton!
    @IBOutlet weak var alertButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var nameButton: UIButton!
    @IBOutlet weak var viewerLabel: UILabel!
    @IBOutlet weak var iconView: UIView! {
        didSet {
            iconView.backgroundColor = UIColor.rgb(red: 248, green: 248, blue: 248)
            iconView.layer.cornerRadius = iconView.frame.height / 2
        }
    }
    @IBOutlet weak var bookmarkButton: UIButton!
    @IBOutlet weak var overViewLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var categoryButton: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // PostDataの内容をセルに表示
    func setPostData(_ postData: PostData) {
        
        if Auth.auth().currentUser != nil {
            
            if postData.caption != nil{
                //PostDataの投稿データをセルに表示
                // キャプションの表示
                self.captionLabel.text = "\(postData.caption!)"
            }
            
            let userRef = Firestore.firestore().collection("users").document(postData.uid)
            userRef.getDocument{ (document, error) in
                if let document = document{
                    
                    self.iconImageView.image = nil
                    self.iconImageView2.image = nil
                    
                    let data = document.data()
                    let name = data!["name"] as! String
                    print("name:\(name)")
                    self.nameLabel.text = "\(name)"
                    
                    let with_iconImage = data!["with_iconImage"] as! String
                    let imageNo = data!["imageNo"] as! Int
                    let imageNoString: String = "\(imageNo)"
                    
                    let iconRef = Storage.storage().reference().child("iconImages").child(postData.uid + imageNoString + ".jpg")
                    if with_iconImage == "exist" {
                        print("exist")
                        
                        self.iconImageView2.sd_setImage(with: iconRef)
                    }else{
                        print("notExist")
                        //self.iconView.isHidden = true
                        self.iconImageView.image = UIImage(named: "icons8-男性ユーザ-80")
                    }
                }
            }
            
            if postData.type == "community" {
                
                let userRef = Firestore.firestore().collection("users").document(postData.community!)
                userRef.getDocument{ (document, error) in
                    if let document = document{
                        
                        let data = document.data()
                        let name = data!["name"] as! String
                        self.communityLabel.text = name
                    }
                }
            }else{
                self.communityLabel.text = "プライベート"
            }
            
            if postData.category == nil || postData.category == "n" {
                self.categoryLabel.text = "カテゴリーなし"
            }else{
                
                if postData.category == "news" {
                    self.categoryLabel.text = "ニュース"
                }else if postData.category == "trend" {
                    self.categoryLabel.text = "話題・トレンド"
                }else if postData.category == "politics" {
                    self.categoryLabel.text = "政治・社会"
                }else if postData.category == "sports" {
                    self.categoryLabel.text = "スポーツ"
                }else if postData.category == "music" {
                    self.categoryLabel.text = "音楽"
                }else if postData.category == "funny" {
                    self.categoryLabel.text = "おもしろ"
                }else if postData.category == "entertainment" {
                    self.categoryLabel.text = "エンタメ"
                }else if postData.category == "tv" {
                    self.categoryLabel.text = "TV・映画"
                }else if postData.category == "youtube" {
                    self.categoryLabel.text = "YouTube"
                }else if postData.category == "economics" {
                    self.categoryLabel.text = "経済・金融"
                }else if postData.category == "business" {
                    self.categoryLabel.text = "ビジネス"
                }else if postData.category == "it" {
                    self.categoryLabel.text = "IT・テクノロジー"
                }else if postData.category == "science" {
                    self.categoryLabel.text = "科学"
                }else if postData.category == "health" {
                    self.categoryLabel.text = "健康・医療"
                }else if postData.category == "beauty" {
                    self.categoryLabel.text = "美容"
                }else if postData.category == "fashion" {
                    self.categoryLabel.text = "ファッション"
                }else if postData.category == "job" {
                    self.categoryLabel.text = "仕事"
                }else if postData.category == "school" {
                    self.categoryLabel.text = "学校"
                }else if postData.category == "hobby" {
                    self.categoryLabel.text = "趣味"
                }else if postData.category == "art" {
                    self.categoryLabel.text = "文化・芸術"
                }else if postData.category == "manga" {
                    self.categoryLabel.text = "漫画・アニメ"
                }else if postData.category == "game" {
                    self.categoryLabel.text = "ゲーム"
                }else if postData.category == "life" {
                    self.categoryLabel.text = "暮らし・生活"
                }else if postData.category == "family" {
                    self.categoryLabel.text = "家族"
                }else if postData.category == "love" {
                    self.categoryLabel.text = "結婚・恋愛"
                }else if postData.category == "parenting" {
                    self.categoryLabel.text = "子育て・教育"
                }else if postData.category == "recipe" {
                    self.categoryLabel.text = "グルメ・レシピ"
                }else if postData.category == "study" {
                    self.categoryLabel.text = "勉強・学問"
                }else if postData.category == "question" {
                    self.categoryLabel.text = "質問・相談"
                }else if postData.category == "mystery" {
                    self.categoryLabel.text = "不思議・謎"
                }else if postData.category == "prefectures" {
                    self.categoryLabel.text = "都道府県"
                }else if postData.category == "world" {
                    self.categoryLabel.text = "海外"
                }else if postData.category == "travel" {
                    self.categoryLabel.text = "旅行"
                }else if postData.category == "pr" {
                    self.categoryLabel.text = "プロモーション"
                }else if postData.category == "car" {
                    self.categoryLabel.text = "自動車・乗り物"
                }else if postData.category == "pet" {
                    self.categoryLabel.text = "ペット・動物"
                }else if postData.category == "chat" {
                    self.categoryLabel.text = "雑談・ネタ"
                }else if postData.category == "other" {
                    self.categoryLabel.text = "その他"
                }
            }
            
            // 日時の表示
            if let date = postData.date {
                let formatter = DateFormatter()
                formatter.dateFormat = "HH:mm・yyyy/MM/dd"
                let dateString = formatter.string(from: date)
                self.dateLabel.text = dateString
            }
            
            // いいね数の表示
            let likes = postData.likes
            let likeNumber = likes.count
            let likeText = "\(likeNumber)件のいいね"
            let likeText1 = "\(likeNumber)"
            let attrs = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 14)]
            let attributedString = NSMutableAttributedString(string:likeText1, attributes:attrs)
            
            let attrText1 = NSMutableAttributedString(string: likeText)
            attrText1.addAttributes([
                .foregroundColor: UIColor.black,
            ], range: NSMakeRange(0, likeText1.count))
            
            let likeText2 = "件のいいね"
            let normalString = NSMutableAttributedString(string:likeText2)
            
            attributedString.append(normalString)
            
            likeLabel.attributedText = attributedString
            likeLabel.attributedText = attrText1
            
            // いいねボタンの表示
            if postData.isLiked {
                let buttonImage = UIImage(named: "icons8-ハート-50-2")
                self.likeButton.setImage(buttonImage, for: .normal)
            } else {
                let buttonImage = UIImage(named: "icons8-ハート-50-5")
                self.likeButton.setImage(buttonImage, for: .normal)
            }
            
            // コメント数の表示
            let comments = postData.allComments
            let commentNumber = comments.count
            let commentText = "\(commentNumber)件のコメント"
            let commentText1 = "\(commentNumber)"
            let attrs2 = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 14)]
            let attributedString2 = NSMutableAttributedString(string:commentText1, attributes:attrs2)
            
            let attrText2 = NSMutableAttributedString(string: commentText)
            attrText2.addAttributes([
                .foregroundColor: UIColor.black,
            ], range: NSMakeRange(0, commentText1.count))
            
            let commentText2 = "件のコメント"
            let normalString2 = NSMutableAttributedString(string:commentText2)
            
            attributedString2.append(normalString2)
            
            commentLabel.attributedText = attributedString2
            commentLabel.attributedText = attrText2
            
            
            // コメント数の表示
            let viewers = postData.viewer
            let viewerNumber = viewers.count
            let viewerText = "\(viewerNumber)件の閲覧"
            let viewerText1 = "\(viewerNumber)"
            let attrs3 = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 14)]
            let attributedString3 = NSMutableAttributedString(string:viewerText1, attributes:attrs3)
            
            let attrText3 = NSMutableAttributedString(string: viewerText)
            attrText3.addAttributes([
                .foregroundColor: UIColor.black,
            ], range: NSMakeRange(0, viewerText1.count))
            
            let viewerText2 = "件の閲覧"
            let normalString3 = NSMutableAttributedString(string:viewerText2)
            
            attributedString3.append(normalString3)
            
            viewerLabel.attributedText = attributedString3
            viewerLabel.attributedText = attrText3
            
            // コメントボタンの表示
            if postData.isCommented {
                let buttonImage = UIImage(named: "comments2")
                self.commentButton.setImage(buttonImage, for: .normal)
            } else {
                let buttonImage = UIImage(named: "comments")
                self.commentButton.setImage(buttonImage, for: .normal)
            }
            
            // ブックマークボタンの表示
            if postData.isBookmarked {
                let buttonImage = UIImage(named: "icons8-ブックマークリボン-50-3")
                self.bookmarkButton.setImage(buttonImage, for: .normal)
            } else {
                let buttonImage = UIImage(named: "icons8-ブックマークリボン-50-2")
                self.bookmarkButton.setImage(buttonImage, for: .normal)
            }
            
            if postData.overView != nil {
                self.overViewLabel.text = "\(postData.overView!)"
            }
            
        }
        
    }
}
