//
//  NotPostTableViewCell.swift
//  Nomad-App
//
//  Created by yuishii on 2021/02/20.
//  Copyright © 2021 Yu Ishii. All rights reserved.
//
// ユーザーとコミュニティがまだ作成されていないときに表示するセル

import UIKit

class NotPostTableViewCell: UITableViewCell {
    
    @IBOutlet weak var label: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
