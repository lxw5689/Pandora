//
//  PDUIImageView.swift
//  Pandora
//
//  Created by xiangwenlai on 16/3/31.
//  Copyright © 2016年 xiangwenlai. All rights reserved.
//

import UIKit

extension UIImageView {
    
    func setImageUrl(url: String?) {
        
        if url == nil {
            self.image = nil
        } else if url!.hasPrefix("http") {
            
            PDDownloader.sharedDownloader.requestImage(url!, completion: {
                
                (image, error) in
                dispatch_async(dispatch_get_main_queue()) {
                    
                    if image != nil {
                        self.image = image
                    } else {
                        print("download image error:\(error)")
                        self.image = nil
                    }
                    self.setNeedsDisplay()
                }
            })
            
        }
        
    }
    
}
