//
//  Post10TableViewCell.swift
//  Nomad-App
//
//  Created by yuishii on 2021/02/01.
//  Copyright © 2021 Yu Ishii. All rights reserved.
//
// MyNomadViewControllerの閲覧した画像ありのスレッドのセル

import UIKit
import FirebaseUI
import Firebase
import LBTAComponents
import SDWebImage

class Post10TableViewCell: UITableViewCell {
    
    var postdata: PostData?
    var message: Message?
    
    @IBOutlet weak var postImageView: UIImageView!{
        didSet {
            postImageView.layer.cornerRadius = postImageView.frame.height / 15
        }
    }
    @IBOutlet weak var captionLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var postView: UIView!{
        didSet {
            postView.layer.cornerRadius = postView.frame.height / 8
            postView.backgroundColor = UIColor.rgb(red: 229, green: 229, blue: 229)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    
    // PostDataの内容をセルに表示
    func setPostData(_ postData: PostData) {
        
        if Auth.auth().currentUser != nil {
            
            let userRef = Firestore.firestore().collection("users").document(postData.uid)
            userRef.getDocument{ (document, error) in
                if let document = document{
                    
                    let data = document.data()
                    let name = data!["name"] as! String
                    print("name:\(name)")
                    self.nameLabel.text = "\(name)"
                }
            }
            
            // 画像の表示
            let imageRef = Storage.storage().reference().child("images").child(postData.id + ".jpg")
            postImageView.sd_setImage(with: imageRef)
            
            if postData.caption != nil{
                //PostDataの投稿データをセルに表示
                // キャプションの表示
                self.captionLabel.text = "\(postData.caption!)"
            }
        }
    }
}
