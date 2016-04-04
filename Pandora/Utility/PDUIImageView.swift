//
//  PDUIImageView.swift
//  Pandora
//
//  Created by xiangwenlai on 16/3/31.
//  Copyright © 2016年 xiangwenlai. All rights reserved.
//

import UIKit

extension UIImageView {
    
    private struct PropertyAssociateKey {
        private static var urlKey = 0
        private static var loadingKey = 0
    }
    var url: String? {
        get {
            return objc_getAssociatedObject(self, &PropertyAssociateKey.urlKey) as? String
        }
        set {
            var val = newValue
            if newValue == nil {
                val = ""
            }
            objc_setAssociatedObject(self, &PropertyAssociateKey.urlKey, val, .OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    var isLoading: Bool? {
        get {
            let loadingObj = objc_getAssociatedObject(self, &PropertyAssociateKey.loadingKey) as? NSNumber
            
            return loadingObj?.boolValue
        }
        set {
            guard newValue != nil else {
                return
            }
            objc_setAssociatedObject(self, &PropertyAssociateKey.loadingKey, NSNumber(bool: newValue!), .OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    func setImageUrl(url: String?) {
        
        if url == nil {
            self.image = nil
            self.url = nil
        } else if url!.hasPrefix("http") {
            
            if let loading = self.isLoading where loading  && self.url != nil {
                PDDownloader.sharedDownloader.cancelImageRequest(self.url!)
                self.isLoading = false
            }
            self.url = url
            self.isLoading = true
            PDDownloader.sharedDownloader.requestImage(url!, completion: {
                
                (image, error) in
                    
                guard url == self.url else {
                    return
                }
                
                self.isLoading = false
                if image != nil {
                    self.image = image
                } else {
                    print("download image error:\(error)")
                    self.image = nil
                }
                self.setNeedsDisplay()
            })
            
        }
    }
}
