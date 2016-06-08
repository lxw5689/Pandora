//
//  PDVideoPlayView.swift
//  Pandora
//
//  Created by xiangwenlai on 16/5/28.
//  Copyright © 2016年 xiangwenlai. All rights reserved.
//

import UIKit
import AVFoundation

class PDVideoPlayView : UIView {
    
    override class func layerClass() -> AnyClass {
        return AVPlayerLayer.self
    }
    
    func setPlayer(player: AVPlayer?) {
        (self.layer as! AVPlayerLayer).player = player
    }
}
