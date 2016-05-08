//
//  PDVideoViewController.swift
//  Pandora
//
//  Created by xiangwenlai on 16/3/19.
//  Copyright © 2016年 xiangwenlai. All rights reserved.
//

import UIKit

class PDVideoViewController: UICollectionViewController {
    
    private static let reuseIdentifier = "PDMediaItemCell"
    
    static func instanceFromNib() -> PDVideoViewController {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("PDVideoViewController")
        
        return vc as! PDVideoViewController
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(collectionViewLayout layout: UICollectionViewLayout) {
        super.init(collectionViewLayout: layout)
    }
    
    var layout: PDMediaCollectionViewLayout!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(PDVideoViewController.updateUI), name: PDVideoDataSource.updateUINotificationName, object: nil)
        
        self.layout = PDMediaCollectionViewLayout(col: 2, dataSource: PDVideoManager.sharedManager.dataSource)
        self.collectionView?.collectionViewLayout = self.layout
        
        PDVideoManager.sharedManager.refleshData()
        
    }
    
    func updateUI() {
        self.collectionView?.reloadData()
    }
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return PDVideoManager.sharedManager.dataSource.mediaItemCount()
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(PDVideoViewController.reuseIdentifier, forIndexPath: indexPath)
        
        // Configure the cell
        let pmCell = cell as! PDMediaItemCell
        let item = PDVideoManager.sharedManager.dataSource.mediaItemDataArr()![indexPath.item] as! PDVideoItem
        pmCell.mediaItem = item
        
        return cell
    }
    
}
