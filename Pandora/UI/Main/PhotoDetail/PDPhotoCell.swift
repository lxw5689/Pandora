//
//  PDPhotoCell.swift
//  Pandora
//
//  Created by xiangwenlai on 16/4/3.
//  Copyright © 2016年 xiangwenlai. All rights reserved.
//

import UIKit

class PDPhotoCell: UICollectionViewCell {
    
    @IBOutlet weak var contentScrollView: UIScrollView!
    @IBOutlet weak var photoView: UIImageView!
    
    @IBOutlet weak var picHeightCons: NSLayoutConstraint!
    @IBOutlet weak var picWidthCons: NSLayoutConstraint!
    @IBOutlet weak var picBottomCons: NSLayoutConstraint!
    @IBOutlet weak var picTopCons: NSLayoutConstraint!
    @IBOutlet weak var picTrailCons: NSLayoutConstraint!
    @IBOutlet weak var picLeadingCons: NSLayoutConstraint!
    
    var url: String?
    var isLoading: Bool = false
    
    var item: PDPhotoItem?
    
    func setPhotoItem(item: PDPhotoItem) {
        
        self.item = item
        guard item.coverUrl != self.url else {
            return
        }
        self.photoView.image = nil
        if self.isLoading && item.coverUrl != self.url  && self.url != nil {
            PDDownloader.sharedDownloader.cancelImageRequest(self.url!)
            self.url = nil
            self.isLoading = false
        }
        
        if item.coverUrl != nil {
            self.url = item.coverUrl
            self.isLoading = true
            
            PDDownloader.sharedDownloader.requestImage(item.coverUrl!, completion: { (image, error) in
                
                if error != nil {
                    print("request photo detail fail:\(item.coverUrl!)")
                } else if image != nil {
                    self.setImage(image)
                } else {
                    print("request image nil...")
                }
                
            })
        }
    }
    
    func setImage(image: UIImage?) {
        
        if image == nil {
            self.photoView.image = nil
        } else {
//            let imgSize = image!.size
//            let screenSize = UIScreen.mainScreen().bounds.size
//            let w = min(imgSize.width, screenSize.width)
//            var h = imgSize.height
//            
//            if imgSize.width > screenSize.width {
//                h = imgSize.height * screenSize.width / imgSize.width
//            }
            
            self.photoView.image = image
            
            //update constraint
//            self.picHeightCons.constant = h
//            self.picWidthCons.constant = w
//            self.picTopCons.constant = (screenSize.height - h) / 2
//            self.picBottomCons.constant = (screenSize.height - h) / 2
//            self.picLeadingCons.constant = (screenSize.width - w) / 2
//            self.picTrailCons.constant = (screenSize.width - w) / 2
        }
    }
}
