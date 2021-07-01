//
//  ProfileHome2TableViewCell.swift
//  Nomad-App
//
//  Created by yuishii on 2020/12/27.
//  Copyright © 2020 Yu Ishii. All rights reserved.
//
// Page1ViewController、Page1ComViewControllerのプロフィール部分のセル

import UIKit
import Firebase

class ProfileHome2TableViewCell: UITableViewCell {
    
    var userdata: UserData?
    
    @IBOutlet weak var key1: UIImageView!{
        didSet {
            key1.isHidden = true
        }
    }
    @IBOutlet weak var key2: UIImageView!{
        didSet {
            key2.isHidden = true
        }
    }
    
    
    @IBOutlet weak var headerView: UIView! {
        didSet {
            headerView.backgroundColor = UIColor.rgb(red: 198, green: 205, blue: 224)
        }
    }
    
    @IBOutlet weak var headerImageView: UIImageView!{
        didSet {
            headerImageView.isUserInteractionEnabled = true
            headerImageView.tag = 0
        }
    }
    @IBOutlet weak var iconImageView: UIImageView! {
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
    
    @IBOutlet weak var iconView: UIView! {
        didSet {
            iconView.backgroundColor = UIColor.white
            iconView.layer.cornerRadius = iconView.frame.height / 2
        }
    }
    
    @IBOutlet weak var iconBack: UIView! {
        didSet {
            iconBack.layer.cornerRadius = iconBack.frame.height / 2
            iconBack.backgroundColor = UIColor.rgb(red: 248, green: 248, blue: 248)
        }
    }
    
    @IBOutlet weak var followButton: UIButton!{
        didSet {
            var link = UIColor(red: 65/255, green: 146/255, blue: 238/255, alpha: 1.0)
            followButton.layer.borderColor = link.cgColor
            followButton.layer.borderWidth = 1.0
            followButton.layer.cornerRadius = followButton.frame.height / 2
        }
    }
    
    @IBOutlet weak var editButton: UIButton!{
        didSet {
            var link = UIColor(red: 65/255, green: 146/255, blue: 238/255, alpha: 1.0)
            editButton.layer.borderColor = link.cgColor
            editButton.layer.borderWidth = 1.0
            editButton.layer.cornerRadius = editButton.frame.height / 2
        }
    }
    
    
    @IBOutlet weak var captionLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var dateLabel: UILabel! {
        didSet {
            dateLabel.textColor = UIColor.rgb(red: 72, green: 85, blue: 101)
        }
    }
    
    @IBOutlet weak var followerLabel: UILabel!{
        didSet {
            followerLabel.textColor = UIColor.rgb(red: 72, green: 85, blue: 101)
        }
    }
    @IBOutlet weak var followerCountLabel: UILabel!
    
    @IBOutlet weak var typeLabel: UILabel!{
        didSet {
            typeLabel.textColor = UIColor.rgb(red: 72, green: 85, blue: 101)
        }
    }
    @IBOutlet weak var followingCountLabel: UILabel!
    
    @IBOutlet weak var followingLabel: UILabel!{
        didSet {
            followingLabel.textColor = UIColor.rgb(red: 72, green: 85, blue: 101)
        }
    }
    
    @IBOutlet weak var moderatorFollowButton: UIButton!{
        didSet {
            var link = UIColor(red: 65/255, green: 146/255, blue: 238/255, alpha: 1.0)
            moderatorFollowButton.layer.borderColor = link.cgColor
            moderatorFollowButton.layer.borderWidth = 1.0
            moderatorFollowButton.layer.cornerRadius = moderatorFollowButton.frame.height / 2
        }
    }
    
    @IBOutlet weak var moderatorEditButton: UIButton!{
        didSet {
            var link = UIColor(red: 65/255, green: 146/255, blue: 238/255, alpha: 1.0)
            moderatorEditButton.layer.borderColor = link.cgColor
            moderatorEditButton.layer.borderWidth = 1.0
            moderatorEditButton.layer.cornerRadius = moderatorEditButton.frame.height / 2
        }
    }
    
    @IBOutlet weak var sectionTitle1: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        iconImageView.image = nil
        iconImageView2.image = nil
        headerImageView.image = nil
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        if Auth.auth().currentUser != nil {
            let myid = Auth.auth().currentUser!.uid
            
            let uid = userdata?.uid
            let name = userdata?.name
            let caption = userdata?.caption
            
            if uid != nil {
                
                let imageNo = userdata!.imageNo!
                let imageNoString: String = "\(imageNo)"
                print("imageNo\(imageNo)")
                
                let iconRef = Storage.storage().reference().child("iconImages").child(userdata!.uid + imageNoString + ".jpg")
                
                
                if userdata!.with_iconImage == "exist" {
                    print("exist")
                    self.iconImageView.sd_setImage(with: iconRef)
                }else{
                    print("notExist")
                    //self.iconBack.isHidden = true
                    self.iconImageView2.image = UIImage(named: "icons8-男性ユーザ-80")
                }
                
                let headerNo = userdata!.headerNo!
                let headerNoString: String = "\(headerNo)"
                print("headerNo\(headerNo)")
                
                let headerRef = Storage.storage().reference().child("headerImages").child(userdata!.uid + headerNoString + ".jpg")
                if userdata!.with_headerImage == "exist" {
                    print("exist")
                    self.headerImageView.sd_setImage(with: headerRef)
                }else{
                    print("notExist")
                }
            }
            
            if name != nil {
                nameLabel.text = name
                print("name:\(name)")
            }else{
                nameLabel.text = ""
                print("name:\(name)")
            }
            
            if caption != nil {
                captionLabel.text = caption
                print("caption:\(caption)")
            }else{
                captionLabel.text = ""
                print("caption:\(caption)")
            }
            
            if let date = self.userdata?.date {
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy年MM月dd日"
                let dateString = formatter.string(from: date)
                // 日時の表示
                if dateString != nil {
                    dateLabel.text = dateString + "に開設"
                    print("dateString:\(dateString)")
                }else{
                    dateLabel.text = ""
                    print("dateString:\(dateString)")
                }
            }
            
            //typeがコミュニティの場合
            if userdata?.type == "community" {
                
                key1.isHidden = true
                key2.isHidden = true
                
                followingLabel.isHidden = true
                followingCountLabel.isHidden = true
                
                //モデレートしているコミュニティの場合
                if userdata?.isModerated == true{
                    followButton.isHidden = true
                    editButton.isHidden = true
                    moderatorFollowButton.isHidden = false
                    moderatorEditButton.isHidden = false
                    
                    moderatorEditButton.setTitle("変更", for: .normal)
                    moderatorEditButton.backgroundColor = .white
                    moderatorEditButton.tintColor = UIColor.rgb(red: 65, green: 146, blue: 238)
                    moderatorEditButton.contentHorizontalAlignment = .center
                    
                    if userdata?.isFollowed == true {
                        moderatorFollowButton.setTitle("フォロー中", for: .normal)
                        moderatorFollowButton.backgroundColor = UIColor.rgb(red: 65, green: 146, blue: 238)
                        moderatorFollowButton.tintColor = .white
                        moderatorFollowButton.contentHorizontalAlignment = .center
                    }else{
                        moderatorFollowButton.setTitle("フォローする", for: .normal)
                        moderatorFollowButton.backgroundColor = .white
                        moderatorFollowButton.tintColor = UIColor.rgb(red: 65, green: 146, blue: 238)
                        moderatorFollowButton.contentHorizontalAlignment = .center
                    }
                    
                    //モデレートしていないコミュニティの場合
                }else{
                    
                    if userdata?.isFollowed == true {
                        followButton.isHidden = false
                        editButton.isHidden = true
                        moderatorFollowButton.isHidden = true
                        moderatorEditButton.isHidden = true
                        followButton.setTitle("フォロー中", for: .normal)
                        followButton.backgroundColor = UIColor.rgb(red: 65, green: 146, blue: 238)
                        followButton.tintColor = .white
                        followButton.contentHorizontalAlignment = .center
                    }else{
                        followButton.isHidden = false
                        editButton.isHidden = true
                        moderatorFollowButton.isHidden = true
                        moderatorEditButton.isHidden = true
                        followButton.setTitle("フォローする", for: .normal)
                        followButton.tintColor = UIColor.rgb(red: 65, green: 146, blue: 238)
                        followButton.backgroundColor = .white
                        followButton.contentHorizontalAlignment = .center
                    }
                }
                
                typeLabel.text = "コミュニティ"
                followerLabel.text = "フォロワー"
                let followedNumber = userdata!.follower.count
                followerCountLabel.text = "\(followedNumber)"
                
            }else{
                
                followingLabel.isHidden = false
                followingCountLabel.isHidden = false
                
                if uid == myid{
                    
                    if userdata?.bePrivate == "on"{
                        key1.isHidden = true
                        key2.isHidden = false
                        followButton.isHidden = true
                        editButton.isHidden = false
                        moderatorFollowButton.isHidden = true
                        moderatorEditButton.isHidden = true
                        editButton.setTitle("変更", for: .normal)
                        editButton.backgroundColor = .white
                        editButton.tintColor = UIColor.rgb(red: 65, green: 146, blue: 238)
                        editButton.contentHorizontalAlignment = .center
                    }else{
                        key1.isHidden = true
                        key2.isHidden = true
                        followButton.isHidden = true
                        editButton.isHidden = false
                        moderatorFollowButton.isHidden = true
                        moderatorEditButton.isHidden = true
                        editButton.setTitle("変更", for: .normal)
                        editButton.backgroundColor = .white
                        editButton.tintColor = UIColor.rgb(red: 65, green: 146, blue: 238)
                        editButton.contentHorizontalAlignment = .center
                    }
                }else{
                    
                    if userdata?.bePrivate == "on"{
                        key1.isHidden = false
                        key2.isHidden = true
                        if userdata?.isBlocked == true {
                            var red = UIColor.rgb(red: 206, green: 57, blue: 95)
                            followButton.layer.borderColor = red.cgColor
                            followButton.layer.borderWidth = 1.0
                            followButton.isHidden = false
                            editButton.isHidden = true
                            moderatorFollowButton.isHidden = true
                            moderatorEditButton.isHidden = true
                            followButton.setTitle("ブロック中", for: .normal)
                            followButton.backgroundColor = UIColor.rgb(red: 206, green: 57, blue: 95)
                            followButton.tintColor = .white
                            followButton.contentHorizontalAlignment = .center
                        }else{
                            var link = UIColor(red: 65/255, green: 146/255, blue: 238/255, alpha: 1.0)
                            followButton.layer.borderColor = link.cgColor
                            followButton.layer.borderWidth = 1.0
                            
                            if userdata?.isFollowed == true {
                                followButton.isHidden = false
                                editButton.isHidden = true
                                moderatorFollowButton.isHidden = true
                                moderatorEditButton.isHidden = true
                                followButton.setTitle("フォロー中", for: .normal)
                                followButton.backgroundColor = UIColor.rgb(red: 65, green: 146, blue: 238)
                                followButton.tintColor = .white
                                followButton.contentHorizontalAlignment = .center
                            }else{
                                followButton.isHidden = false
                                editButton.isHidden = true
                                moderatorFollowButton.isHidden = true
                                moderatorEditButton.isHidden = true
                                followButton.setTitle("フォローする", for: .normal)
                                followButton.tintColor = UIColor.rgb(red: 65, green: 146, blue: 238)
                                followButton.backgroundColor = .white
                                followButton.contentHorizontalAlignment = .center
                            }
                        }
                    }else{
                        key1.isHidden = true
                        key2.isHidden = true
                        if userdata?.isBlocked == true {
                            var red = UIColor.rgb(red: 206, green: 57, blue: 95)
                            followButton.layer.borderColor = red.cgColor
                            followButton.layer.borderWidth = 1.0
                            followButton.isHidden = false
                            editButton.isHidden = true
                            moderatorFollowButton.isHidden = true
                            moderatorEditButton.isHidden = true
                            followButton.setTitle("ブロック中", for: .normal)
                            followButton.backgroundColor = UIColor.rgb(red: 206, green: 57, blue: 95)
                            followButton.tintColor = .white
                            followButton.contentHorizontalAlignment = .center
                        }else{
                            var link = UIColor(red: 65/255, green: 146/255, blue: 238/255, alpha: 1.0)
                            followButton.layer.borderColor = link.cgColor
                            followButton.layer.borderWidth = 1.0
                            
                            if userdata?.isFollowed == true {
                                followButton.isHidden = false
                                editButton.isHidden = true
                                moderatorFollowButton.isHidden = true
                                moderatorEditButton.isHidden = true
                                followButton.setTitle("フォロー中", for: .normal)
                                followButton.backgroundColor = UIColor.rgb(red: 65, green: 146, blue: 238)
                                followButton.tintColor = .white
                                followButton.contentHorizontalAlignment = .center
                            }else{
                                followButton.isHidden = false
                                editButton.isHidden = true
                                moderatorFollowButton.isHidden = true
                                moderatorEditButton.isHidden = true
                                followButton.setTitle("フォローする", for: .normal)
                                followButton.tintColor = UIColor.rgb(red: 65, green: 146, blue: 238)
                                followButton.backgroundColor = .white
                                followButton.contentHorizontalAlignment = .center
                            }
                        }
                    }
                }
                
                typeLabel.text = "プライベート"
                followerLabel.text = "フォロワー"
                followingLabel.text = "フォロー中"
                if userdata?.follower != nil {
                    let followedNumber = userdata!.follower.count
                    followerCountLabel.text = "\(followedNumber)"
                }else{
                    followerCountLabel.text = "\(0)"
                }
                if userdata?.follow != nil {
                    let followingNumber = userdata!.follow.count
                    followingCountLabel.text = "\(followingNumber)"
                }else{
                    followingCountLabel.text = "\(0)"
                }
            }
        }
    }
}
