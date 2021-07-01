//
//  ChatRoomTableViewCell2.swift
//  Nomad-App
//
//  Created by yuishii on 2021/02/17.
//  Copyright © 2021 Yu Ishii. All rights reserved.
//
// ChatRoomViewControllerのコメント(返信)のセル

import UIKit
import Firebase
import LBTAComponents

class ChatRoomTableViewCell2: UITableViewCell {
    
    var postdata: PostData?
    
    var lineIndex = 1
    
    var message: Message?
    
    @IBOutlet weak var didSelectButton: UIButton!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var alertButton: UIButton!
    @IBOutlet weak var nameButton: UIButton!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var likeLabel: UILabel!
    @IBOutlet weak var iconView: UIView! {
        didSet {
            iconView.backgroundColor = UIColor.rgb(red: 248, green: 248, blue: 248)
            iconView.layer.cornerRadius = iconView.frame.height / 2
        }
    }
    
    @IBOutlet weak var iconImageView: UIImageView!{
        didSet {
            iconImageView.contentMode = .scaleToFill
            iconImageView.clipsToBounds = true
            iconImageView.layer.cornerRadius = iconImageView.frame.height / 2
        }
    }
    
    @IBOutlet weak var iconImageView2: UIImageView! {
        didSet {
            iconImageView2.contentMode = .scaleToFill
            iconImageView2.clipsToBounds = true
            iconImageView2.layer.cornerRadius = iconImageView2.frame.height / 2
        }
    }
    
    @IBOutlet weak var iconButton: UIButton! {
        didSet {
            iconButton.layer.cornerRadius = iconButton.frame.height / 2
        }
    }
    
    @IBOutlet weak var replyNameLabel: UILabel!
    @IBOutlet weak var replyButton: UIButton!
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    func setMessageData(_ messageData: Message) {
        
        
        if Auth.auth().currentUser != nil {
            
            messageLabel.text = messageData.message
            
            print("messageData.reply:\(messageData.reply)")
            
            let replyRef = Firestore.firestore().collection("users").document(messageData.replyName)
            replyRef.getDocument{ (document, error) in
                if let document = document{
                    
                    let data = document.data()
                    if data != nil {
                        let name = data!["name"] as! String
                        print("name:\(name)")
                        self.replyNameLabel.text = "\(name)さん"
                    }
                }
            }
            
            let userRef = Firestore.firestore().collection("users").document(messageData.uid)
            userRef.getDocument{ (document, error) in
                if let document = document{
                    
                    self.iconImageView.image = nil
                    self.iconImageView2.image = nil
                    
                    let data = document.data()
                    let name = data!["name"] as! String
                    print("name:\(name)")
                    
                    
                    let date = messageData.date.readableDate(start: messageData.date, end: Date())
                    if date == "・0秒" {
                        print("7日未満")
                        
                        let dateText = "・今"
                        self.nameLabel.text = "\(name)"
                        self.dateLabel.text = "\(dateText)"
                    } else if date == "・7日以上" {
                        // 日時の表示
                        print("7日以上")
                        
                        let formatter = DateFormatter()
                        formatter.dateFormat = "yyyy/MM/dd"
                        let dateString = formatter.string(from: messageData.date)
                        let dateText = "・" + dateString
                        self.nameLabel.text = "\(name)"
                        self.dateLabel.text = "\(dateText)"
                        
                    }else{
                        self.nameLabel.text = "\(name)"
                        self.dateLabel.text = "\(date)"
                    }
                    
                    
                    let with_iconImage = data!["with_iconImage"] as! String
                    let imageNo = data!["imageNo"] as! Int
                    let imageNoString: String = "\(imageNo)"
                    
                    let iconRef = Storage.storage().reference().child("iconImages").child(messageData.uid + imageNoString + ".jpg")
                    if with_iconImage == "exist" {
                        print("exist")
                        self.iconImageView2.sd_setImage(with: iconRef)
                    }else{
                        print("notExist")
                        //self.iconView.isHidden = true
                        self.iconImageView.image = UIImage(named: "icons8-男性ユーザ-80")
                    }
                }
            }
            
            
            if postdata?.uid == messageData.uid{
                //コメントを紫色にする
                messageLabel.textColor = UIColor.rgb(red: 102, green: 0, blue: 153)
            }else{
                messageLabel.textColor = UIColor.black
            }
            
            // いいね数の表示
            let likes = messageData.likes
            let likeNumber = likes.count
            likeLabel.text = "\(likeNumber.shorted())"
            
            // いいねボタンの表示
            if messageData.isLiked {
                let buttonImage = UIImage(named: "icons8-ハート-50-2")
                self.likeButton.setImage(buttonImage, for: .normal)
            } else {
                let buttonImage = UIImage(named: "icons8-ハート-50-5")
                self.likeButton.setImage(buttonImage, for: .normal)
            }
            
            
            //ChatRoomViewControllerでブロックしているユーザーの配列の中にself.messageが含まれていたらその投稿のキャプションは"このコメントは非表示になっています"にしており、その投稿のフォントは変更する。
            //92行目、96行目のテキストと統一することに注意
            if messageData.isReported2 == true && self.messageLabel.text == "[このコメントは削除されました]" {
                messageLabel.textColor = .gray
                messageLabel.font = UIFont.systemFont(ofSize: 16)
            }else if messageData.isReported2 == true && self.messageLabel.text == "[このコメントは非表示になっています]" {
                messageLabel.textColor = .gray
                messageLabel.font = UIFont.systemFont(ofSize: 16)
            }
            
            //68行目のテキストと統一することに注意
            if messageData.isReported2 == true {
                messageLabel.text = "[このコメントは削除されました]"
                messageLabel.textColor = .gray
                messageLabel.font = UIFont.systemFont(ofSize: 16)
            } else if messageData.isReported3 == true {
                messageLabel.text = "[このコメントは非表示になっています]"
                messageLabel.textColor = .gray
                messageLabel.font = UIFont.systemFont(ofSize: 16)
            }
        }
    }
    
    //日付の表示を設定する
    private func dateFormatterDateLabel(date: Date) -> String{
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "ja_Jp")
        return formatter.string(from: date)
    }
}

