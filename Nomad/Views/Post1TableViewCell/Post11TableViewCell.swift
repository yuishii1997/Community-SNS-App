//
//  Post11TableViewCell.swift
//  Nomad-App
//
//  Created by yuishii on 2021/02/02.
//  Copyright © 2021 Yu Ishii. All rights reserved.
//
// MyNomadViewControllerで閲覧したスレッドがない場合に表示するセル

import UIKit

class Post11TableViewCell: UITableViewCell {
    
    @IBOutlet weak var postView: UIView!{
        didSet {
            postView.layer.cornerRadius = postView.frame.height / 8
            postView.backgroundColor = UIColor.rgb(red: 229, green: 229, blue: 229)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
