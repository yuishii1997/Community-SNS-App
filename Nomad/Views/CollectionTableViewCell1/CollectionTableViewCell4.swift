//
//  CollectionTableViewCell4.swift
//  Nomad-App
//
//  Created by yuishii on 2021/01/28.
//  Copyright © 2021 Yu Ishii. All rights reserved.
//

import UIKit
import Firebase

public protocol CollectionTableViewCell4Delegate: class {
    func onCollectoinViewCell4DidSelect(tag: Int, indexPath: IndexPath)
}
class CollectionTableViewCell4: UITableViewCell,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    public weak var cell4Delegate: CollectionTableViewCell4Delegate?
    
    static let identifier = "CollectionTableViewCell4"
    
    static func nib() -> UINib {
        return UINib(nibName: "CollectionTableViewCell4", bundle: nil)
    }
    
    //ユーザーデータを格納する配列
    var postArray2: [PostData] = []
    
    private var postdata: PostData?
    
    func configure4(with models: [PostData]) {
        self.postArray2 = models
        collectionView.reloadData()
    }
    
    @IBOutlet weak var collectionViewFlowLayout: UICollectionViewFlowLayout!
    @IBOutlet var collectionView: UICollectionView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        collectionView.register(MyCollectionViewCell4.nib(), forCellWithReuseIdentifier: MyCollectionViewCell4.identifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        
        //collectionViewFlowLayout.itemSize = CGSize(width: 1000, height: 150)
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 320, height: 200)
        collectionView.collectionViewLayout = layout
        
        layout.scrollDirection = .horizontal // 横スクロール
        collectionView.collectionViewLayout = layout
        
        //これで左端に余白開ける
        layout.sectionInset = UIEdgeInsets(top: 0, left: 15, bottom: 10, right: 15)
        collectionView.collectionViewLayout = layout
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if collectionView.tag == 4 {
            self.cell4Delegate?.onCollectoinViewCell4DidSelect(tag: 4, indexPath: indexPath)
            
            postdata = self.postArray2[indexPath.row]
            
            print("postdata!.caption! \(indexPath.row):\(postdata!.caption!)")
            print("postdata!.id \(indexPath.row):\(postdata!.id)")
            print("postdata!.viewedTime \(indexPath.row):\(postdata!.viewedTime)")
            
            if Auth.auth().currentUser != nil {
                // viewerを更新する
                let myid = Auth.auth().currentUser!.uid
                
                print("myid \(indexPath.row):\(myid)")
                
                // 更新データを作成する
                var updateValue: FieldValue
                var updateValue2: FieldValue
                
                if postdata!.viewed {
                    print("古いmyidを消して新しいmyidを加えます")
                    //再度新しい日付でmyidを加えるために一度古い日付で登録したmyidを消す
                    updateValue = FieldValue.arrayRemove([["uid": myid, "time": postdata!.viewedTime]])
                    updateValue2 = FieldValue.arrayUnion([["uid": myid, "time": Date.timeIntervalSinceReferenceDate]])
                    let postRef = Firestore.firestore().collection("posts").document(self.postdata!.id)
                    postRef.updateData(["viewer": updateValue])
                    postRef.updateData(["viewer": updateValue2])
                } else{
                    print("新しいmyidを加えます")
                    updateValue = FieldValue.arrayUnion([["uid": myid, "time": Date.timeIntervalSinceReferenceDate]])
                    let postRef = Firestore.firestore().collection("posts").document(self.postdata!.id)
                    postRef.updateData(["viewer": updateValue])
                }
            }
        }
    }
    
    //横に何列か
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        
        
        if postArray2.count >= 5 {
            return 5
        }else{
            return postArray2.count
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MyCollectionViewCell4.identifier, for: indexPath) as! MyCollectionViewCell4
        
        
        cell.configure4(with: postArray2[indexPath.row])
        return cell
        
    }
    
    //ここでCollectionViewCellの縦と横のサイズを決定
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 320, height: 200)
    }
    
}
