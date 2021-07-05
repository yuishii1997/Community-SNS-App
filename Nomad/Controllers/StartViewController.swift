//
//  StartViewController.swift
//  Nomad-App
//
//  Created by yuishii on 2020/11/15.
//  Copyright © 2020 Yu Ishii. All rights reserved.
//
// アプリ起動直後ログインと新規登録選択画面

import UIKit
import Firebase
import GoogleMobileAds
import Foundation
import AppTrackingTransparency
import AdSupport

class StartViewController: UIViewController {
    
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!
    
    var window: UIWindow?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.barTintColor = .white
        self.navigationController?.navigationBar.tintColor = UIColor.white
        
        signInButton.layer.borderWidth = 1.0 // 枠線の幅
        signInButton.layer.borderColor = UIColor.systemGray3.cgColor // 枠線の色
        signInButton.layer.cornerRadius = 22
        
        signupButton.layer.borderWidth = 1.0 // 枠線の幅
        signupButton.layer.borderColor = UIColor.systemGray3.cgColor // 枠線の色
        signupButton.layer.cornerRadius = 22
        
        if #available(iOS 14, *) {
            switch ATTrackingManager.trackingAuthorizationStatus {
            case .authorized:
                print("Allow Tracking")
                print("IDFA: \(ASIdentifierManager.shared().advertisingIdentifier)")
            case .denied:
                print("😭拒否")
            case .restricted:
                print("🥺制限")
            case .notDetermined:
                showRequestTrackingAuthorizationAlert()
            @unknown default:
                fatalError()
            }
        } else {// iOS14未満
            if ASIdentifierManager.shared().isAdvertisingTrackingEnabled {
                print("Allow Tracking")
                print("IDFA: \(ASIdentifierManager.shared().advertisingIdentifier)")
            } else {
                print("🥺制限")
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        let backBarButtonItem = UIBarButtonItem()
        backBarButtonItem.title = "Back"
        self.navigationItem.backBarButtonItem = backBarButtonItem
        self.navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    ///Alert表示
    private func showRequestTrackingAuthorizationAlert() {
        if #available(iOS 14, *) {
            ATTrackingManager.requestTrackingAuthorization(completionHandler: { status in
                switch status {
                case .authorized:
                    print("🎉")
                    //IDFA取得
                    print("IDFA: \(ASIdentifierManager.shared().advertisingIdentifier)")
                case .denied, .restricted, .notDetermined:
                    print("😭")
                @unknown default:
                    fatalError()
                }
            })
        }
    }
}
