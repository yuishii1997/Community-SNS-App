//
//  PrivacyTableViewCell.swift
//  Nomad-App
//
//  Created by yuishii on 2021/02/11.
//  Copyright © 2021 Yu Ishii. All rights reserved.
//
// 「設定」の「プライバシー」部分のセル

import UIKit
import Firebase

class PrivacyTableViewCell: UITableViewCell {
    
    var userdata: UserData?
    
    @IBOutlet weak var button1: UIButton!
    
    @IBOutlet weak var switch1: UISwitch!
    
    @IBAction func switch1(sender: UISwitch) {
        
        if ( sender.isOn ) {
            let ref = Firestore.firestore().collection("users").document(self.userdata!.id)
            ref.updateData(["bePrivate": "on"])
        } else {
            let ref = Firestore.firestore().collection("users").document(self.userdata!.id)
            ref.updateData(["bePrivate": "off"])
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        if self.userdata?.bePrivate == "on" {
            self.switch1.isOn = true
            self.switch1.onTintColor = UIColor.rgb(red: 74, green: 162, blue: 235)
        }else{
            self.switch1.isOn = false
        }
        
    }
    
}
