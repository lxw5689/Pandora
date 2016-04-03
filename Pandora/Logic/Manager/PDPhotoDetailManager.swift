//
//  PDPhotoDetailManager.swift
//  Pandora
//
//  Created by xiangwenlai on 16/4/3.
//  Copyright © 2016年 xiangwenlai. All rights reserved.
//

import Foundation
class PDPhotoDetailManager {
    
    static let sharedManager: PDPhotoDetailManager = PDPhotoDetailManager()
    
    var photoItems: Array<PDPhotoItem> = [] {
        didSet {
            if photoItems.count > 0 {
                dispatch_async(dispatch_get_main_queue()) {
                    NSNotificationCenter.defaultCenter().postNotificationName("updatePhotoDetailUI", object: nil)
                }
            }
        }
    }
    
    func requestPhotoDetail(url: String) {
        self.photoItems = []
        PDDownloader.sharedDownloader.requestData(url) { (path, error) in
            if error != nil {
                print("get photo detail fail...")
            } else if path != nil {
                self.parseData(path!)
            } else {
                print("get photo detail no data!")
            }
        }
    }
    
    private func parseData(cachePath: String) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            
            do {
                let htmlString = try String(contentsOfFile: cachePath, encoding: NSUTF8StringEncoding)
                let regularExp = try NSRegularExpression(pattern: "<div class=\"imgList group\">[\\s\\S]+?/div>", options: .CaseInsensitive)
                let resultArr = regularExp.matchesInString(htmlString, options: .ReportCompletion, range: NSMakeRange(0, htmlString.characters.count)).map({ (result) -> String in
                    
                    let index1 = htmlString.startIndex.advancedBy(result.range.location)
                    let index2 = htmlString.startIndex.advancedBy(result.range.location + result.range.length)
                    return htmlString.substringWithRange(Range<String.Index>(index1 ..< index2))
                    
                })
                
                let value = resultArr.first!
                
                let imgReg = try NSRegularExpression(pattern: "(?<=data-src=\").*?(?=\" class)", options: .CaseInsensitive)
                let phItemsArr = imgReg.matchesInString(value, options: .ReportCompletion, range: NSMakeRange(0, value.characters.count)).map({ (result) -> PDPhotoItem in
                    let index1 = value.startIndex.advancedBy(result.range.location)
                    let index2 = value.startIndex.advancedBy(result.range.location + result.range.length)
                    
                    let thumbSrc = value.substringWithRange(Range<String.Index>(index1 ..< index2))
                    let range = thumbSrc.rangeOfString("thumbs/")
                    var imageSrc = thumbSrc
                    if range != nil {
                        imageSrc = thumbSrc.substringToIndex(range!.startIndex) + thumbSrc.substringFromIndex(range!.endIndex)
                    }
                    
                    let phItem = PDPhotoItem(url: imageSrc, href: nil, thumbUrl: thumbSrc, coverWidth: 0, coverHeight: 0, photoCount: 1)
                    
                    return phItem
                })
                
                print("detail photo cnt:\(phItemsArr.count)");
                
                self.photoItems = phItemsArr
                
            } catch {
                
            }
            
        }
    }
}