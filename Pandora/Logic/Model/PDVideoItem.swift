//
//  PDVideoItem.swift
//  Pandora
//
//  Created by xiangwenlai on 16/3/19.
//  Copyright © 2016年 xiangwenlai. All rights reserved.
//

import Foundation

class PDVideoItem: PDMediaItem {
    
    var videoUrl: String?
    var videoDesc: String?
    
    init(url: String?, thumbUrl: String?, coverWidth: Float, coverHeight: Float, videoUrl: String?) {
        self.videoUrl = videoUrl
        
        super.init(url: url, thumbUrl: thumbUrl, coverWidth: coverWidth, coverHeight: coverHeight)
    }
    
}