//
//  PDMPhotoManager.swift
//  Pandora
//
//  Created by xiangwenlai on 16/3/28.
//  Copyright © 2016年 xiangwenlai. All rights reserved.
//

import Foundation

class PDMPhotoManager {
    
    static let hostUrl: String = "http://www.porndao.net/p/"
    static let sharedManager: PDMPhotoManager = PDMPhotoManager()
    let phDataSource: PDMediaPhotoDataSource = PDMediaPhotoDataSource()
    var curPage: Int = 1
    var hasMore: Bool = true
    
    let parseQueue: dispatch_queue_t = dispatch_queue_create("parse_queue", DISPATCH_QUEUE_SERIAL)
    
    func refleshData() {
        
        self.curPage = 1
        self.doRequestData()
        
    }
    
    func getNextPageData() {
        
        self.curPage = self.curPage + 1
        self.doRequestData()
        
    }
    
    func doRequestData() {
        
        let curPageUrl = self.getCurPageHostUrl()
        
        PDDownloader.sharedDownloader.requestData(curPageUrl, completion: {
            (cachePath, error) in
            if error != nil {
                
                print("get page \(self.curPage) data fail...")
                
            } else if cachePath != nil {
                
                self.parseData(cachePath!, reflesh: self.curPage == 1)
                
            } else {
                
                print("get page \(self.curPage) cache is nil")
                
            }
        })
    }
    
    private func getCurPageHostUrl() -> String {
        
        return PDMPhotoManager.hostUrl + String(self.curPage)
        
    }
    
    private func parseData(file: String, reflesh: Bool) {
        
        dispatch_async(self.parseQueue) {
            
            do {
                let htmlString = try String(contentsOfFile: file, encoding: NSUTF8StringEncoding)
                let regularExp = try NSRegularExpression(pattern: "<div\\s*class=\"item\"[\\s\\S]+?/div>", options: .CaseInsensitive)
                
                let results = regularExp.matchesInString(htmlString, options: .ReportCompletion, range: NSMakeRange(0, htmlString.characters.count))
                    .map({ (ckResult) -> String in
                    let index1 = htmlString.startIndex.advancedBy(ckResult.range.location)
                    let index2 = htmlString.startIndex.advancedBy(ckResult.range.location + ckResult.range.length)
                    return htmlString.substringWithRange(Range<String.Index>(index1 ..< index2))
                })
                
                let photoItems = try results.map({ (value) -> PDPhotoItem in
                    
                    let wReg = try NSRegularExpression(pattern: "(?<=data-w=\")\\d+(?=\")", options: .CaseInsensitive)
                    
                    let widths = wReg.matchesInString(value, options: .ReportCompletion, range: NSMakeRange(0, value.characters.count)).map({ (result) -> Float in
                        let index1 = htmlString.startIndex.advancedBy(result.range.location)
                        let index2 = htmlString.startIndex.advancedBy(result.range.location + result.range.length)
                        let str = value.substringWithRange(Range<String.Index>(index1 ..< index2))
                        
                        return Float(str)!
                    })
                    
                    let hReg = try NSRegularExpression(pattern: "(?<=data-h=\")\\d+(?=\")", options: .CaseInsensitive)
                    let heights = hReg.matchesInString(value, options: .ReportCompletion, range: NSMakeRange(0, value.characters.count)).map({ (result) -> Float in
                        let index1 = htmlString.startIndex.advancedBy(result.range.location)
                        let index2 = htmlString.startIndex.advancedBy(result.range.location + result.range.length)
                        let str = value.substringWithRange(Range<String.Index>(index1 ..< index2))
                        
                        return Float(str)!
                    })

                    
                    let imageReg = try NSRegularExpression(pattern: "(?<=src=\").*?(?=\">)", options: .CaseInsensitive)
                    let srcs = imageReg.matchesInString(value, options: .ReportCompletion, range: NSMakeRange(0, value.characters.count)).map({ (result) -> String in
                        let index1 = htmlString.startIndex.advancedBy(result.range.location)
                        let index2 = htmlString.startIndex.advancedBy(result.range.location + result.range.length)
                        return value.substringWithRange(Range<String.Index>(index1 ..< index2))
                    })
                    let picCntReg = try NSRegularExpression(pattern: "(?<=<div class=\"ipics\">)\\d+(?=</div>)", options: .CaseInsensitive)
                    
                    let picCnts = picCntReg.matchesInString(value, options: .ReportCompletion, range: NSMakeRange(0, value.characters.count)).map({ (result) -> Int in
                        
                        let index1 = value.startIndex.advancedBy(result.range.location)
                        let index2 = value.startIndex.advancedBy(result.range.location + result.range.length)
                        let cntStr = value.substringWithRange(Range<String.Index>(index1 ..< index2))
                        
                        return Int(cntStr)!
                    })
                    
                    let thumbsrc = srcs.first
                    let range = thumbsrc?.rangeOfString("thumbs/")
                    var imageSrc = thumbsrc
                    if range != nil {
                        imageSrc = (thumbsrc?.substringToIndex(range!.startIndex))! + (thumbsrc?.substringFromIndex(range!.endIndex))!
                    }
                    
                    let item: PDPhotoItem = PDPhotoItem(url: imageSrc, thumbUrl: thumbsrc, coverWidth: widths.first!, coverHeight: heights.first!, photoCount: picCnts.first!)
                    
                    return item
                    
                })
                
                dispatch_async(dispatch_get_main_queue(), { 
                    if self.curPage == 1 {
                        self.phDataSource.addNewMediaItems(photoItems, reflesh: true)
                    } else {
                        self.phDataSource.addNewMediaItems(photoItems, reflesh: false)
                    }
                    self.phDataSource.updateUIMark = true
                });
                
            } catch {
                print("read cache data fail..")
            }
            
        }
    }
    
}