//
//  Post2TableViewCell.swift
//  Nomad-App
//
//  Created by yuishii on 2020/07/14.
//  Copyright © 2020 Yu Ishii. All rights reserved.
//
// 画像ありの投稿のセル(ボーダーなし)

import UIKit
import FirebaseUI
import Firebase
import LBTAComponents
import SDWebImage

class Post2TableViewCell: UITableViewCell {
    
    var postdata: PostData?
    var message: Message?
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var likeLabel: UILabel!
    @IBOutlet weak var captionLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var communityLabel: UILabel!
    @IBOutlet weak var alertButton: UIButton!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var nameButton: UIButton!
    @IBOutlet weak var communityButton: UIButton!
    @IBOutlet weak var iconView: UIView! {
        didSet {
            iconView.backgroundColor = UIColor.rgb(red: 248, green: 248, blue: 248)
            iconView.layer.cornerRadius = iconView.frame.height / 2
        }
    }
    
    @IBOutlet weak var postView: UIView!{
        didSet {
            postView.backgroundColor = UIColor.rgb(red: 230, green: 230, blue: 230)
        }
    }
    
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
    
    @IBOutlet weak var bookmarkButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // PostDataの内容をセルに表示
    func setPostData(_ postData: PostData) {
        
        
        if Auth.auth().currentUser != nil {
            
            let userRef = Firestore.firestore().collection("users").document(postData.uid)
            userRef.getDocument{ (document, error) in
                if let document = document{
                    
                    self.iconImageView.image = nil
                    self.iconImageView2.image = nil
                    
                    let data = document.data()
                    let name = data!["name"] as! String
                    print("name:\(name)")
                    
                    if postData.date != nil {
                        let date = postData.date!.readableDate(start: postData.date!, end: Date())
                        if date == "・0秒" {
                            let dateText = "・今"
                            self.nameLabel.text = "\(name)"
                            self.dateLabel.text = "\(dateText)"
                        } else if date == "・7日以上" {
                            // 日時の表示
                            if let date = postData.date {
                                let formatter = DateFormatter()
                                formatter.dateFormat = "yyyy/MM/dd"
                                let dateString = formatter.string(from: date)
                                let dateText = "・" + dateString
                                self.nameLabel.text = "\(name)"
                                self.dateLabel.text = "\(dateText)"
                            }
                        }else{
                            self.nameLabel.text = "\(name)"
                            self.dateLabel.text = "\(date)"
                        }
                    }
                    
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
            
            // 画像の表示
            let imageRef = Storage.storage().reference().child("images").child(postData.id + ".jpg")
            postImageView.sd_setImage(with: imageRef)
            
            if postData.caption != nil{
                //PostDataの投稿データをセルに表示
                // キャプションの表示 with:"  "は空白二個にしている
                let captionArray = postData.caption!.components(separatedBy: "\n")
                let convertedCaption = captionArray.reduce("") {
                    if $0.isEmpty {
                        if $1.isEmpty {
                            return $0
                        } else {
                            return $1
                        }
                    } else {
                        if $1.isEmpty {
                            return $0
                        } else {
                            return $0 + " " + $1
                        }
                    }
                }
                self.captionLabel.text = convertedCaption
            }
            
            // いいね数の表示
            let likes = postData.likes
            let likeNumber = likes.count
            likeLabel.text = "\(likeNumber.shorted())"
            
            // コメント数の表示
            let comments = postData.allComments
            let commentNumber = comments.count
            commentLabel.text = "\(commentNumber.shorted())"
            
            // いいねボタンの表示
            if postData.isLiked {
                let buttonImage = UIImage(named: "icons8-ハート-50-2")
                self.likeButton.setImage(buttonImage, for: .normal)
            } else {
                let buttonImage = UIImage(named: "icons8-ハート-50-5")
                self.likeButton.setImage(buttonImage, for: .normal)
            }
            
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
        }
    }
}
