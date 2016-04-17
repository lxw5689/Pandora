//
//  PDPhotoCellEx.swift
//  Pandora
//
//  Created by xiangwenlai on 16/4/14.
//  Copyright © 2016年 xiangwenlai. All rights reserved.
//

import UIKit

class PDPhotoCellEx: UICollectionViewCell, UIScrollViewDelegate {
    let scrollView = UIScrollView()
    let photoView = UIImageView()
    let progressView = PDProgressView()
    
    var url: String?
    var isLoading: Bool = false {
        didSet {
            self.progressView.hidden = !isLoading
        }
    }
    var zoomed: Bool = false
    var item: PDPhotoItem?
    var doubleTapGesture: UITapGestureRecognizer!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(PDPhotoCellEx.onDoubleTapGesture))
        self.doubleTapGesture.numberOfTapsRequired = 2
        
        self.addSubview(self.scrollView)
        self.scrollView.addSubview(self.photoView)
        self.scrollView.addGestureRecognizer(self.doubleTapGesture)
        self.scrollView.delegate = self
        self.scrollView.addSubview(self.progressView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func prepareForReuse() {
        self.isLoading = false
        self.zoomed = false
        self.url = nil
        self.photoView.frame = CGRectZero
        self.scrollView.minimumZoomScale = 1
        self.scrollView.maximumZoomScale = 1
        self.scrollView.zoomScale = 1
        self.progressView.progress = 0
    }
    
    func setPhotoItem(item: PDPhotoItem) {
        
        self.item = item
        self.photoView.image = nil
        if self.isLoading && item.coverUrl != self.url  && self.url != nil {
            PDDownloader.sharedDownloader.cancelImageRequest(self.url!)
            self.url = nil
            self.isLoading = false
        }
        
        if item.coverUrl != nil {
            self.url = item.coverUrl
            self.isLoading = true
            
            PDDownloader.sharedDownloader.requestImage(item.coverUrl!, progress: {
                 (progress) in
                    guard item.coverUrl == self.url else {
                        print("url is not identify, ignore progress...")
                        return
                    }
                    self.progressView.progress = progress
                }, completion: { (image, error) in
                
                    guard item.coverUrl == self.url else {
                        print("url is not identify, ignore...")
                        return
                    }
                    if error != nil {
                        print("request photo detail fail:\(item.coverUrl!)")
                    } else if image != nil {
                        self.setImage(image)
                        self.isLoading = false
                    } else {
                        print("request image nil...")
                    }
                
            })
        }
    }
    
    func setImage(image: UIImage?) {
        
        if image == nil {
            self.photoView.image = nil
            self.scrollView.maximumZoomScale = 1.0
        } else {
            let imgSize = image!.size
            let scrSize = UIScreen.mainScreen().bounds.size
            let wRate = scrSize.width / imgSize.width
            let hRate = scrSize.height / imgSize.height
            
            let minRate = min(wRate, hRate)
            self.scrollView.minimumZoomScale = minRate
            let whRate = imgSize.width / imgSize.height
            if whRate > 1.2 {
                self.scrollView.maximumZoomScale = hRate
            } else if whRate < 0.3 {
                self.scrollView.maximumZoomScale = wRate
            }
            else {
                self.scrollView.maximumZoomScale = 2
            }
            
//            print("minScale:\(minRate) imageSize:\(imgSize)")
            
            self.photoView.image = image
            self.photoView.frame = CGRectMake(0, 0, imgSize.width, imgSize.height)
            self.scrollView.zoomScale = minRate
            
            self.scrollView.pinchGestureRecognizer?.removeTarget(self, action: #selector(PDPhotoCell.onPinchGesture))
            self.scrollView.pinchGestureRecognizer?.addTarget(self, action: #selector(PDPhotoCell.onPinchGesture))
            self.setNeedsLayout()
        }
    }
    
    func onDoubleTapGesture(gesture: UITapGestureRecognizer) {
        
        var point = gesture.locationInView(self.photoView)
        
        var zoomScale = self.scrollView.maximumZoomScale
        if self.scrollView.zoomScale >= zoomScale {
            point = CGPointMake(self.photoView.bounds.width / 2, self.photoView.bounds.height / 2)
            zoomScale = self.scrollView.minimumZoomScale
        }
        let zoomSize = CGSizeMake(self.scrollView.bounds.width / zoomScale, self.scrollView.bounds.height / zoomScale)
        
        let zoomRect = CGRectMake(point.x - zoomSize.width / 2, point.y - zoomSize.height / 2, zoomSize.width, zoomSize.height)
        
        self.scrollView.zoomToRect(zoomRect, animated: true)
    }
    
    func onPinchGesture(gesture: UIPinchGestureRecognizer) {
        
        let zoomScale = min(gesture.scale, self.scrollView.maximumZoomScale)
        self.scrollView.setZoomScale(zoomScale, animated: false)
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        
        return self.photoView
        
    }
    
    func scrollViewDidZoom(scrollView: UIScrollView) {
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.scrollView.frame = self.bounds
//        print("scollview fr:\(self.scrollView.frame), contentSize:\(self.scrollView.contentSize), offset:\(self.scrollView.contentOffset), inset:\(self.scrollView.contentInset) photoviewfr:\(self.photoView.frame)")
//        print("zoomScale:\(self.scrollView.zoomScale)")
        var fr = self.photoView.frame
        fr.origin = CGPointZero
        
        if fr.width < self.scrollView.frame.width {
            fr.origin.x = (self.scrollView.frame.width - fr.width ) / 2
        }
        if fr.height < self.scrollView.frame.height {
            fr.origin.y = (self.scrollView.frame.height - fr.height) / 2
        }
        self.photoView.frame = fr
        if !self.progressView.hidden {
            self.progressView.center = CGPointMake(self.scrollView.frame.width / 2, self.scrollView.frame.height / 2)
        }
    }
}