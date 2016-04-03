//
//  PDCollectionViewLoadMore.swift
//  Pandora
//
//  Created by xiangwenlai on 16/4/2.
//  Copyright © 2016年 xiangwenlai. All rights reserved.
//

import Foundation
import UIKit

//MARK: uicollection view load more
extension UICollectionView {
    
    private static let threshold = 40
    
    private struct PropertyAssociateKey {
        private static var obsAddKey = 0
        private static var loadmoreKey = 1
        private static var loadMoreActionKey = 2
    }
    
    private class PDActionWrapper {
        
        var action: (Void -> Void)
        
        init(action: (Void -> Void)) {
            self.action = action
        }
        
    }
    
    override public func willMoveToSuperview(newSuperview: UIView?) {
        
        super.willMoveToSuperview(newSuperview)
        
        let addObs = self.observerSet
        if newSuperview == nil && addObs != nil && addObs! {
            self.removeObserver(self, forKeyPath: "contentOffset")
            self.removeObserver(self, forKeyPath: "contentSize")
        }
    }
    
    var observerSet: Bool? {
        get {
            let obj = objc_getAssociatedObject(self, &PropertyAssociateKey.obsAddKey)
            
            return (obj as? NSNumber)?.boolValue
        }
        set {
            if newValue != nil {
                objc_setAssociatedObject(self, &PropertyAssociateKey.obsAddKey, NSNumber(bool: newValue!), .OBJC_ASSOCIATION_RETAIN)
            }
        }
    }
    
    var loadMoreView: PDMLoadMoreView? {
        get {
            let obj = objc_getAssociatedObject(self, &PropertyAssociateKey.loadmoreKey)
            
            return obj as? PDMLoadMoreView
        }
        set {
            if newValue != nil {
                objc_setAssociatedObject(self, &PropertyAssociateKey.loadmoreKey, newValue!, .OBJC_ASSOCIATION_RETAIN)
            }
        }
    }
    
    var loadMoreAction: (Void -> Void)? {
        get {
            let obj = objc_getAssociatedObject(self, &PropertyAssociateKey.loadMoreActionKey)
            
            let wrapper = obj as? PDActionWrapper
            
            return wrapper?.action
        }
        set {
            if newValue != nil {
                
                let wrapper = PDActionWrapper(action: newValue!)
                objc_setAssociatedObject(self, &PropertyAssociateKey.loadMoreActionKey, wrapper, .OBJC_ASSOCIATION_RETAIN)
            }
        }
        
    }
    
    var isLoadingMore: Bool {
        get {
            return self.loadMoreView?.state == PDMLoadMoreView.PDMLoadMoreState.Loading
        }
    }
    
    func addLoadMoreAction(action: (Void -> Void)) {
        
        let loadMoreView = PDMLoadMoreView.instanceFromNib()
        if loadMoreView != nil {
            loadMoreView?.frame = CGRectMake(0, CGRectGetHeight(self.frame), CGRectGetWidth(self.frame), CGFloat(UICollectionView.threshold))
            self.addSubview(loadMoreView!)
            loadMoreView?.autoresizingMask = .FlexibleWidth
            
            self.loadMoreView = loadMoreView
            self.loadMoreAction = action
        }
        
        self.addObserver(self , forKeyPath: "contentOffset", options: .New, context: nil)
        self.addObserver(self, forKeyPath: "contentSize", options: .New, context: nil)
        self.observerSet = true
    }
    
    public override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        
        if keyPath != nil && keyPath == "contentSize" {
            if let change = change {
                let value = change[NSKeyValueChangeNewKey]
                let contentSize = (value?.CGSizeValue())!
                self.loadMoreView?.frame = CGRectMake(0, contentSize.height, CGRectGetWidth(self.frame), (loadMoreView?.frame.size.height)!)
            }
        }
        
        guard (self.loadMoreView?.state != PDMLoadMoreView.PDMLoadMoreState.Loading
            && self.loadMoreView?.state != PDMLoadMoreView.PDMLoadMoreState.Finish
            && self.contentSize.height >= self.bounds.size.height) else {
                
                if self.loadMoreView?.state == PDMLoadMoreView.PDMLoadMoreState.Loading && self.decelerating {
                    let offsety = self.contentOffset.y + self.contentInset.top - self.contentInset.bottom + self.bounds.size.height - self.contentSize.height
                    
                    if offsety >= CGFloat(UICollectionView.threshold) {
                        self.setContentOffset(CGPointMake(self.contentOffset.x, self.contentSize.height + CGFloat(UICollectionView.threshold) - (self.contentInset.top - self.contentInset.bottom + self.bounds.size.height )), animated: true)
                    }
                }
            return
        }
        
        if keyPath != nil
            && keyPath == "contentOffset"
            && self.loadMoreView?.state != PDMLoadMoreView.PDMLoadMoreState.Loading
            && self.decelerating {
            
            if let change = change {
                let value = change[NSKeyValueChangeNewKey]
                let contentOffset: CGPoint = (value?.CGPointValue())!
                let offsety = contentOffset.y + self.contentInset.top - self.contentInset.bottom + self.bounds.size.height - self.contentSize.height
                self.loadMoreView?.state = PDMLoadMoreView.PDMLoadMoreState.Normal
                
                if offsety >= CGFloat(UICollectionView.threshold) {
                    self.loadMoreView?.state = PDMLoadMoreView.PDMLoadMoreState.Loading
                    self.setContentOffset(CGPointMake(self.contentOffset.x, self.contentSize.height + CGFloat(UICollectionView.threshold) - (self.contentInset.top - self.contentInset.bottom + self.bounds.size.height )), animated: true)
                    if self.loadMoreAction != nil {
                        self.loadMoreAction!()
                    }
                }
            }
            
        }
        
    }
    
    func stopLoadMore(hasMore: Bool) {
        self.loadMoreView?.state = hasMore ? PDMLoadMoreView.PDMLoadMoreState.Normal : PDMLoadMoreView.PDMLoadMoreState.Finish
    }
    
}
