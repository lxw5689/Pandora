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
        
        self.collectionView?.addLoadMoreAction(){
            PDVideoManager.sharedManager.getNextPage()
        }
    }
    
    func updateUI() {
        let dataSource = PDVideoManager.sharedManager.dataSource
        if dataSource.isReflesh() {
            self.collectionView?.reloadData()
        } else {
            let beginIndex = (dataSource.mediaItemCount() - dataSource.newAppendCount())
            var indexPathArr: Array<NSIndexPath> = Array<NSIndexPath>()
            
            for index in beginIndex ..< dataSource.mediaItemCount() {
                let indexPath = NSIndexPath(forItem: index, inSection: 0)
                indexPathArr.append(indexPath)
            }
            self.collectionView?.insertItemsAtIndexPaths(indexPathArr)
        }
        
        /*if self.refleshControl != nil && self.refleshControl!.refreshing {
            self.refleshControl?.endRefreshing()
        } else */if let clView = self.collectionView where clView.isLoadingMore {
            clView.stopLoadMore(PDMPhotoManager.sharedManager.hasMore)
        }
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
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let item = PDVideoManager.sharedManager.dataSource.mediaItemDataArr()![indexPath.item] as! PDVideoItem
        
        if item.target != nil {
            
            let cell = collectionView.cellForItemAtIndexPath(indexPath)
            let fr = collectionView.convertRect(cell!.frame, toView: self.view.window!)
            let frImage = (cell as? PDMediaItemCell)?.coverView.image
            
            let detailVC = PDVideoDetailViewController.instanceFromNib()
            detailVC.targetUrl = item.target!
            detailVC.presentAnimator.fromRect = fr
            detailVC.presentAnimator.fromImage = frImage
            
            self.presentViewController(detailVC, animated: true, completion: nil)
        }
    }
}
