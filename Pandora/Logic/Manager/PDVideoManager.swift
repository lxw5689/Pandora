//
//  PDVideoManager.swift
//  Pandora
//
//  Created by xiangwenlai on 16/5/8.
//  Copyright © 2016年 xiangwenlai. All rights reserved.
//

import Foundation
class PDVideoManager {
    static let sharedManager = PDVideoManager()
    static let hostUrl = "http://www.porndao.net/v/"
    
    let dataSource = PDVideoDataSource()
    var curPage = 1
    var hasMore = true
    
    func curRequestUrl() -> String {
        return PDVideoManager.hostUrl + String(curPage)
    }
    
    func refleshData() {
        self.curPage = 1
        
        self.doRequest()
    }
    
    func getNextPage() {
        self.curPage += 1
        
        self.doRequest()
    }
    
    func doRequest() {
        PDDownloader.sharedDownloader.requestData(self.curRequestUrl()) { (file, error) in
            if file != nil {
                self.parseData(file!, isReflesh: self.curPage == 1)
            } else if error != nil {
                print("request video error:%s curPage:%d", error!.localizedFailureReason, self.curPage)
            }
        }
    }
    
    func parseData(file: String, isReflesh: Bool) {
        PDDataParser.sharedParser.parseVideoItems(file) { (videoItems, error) in
            if videoItems != nil {
                self.dataSource.addNewVideoItems(videoItems!, isReflesh: isReflesh)
            }
        }
    }
    
}