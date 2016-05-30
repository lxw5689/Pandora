//
//  PDVideoProgressBar.swift
//  Pandora
//
//  Created by xiangwenlai on 16/5/28.
//  Copyright © 2016年 xiangwenlai. All rights reserved.
//

import UIKit

class PDVideoProgressBar: UIView {
    private static let barHeight: CGFloat = 2
    var playProgress: CGFloat = 0 {
        didSet {
            if playProgress < 0 {
                playProgress = 0
            } else if playProgress > 1 {
                playProgress = 1
            }
            self.setNeedsDisplay()
        }
    }
    var loadProgress: CGFloat = 0 {
        didSet {
            if loadProgress < 0 {
                loadProgress = 0
            } else if loadProgress > 1 {
                loadProgress = 1
            }
            self.setNeedsDisplay()
        }
    }
    
    
    var duration: Int = 0
    var time: Int = 0
    
    func textWithTime(time: Int) -> String {
        let h = time / 3600
        let m = (time - h * 3600) / 60
        let s = time % 60
        
        var timeString = ""
        if h > 0 {
            timeString = String(format: "%02d:%02d:%02d", h, m, s)
        } else {
            timeString = String(format: "%02d:%02d", m, s)
        }
        
        return timeString
    }
    
    override func drawRect(rect: CGRect) {
        let ctx = UIGraphicsGetCurrentContext()
        UIGraphicsPushContext(ctx!)
        
        //draw duration text.
        let curTimeText = self.textWithTime(time)
        let durationTimeText = self.textWithTime(duration)
        let font = UIFont.systemFontOfSize(13)
        let textColor = UIColor.whiteColor()
        let txtAttr = [NSFontAttributeName: font, NSForegroundColorAttributeName: textColor]
        
        let gap: CGFloat = 10
        let curTimePos = CGPoint(x: 10, y: (rect.height - font.lineHeight) / 2)
        curTimeText.drawAtPoint(curTimePos, withAttributes: txtAttr)
        
        let durTimeTxtSize = durationTimeText.sizeWithAttributes(txtAttr)
        let durTimePos = CGPoint(x: rect.width - 10 - durTimeTxtSize.width, y: (rect.height - font.lineHeight) / 2)
        durationTimeText.drawAtPoint(durTimePos, withAttributes: txtAttr)
        
        //draw bar
        let barWidth = durTimePos.x - gap - (curTimePos.x + durTimeTxtSize.width + gap)
        var barFr = CGRect(x: curTimePos.x + durTimeTxtSize.width + gap, y: (rect.height - PDVideoProgressBar.barHeight) / 2, width: barWidth, height: PDVideoProgressBar.barHeight)
        
        CGContextSetStrokeColorWithColor(ctx, UIColor.whiteColor().CGColor)
        CGContextSetLineWidth(ctx, 0.5)
        CGContextSetLineCap(ctx, .Butt)
        CGContextStrokeRect(ctx, barFr)
        
        if playProgress > 0 {
            barFr.size.width = barWidth * playProgress
            CGContextSetFillColorWithColor(ctx, UIColor.redColor().CGColor)
            CGContextFillRect(ctx, barFr)
        }
        
        
        if loadProgress > 0 {
            barFr.size.width = barWidth * loadProgress
            CGContextSetFillColorWithColor(ctx, UIColor.whiteColor().CGColor)
            UIGraphicsPopContext()
        }
    }
}
