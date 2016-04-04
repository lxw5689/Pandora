//
//  PDPhotoDetailViewController.swift
//  Pandora
//
//  Created by xiangwenlai on 16/4/3.
//  Copyright © 2016年 xiangwenlai. All rights reserved.
//

import UIKit

private let reuseIdentifier = "PDPhotoCell"

class PDPhotoDetailViewController: UICollectionViewController {
    
    static func instanceFromNib() -> PDPhotoDetailViewController{
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        
        return storyBoard.instantiateViewControllerWithIdentifier("PDPhotoDetailViewController") as! PDPhotoDetailViewController
    }
    
    var phDetailHref: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let layout: UICollectionViewFlowLayout = self.collectionView?.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSizeMake(CGRectGetWidth(UIScreen.mainScreen().bounds), CGRectGetHeight(UIScreen.mainScreen().bounds))
        layout.minimumLineSpacing = 0
        
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(PDPhotoDetailViewController.updateUI),
                                                         name: "updatePhotoDetailUI",
                                                         object: nil)
        
        if self.phDetailHref != nil {
            PDPhotoDetailManager.sharedManager.requestPhotoDetail(self.phDetailHref!)
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(PDPhotoDetailViewController.tapAction))
        self.collectionView?.addGestureRecognizer(tapGesture)
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
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! PDPhotoCell
        
        let photoItem = PDPhotoDetailManager.sharedManager.photoItems[indexPath.item]
        cell.setPhotoItem(photoItem)
        
        return cell
    }
}
