//
//  PDProgressView.swift
//  Pandora
//
//  Created by xiangwenlai on 16/4/17.
//  Copyright © 2016年 xiangwenlai. All rights reserved.
//

import UIKit

private let PDProgressViewSize: CGFloat = 40

class PDProgressView: UIView {
    
    var progress: CGFloat = 0 {
        didSet {
            if progress > 1 {
                progress = 1
            } else if progress <= 0 {
                progress = 0.01
            }
            self.setNeedsDisplay()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init() {
        super.init(frame: CGRectMake(0, 0, PDProgressViewSize, PDProgressViewSize))
    }
    
    override func drawRect(rect: CGRect) {
        let ctx = UIGraphicsGetCurrentContext()
        
        if let ctx = ctx {
            UIGraphicsPushContext(ctx)
            
            CGContextClearRect(ctx, rect)
            CGContextBeginPath(ctx)
            CGContextAddArc(ctx, rect.width / 2, rect.height / 2, (rect.width / 2 - 4), CGFloat(-M_PI_2), CGFloat(-M_PI_2) + CGFloat(M_PI * 2) * self.progress, 0)
            CGContextSetStrokeColorWithColor(ctx, UIColor.whiteColor().CGColor)
            CGContextSetLineWidth(ctx, 2)
            CGContextSetLineCap(ctx, .Round)
            CGContextStrokePath(ctx)
            
            UIGraphicsPopContext()
        }
    }
}
