//
//  MyCollectionViewCell11.swift
//  Nomad-App
//
//  Created by yuishii on 2021/01/28.
//  Copyright © 2021 Yu Ishii. All rights reserved.
//

import UIKit
import Firebase

class MyCollectionViewCell11: UICollectionViewCell {
    
    
    @IBOutlet weak var placeHolederImage: UIImageView!
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var captionLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var postView: UIView!{
        didSet {
            postView.backgroundColor = UIColor.rgb(red: 198, green: 205, blue: 224)
        }
    }
    @IBOutlet weak var viewerLabel: UILabel!
    @IBOutlet weak var noImageLabel: UILabel!
    
    @IBOutlet weak var noImageLabel2: UILabel!
    
    static let identifier = "MyCollectionViewCell11"
    
    static func nib() -> UINib {
        return UINib(nibName: "MyCollectionViewCell11", bundle: nil)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        postImageView.image = nil
        noImageLabel.text = ""
        noImageLabel2.text = ""
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor(red: 233/255, green: 234/255, blue: 236/255, alpha: 1.0).cgColor
        self.layer.cornerRadius = self.frame.height / 20
        
    }
    
    
    public func configure11(with model: PostData) {
        
        
        let userRef = Firestore.firestore().collection("users").document(model.uid)
        userRef.getDocument{ (document, error) in
            if let document = document{
                
                let data = document.data()
                let name = data!["name"] as! String
                print("name:\(name)")
                self.nameLabel.text = "\(name)"
            }
        }
        
        // 画像の表示
        let imageRef = Storage.storage().reference().child("images").child(model.id + ".jpg")
        
        if model.with_image != false {
            //placeHolederImage.isHidden = true
            noImageLabel.isHidden = true
            noImageLabel2.isHidden = true
            postImageView.sd_setImage(with: imageRef)
        }else{
            noImageLabel.isHidden = false
            noImageLabel2.isHidden = false
            //placeHolederImage.isHidden = false
            noImageLabel.text = "NO"
            noImageLabel2.text = "IMAGE"
        }
        
        
        if model.caption != nil{
            let captionArray = model.caption!.components(separatedBy: "\n")
            let convertedCaption = captionArray.reduce("") {
                if $0.isEmpty {
                    if $1.isEmpty {
                        return $0
                    } else {
                        return $1
                    }
                } else {
                    if $1.isEmpty {
                        return $0
                    } else {
                        return $0 + " " + $1
                    }
                }
            }
            self.captionLabel.text = convertedCaption
        }
        
        // コメント数の表示
        let comments = model.allComments
        let commentNumber = comments.count
        let commentText = "コメント\(commentNumber.shorted())件"
        viewerLabel.text = commentText
    }
    
}
