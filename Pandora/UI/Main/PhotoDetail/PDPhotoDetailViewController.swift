//
//  PDPhotoDetailViewController.swift
//  Pandora
//
//  Created by xiangwenlai on 16/4/3.
//  Copyright © 2016年 xiangwenlai. All rights reserved.
//

import UIKit

private let reuseIdentifier = "PDPhotoCellEx"

class PDPhotoDetailViewController: UICollectionViewController {
    
    static func instanceFromNib() -> PDPhotoDetailViewController{
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        
        return storyBoard.instantiateViewControllerWithIdentifier("PDPhotoDetailViewController") as! PDPhotoDetailViewController
    }
    
    var phDetailHref: String?
    var tapGesture: UITapGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let layout: UICollectionViewFlowLayout = self.collectionView?.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSizeMake(CGRectGetWidth(UIScreen.mainScreen().bounds), CGRectGetHeight(UIScreen.mainScreen().bounds))
        layout.minimumLineSpacing = 0
        
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(PDPhotoDetailViewController.updateUI),
                                                         name: "updatePhotoDetailUI",
                                                         object: nil)
        
        self.collectionView?.registerClass(PDPhotoCellEx.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        if self.phDetailHref != nil {
            PDPhotoDetailManager.sharedManager.requestPhotoDetail(self.phDetailHref!)
        }
        
        self.tapGesture = UITapGestureRecognizer(target: self, action: #selector(PDPhotoDetailViewController.tapAction))
        self.tapGesture.numberOfTapsRequired = 1
        self.collectionView?.addGestureRecognizer(self.tapGesture!)
    }
    
    func tapAction() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func updateUI() {
        self.collectionView?.reloadData()
    }
    
    //MARK : uicollection view datasource
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return PDPhotoDetailManager.sharedManager.photoItems.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! PDPhotoCellEx
        
        let items = PDPhotoDetailManager.sharedManager.photoItems
        let photoItem = items[indexPath.item]
        cell.setPhotoItem(photoItem)
        
        if indexPath.item + 5 < items.count {
            let cnt = min((indexPath.item + 5), items.count)
            for index in (indexPath.item + 1) ..< cnt {
                let itm = items[index]
                PDDownloader.sharedDownloader.requestImage(itm.coverUrl!, completion: nil)
            }
        }
        self.tapGesture!.requireGestureRecognizerToFail(cell.doubleTapGesture)
        
        return cell
    }
}
