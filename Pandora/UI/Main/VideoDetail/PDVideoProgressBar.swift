//
//  PDVideoProgressBar.swift
//  Pandora
//
//  Created by xiangwenlai on 16/5/28.
//  Copyright © 2016年 xiangwenlai. All rights reserved.
//

import UIKit

class PDVideoProgressBar: UIView {
    typealias PDProgressChangeHandler = (CGFloat) -> Void
    
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
    
    var seekingTime: Bool = false
    var duration: Int = 0
    var time: Int = 0
    var timeBarRect: CGRect = CGRectZero
    var progressChangeHandler: PDProgressChangeHandler? = nil
    var seekEnable: Bool = false {
        didSet {
            self.userInteractionEnabled = seekEnable
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(PDVideoProgressBar.panGestureAction))
        self.addGestureRecognizer(panGesture)
        self.userInteractionEnabled = false
    }
    
    func panGestureAction(gesture: UIPanGestureRecognizer) {
        if timeBarRect.width > 0 {
            var point = gesture.locationInView(self)
            
            if point.x < timeBarRect.minX {
                point.x = timeBarRect.minX + 1
            } else if point.x > timeBarRect.maxX {
                point.x = timeBarRect.maxX
            }
            
            let offset = point.x - timeBarRect.minX
            let progress = offset / timeBarRect.width
            playProgress = progress
            seekingTime = true
            time = Int(progress * CGFloat(duration))
            
            if progressChangeHandler != nil && gesture.state == .Ended {
                progressChangeHandler!(progress)
            }
        }
    }
    
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
        timeBarRect = barFr
        
        CGContextSetStrokeColorWithColor(ctx, UIColor.whiteColor().CGColor)
        CGContextSetLineWidth(ctx, 0.5)
        CGContextSetLineCap(ctx, .Butt)
        CGContextStrokeRect(ctx, barFr)
        
        if loadProgress > 0 {
            barFr.size.width = barWidth * loadProgress
            CGContextSetFillColorWithColor(ctx, UIColor.whiteColor().CGColor)
            CGContextFillRect(ctx, barFr)
            UIGraphicsPopContext()
        }
        
        if playProgress > 0 {
            barFr.size.width = barWidth * playProgress
            CGContextSetFillColorWithColor(ctx, UIColor.redColor().CGColor)
            CGContextFillRect(ctx, barFr)
            
            //draw pos
            let r: CGFloat = 4
            let path = UIBezierPath(ovalInRect: CGRect(x: barFr.maxX - r, y: barFr.midY - r, width: r * 2, height: r * 2))
            UIColor.redColor().setFill()
            path.fill()
        }
    }
}
