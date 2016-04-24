//
//  PDPhotoDetailViewController.swift
//  Pandora
//
//  Created by xiangwenlai on 16/4/3.
//  Copyright © 2016年 xiangwenlai. All rights reserved.
//

import UIKit

private let reuseIdentifier = "PDPhotoCellEx"

class PDPhotoDetailViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var pageIndexLabel: UILabel!
    @IBOutlet weak var loadingView: UIActivityIndicatorView!
    
    static func instanceFromNib() -> PDPhotoDetailViewController{
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        
        return storyBoard.instantiateViewControllerWithIdentifier("PDPhotoDetailViewController") as! PDPhotoDetailViewController
    }
    
    let presentAnimator = PDPhotoDetailPresentAnimator()
    let dismissAnimator = PDPhotoDetailDismissAnimator()
    
    var phDetailHref: String?
    var tapGesture: UITapGestureRecognizer!
    var animImageView: UIImageView? {
        didSet {
            if animImageView != nil {
                let cell = self.collectionView.cellForItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 0)) as? PDPhotoCellEx
                if cell != nil {
                    cell?.animImageView = animImageView
                    self.animImageView = nil
                }
                else {
                    self.view.insertSubview(animImageView!, belowSubview: loadingView)
                }
            }
        }
    }
    var curIndex: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(PDPhotoDetailViewController.updateUI),
                                                         name: "updatePhotoDetailUI",
                                                         object: nil)
        
        self.collectionView.registerClass(PDPhotoCellEx.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        if self.phDetailHref != nil {
            PDPhotoDetailManager.sharedManager.requestPhotoDetail(self.phDetailHref!)
        }
        
        
        self.tapGesture = UITapGestureRecognizer(target: self, action: #selector(PDPhotoDetailViewController.tapAction))
        self.tapGesture.numberOfTapsRequired = 1
        self.collectionView.addGestureRecognizer(self.tapGesture!)
        self.loadingView.startAnimating()
        self.transitioningDelegate = self
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let layout: UICollectionViewFlowLayout = self.collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSizeMake(CGRectGetWidth(self.collectionView.bounds), CGRectGetHeight(self.collectionView.bounds))
        layout.minimumLineSpacing = 0
        
        if self.animImageView != nil {
            self.animImageView!.center = CGPointMake(self.view.frame.width / 2, self.view.frame.height / 2)
        }
    }
    
    func tapAction() {
        if self.curIndex == 0 {
            let cell = self.collectionView.cellForItemAtIndexPath(NSIndexPath(forItem: self.curIndex, inSection: 0)) as? PDPhotoCellEx
            if cell != nil {
                let image = cell!.photoView.image
                let fr = cell?.scrollView.convertRect((cell?.photoView.frame)!, toView: self.view.window)
                
                if image != nil && fr != nil {
                    self.dismissAnimator.fromFr = fr
                    self.dismissAnimator.fromImage = image
                    self.dismissAnimator.toFr = self.presentAnimator.imageFromFr
                }
            }
        }
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func updateUI() {
        self.collectionView.reloadData()
        let items = PDPhotoDetailManager.sharedManager.photoItems
        
        if items.count > 0 {
            self.pageIndexLabel.text = "1/\(items.count)"
        }
        self.loadingView.stopAnimating()
    }
}

//MARK: UICollectionViewDataSource
extension PDPhotoDetailViewController : UICollectionViewDataSource {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return PDPhotoDetailManager.sharedManager.photoItems.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! PDPhotoCellEx
        
        let items = PDPhotoDetailManager.sharedManager.photoItems
        let photoItem = items[indexPath.item]
        cell.setPhotoItem(photoItem)
        
        if self.animImageView != nil {
            cell.animImageView = self.animImageView
            self.animImageView = nil
        }
        
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

//MARK: UICollectionViewDelegate
extension PDPhotoDetailViewController : UICollectionViewDelegate {
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let halfWidth = scrollView.frame.width / 2
        let index = Int((scrollView.contentOffset.x + halfWidth) / scrollView.frame.width)
        let items = PDPhotoDetailManager.sharedManager.photoItems
        
        if items.count > 0 {
            self.pageIndexLabel.text = "\(index + 1)/\(items.count)"
            self.curIndex = index
        }
    }
}

//MARK: UIViewControllerTransitioningDelegate
extension PDPhotoDetailViewController : UIViewControllerTransitioningDelegate {
    
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self.presentAnimator
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self.dismissAnimator
    }
}
