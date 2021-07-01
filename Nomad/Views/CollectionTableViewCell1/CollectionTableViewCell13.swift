//
//  CollectionTableViewCell13.swift
//  Nomad-App
//
//  Created by yuishii on 2021/01/31.
//  Copyright © 2021 Yu Ishii. All rights reserved.
//

import UIKit
import Firebase

public protocol CollectionTableViewCell13Delegate: class {
    func onCollectoinViewCell13DidSelect(tag: Int, indexPath: IndexPath)
}
class CollectionTableViewCell13: UITableViewCell,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    public weak var cell13Delegate: CollectionTableViewCell13Delegate?
    
    static let identifier = "CollectionTableViewCell13"
    
    static func nib() -> UINib {
        return UINib(nibName: "CollectionTableViewCell13", bundle: nil)
    }
    
    //ユーザーデータを格納する配列
    var modifiedPostArray: [PostData] = []
    
    func configure13(with models: [PostData]) {
        self.modifiedPostArray = models
        collectionView.reloadData()
    }
    
    
    @IBOutlet weak var collectionViewFlowLayout: UICollectionViewFlowLayout!
    @IBOutlet var collectionView: UICollectionView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        collectionView.register(MyCollectionViewCell13.nib(), forCellWithReuseIdentifier: MyCollectionViewCell13.identifier)
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
        collectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        self.cell13Delegate?.onCollectoinViewCell13DidSelect(tag: 13, indexPath: indexPath)
        
    }
    
    //横に何列か
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if modifiedPostArray.count >= 5 {
            return 5
        }else{
            return modifiedPostArray.count
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MyCollectionViewCell13.identifier, for: indexPath) as! MyCollectionViewCell13
        cell.configure13(with: modifiedPostArray[indexPath.row])
        return cell
        
    }
    
    //ここでCollectionViewCellの縦と横のサイズを決定
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 167, height: 167)
    }
}

