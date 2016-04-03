//
//  PDDownloadCacher.swift
//  Pandora
//
//  Created by xiangwenlai on 16/3/27.
//  Copyright © 2016年 xiangwenlai. All rights reserved.
//

import Foundation

class PDDownloadCacher: NSObject {
    
    static let sharedCacher: PDDownloadCacher = PDDownloadCacher()
    
    var outStream: NSOutputStream?
    
    override init() {
        super.init()
        
        self.setupCachePath()
    }
    
    deinit {
        if self.outStream != nil {
            self.outStream?.close()
            self.outStream = nil
        }
    }
    
    private func setupCachePath() {
        
        let cacheDir = self.cachePath()
        
        if !NSFileManager.defaultManager().fileExistsAtPath(cacheDir) {
            
            do {
                try NSFileManager.defaultManager().createDirectoryAtPath(cacheDir, withIntermediateDirectories: true, attributes: nil)
            } catch _ {
                print("create pdm cache dir error")
            }
        }
        
        let tempCacheDir = self.tempCachePath()
        
        if !NSFileManager.defaultManager().fileExistsAtPath(tempCacheDir) {
            
            do {
                try NSFileManager.defaultManager().createDirectoryAtPath(tempCacheDir, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("create temp cache dir error")
            }
            
        }
        
    }
    
    private func cachePath() -> String {
        
        let pathArr = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        
        let documentPath = pathArr.first!
        let cacheDir = documentPath.stringByAppendingString("/PDMCache")
        
        return cacheDir
    }
    
    private func tempCachePath() -> String {
        
        let pathArr = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        
        let documentPath = pathArr.first!
        let cacheDir = documentPath.stringByAppendingString("/TempCache")
        
        return cacheDir
    }
    
    func tempCachePath(url: String) -> String {
        
        let path = self.tempCachePath()
        let tempCacheFilePath = path.stringByAppendingFormat("/%d", abs(url.hashValue))
        
        return tempCacheFilePath
    }
    
    func cachePath(url: String) -> String {
    
        let path = self.cachePath()
        
        let cacheFilePath = path.stringByAppendingFormat("/%d", abs(url.hashValue))
        
        return cacheFilePath
    }
    
    func writeData(data: NSData) -> Int {
        
        let length: Int = data.length
        
        if self.outStream != nil {
            
            return self.outStream!.write(UnsafePointer<UInt8>(data.bytes), maxLength: length)
        }
        
        return 0
    }
    
    func openFileOfUrl(url: String) {
        
        let filePath = self.tempCachePath(url)
        
        if NSFileManager.defaultManager().fileExistsAtPath(filePath) {
        
            do {
                try NSFileManager.defaultManager().removeItemAtPath(filePath)
            } catch _ {
                
            }
        }
        
        if !NSFileManager.defaultManager().createFileAtPath(filePath, contents: nil, attributes: nil) {
            
            print("ceate file failed...")
            
        }
        
        if self.outStream != nil {
            self.outStream?.close()
        }
        
        self.outStream = NSOutputStream(toFileAtPath: filePath, append: true)
        self.outStream?.open()
    }
    
    func closeFileOfUrl(url: String) {
        
        if self.outStream != nil {
            self.outStream?.close()
            self.outStream = nil
        }
    }
    
    func hasCache(url: String) -> (Bool, String?) {
        
        let cachePath = self.cachePath(url)
        
        let hasCache = NSFileManager.defaultManager().fileExistsAtPath(cachePath)
        
        return (hasCache, hasCache ? cachePath : nil)
    }
    
    func finishDownloadFile(url: String) {
        
        let cacheFile = self.cachePath(url)
        let tempFile = self.tempCachePath(url)
        
        do {
            if NSFileManager.defaultManager().fileExistsAtPath(cacheFile) {
                try NSFileManager.defaultManager().removeItemAtPath(cacheFile)
            }
            try NSFileManager.defaultManager().moveItemAtPath(tempFile, toPath: cacheFile)
        } catch {
            print("move file fail...")
        }
    }
}
