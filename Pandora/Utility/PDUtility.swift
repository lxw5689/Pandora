//
//  PDUtility.swift
//  Pandora
//
//  Created by xiangwenlai on 16/4/2.
//  Copyright © 2016年 xiangwenlai. All rights reserved.
//

import UIKit

//MARK: Color utils
extension UIColor {
    
    static func colorWithHexString(hex: String) -> UIColor? {
        let scanner = NSScanner(string: hex)
        var value: UInt32 = 0
        if scanner.scanHexInt(&value) {
            
            let blue: CGFloat = CGFloat(Double(value & 0xff) / 255.0)
            let green: CGFloat = CGFloat(Double((value >> 8) & 0xff) / 255.0)
            let red: CGFloat = CGFloat(Double((value >> 16) & 0xff) / 255.0)
            
            let color = UIColor(red: red, green: green, blue: blue, alpha: 1)
            
            return color
            
        } else {
            return nil
        }
    }
    
}