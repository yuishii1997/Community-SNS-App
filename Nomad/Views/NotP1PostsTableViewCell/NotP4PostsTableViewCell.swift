//
//  NotP4PostsTableViewCell.swift
//  Nomad-App
//
//  Created by yuishii on 2021/01/09.
//  Copyright © 2021 Yu Ishii. All rights reserved.
//
// Page4ViewController,Page4ComViewControllerで何も投稿がない場合に表示するセル

import UIKit

class NotP4PostsTableViewCell: UITableViewCell {
    
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
