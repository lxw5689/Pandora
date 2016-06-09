//
//  PDRefleshView.swift
//  Pandora
//
//  Created by xiangwenlai on 16/6/9.
//  Copyright © 2016年 xiangwenlai. All rights reserved.
//

import UIKit

class PDRefleshView: UIView {
    
    enum PDRefleshState {
        case Initial, Pulling, ReleasePullingToReflesh, Loading, Finish
    }
    
    @IBOutlet weak var loadingView: UIActivityIndicatorView!
    
    @IBOutlet weak var tipsLabel: UILabel!
    
    var state: PDRefleshState = .Initial {
        didSet {
            let tipsDict = [PDRefleshState.Initial: "下拉刷新",
                            PDRefleshState.Pulling: "下拉刷新",
                            PDRefleshState.ReleasePullingToReflesh: "释放刷新",
                            PDRefleshState.Loading: "加载中...",
                            PDRefleshState.Finish: "下拉刷新"]
            tipsLabel.text = tipsDict[state]
            if state == .Loading {
                loadingView.startAnimating()
            } else {
                loadingView.stopAnimating()
            }
        }
    }
    
    static func instanceFromXib() -> PDRefleshView? {
        let nib = UINib(nibName: "PDRefleshView", bundle: nil)
        let view = nib.instantiateWithOwner(nil, options: nil).first
        
        return view as? PDRefleshView
    }
}
