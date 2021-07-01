//
//  MyCollectionViewCell1.swift
//  Nomad-App
//
//  Created by yuishii on 2021/01/28.
//  Copyright © 2021 Yu Ishii. All rights reserved.
//

import UIKit
import Firebase

class MyCollectionViewCell1: UICollectionViewCell {
    
    
    @IBOutlet weak var headerView: UIView! {
        didSet {
            headerView.backgroundColor = UIColor.rgb(red: 198, green: 205, blue: 224)
        }
    }
    
    @IBOutlet weak var headerImageView: UIImageView!{
        didSet {
            headerImageView?.contentMode = .scaleToFill
            headerImageView?.clipsToBounds = true
            headerImageView.isUserInteractionEnabled = true
            headerImageView.tag = 0
        }
    }
    
    @IBOutlet weak var iconImageView: UIImageView! {
        didSet {
            iconImageView?.contentMode = .scaleToFill
            iconImageView?.clipsToBounds = true
            iconImageView.layer.cornerRadius = iconImageView.frame.height / 2
        }
    }
    
    @IBOutlet weak var iconImageView2: UIImageView! {
        didSet {
            iconImageView2?.contentMode = .scaleToFill
            iconImageView2?.clipsToBounds = true
            iconImageView2.layer.cornerRadius = iconImageView2.frame.height / 2
        }
    }
    
    @IBOutlet weak var iconView: UIView! {
        didSet {
            iconView.layer.cornerRadius = iconView.frame.height / 2
            iconView.backgroundColor = UIColor.rgb(red: 248, green: 248, blue: 248)
        }
    }
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var captionLabel: UILabel!
    @IBOutlet weak var followerLabel: UILabel!{
        didSet {
            followerLabel.textColor = UIColor.rgb(red: 72, green: 85, blue: 101)
        }
    }
    
    
    static let identifier = "MyCollectionViewCell1"
    
    static func nib() -> UINib {
        return UINib(nibName: "MyCollectionViewCell1", bundle: nil)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor(red: 233/255, green: 234/255, blue: 236/255, alpha: 1.0).cgColor
        self.layer.cornerRadius = self.frame.height / 20
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        headerImageView.image = nil
        iconImageView.image = nil
        iconImageView2.image = nil
    }
    
    public func configure1(with model: UserData) {
        
        let uid = model.uid
        let name = model.name
        let caption = model.caption
        
        if uid != nil {
            
            let imageNo = model.imageNo!
            let imageNoString: String = "\(imageNo)"
            print("imageNo\(imageNo)")
            
            let iconRef = Storage.storage().reference().child("iconImages").child(uid + imageNoString + ".jpg")
            
            if model.with_iconImage == "exist" {
                print("exist")
                self.iconImageView2.sd_setImage(with: iconRef)
            }else{
                print("notExist")
                //self.iconView.isHidden = true
                self.iconImageView.image = UIImage(named: "icons8-男性ユーザ-80")
            }
            
            let headerNo = model.headerNo!
            let headerNoString: String = "\(headerNo)"
            print("headerNo\(headerNo)")
            
            let headerRef = Storage.storage().reference().child("headerImages").child(uid + headerNoString + ".jpg")
            if model.with_headerImage == "exist" {
                print("exist")
                self.headerImageView.sd_setImage(with: headerRef)
            }else{
                print("notExist")
            }
        }
        
        if name != nil {
            nameLabel.text = name
        }else{
            nameLabel.text = ""
        }
        
        if caption != nil {
            captionLabel.text = caption
        }else{
            captionLabel.text = ""
        }
        
        if model.follower != nil {
            let followedNumber = model.follower.count.shorted()
            followerLabel.text = "\(followedNumber)フォロワー"
        }else{
            followerLabel.text = "0フォロワー"
        }
        
    }
}
