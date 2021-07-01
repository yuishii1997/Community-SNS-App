//
//  AccountTableViewCell.swift
//  Nomad-App
//
//  Created by yuishii on 2021/02/11.
//  Copyright © 2021 Yu Ishii. All rights reserved.
//
// 「設定」の「アカウント」部分のセル

import UIKit

class AccountTableViewCell: UITableViewCell {
    
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
        
        // Configure the view for the selected state
    }
    
}
