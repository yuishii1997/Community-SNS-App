//
//  CustomTableViewCell.swift
//  Nomad-App
//
//  Created by yuishii on 2020/11/27.
//  Copyright © 2020 Yu Ishii. All rights reserved.
//
// 新規作成ボタンを押した時に下から表示されるメニュー

import UIKit

class CustomTableViewCell: UITableViewCell {
    
    @IBOutlet weak var circle1: UIView!
    @IBOutlet weak var circle2: UIView!
    //左のアカウントボタン
    @IBOutlet weak var postButton1: UIButton!
    //右のコミュニティボタン
    @IBOutlet weak var postButton2: UIButton!
    //バツボタン
    @IBOutlet weak var closeButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        circle1.backgroundColor = .white
        circle1.layer.cornerRadius = 27.5
        circle1.layer.borderColor = UIColor.white.cgColor
        circle2.backgroundColor = .white
        circle2.layer.cornerRadius = 27.5
        circle2.layer.borderColor = UIColor.white.cgColor
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    
}
