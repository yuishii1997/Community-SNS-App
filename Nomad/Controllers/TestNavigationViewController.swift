//
//  TestNavigationViewController.swift
//  Nomad-App
//
//  Created by yuishii on 2020/12/09.
//  Copyright © 2020 Yu Ishii. All rights reserved.
//

import UIKit
class TestNavigationViewController: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    override var childForStatusBarStyle: UIViewController? {
        return self.visibleViewController
    }
    override var childForStatusBarHidden: UIViewController? {
        return self.visibleViewController
    }
}
