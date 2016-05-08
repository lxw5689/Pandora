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
    var target: String?
    var duration: String?
    
    init(url: String?, target: String?, duration: String?, thumbUrl: String?, coverWidth: Float, coverHeight: Float, videoUrl: String?) {
        super.init(url: url, thumbUrl: thumbUrl, coverWidth: coverWidth, coverHeight: coverHeight)
        
        self.videoUrl = videoUrl
        self.target = target
        self.duration = duration
    }
    
}