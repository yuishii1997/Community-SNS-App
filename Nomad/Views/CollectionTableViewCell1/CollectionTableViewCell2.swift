//
//  CollectionTableViewCell2.swift
//  Nomad-App
//
//  Created by yuishii on 2021/01/28.
//  Copyright © 2021 Yu Ishii. All rights reserved.
//

import UIKit
import Firebase

public protocol CollectionTableViewCell2Delegate: class {
    func onCollectoinViewCell2DidSelect(tag: Int, indexPath: IndexPath)
}
class CollectionTableViewCell2: UITableViewCell,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    public weak var cell2Delegate: CollectionTableViewCell2Delegate?
    
    static let identifier = "CollectionTableViewCell2"
    
    static func nib() -> UINib {
        return UINib(nibName: "CollectionTableViewCell2", bundle: nil)
    }
    
    //ユーザーデータを格納する配列
    var userArray2: [UserData] = []
    
    func configure2(with models: [UserData]) {
        self.userArray2 = models
        collectionView.reloadData()
    }
    
    @IBOutlet weak var collectionViewFlowLayout: UICollectionViewFlowLayout!
    @IBOutlet var collectionView: UICollectionView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        collectionView.register(MyCollectionViewCell2.nib(), forCellWithReuseIdentifier: MyCollectionViewCell2.identifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        
        //collectionViewFlowLayout.itemSize = CGSize(width: 1000, height: 150)
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 167, height: 167)
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
        
        if collectionView.tag == 2 {
            self.cell2Delegate?.onCollectoinViewCell2DidSelect(tag: 2, indexPath: indexPath)
        }
    }
    
    //横に何列か
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        
        
        if userArray2.count >= 5 {
            return 5
        }else{
            return userArray2.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MyCollectionViewCell2.identifier, for: indexPath) as! MyCollectionViewCell2
        
        
        cell.configure2(with: userArray2[indexPath.row])
        return cell
        
    }
    
    //ここでCollectionViewCellの縦と横のサイズを決定
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 167, height: 167)
    }
    
}
