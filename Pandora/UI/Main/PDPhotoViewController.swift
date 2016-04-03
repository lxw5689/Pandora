//
//  PDPhotoViewController.swift
//  Pandora
//
//  Created by xiangwenlai on 16/3/19.
//  Copyright © 2016年 xiangwenlai. All rights reserved.
//

import UIKit

private let reuseIdentifier = "PDMediaItemCell"

class PDPhotoViewController: UICollectionViewController {
    
    static func instanceFromNib() -> PDPhotoViewController {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("PDPhotoViewController")
        
        return vc as! PDPhotoViewController
        
    }
    
    var layout: PDMediaCollectionViewLayout?
    var dataSource: PDMediaPhotoDataSource?
    var refleshControl: UIRefreshControl?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(collectionViewLayout layout: UICollectionViewLayout) {
        
        super.init(collectionViewLayout: layout)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        let refleshControl = UIRefreshControl()
        refleshControl.tintColor = UIColor.colorWithHexString("D8AF96")
        refleshControl.attributedTitle = NSAttributedString(string: "加载中...")
        refleshControl.addTarget(self, action: #selector(PDPhotoViewController.onReflesh), forControlEvents: .ValueChanged)
        self.collectionView?.addSubview(refleshControl)
        self.refleshControl = refleshControl
        
        // Register cell classes
        self.layout = PDMediaCollectionViewLayout(col: 3, dataSource: nil)
        
        self.collectionView?.collectionViewLayout = self.layout!
        
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(PDPhotoViewController.updateUI),
                                                         name: "updatePhotoUI",
                                                         object: nil)
        
        
        self.dataSource = PDMPhotoManager.sharedManager.phDataSource
        self.layout?.dataSource = self.dataSource
        
        self.refleshControl?.beginRefreshing()
        self.onReflesh()
        
        self.collectionView?.addLoadMoreAction(){
            PDMPhotoManager.sharedManager.getNextPageData()
        }
        
    }
    
    func updateUI() {
        
        if self.dataSource!.isReflesh() {
            self.collectionView?.reloadData()
        } else {
            let beginIndex = (self.dataSource!.mediaItemCount() - self.dataSource!.newAppendCount())
            var indexPathArr: Array<NSIndexPath> = Array<NSIndexPath>()
            
            for index in beginIndex ..< self.dataSource!.mediaItemCount() {
                let indexPath = NSIndexPath(forItem: index, inSection: 0)
                indexPathArr.append(indexPath)
            }
            self.collectionView?.insertItemsAtIndexPaths(indexPathArr)
        }
        
        if self.refleshControl != nil && self.refleshControl!.refreshing {
             self.refleshControl?.endRefreshing()
        } else if let clView = self.collectionView where clView.isLoadingMore {
            clView.stopLoadMore(PDMPhotoManager.sharedManager.hasMore)
        }
    }
    
    func onReflesh() {
        PDMPhotoManager.sharedManager.refleshData()
    
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items

        return self.dataSource!.mediaItemCount()
        
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath)
    
        // Configure the cell
        let pmCell = cell as! PDMediaItemCell
        let photoItem: PDPhotoItem? = (self.dataSource?.mediaItemDataArr()?[indexPath.item]) as? PDPhotoItem
        
        pmCell.mediaItem = photoItem
        
    
        return cell
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(collectionView: UICollectionView, shouldShowMenuForItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
    
    }
    */

}
