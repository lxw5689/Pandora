//
//  PDMediaItem.swift
//  Pandora
//
//  Created by xiangwenlai on 16/3/19.
//  Copyright © 2016年 xiangwenlai. All rights reserved.
//

import UIKit

class PDMediaItem: NSObject {
    
    var coverUrl: String?
    var thumbUrl: String?
    var coverWidth: Float
    var coverHeight: Float
    
    init(url: String?, thumbUrl: String?, coverWidth: Float, coverHeight: Float) {
        
        self.coverUrl = url
        self.thumbUrl = thumbUrl
        self.coverWidth = coverWidth
        self.coverHeight = coverHeight
    }
}
