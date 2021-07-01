//
//  NotPost2TableViewCell.swift
//  Nomad-App
//
//  Created by yuishii on 2021/02/24.
//  Copyright © 2021 Yu Ishii. All rights reserved.
//
// 投稿がない場合に"まだ投稿をしていません 投稿をするとここに表示されます。"と表示する画面

import UIKit

class NotPost2TableViewCell: UITableViewCell {
    
    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var label2: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
