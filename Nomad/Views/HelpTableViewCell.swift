//
//  HelpTableViewCell.swift
//  Nomad-App
//
//  Created by yuishii on 2021/02/19.
//  Copyright © 2021 Yu Ishii. All rights reserved.
//
//「設定」のヘルプデータ

import UIKit

class HelpTableViewCell: UITableViewCell {
    
    @IBOutlet weak var button1: UIButton!
    @IBOutlet weak var button2: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
