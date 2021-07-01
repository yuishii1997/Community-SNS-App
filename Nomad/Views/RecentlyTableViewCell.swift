//
//  RecentlyTableViewCell.swift
//  Nomad-App
//
//  Created by yuishii on 2021/02/08.
//  Copyright © 2021 Yu Ishii. All rights reserved.
//
// Search2ViewControllerで「最近」と表示するセル

import UIKit

class RecentlyTableViewCell: UITableViewCell {
    
    @IBOutlet weak var recentlyButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
