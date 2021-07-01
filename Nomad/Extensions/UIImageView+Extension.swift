//
//  UIImageView+Extension.swift
//  Nomad-App
//
//  Created by Yu Ishii on 2020/08/14.
//  Copyright © 2020 Yu Ishii. All rights reserved.
//

import UIKit

extension UIImageView {
    func circle() {
        layer.masksToBounds = false
        layer.cornerRadius = frame.width/2
        clipsToBounds = true
    }
}
