//
//  PDMediaItemCell.swift
//  Pandora
//
//  Created by xiangwenlai on 16/3/31.
//  Copyright © 2016年 xiangwenlai. All rights reserved.
//

import UIKit

class PDMediaItemCell: UICollectionViewCell {
    
    @IBOutlet weak var coverView: UIImageView!
    @IBOutlet weak var picNumLable: UILabel!
    @IBOutlet weak var picNumBGView: UIView!
    
    @IBOutlet weak var picNumBGWidthCons: NSLayoutConstraint!
    @IBOutlet weak var picNumBGHeightCons: NSLayoutConstraint!
    
    
    var mediaItem: PDMediaItem? = nil {
        didSet {
            if mediaItem != nil {
                self.updateUI()
            }
        }
    }
    
    func setPicNumVisible(visible: Bool) {
        self.picNumBGView.hidden = !visible
    }
    
    func updateUI() {
        self.coverView.image = nil
        let url: String? = self.mediaItem?.thumbUrl
        if url != nil {
            self.coverView.setImageUrl(url)
        }
        
        if let phItm = self.mediaItem {
            if phItm.isKindOfClass(PDPhotoItem) {
                
                self.setPicNumVisible(true)
                let photoItem = phItm as! PDPhotoItem
                self.picNumLable.text = String(photoItem.photoCount)
                let numSize = self.picNumLable .sizeThatFits(CGSizeZero)
                self.picNumBGWidthCons.constant = numSize.width + 2
                self.picNumBGHeightCons.constant = numSize.height
                
            }
            else {
                self.setPicNumVisible(false)
            }
        }
    }
    
}
