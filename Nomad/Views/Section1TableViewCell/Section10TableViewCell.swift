//
//  Section10TableViewCell.swift
//  Nomad-App
//
//  Created by yuishii on 2021/01/17.
//  Copyright © 2021 Yu Ishii. All rights reserved.
//
// CategoryViewControllerで「週間ランキング」と表示するセル

import UIKit
import Firebase

class Section10TableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var toMyProfileButton: UIButton!
    
    @IBOutlet weak var toMyHistoryButton: UIButton!
    
    @IBOutlet weak var toMyPostsButton: UIButton!
    
    @IBOutlet weak var toMyBookmarkButton: UIButton!
    
    @IBOutlet weak var toMySettingsButton: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
