//
//  CategoryMenuTableViewCell.swift
//  Nomad-App
//
//  Created by yuishii on 2021/01/28.
//  Copyright © 2021 Yu Ishii. All rights reserved.
//
// Search1ViewControllerで表示するカテゴリーのセル

import UIKit
import Firebase

class CategoryMenuTableViewCell: UITableViewCell {
    
    @IBOutlet weak var image1: UIImageView! {
        didSet {
            image1.layer.cornerRadius = image1.frame.height / 15
        }
    }
    @IBOutlet weak var image2: UIImageView! {
        didSet {
            image2.layer.cornerRadius = image2.frame.height / 15
        }
    }
    @IBOutlet weak var image3: UIImageView! {
        didSet {
            image3.layer.cornerRadius = image3.frame.height / 15
        }
    }
    @IBOutlet weak var image4: UIImageView! {
        didSet {
            image4.layer.cornerRadius = image4.frame.height / 15
        }
    }
    @IBOutlet weak var image5: UIImageView! {
        didSet {
            image5.layer.cornerRadius = image5.frame.height / 15
        }
    }
    
    @IBOutlet weak var iconView1: UIView! {
        didSet {
            iconView1.backgroundColor = UIColor.rgb(red: 248, green: 248, blue: 248)
            iconView1.layer.cornerRadius = iconView1.frame.height / 15
        }
    }
    @IBOutlet weak var iconView2: UIView! {
        didSet {
            iconView2.backgroundColor = UIColor.rgb(red: 248, green: 248, blue: 248)
            iconView2.layer.cornerRadius = iconView2.frame.height / 15
        }
    }
    @IBOutlet weak var iconView3: UIView! {
        didSet {
            iconView3.backgroundColor = UIColor.rgb(red: 248, green: 248, blue: 248)
            iconView3.layer.cornerRadius = iconView3.frame.height / 15
        }
    }
    @IBOutlet weak var iconView4: UIView! {
        didSet {
            iconView4.backgroundColor = UIColor.rgb(red: 248, green: 248, blue: 248)
            iconView4.layer.cornerRadius = iconView4.frame.height / 15
        }
    }
    @IBOutlet weak var iconView5: UIView! {
        didSet {
            iconView5.backgroundColor = UIColor.rgb(red: 248, green: 248, blue: 248)
            iconView5.layer.cornerRadius = iconView5.frame.height / 15
        }
    }
    @IBOutlet weak var button1: UIButton!
    @IBOutlet weak var button2: UIButton!
    @IBOutlet weak var button3: UIButton!
    @IBOutlet weak var button4: UIButton!
    @IBOutlet weak var button5: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        let iconRef1 = Storage.storage().reference().child("category").child("image1" + ".jpg")
        self.image1.sd_setImage(with: iconRef1)
        let iconRef2 = Storage.storage().reference().child("category").child("image2" + ".jpg")
        self.image2.sd_setImage(with: iconRef2)
        let iconRef3 = Storage.storage().reference().child("category").child("image3" + ".jpg")
        self.image3.sd_setImage(with: iconRef3)
        let iconRef4 = Storage.storage().reference().child("category").child("image4" + ".jpg")
        self.image4.sd_setImage(with: iconRef4)
        let iconRef5 = Storage.storage().reference().child("category").child("image5" + ".jpg")
        self.image5.sd_setImage(with: iconRef5)
    }
    
}
