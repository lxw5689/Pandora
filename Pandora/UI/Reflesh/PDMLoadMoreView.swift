//
//  PDMLoadMoreView.swift
//  Pandora
//
//  Created by xiangwenlai on 16/4/2.
//  Copyright © 2016年 xiangwenlai. All rights reserved.
//

import UIKit

class PDMLoadMoreView: UIView {
    
    enum PDMLoadMoreState {
        case Init
        case Normal
        case Loading
        case Finish
    }
    
    @IBOutlet weak var loadingIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var tipsLabel: UILabel!
    
    var state: PDMLoadMoreState {
        willSet {
            guard newValue != state else {
                return
            }
        }
        didSet {
            switch state {
            case .Init:
                self.tipsLabel.hidden = true
                self.tipsLabel.text = "上拉加载更多"
                self.loadingIndicatorView.stopAnimating()
            case .Normal:
                self.tipsLabel.hidden = false
                self.tipsLabel.text = "上拉加载更多"
                self.loadingIndicatorView.stopAnimating()
            case .Loading:
                self.loadingIndicatorView.startAnimating()
                self.tipsLabel.hidden = true
            case .Finish:
                self.loadingIndicatorView.stopAnimating()
                self.tipsLabel.text = "全部加载完成"
                self.tipsLabel.hidden = false
            }
        }
    }
    
    static func instanceFromNib() -> PDMLoadMoreView? {
        let nib = UINib(nibName: "PDMLoadMoreView", bundle: nil)
        let view = nib.instantiateWithOwner(nil, options: nil).first
        
        return view as? PDMLoadMoreView
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.state = .Init
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        
    }
}
