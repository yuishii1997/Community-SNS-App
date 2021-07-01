//
//  CategoryMenuTableViewCell2.swift
//  Nomad-App
//
//  Created by yuishii on 2021/01/28.
//  Copyright © 2021 Yu Ishii. All rights reserved.
//
// CategoryMenuViewControllerで表示するカテゴリーのセル

import UIKit
import Firebase

class CategoryMenuTableViewCell2: UITableViewCell {
    
    
    @IBOutlet weak var image1: UIImageView!{
        didSet {
            image1.layer.cornerRadius = image1.frame.height / 15
        }
    }
    @IBOutlet weak var image2: UIImageView!{
        didSet {
            image2.layer.cornerRadius = image2.frame.height / 15
        }
    }
    @IBOutlet weak var image3: UIImageView!{
        didSet {
            image3.layer.cornerRadius = image3.frame.height / 15
        }
    }
    @IBOutlet weak var image4: UIImageView!{
        didSet {
            image4.layer.cornerRadius = image4.frame.height / 15
        }
    }
    @IBOutlet weak var image5: UIImageView!{
        didSet {
            image5.layer.cornerRadius = image5.frame.height / 15
        }
    }
    @IBOutlet weak var image6: UIImageView!{
        didSet {
            image6.layer.cornerRadius = image6.frame.height / 15
        }
    }
    @IBOutlet weak var image7: UIImageView!{
        didSet {
            image7.layer.cornerRadius = image7.frame.height / 15
        }
    }
    @IBOutlet weak var image8: UIImageView!{
        didSet {
            image8.layer.cornerRadius = image8.frame.height / 15
        }
    }
    @IBOutlet weak var image9: UIImageView!{
        didSet {
            image9.layer.cornerRadius = image9.frame.height / 15
        }
    }
    @IBOutlet weak var image10: UIImageView!{
        didSet {
            image10.layer.cornerRadius = image10.frame.height / 15
        }
    }
    @IBOutlet weak var image11: UIImageView!{
        didSet {
            image11.layer.cornerRadius = image11.frame.height / 15
        }
    }
    @IBOutlet weak var image12: UIImageView!{
        didSet {
            image12.layer.cornerRadius = image12.frame.height / 15
        }
    }
    @IBOutlet weak var image13: UIImageView!{
        didSet {
            image13.layer.cornerRadius = image13.frame.height / 15
        }
    }
    @IBOutlet weak var image14: UIImageView!{
        didSet {
            image14.layer.cornerRadius = image14.frame.height / 15
        }
    }
    @IBOutlet weak var image15: UIImageView!{
        didSet {
            image15.layer.cornerRadius = image15.frame.height / 15
        }
    }
    @IBOutlet weak var image16: UIImageView!{
        didSet {
            image16.layer.cornerRadius = image16.frame.height / 15
        }
    }
    @IBOutlet weak var image17: UIImageView!{
        didSet {
            image17.layer.cornerRadius = image17.frame.height / 15
        }
    }
    @IBOutlet weak var image18: UIImageView!{
        didSet {
            image18.layer.cornerRadius = image18.frame.height / 15
        }
    }
    @IBOutlet weak var image19: UIImageView!{
        didSet {
            image19.layer.cornerRadius = image19.frame.height / 15
        }
    }
    @IBOutlet weak var image20: UIImageView!{
        didSet {
            image20.layer.cornerRadius = image20.frame.height / 15
        }
    }
    @IBOutlet weak var image21: UIImageView!{
        didSet {
            image21.layer.cornerRadius = image21.frame.height / 15
        }
    }
    @IBOutlet weak var image22: UIImageView!{
        didSet {
            image22.layer.cornerRadius = image22.frame.height / 15
        }
    }
    @IBOutlet weak var image23: UIImageView!{
        didSet {
            image23.layer.cornerRadius = image23.frame.height / 15
        }
    }
    @IBOutlet weak var image24: UIImageView!{
        didSet {
            image24.layer.cornerRadius = image24.frame.height / 15
        }
    }
    @IBOutlet weak var image25: UIImageView!{
        didSet {
            image25.layer.cornerRadius = image25.frame.height / 15
        }
    }
    @IBOutlet weak var image26: UIImageView!{
        didSet {
            image26.layer.cornerRadius = image26.frame.height / 15
        }
    }
    @IBOutlet weak var image27: UIImageView!{
        didSet {
            image27.layer.cornerRadius = image27.frame.height / 15
        }
    }
    @IBOutlet weak var image28: UIImageView!{
        didSet {
            image28.layer.cornerRadius = image28.frame.height / 15
        }
    }
    @IBOutlet weak var image29: UIImageView!{
        didSet {
            image29.layer.cornerRadius = image29.frame.height / 15
        }
    }
    @IBOutlet weak var image30: UIImageView!{
        didSet {
            image30.layer.cornerRadius = image30.frame.height / 15
        }
    }
    @IBOutlet weak var image31: UIImageView!{
        didSet {
            image31.layer.cornerRadius = image31.frame.height / 15
        }
    }
    @IBOutlet weak var image32: UIImageView!{
        didSet {
            image32.layer.cornerRadius = image32.frame.height / 15
        }
    }
    @IBOutlet weak var image33: UIImageView!{
        didSet {
            image33.layer.cornerRadius = image33.frame.height / 15
        }
    }
    @IBOutlet weak var image34: UIImageView!{
        didSet {
            image34.layer.cornerRadius = image34.frame.height / 15
        }
    }
    @IBOutlet weak var image35: UIImageView!{
        didSet {
            image35.layer.cornerRadius = image35.frame.height / 15
        }
    }
    @IBOutlet weak var image36: UIImageView!{
        didSet {
            image36.layer.cornerRadius = image36.frame.height / 15
        }
    }
    @IBOutlet weak var image37: UIImageView!{
        didSet {
            image37.layer.cornerRadius = image37.frame.height / 15
        }
    }
    @IBOutlet weak var image38: UIImageView!{
        didSet {
            image38.layer.cornerRadius = image38.frame.height / 15
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
    @IBOutlet weak var iconView6: UIView! {
        didSet {
            iconView6.backgroundColor = UIColor.rgb(red: 248, green: 248, blue: 248)
            iconView6.layer.cornerRadius = iconView6.frame.height / 15
        }
    }
    @IBOutlet weak var iconView7: UIView! {
        didSet {
            iconView7.backgroundColor = UIColor.rgb(red: 248, green: 248, blue: 248)
            iconView7.layer.cornerRadius = iconView7.frame.height / 15
        }
    }
    @IBOutlet weak var iconView8: UIView! {
        didSet {
            iconView8.backgroundColor = UIColor.rgb(red: 248, green: 248, blue: 248)
            iconView8.layer.cornerRadius = iconView8.frame.height / 15
        }
    }
    @IBOutlet weak var iconView9: UIView! {
        didSet {
            iconView9.backgroundColor = UIColor.rgb(red: 248, green: 248, blue: 248)
            iconView9.layer.cornerRadius = iconView9.frame.height / 15
        }
    }
    @IBOutlet weak var iconView10: UIView! {
        didSet {
            iconView10.backgroundColor = UIColor.rgb(red: 248, green: 248, blue: 248)
            iconView10.layer.cornerRadius = iconView10.frame.height / 15
        }
    }
    @IBOutlet weak var iconView11: UIView! {
        didSet {
            iconView11.backgroundColor = UIColor.rgb(red: 248, green: 248, blue: 248)
            iconView11.layer.cornerRadius = iconView11.frame.height / 15
        }
    }
    @IBOutlet weak var iconView12: UIView! {
        didSet {
            iconView12.backgroundColor = UIColor.rgb(red: 248, green: 248, blue: 248)
            iconView12.layer.cornerRadius = iconView12.frame.height / 15
        }
    }
    @IBOutlet weak var iconView13: UIView! {
        didSet {
            iconView13.backgroundColor = UIColor.rgb(red: 248, green: 248, blue: 248)
            iconView13.layer.cornerRadius = iconView13.frame.height / 15
        }
    }
    @IBOutlet weak var iconView14: UIView! {
        didSet {
            iconView14.backgroundColor = UIColor.rgb(red: 248, green: 248, blue: 248)
            iconView14.layer.cornerRadius = iconView14.frame.height / 15
        }
    }
    @IBOutlet weak var iconView15: UIView! {
        didSet {
            iconView15.backgroundColor = UIColor.rgb(red: 248, green: 248, blue: 248)
            iconView15.layer.cornerRadius = iconView15.frame.height / 15
        }
    }
    @IBOutlet weak var iconView16: UIView! {
        didSet {
            iconView16.backgroundColor = UIColor.rgb(red: 248, green: 248, blue: 248)
            iconView16.layer.cornerRadius = iconView16.frame.height / 15
        }
    }
    @IBOutlet weak var iconView17: UIView! {
        didSet {
            iconView17.backgroundColor = UIColor.rgb(red: 248, green: 248, blue: 248)
            iconView17.layer.cornerRadius = iconView17.frame.height / 15
        }
    }
    @IBOutlet weak var iconView18: UIView! {
        didSet {
            iconView18.backgroundColor = UIColor.rgb(red: 248, green: 248, blue: 248)
            iconView18.layer.cornerRadius = iconView18.frame.height / 15
        }
    }
    @IBOutlet weak var iconView19: UIView! {
        didSet {
            iconView19.backgroundColor = UIColor.rgb(red: 248, green: 248, blue: 248)
            iconView19.layer.cornerRadius = iconView19.frame.height / 15
        }
    }
    @IBOutlet weak var iconView20: UIView! {
        didSet {
            iconView20.backgroundColor = UIColor.rgb(red: 248, green: 248, blue: 248)
            iconView20.layer.cornerRadius = iconView20.frame.height / 15
        }
    }
    @IBOutlet weak var iconView21: UIView! {
        didSet {
            iconView21.backgroundColor = UIColor.rgb(red: 248, green: 248, blue: 248)
            iconView21.layer.cornerRadius = iconView21.frame.height / 15
        }
    }
    @IBOutlet weak var iconView22: UIView! {
        didSet {
            iconView22.backgroundColor = UIColor.rgb(red: 248, green: 248, blue: 248)
            iconView22.layer.cornerRadius = iconView22.frame.height / 15
        }
    }
    @IBOutlet weak var iconView23: UIView! {
        didSet {
            iconView23.backgroundColor = UIColor.rgb(red: 248, green: 248, blue: 248)
            iconView23.layer.cornerRadius = iconView23.frame.height / 15
        }
    }
    @IBOutlet weak var iconView24: UIView! {
        didSet {
            iconView24.backgroundColor = UIColor.rgb(red: 248, green: 248, blue: 248)
            iconView24.layer.cornerRadius = iconView24.frame.height / 15
        }
    }
    @IBOutlet weak var iconView25: UIView! {
        didSet {
            iconView25.backgroundColor = UIColor.rgb(red: 248, green: 248, blue: 248)
            iconView25.layer.cornerRadius = iconView25.frame.height / 15
        }
    }
    @IBOutlet weak var iconView26: UIView! {
        didSet {
            iconView1.backgroundColor = UIColor.rgb(red: 248, green: 248, blue: 248)
            iconView1.layer.cornerRadius = iconView1.frame.height / 15
        }
    }
    @IBOutlet weak var iconView27: UIView! {
        didSet {
            iconView27.backgroundColor = UIColor.rgb(red: 248, green: 248, blue: 248)
            iconView27.layer.cornerRadius = iconView27.frame.height / 15
        }
    }
    @IBOutlet weak var iconView28: UIView! {
        didSet {
            iconView28.backgroundColor = UIColor.rgb(red: 248, green: 248, blue: 248)
            iconView28.layer.cornerRadius = iconView28.frame.height / 15
        }
    }
    @IBOutlet weak var iconView29: UIView! {
        didSet {
            iconView29.backgroundColor = UIColor.rgb(red: 248, green: 248, blue: 248)
            iconView29.layer.cornerRadius = iconView29.frame.height / 15
        }
    }
    @IBOutlet weak var iconView30: UIView! {
        didSet {
            iconView30.backgroundColor = UIColor.rgb(red: 248, green: 248, blue: 248)
            iconView30.layer.cornerRadius = iconView30.frame.height / 15
        }
    }
    @IBOutlet weak var iconView31: UIView! {
        didSet {
            iconView31.backgroundColor = UIColor.rgb(red: 248, green: 248, blue: 248)
            iconView31.layer.cornerRadius = iconView31.frame.height / 15
        }
    }
    @IBOutlet weak var iconView32: UIView! {
        didSet {
            iconView32.backgroundColor = UIColor.rgb(red: 248, green: 248, blue: 248)
            iconView32.layer.cornerRadius = iconView32.frame.height / 15
        }
    }
    @IBOutlet weak var iconView33: UIView! {
        didSet {
            iconView33.backgroundColor = UIColor.rgb(red: 248, green: 248, blue: 248)
            iconView33.layer.cornerRadius = iconView33.frame.height / 15
        }
    }
    @IBOutlet weak var iconView34: UIView! {
        didSet {
            iconView34.backgroundColor = UIColor.rgb(red: 248, green: 248, blue: 248)
            iconView34.layer.cornerRadius = iconView34.frame.height / 15
        }
    }
    @IBOutlet weak var iconView35: UIView! {
        didSet {
            iconView35.backgroundColor = UIColor.rgb(red: 248, green: 248, blue: 248)
            iconView35.layer.cornerRadius = iconView35.frame.height / 15
        }
    }
    @IBOutlet weak var iconView36: UIView! {
        didSet {
            iconView36.backgroundColor = UIColor.rgb(red: 248, green: 248, blue: 248)
            iconView36.layer.cornerRadius = iconView36.frame.height / 15
        }
    }
    @IBOutlet weak var iconView37: UIView! {
        didSet {
            iconView37.backgroundColor = UIColor.rgb(red: 248, green: 248, blue: 248)
            iconView37.layer.cornerRadius = iconView37.frame.height / 15
        }
    }
    @IBOutlet weak var iconView38: UIView! {
        didSet {
            iconView38.backgroundColor = UIColor.rgb(red: 248, green: 248, blue: 248)
            iconView38.layer.cornerRadius = iconView38.frame.height / 15
        }
    }
    @IBOutlet weak var button1: UIButton!
    @IBOutlet weak var button2: UIButton!
    @IBOutlet weak var button3: UIButton!
    @IBOutlet weak var button4: UIButton!
    @IBOutlet weak var button5: UIButton!
    @IBOutlet weak var button6: UIButton!
    @IBOutlet weak var button7: UIButton!
    @IBOutlet weak var button8: UIButton!
    @IBOutlet weak var button9: UIButton!
    @IBOutlet weak var button10: UIButton!
    @IBOutlet weak var button11: UIButton!
    @IBOutlet weak var button12: UIButton!
    @IBOutlet weak var button13: UIButton!
    @IBOutlet weak var button14: UIButton!
    @IBOutlet weak var button15: UIButton!
    @IBOutlet weak var button16: UIButton!
    @IBOutlet weak var button17: UIButton!
    @IBOutlet weak var button18: UIButton!
    @IBOutlet weak var button19: UIButton!
    @IBOutlet weak var button20: UIButton!
    @IBOutlet weak var button21: UIButton!
    @IBOutlet weak var button22: UIButton!
    @IBOutlet weak var button23: UIButton!
    @IBOutlet weak var button24: UIButton!
    @IBOutlet weak var button25: UIButton!
    @IBOutlet weak var button26: UIButton!
    @IBOutlet weak var button27: UIButton!
    @IBOutlet weak var button28: UIButton!
    @IBOutlet weak var button29: UIButton!
    @IBOutlet weak var button30: UIButton!
    @IBOutlet weak var button31: UIButton!
    @IBOutlet weak var button32: UIButton!
    @IBOutlet weak var button33: UIButton!
    @IBOutlet weak var button34: UIButton!
    @IBOutlet weak var button35: UIButton!
    @IBOutlet weak var button36: UIButton!
    @IBOutlet weak var button37: UIButton!
    @IBOutlet weak var button38: UIButton!
    
    @IBOutlet weak var next1: UIImageView!
    @IBOutlet weak var next2: UIImageView!
    @IBOutlet weak var next3: UIImageView!
    @IBOutlet weak var next4: UIImageView!
    @IBOutlet weak var next5: UIImageView!
    @IBOutlet weak var next6: UIImageView!
    @IBOutlet weak var next7: UIImageView!
    @IBOutlet weak var next8: UIImageView!
    @IBOutlet weak var next9: UIImageView!
    @IBOutlet weak var next10: UIImageView!
    @IBOutlet weak var next11: UIImageView!
    @IBOutlet weak var next12: UIImageView!
    @IBOutlet weak var next13: UIImageView!
    @IBOutlet weak var next14: UIImageView!
    @IBOutlet weak var next15: UIImageView!
    @IBOutlet weak var next16: UIImageView!
    @IBOutlet weak var next17: UIImageView!
    @IBOutlet weak var next18: UIImageView!
    @IBOutlet weak var next19: UIImageView!
    @IBOutlet weak var next20: UIImageView!
    @IBOutlet weak var next21: UIImageView!
    @IBOutlet weak var next22: UIImageView!
    @IBOutlet weak var next23: UIImageView!
    @IBOutlet weak var next24: UIImageView!
    @IBOutlet weak var next25: UIImageView!
    @IBOutlet weak var next26: UIImageView!
    @IBOutlet weak var next27: UIImageView!
    @IBOutlet weak var next28: UIImageView!
    @IBOutlet weak var next29: UIImageView!
    @IBOutlet weak var next30: UIImageView!
    @IBOutlet weak var next31: UIImageView!
    @IBOutlet weak var next32: UIImageView!
    @IBOutlet weak var next33: UIImageView!
    @IBOutlet weak var next34: UIImageView!
    @IBOutlet weak var next35: UIImageView!
    @IBOutlet weak var next36: UIImageView!
    @IBOutlet weak var next37: UIImageView!
    @IBOutlet weak var next38: UIImageView!
    
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
        
        let iconRef6 = Storage.storage().reference().child("category").child("image6" + ".jpg")
        self.image6.sd_setImage(with: iconRef6)
        let iconRef7 = Storage.storage().reference().child("category").child("image7" + ".jpg")
        self.image7.sd_setImage(with: iconRef7)
        let iconRef8 = Storage.storage().reference().child("category").child("image8" + ".jpg")
        self.image8.sd_setImage(with: iconRef8)
        let iconRef9 = Storage.storage().reference().child("category").child("image9" + ".jpg")
        self.image9.sd_setImage(with: iconRef9)
        let iconRef10 = Storage.storage().reference().child("category").child("image10" + ".jpg")
        self.image10.sd_setImage(with: iconRef10)
        
        let iconRef11 = Storage.storage().reference().child("category").child("image11" + ".jpg")
        self.image11.sd_setImage(with: iconRef11)
        let iconRef12 = Storage.storage().reference().child("category").child("image12" + ".jpg")
        self.image12.sd_setImage(with: iconRef12)
        let iconRef13 = Storage.storage().reference().child("category").child("image13" + ".jpg")
        self.image13.sd_setImage(with: iconRef13)
        let iconRef14 = Storage.storage().reference().child("category").child("image14" + ".jpg")
        self.image14.sd_setImage(with: iconRef14)
        let iconRef15 = Storage.storage().reference().child("category").child("image15" + ".jpg")
        self.image15.sd_setImage(with: iconRef15)
        
        let iconRef16 = Storage.storage().reference().child("category").child("image16" + ".jpg")
        self.image16.sd_setImage(with: iconRef16)
        let iconRef17 = Storage.storage().reference().child("category").child("image17" + ".jpg")
        self.image17.sd_setImage(with: iconRef17)
        let iconRef18 = Storage.storage().reference().child("category").child("image18" + ".jpg")
        self.image18.sd_setImage(with: iconRef18)
        let iconRef19 = Storage.storage().reference().child("category").child("image19" + ".jpg")
        self.image19.sd_setImage(with: iconRef19)
        let iconRef20 = Storage.storage().reference().child("category").child("image20" + ".jpg")
        self.image20.sd_setImage(with: iconRef20)
        
        let iconRef21 = Storage.storage().reference().child("category").child("image21" + ".jpg")
        self.image21.sd_setImage(with: iconRef21)
        let iconRef22 = Storage.storage().reference().child("category").child("image22" + ".jpg")
        self.image22.sd_setImage(with: iconRef22)
        let iconRef23 = Storage.storage().reference().child("category").child("image23" + ".jpg")
        self.image23.sd_setImage(with: iconRef23)
        let iconRef24 = Storage.storage().reference().child("category").child("image24" + ".jpg")
        self.image24.sd_setImage(with: iconRef24)
        let iconRef25 = Storage.storage().reference().child("category").child("image25" + ".jpg")
        self.image25.sd_setImage(with: iconRef25)
        
        let iconRef26 = Storage.storage().reference().child("category").child("image26" + ".jpg")
        self.image26.sd_setImage(with: iconRef26)
        let iconRef27 = Storage.storage().reference().child("category").child("image27" + ".jpg")
        self.image27.sd_setImage(with: iconRef27)
        let iconRef28 = Storage.storage().reference().child("category").child("image28" + ".jpg")
        self.image28.sd_setImage(with: iconRef28)
        let iconRef29 = Storage.storage().reference().child("category").child("image29" + ".jpg")
        self.image29.sd_setImage(with: iconRef29)
        let iconRef30 = Storage.storage().reference().child("category").child("image30" + ".jpg")
        self.image30.sd_setImage(with: iconRef30)
        
        let iconRef31 = Storage.storage().reference().child("category").child("image31" + ".jpg")
        self.image31.sd_setImage(with: iconRef31)
        let iconRef32 = Storage.storage().reference().child("category").child("image32" + ".jpg")
        self.image32.sd_setImage(with: iconRef32)
        let iconRef33 = Storage.storage().reference().child("category").child("image33" + ".jpg")
        self.image33.sd_setImage(with: iconRef33)
        let iconRef34 = Storage.storage().reference().child("category").child("image34" + ".jpg")
        self.image34.sd_setImage(with: iconRef34)
        let iconRef35 = Storage.storage().reference().child("category").child("image35" + ".jpg")
        self.image35.sd_setImage(with: iconRef35)
        let iconRef36 = Storage.storage().reference().child("category").child("image36" + ".jpg")
        self.image36.sd_setImage(with: iconRef36)
        let iconRef37 = Storage.storage().reference().child("category").child("image37" + ".jpg")
        self.image37.sd_setImage(with: iconRef37)
        let iconRef38 = Storage.storage().reference().child("category").child("image38" + ".jpg")
        self.image38.sd_setImage(with: iconRef38)
        
        
    }
    
}
