//
//  PDDownloader.swift
//  Pandora
//
//  Created by xiangwenlai on 16/3/27.
//  Copyright © 2016年 xiangwenlai. All rights reserved.
//

import Foundation
import UIKit

class PDDownloader: NSObject, NSURLSessionDataDelegate {
    
    typealias PDMCompletion = (String?, NSError?) -> Void
    typealias PDMImageCompletion = (UIImage?, NSError?) -> Void
    typealias PDMProgressNotify = (CGFloat) -> Void
    
    class PDDownloadItem: NSObject {
        
        var task: NSURLSessionDataTask
        var url: String
        var completions: Array<PDMCompletion>
        var progressNotifiers: Array<PDMProgressNotify>
        var cacher: PDDownloadCacher
        var compCnt: Int = 0
        var contentLength: Int = 0
        var downloadedLength: Int = 0
        var progress: CGFloat {
            get {
                if contentLength <= 0 {
                    return 0
                } else {
                    return CGFloat(self.downloadedLength) / CGFloat(self.contentLength)
                }
            }
        }
        
        init(task: NSURLSessionDataTask, url: String, completion: PDMCompletion?, progress: PDMProgressNotify?) {
            
            self.task = task
            self.url = url
            self.completions = Array<PDMCompletion>()
            self.progressNotifiers = Array<PDMProgressNotify>()
            self.cacher = PDDownloadCacher()
            
            if completion != nil {
                self.completions.append(completion!)
            }
            if progress != nil {
                self.progressNotifiers.append(progress!)
            }
            
            super.init()
        }
    }
    
    
    
    static let sharedDownloader: PDDownloader = PDDownloader()
    var taskDict: Dictionary<NSURLSessionTask, PDDownloadItem> = Dictionary<NSURLSessionTask, PDDownloadItem>()
    
    var session: NSURLSession?
    let downloadQueue = dispatch_queue_create("pandora.downloader", DISPATCH_QUEUE_CONCURRENT)
    let lock = NSRecursiveLock()
    
    private override init() {
        super.init()
        
        self.setupSession()
    }
    
    private func setupSession() {
        
        self.session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
                                    delegate: self,
                                    delegateQueue: nil)
    }
    
    func getDownloadItem(url: String) -> PDDownloadItem? {
        
        var foundItem: PDDownloadItem?
        
        self.lock.lock()
        let tmpTaskDict = self.taskDict
        self.lock.unlock()
        
            for (_, item) in tmpTaskDict {
                if item.url == url {
                    foundItem = item
                    break
                }
            }
        
        return foundItem
    }
    
    func requestData(url: String, ignoreCache: Bool, completion: PDMCompletion?) {
        if !ignoreCache {
            let (hasCache, cachePath) = PDDownloadCacher.sharedCacher.hasCache(url)
            if hasCache && cachePath != nil {
                if completion != nil {
                    completion!(cachePath, nil)
                    return
                }
            }
        }
        
        self.requestData(url, completion: completion)
    }
    
    func requestData(url: String, completion: PDMCompletion?) {
        self.requestData(url, progressNotify: nil, completion: completion)
    }
    
    func requestData(url: String, progressNotify: PDMProgressNotify?, completion: PDMCompletion?) {
        dispatch_async(self.downloadQueue, {
            
            let item = self.getDownloadItem(url)
            
            if item != nil {
                
                if completion != nil {
                    self.lock.lock()
                    item!.completions.append(completion!)
                    item!.compCnt = item!.compCnt + 1
                    self.lock.unlock()
                }
                
                if progressNotify != nil {
                    self.lock.lock()
                    item!.progressNotifiers.append(progressNotify!)
                    if completion == nil {
                        item!.compCnt = item!.compCnt + 1
                    }
                    self.lock.unlock()
                }
                
                return
            }
            
            let resURL: NSURL = NSURL(string: url)!
            let urlReq: NSURLRequest = NSURLRequest(URL: resURL, cachePolicy: .ReloadIgnoringLocalCacheData, timeoutInterval: 60)
            
            let task: NSURLSessionDataTask = self.session!.dataTaskWithRequest(urlReq)
            
            let dlItem = PDDownloadItem(task: task, url: url, completion: completion, progress: progressNotify)
            
            self.lock.lock()
            self.taskDict[task] = dlItem
            self.lock.unlock()
            
            task.resume()
            
        })
    }
    
    func requestImage(url: String, progress: PDMProgressNotify?, completion: PDMImageCompletion?) {
        let (hasCache, cachePath) = PDDownloadCacher.sharedCacher.hasCache(url)
        
        if hasCache && cachePath != nil {
            
            if progress != nil {
                dispatch_async(dispatch_get_main_queue()) {
                    progress!(1)
                }
            }
            if completion != nil {
                let image: UIImage? = UIImage(contentsOfFile: cachePath!)
                dispatch_async(dispatch_get_main_queue()) {
                    completion!(image, nil)
                }
            }
            return
        }
        
        self.requestData(url, progressNotify: progress, completion: {
            
            (cachePath, error) in
            
            if error == nil  && cachePath != nil {
                let image: UIImage? = UIImage(contentsOfFile: cachePath!)
                if completion != nil {
                    dispatch_async(dispatch_get_main_queue()) {
                        completion!(image, nil)
                    }
                }
            } else {
                if completion != nil {
                    dispatch_async(dispatch_get_main_queue()) {
                        completion!(nil, error)
                    }
                }
            }
            
        })

    }
    
    func requestImage(url: String, completion: PDMImageCompletion?) {
        self.requestImage(url, progress: nil, completion: completion)
    }
    
    func cancelImageRequest(url: String) {
        
        dispatch_async(self.downloadQueue, {
            let item = self.getDownloadItem(url)
            if item != nil {
                self.lock.lock()
                item!.compCnt = item!.compCnt - 1
                let remainCnt = item!.compCnt
                if remainCnt <= 0 {
                    item!.task.cancel()
                    self.taskDict.removeValueForKey(item!.task)
                }
                self.lock.unlock()
            }
        })
    }
    
}

//urlsessiontask delegate
extension PDDownloader {
    
    func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveResponse response: NSURLResponse, completionHandler: (NSURLSessionResponseDisposition) -> Void) {
        
//        print("received response \(response)")
//        print("contentlength:\(response.expectedContentLength)")
        
        completionHandler(.Allow)
        
        let item = self.taskDict[dataTask]
        item?.contentLength = Int(response.expectedContentLength)
        
        if let dlItem = item {
            
            dlItem.cacher.openFileOfUrl(dlItem.url)
            
        }
        
    }
    
    func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveData data: NSData) {
        
        let item = self.taskDict[dataTask]
        
        if let dlItem = item {
            
            if dlItem.cacher.writeData(data) == data.length {
                dlItem.downloadedLength += data.length
                
                self.lock.lock()
                let progressArr = dlItem.progressNotifiers
                self.lock.unlock()
                let progress = dlItem.progress
                
                if progressArr.count > 0 {
                    dispatch_async(dispatch_get_main_queue()) {
                        for progressNotifier in progressArr {
                            progressNotifier(progress)
                        }
                    }
                }
            } else {
                print("write data fail..")
            }
            
        }
        
    }
    
    func URLSession(session: NSURLSession, task: NSURLSessionTask, willPerformHTTPRedirection response: NSHTTPURLResponse, newRequest request: NSURLRequest, completionHandler: (NSURLRequest?) -> Void) {
        
        print("perform redirection newRequest:\(request.URL)")
        
        completionHandler(request)
        
    }
    
    func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
        
        dispatch_async(self.downloadQueue) {
            
            let item = self.taskDict[task]
            
            if let dlItem = item {
                
                dlItem.cacher.closeFileOfUrl(dlItem.url)
                dlItem.cacher.finishDownloadFile(dlItem.url)
                
                self.lock.lock()
                let comps = dlItem.completions
                for completion in comps {
                    
                    completion((error != nil) ? nil : dlItem.cacher.cachePath(dlItem.url), error)
                    
                }
                
                self.taskDict.removeValueForKey(task)
                self.lock.unlock()
            }
        }
    }
}
