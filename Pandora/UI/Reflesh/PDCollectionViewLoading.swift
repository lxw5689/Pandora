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
    
    private static let refleshHeaderHeight = 80
    private static let threshold = 40
    
    private struct PropertyAssociateKey {
        private static var obsAddKey = 0
        private static var loadmoreKey = 1
        private static var loadMoreActionKey = 2
        private static var refleshKey = 3
        private static var refleshActionKey = 4
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
    
    func setUpObserverIfNeed() {
        if observerSet == nil || !(observerSet!) {
            self.addObserver(self , forKeyPath: "contentOffset", options: .New, context: nil)
            self.addObserver(self, forKeyPath: "contentSize", options: .New, context: nil)
            self.observerSet = true
        }
    }
    
    func handleContentSizeChanged(change: [String: AnyObject]?) {
        guard self.loadMoreView != nil else {
            return
        }
        
        if let change = change {
            let value = change[NSKeyValueChangeNewKey]
            let contentSize = (value?.CGSizeValue())!
            self.loadMoreView?.frame = CGRectMake(0, contentSize.height, CGRectGetWidth(self.frame), (loadMoreView?.frame.size.height)!)
        }
    }
    
    func handleContentOffsetChanged(change: [String: AnyObject]?) {
        let offsetY = self.contentOffset.y + self.contentInset.top - self.contentInset.bottom
        if offsetY < 0 {
            self.handleRefleshLoading(offsetY)
        } else {
            let bOffsetY = offsetY + self.bounds.height - self.contentSize.height
            if bOffsetY > 0 {
                self.handleLoadMoreLoading(bOffsetY)
            }
        }
    }
    
    public override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        
        if keyPath != nil && keyPath == "contentSize" {
            self.handleContentSizeChanged(change)
        } else if keyPath != nil && keyPath == "contentOffset" {
            self.handleContentOffsetChanged(change)
        }
    }
}

//MARK:Reflesh
extension UICollectionView {
    var refleshView: PDRefleshView? {
        get {
            let rfView = objc_getAssociatedObject(self, &PropertyAssociateKey.refleshKey)
            
            return rfView as? PDRefleshView
        }
        set {
            if newValue != nil {
                objc_setAssociatedObject(self, &PropertyAssociateKey.refleshKey, newValue!, .OBJC_ASSOCIATION_RETAIN)
            }
        }
    }
    
    var refleshAction: (Void -> Void)? {
        get {
            let action = objc_getAssociatedObject(self, &PropertyAssociateKey.refleshActionKey)
            
            let wrapper = action as? PDActionWrapper
            
            return wrapper?.action
        }
        set {
            if newValue != nil {
                
                let wrapper = PDActionWrapper(action: newValue!)
                objc_setAssociatedObject(self, &PropertyAssociateKey.refleshActionKey, wrapper, .OBJC_ASSOCIATION_RETAIN)
            }
        }
        
    }
    
    var isRefleshLoading: Bool {
        return self.refleshView?.state == PDRefleshView.PDRefleshState.Loading
    }
    
    func triggerReflesh() {
        guard self.refleshView != nil else {
            return
        }
        
        self.refleshView?.state = PDRefleshView.PDRefleshState.Loading
        dispatch_async(dispatch_get_main_queue()) { 
            self.setContentOffset(CGPoint(x: 0, y: self.contentInset.top - self.contentInset.bottom - CGFloat(UICollectionView.refleshHeaderHeight)), animated: true)
            if self.refleshAction != nil {
                self.refleshAction!()
            }
        }
    }
    
    func stopReflesh() {
        self.refleshView?.state = PDRefleshView.PDRefleshState.Finish
        let offsetY = self.contentOffset.y + self.contentInset.top - self.contentInset.bottom
        if offsetY < 0 {
            self.setContentOffset(CGPoint(x: 0, y: (self.contentInset.top - self.contentInset.bottom)), animated: true)
        }
    }
    
    func addRefleshAction(rfAction: (Void -> Void)) {
        var rfView = self.refleshView
        if rfView == nil {
            rfView = PDRefleshView.instanceFromXib()
            rfView?.frame = CGRect(x: 0, y: -CGFloat(UICollectionView.refleshHeaderHeight), width: self.bounds.width, height: CGFloat(UICollectionView.refleshHeaderHeight))
            rfView?.autoresizingMask = .FlexibleWidth
            self.addSubview(rfView!)
            
            self.refleshView = rfView
            self.refleshAction = rfAction
            
        } else {
            rfView?.frame = CGRect(x: 0, y: 0, width: self.bounds.width, height: CGFloat(UICollectionView.refleshHeaderHeight))
            self.bringSubviewToFront(rfView!)
        }
        self.setUpObserverIfNeed()
    }
    
    func handleRefleshLoading(offsetY: CGFloat) {
        guard self.refleshView != nil else {
            return
        }
        let curState = self.refleshView?.state
        
        if curState == PDRefleshView.PDRefleshState.Loading {
            if self.decelerating {
                self.setContentOffset(CGPoint(x: 0, y: self.contentInset.top - self.contentInset.bottom - CGFloat(UICollectionView.refleshHeaderHeight)), animated: true)
            }
            return
        }
        
        if offsetY < 0 {
            var state = PDRefleshView.PDRefleshState.Pulling
            if (Int(offsetY) <= -60) {
                state = self.decelerating ? PDRefleshView.PDRefleshState.Loading : PDRefleshView.PDRefleshState.ReleasePullingToReflesh
                if state == PDRefleshView.PDRefleshState.Loading  && curState != state {
                    self.setContentOffset(CGPoint(x: 0, y: self.contentInset.top - self.contentInset.bottom - CGFloat(UICollectionView.refleshHeaderHeight)), animated: true)
                    if self.refleshAction != nil {
                        self.refleshAction!()
                    }
                }
            }
            self.refleshView?.state = state
        } else {
            self.refleshView?.state = PDRefleshView.PDRefleshState.Initial
        }
    }
}

//MARK:LoadMore
extension UICollectionView {
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
        
        var loadMoreView = self.loadMoreView
        if loadMoreView == nil {
            loadMoreView = PDMLoadMoreView.instanceFromNib()
            loadMoreView?.frame = CGRectMake(0, CGRectGetHeight(self.frame), CGRectGetWidth(self.frame), CGFloat(UICollectionView.threshold))
            self.addSubview(loadMoreView!)
            loadMoreView?.autoresizingMask = .FlexibleWidth
            
            self.loadMoreView = loadMoreView
            self.loadMoreAction = action
        } else {
            loadMoreView?.frame = CGRectMake(0, CGRectGetHeight(self.frame), CGRectGetWidth(self.frame), CGFloat(UICollectionView.threshold))
            self.bringSubviewToFront(loadMoreView!)
        }
        self.setUpObserverIfNeed()
    }

    
    func stopLoadMore(hasMore: Bool) {
        self.loadMoreView?.state = hasMore ? PDMLoadMoreView.PDMLoadMoreState.Normal : PDMLoadMoreView.PDMLoadMoreState.Finish
    }
    
    func handleLoadMoreLoading(offsetY: CGFloat) {
        
        guard self.loadMoreView != nil else {
            return
        }
        
        guard (self.loadMoreView?.state != PDMLoadMoreView.PDMLoadMoreState.Loading
            && self.loadMoreView?.state != PDMLoadMoreView.PDMLoadMoreState.Finish
            && self.contentSize.height >= self.bounds.size.height) else {
                
                if self.loadMoreView?.state == PDMLoadMoreView.PDMLoadMoreState.Loading && self.decelerating {
                    
                    if offsetY >= CGFloat(UICollectionView.threshold) {
                        self.setContentOffset(CGPointMake(self.contentOffset.x, self.contentSize.height + CGFloat(UICollectionView.threshold) - (self.contentInset.top - self.contentInset.bottom + self.bounds.size.height )), animated: true)
                    }
                }
                return
        }
        
        if self.loadMoreView?.state != PDMLoadMoreView.PDMLoadMoreState.Loading && self.decelerating {
            self.loadMoreView?.state = PDMLoadMoreView.PDMLoadMoreState.Normal
            
            if offsetY >= CGFloat(UICollectionView.threshold) {
                self.loadMoreView?.state = PDMLoadMoreView.PDMLoadMoreState.Loading
                self.setContentOffset(CGPointMake(self.contentOffset.x, self.contentSize.height + CGFloat(UICollectionView.threshold) - (self.contentInset.top - self.contentInset.bottom + self.bounds.size.height )), animated: true)
                if self.loadMoreAction != nil {
                    self.loadMoreAction!()
                }
            }
        }
    }
}


