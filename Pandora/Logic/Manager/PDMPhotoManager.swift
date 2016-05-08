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
        
        PDDataParser.sharedParser.parsePhotoItems(file) { (photoItems, error) in
            if photoItems != nil {
                if self.curPage == 1 {
                    self.phDataSource.addNewMediaItems(photoItems!, reflesh: true)
                } else {
                    self.phDataSource.addNewMediaItems(photoItems!, reflesh: false)
                }
                self.phDataSource.updateUIMark = true
            }
        }
    }
}