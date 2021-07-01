//
//  MyCollectionViewCell13.swift
//  Nomad-App
//
//  Created by yuishii on 2021/01/31.
//  Copyright © 2021 Yu Ishii. All rights reserved.
//

import UIKit
import Firebase

class MyCollectionViewCell13: UICollectionViewCell {
    
    var listener: ListenerRegistration?
    
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
    
    static let identifier = "MyCollectionViewCell13"
    
    static func nib() -> UINib {
        return UINib(nibName: "MyCollectionViewCell13", bundle: nil)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor(red: 233/255, green: 234/255, blue: 236/255, alpha: 1.0).cgColor
        self.layer.cornerRadius = self.frame.height / 20
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        if listener != nil {
            print("DEBUG001 remove listner cell=\(Unmanaged.passUnretained(self).toOpaque())")
            listener?.remove()
        }
        headerImageView.image = nil
        iconImageView.image = nil
        iconImageView2.image = nil
    }
    
    public func configure13(with model: PostData) {
        
        let myid = Auth.auth().currentUser!.uid
        if Auth.auth().currentUser != nil {
            
            if model.community == nil || model.community == myid {
                let uid = model.uid
                let userRef = Firestore.firestore().collection("users").document(uid)
                listener = userRef.addSnapshotListener { (document, error) in
                    if let document = document{
                        
                        let data = document.data()
                        let name = data?["name"] as? String
                        print("configure1 name:\(name)")
                        let caption = data?["caption"] as? String
                        print("configure1 caption:\(caption)")
                        
                        if name != nil {
                            self.nameLabel.text = name
                        }else{
                            self.nameLabel.text = ""
                        }
                        
                        
                        if caption != nil {
                            self.captionLabel.text = caption
                        }else{
                            self.captionLabel.text = ""
                        }
                        
                        let with_iconImage = data!["with_iconImage"] as? String
                        let imageNo = data!["imageNo"] as! Int
                        let imageNoString: String = "\(imageNo)"
                        print("configure13 imageNo:\(imageNoString)")
                        
                        if with_iconImage != nil {
                            let iconRef = Storage.storage().reference().child("iconImages").child(uid + imageNoString + ".jpg")
                            if with_iconImage == "exist" {
                                print("exist")
                                self.iconImageView2.sd_setImage(with: iconRef)
                            }else{
                                print("notExist")
                                //self.iconView.isHidden = true
                                self.iconImageView.image = UIImage(named: "icons8-男性ユーザ-80")
                            }
                        }
                        
                        let with_headerImage = data!["with_headerImage"] as? String
                        let headerNo = data!["headerNo"] as! Int
                        let headerNoString: String = "\(headerNo)"
                        print("configure1 headerNo:\(headerNoString)")
                        
                        if with_headerImage != nil {
                            let headerRef = Storage.storage().reference().child("headerImages").child(uid + headerNoString + ".jpg")
                            if with_headerImage == "exist" {
                                print("exist")
                                self.headerImageView.sd_setImage(with: headerRef)
                            }else{
                                print("notExist")
                            }
                        }
                        
                        let follower = data!["follower"] as? [[String:Any]]
                        if follower != nil {
                            let followedNumber = follower!.count.shorted()
                            self.followerLabel.text = "\(followedNumber)フォロワー"
                        }else{
                            self.followerLabel.text = "0フォロワー"
                        }
                    }
                }
                
            }else{
                let uid = model.community
                let userRef = Firestore.firestore().collection("users").document(uid!)
                listener = userRef.addSnapshotListener { (document, error) in
                    if let document = document{
                        
                        let data = document.data()
                        let name = data?["name"] as? String
                        print("configure1 name:\(name)")
                        let caption = data?["caption"] as? String
                        print("configure1 caption:\(caption)")
                        
                        
                        if name != nil {
                            self.nameLabel.text = name
                        }else{
                            self.nameLabel.text = ""
                        }
                        
                        
                        if caption != nil {
                            self.captionLabel.text = caption
                        }else{
                            self.captionLabel.text = ""
                        }
                        
                        let with_iconImage = data!["with_iconImage"] as? String
                        let imageNo = data!["imageNo"] as! Int
                        let imageNoString: String = "\(imageNo)"
                        print("configure13 imageNo:\(imageNoString)")
                        
                        
                        if with_iconImage != nil {
                            let iconRef = Storage.storage().reference().child("iconImages").child(uid! + imageNoString + ".jpg")
                            if with_iconImage == "exist" {
                                print("exist")
                                self.iconImageView2.sd_setImage(with: iconRef)
                            }else{
                                print("notExist")
                                //self.iconView.isHidden = true
                                self.iconImageView.image = UIImage(named: "icons8-男性ユーザ-80")
                            }
                        }
                        
                        let with_headerImage = data!["with_headerImage"] as? String
                        let headerNo = data!["headerNo"] as! Int
                        let headerNoString: String = "\(headerNo)"
                        print("configure1 headerNo:\(headerNoString)")
                        
                        if with_headerImage != nil {
                            let headerRef = Storage.storage().reference().child("headerImages").child(uid! + headerNoString + ".jpg")
                            if with_headerImage == "exist" {
                                print("exist")
                                self.headerImageView.sd_setImage(with: headerRef)
                            }else{
                                print("notExist")
                            }
                        }
                        
                        let follower = data!["follower"] as? [[String:Any]]
                        if follower != nil {
                            let followedNumber = follower!.count.shorted()
                            self.followerLabel.text = "\(followedNumber)フォロワー"
                        }else{
                            self.followerLabel.text = "0フォロワー"
                        }
                    }
                }
                
            }
            
        }
    }
}
