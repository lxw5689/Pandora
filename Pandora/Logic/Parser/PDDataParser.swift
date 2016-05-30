//
//  PDDataParser.swift
//  Pandora
//
//  Created by xiangwenlai on 16/5/7.
//  Copyright © 2016年 xiangwenlai. All rights reserved.
//

import Foundation

class PDDataParser {
    static let sharedParser = PDDataParser()
    private let parseQueue: dispatch_queue_t = dispatch_queue_create("parse_queue", DISPATCH_QUEUE_SERIAL)
    
    func parseData(originString: String, regularText: String) -> [String] {
        do {
            let regularExp = try NSRegularExpression(pattern: regularText, options: .CaseInsensitive)
            let results = regularExp.matchesInString(originString, options: .ReportCompletion, range: NSRange(location: 0, length: originString.characters.count)).map({ (result) -> String in
                let index1 = originString.startIndex.advancedBy(result.range.location)
                let index2 = originString.startIndex.advancedBy(result.range.location + result.range.length)
                let str = originString.substringWithRange(Range<String.Index>(index1 ..< index2))
                
                return str
            })
            
            return results
        } catch {
            print("catch error..." + #function + String(#line))
        }
        return [""]
    }
    
    func parsePhotoItems(file: String, complete: ([PDPhotoItem]?, NSError?) -> Void) {
        dispatch_async(self.parseQueue) {
            do {
                let htmlString = try String(contentsOfFile: file, encoding: NSUTF8StringEncoding)
                let results = self.parseData(htmlString, regularText: "<div\\s*class=\"item\"[\\s\\S]+?/div>")
                
                let photoItems = results.map({ (value) -> PDPhotoItem in
                    
                    let strWidths = self.parseData(value, regularText: "(?<=data-w=\")\\d+(?=\")")
                    let widths = strWidths.map({ (str) -> Float in
                        let fvalue = Float(str)
                        return (fvalue == nil) ? 0 : fvalue!
                    })
                    
                    let strHeights = self.parseData(value, regularText: "(?<=data-h=\")\\d+(?=\")")
                    let heights = strHeights.map({ (str) -> Float in
                        let fvalue = Float(str)
                        return (fvalue == nil) ? 0 : fvalue!
                    })
                    
                    let hrefArr = self.parseData(value, regularText: "(?<=<a href=\").*?(?=\"\\starget)")
                    let srcs = self.parseData(value, regularText: "(?<=src=\").*?(?=\">)")
                    let strPicCnts = self.parseData(value, regularText: "(?<=<div class=\"ipics\">)\\d+(?=</div>)")
                    let picCnts = strPicCnts.map({ (str) -> Int in
                        let ivalue = Int(str)
                        return (ivalue == nil) ? 0 : ivalue!
                    })
                    let thumbsrc = srcs.first
                    let range = thumbsrc?.rangeOfString("thumbs/")
                    var imageSrc = thumbsrc
                    if range != nil {
                        imageSrc = (thumbsrc?.substringToIndex(range!.startIndex))! + (thumbsrc?.substringFromIndex(range!.endIndex))!
                    }
                    
                    let item: PDPhotoItem = PDPhotoItem(url: imageSrc, href: hrefArr.first, thumbUrl: thumbsrc, coverWidth: widths.first!, coverHeight: heights.first!, photoCount: picCnts.first!)
                    
                    return item
                    
                })
                dispatch_async(dispatch_get_main_queue()) {
                    complete(photoItems, nil)
                }
            } catch {
                dispatch_async(dispatch_get_main_queue()) {
                    complete(nil, NSError(domain: "parse data", code: -1, userInfo: [NSLocalizedFailureReasonErrorKey: "parse data error"]))
                }
            }
        }
    }
    
    func parseVideoItems(file: String, complete: ([PDVideoItem]?, NSError?) -> Void) {
        dispatch_async(self.parseQueue) {
            do {
                let htmlString = try String(contentsOfFile: file, encoding: NSUTF8StringEncoding)
                let results = self.parseData(htmlString, regularText: "<div\\s*class=\"item\"[\\s\\S]+?/div>")
                
                let photoItems = results.map({ (value) -> PDVideoItem in
                    
                    let strWidths = self.parseData(value, regularText: "(?<=data-w=\")\\d+(?=\")")
                    let widths = strWidths.map({ (str) -> Float in
                        let fvalue = Float(str)
                        return (fvalue == nil) ? 0 : fvalue!
                    })
                    
                    let strHeights = self.parseData(value, regularText: "(?<=data-h=\")\\d+(?=\")")
                    let heights = strHeights.map({ (str) -> Float in
                        let fvalue = Float(str)
                        return (fvalue == nil) ? 0 : fvalue!
                    })
                    
                    let hrefArr = self.parseData(value, regularText: "(?<=<a href=\").*?(?=\"\\starget)")
                    let srcs = self.parseData(value, regularText: "(?<=src=\").*?(?=\">)")
                    let strPicCnts = self.parseData(value, regularText: "(?<=<div class=\"ipics\">).*(?=</div>)")
                    
                    let item = PDVideoItem(url: srcs.first, target: hrefArr.first, duration: strPicCnts.first, thumbUrl: srcs.first, coverWidth: widths.first!, coverHeight: heights.first!, videoUrl: nil)
                    
                    return item
                    
                })
                dispatch_async(dispatch_get_main_queue()) {
                    complete(photoItems, nil)
                }
            } catch {
                dispatch_async(dispatch_get_main_queue()) {
                    complete(nil, NSError(domain: "parse data", code: -2, userInfo: [NSLocalizedFailureReasonErrorKey: "parse video item fail.."]))
                }
            }
        }
    }
    
    func parseDetailVideo(file: String, complete:(PDVideoItem?, NSError?) -> Void) {
        dispatch_async(self.parseQueue) {
            do {
                let htmlString = try String(contentsOfFile: file, encoding: NSUTF8StringEncoding)
                let result = self.parseData(htmlString, regularText: "(?<=video_url: ').*?(?=',)")
                
                var vItem: PDVideoItem?
                var error: NSError?
                
                if result.count > 0 {
                     vItem = PDVideoItem(url: nil, target: nil, duration: nil, thumbUrl: nil, coverWidth: 0, coverHeight: 0, videoUrl: result.first)
                } else {
                    error = NSError(domain: "parse data", code: -3, userInfo: [NSLocalizedFailureReasonErrorKey: "parse data error"])
                }
                
                dispatch_async(dispatch_get_main_queue(), { 
                    complete(vItem, error)
                })
                
            } catch {
                dispatch_async(dispatch_get_main_queue(), { 
                    complete(nil, NSError(domain: "parse data", code: -2, userInfo: [NSLocalizedFailureReasonErrorKey: "parse detail video fail..."]))
                })
            }
        }
    }
}