//
//  PDPhotoItem.swift
//  Pandora
//
//  Created by xiangwenlai on 16/3/19.
//  Copyright © 2016年 xiangwenlai. All rights reserved.
//

import Foundation

class PDPhotoItem: PDMediaItem {
    
    var photoCount: NSInteger
    var photoDesc: String?
    var detailRef: String?
    
    init(url: String?, href: String?, thumbUrl: String?, coverWidth: Float, coverHeight: Float, photoCount: Int) {
        self.photoCount = photoCount
        self.detailRef = href
        
        super.init(url: url, thumbUrl: thumbUrl, coverWidth: coverWidth, coverHeight: coverHeight)
    }
    
}