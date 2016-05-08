//
//  PDVideoDataSource.swift
//  Pandora
//
//  Created by xiangwenlai on 16/5/8.
//  Copyright © 2016年 xiangwenlai. All rights reserved.
//

import Foundation

class PDVideoDataSource: PDMediaLayoutDataSource {
    static let updateUINotificationName = "updateVideoUI"
    
    private var videoItems = [PDVideoItem]()
    var reflesh: Bool = false
    var newAppendCnt: Int = 0
    var updateUI: Bool = false {
        didSet {
            if updateUI {
                NSNotificationCenter.defaultCenter().postNotificationName(PDVideoDataSource.updateUINotificationName, object: self)
            }
        }
    }
    
    func mediaItemCount() -> Int {
        return self.videoItems.count
    }
    
    func mediaItemDataArr() -> Array<PDMediaItem>? {
        return self.videoItems
    }
    
    func isReflesh() -> Bool {
        return self.reflesh
    }
    
    func newAppendCount() -> Int {
        return self.newAppendCnt
    }
    
    func addNewVideoItems(items: [PDVideoItem], isReflesh: Bool) {
        if isReflesh {
            self.videoItems.removeAll()
        }
        self.videoItems.appendContentsOf(items)
        self.newAppendCnt = items.count
        self.reflesh = isReflesh
        self.updateUI = true
    }
}