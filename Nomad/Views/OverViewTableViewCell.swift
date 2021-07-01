//
//  OverViewTableViewCell.swift
//  Nomad-App
//
//  Created by yuishii on 2021/01/09.
//  Copyright © 2021 Yu Ishii. All rights reserved.
//
// Page6ViewController、Page6ComViewControllerで「概要」と表示するセル

import UIKit
import Firebase

class OverViewTableViewCell: UITableViewCell {
    
    var userdata: UserData?
    
    @IBOutlet weak var overViewLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        print("OverViewTableViewCell表示")
        
        let overView = userdata?.overView
        
        if overView != nil {
            self.overViewLabel.text = overView
            
        }
    }
}
