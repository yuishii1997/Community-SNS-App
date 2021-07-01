//
//  SettingsSectionTableViewCell.swift
//  Nomad-App
//
//  Created by yuishii on 2021/02/18.
//  Copyright © 2021 Yu Ishii. All rights reserved.
//
//「設定」のセクション名

import UIKit

class SettingsSectionTableViewCell: UITableViewCell {
    
    @IBOutlet weak var sectionTitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
