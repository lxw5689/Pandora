//
//  PDMediaPhotoDataSource.swift
//  Pandora
//
//  Created by xiangwenlai on 16/3/20.
//  Copyright © 2016年 xiangwenlai. All rights reserved.
//

import Foundation

class PDMediaPhotoDataSource: PDMediaLayoutDataSource {
    
    private var mediaItems: Array<PDPhotoItem>?
    
    var reflesh: Bool
    var newAppendCnt: Int
    
    var updateUIMark: Bool = false {
        
        didSet {
            if updateUIMark {
                dispatch_async(dispatch_get_main_queue(), {
                    NSNotificationCenter.defaultCenter().postNotificationName("updatePhotoUI", object: nil)
                    })
                
            }
        }
        
    }
    
    init() {
        self.reflesh = false
        self.newAppendCnt = 0
        self.mediaItems = Array<PDPhotoItem>()
    }
    
    func mediaItemCount() -> Int {
        var count = 0
        if self.mediaItems != nil {
            count = (self.mediaItems?.count)!
        }
        
        return count
    }
    
    func mediaItemDataArr() -> Array<PDMediaItem>? {
        return self.mediaItems
    }
    
    func isReflesh() -> Bool {
        return self.reflesh
    }
    
    func newAppendCount() -> Int {
        return newAppendCnt
    }
    
    func addNewMediaItems(items: Array<PDPhotoItem>, reflesh: Bool) {
        self.reflesh = reflesh
        if reflesh {
            self.mediaItems?.removeAll()
        }
        self.newAppendCnt = items.count
        self.mediaItems?.appendContentsOf(items)
    }
    
}
