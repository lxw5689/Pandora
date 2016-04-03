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
    
    var item: PDPhotoItem?
    
    func setPhotoItem(item: PDPhotoItem) {
        self.item = item
        self.photoView.setImageUrl(item.coverUrl)
    }
}
