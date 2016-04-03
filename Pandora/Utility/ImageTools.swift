//
//  imageTools.swift
//  Pandora
//
//  Created by xiangwenlai on 16/3/13.
//  Copyright © 2016年 xiangwenlai. All rights reserved.
//

import Foundation
import UIKit


extension UIImage {
    
    public static func resizeImage(image : UIImage, size : CGSize) -> UIImage {
        
        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.mainScreen().scale);
        
        image.drawInRect(CGRectMake(0, 0, size.width, size.height));
        
        let resultImg : UIImage = UIGraphicsGetImageFromCurrentImageContext();
        
        return resultImg;
    }
    
}

class PDTool : NSObject {
    
    func beginMakeIcon(sizeArr : Array<CGSize>, name: String) {
        
        for size: CGSize in sizeArr {
            
            self.makeIcon(name, size: size)
        }
    }
    
    func makeIcon(name : String, size : CGSize) {
        
        let image : UIImage? = UIImage(named: name);
        guard (image != nil)
            else {
                return
        }
        let docPath = self.pathToSaveImage()
        
        let resizeImg = UIImage.resizeImage(image!, size: size)
        let data = UIImagePNGRepresentation(resizeImg)
        
        print(docPath)
        
        if let dd = data
        {
            dd.writeToFile(docPath + "/\(Int(size.width*2))x\(Int(size.height * 2)).png", atomically: true)
        }
    }
    
    func pathToSaveImage() -> String {
        
        let pathArr = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true);
        let docPath = pathArr.first!;
        
        return docPath;
    }
    
}