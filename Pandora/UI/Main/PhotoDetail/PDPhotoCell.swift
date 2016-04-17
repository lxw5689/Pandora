//
//  PDPhotoCell.swift
//  Pandora
//
//  Created by xiangwenlai on 16/4/3.
//  Copyright © 2016年 xiangwenlai. All rights reserved.
//

import UIKit

class PDPhotoCell: UICollectionViewCell, UIScrollViewDelegate {
    
    @IBOutlet weak var contentScrollView: UIScrollView!
    @IBOutlet weak var photoView: UIImageView!
    
    @IBOutlet weak var photoViewLeadingCons: NSLayoutConstraint!
    @IBOutlet weak var photoViewTrailingCons: NSLayoutConstraint!
    @IBOutlet weak var photoViewTopCons: NSLayoutConstraint!
    @IBOutlet weak var photoViewBottomCons: NSLayoutConstraint!
    
    var url: String?
    var isLoading: Bool = false
    var zoomed: Bool = false
    var item: PDPhotoItem?
    var doubleTapGesture: UITapGestureRecognizer!
    
    override func awakeFromNib() {
        
        self.doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(PDPhotoCell.onDoubleTapGesture))
        self.doubleTapGesture.numberOfTapsRequired = 2
        self.contentScrollView.addGestureRecognizer(self.doubleTapGesture)
        self.contentScrollView.delegate = self
    }
    
    override func prepareForReuse() {
        self.isLoading = false
        self.zoomed = false
        self.url = nil
        self.contentScrollView.delegate = self
        self.contentScrollView.minimumZoomScale = 1
        self.contentScrollView.maximumZoomScale = 1
        self.contentScrollView.zoomScale = 1
        self.photoView.frame = self.contentScrollView.bounds
        self.contentScrollView.zoomScale = 1
        print("....")
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
            
            PDDownloader.sharedDownloader.requestImage(item.coverUrl!, completion: { (image, error) in
                
                if error != nil {
                    print("request photo detail fail:\(item.coverUrl!)")
                } else if image != nil {
                    self.setImage(image)
                } else {
                    print("request image nil...")
                }
                
            })
        }
    }
    
    func setImage(image: UIImage?) {
        
        if image == nil {
            self.photoView.image = nil
            self.contentScrollView.maximumZoomScale = 1.0
        } else {
            let imgSize = image!.size
            let scrSize = UIScreen.mainScreen().bounds.size
            let wRate = scrSize.width / imgSize.width
            let hRate = scrSize.height / imgSize.height
            
            let minRate = min(wRate, hRate)
            self.contentScrollView.minimumZoomScale = minRate
            self.contentScrollView.maximumZoomScale = 2
            
            print("minScale:\(minRate) imageSize:\(imgSize)")
            print("cons:\(self.photoViewTopCons.constant), \(self.photoViewBottomCons.constant), \(self.photoViewLeadingCons.constant), \(self.photoViewTrailingCons.constant)")

            self.photoView.image = image
            self.photoView.frame = CGRectMake(0, 0, imgSize.width, imgSize.height)
            self.contentScrollView.zoomScale = minRate
            
            self.contentScrollView.pinchGestureRecognizer?.removeTarget(self, action: #selector(PDPhotoCell.onPinchGesture))
            self.contentScrollView.pinchGestureRecognizer?.addTarget(self, action: #selector(PDPhotoCell.onPinchGesture))
        }
    }
    
    func onDoubleTapGesture(gesture: UITapGestureRecognizer) {
        
        var point = gesture.locationInView(self.contentScrollView)
        
        var zoomScale = self.contentScrollView.maximumZoomScale
        if self.contentScrollView.zoomScale >= zoomScale {
            point = CGPointMake(self.photoView.bounds.width / 2, self.photoView.bounds.height / 2)
            zoomScale = self.contentScrollView.minimumZoomScale
        }
        let zoomSize = CGSizeMake(self.contentScrollView.bounds.width / zoomScale, self.contentScrollView.bounds.height / zoomScale)
        
        let zoomRect = CGRectMake(point.x - zoomSize.width / 2, point.y - zoomSize.height / 2, zoomSize.width, zoomSize.height)
        
        self.contentScrollView.zoomToRect(zoomRect, animated: true)
    }
    
    func onPinchGesture(gesture: UIPinchGestureRecognizer) {
        
        let zoomScale = min(gesture.scale, self.contentScrollView.maximumZoomScale)
        self.contentScrollView.setZoomScale(zoomScale, animated: false)
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        
        return self.photoView
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        print("scollview fr:\(self.contentScrollView.frame), contentSize:\(self.contentScrollView.contentSize), offset:\(self.contentScrollView.contentOffset), inset:\(self.contentScrollView.contentInset) photoviewfr:\(self.photoView.frame)")
        print("zoomScale:\(self.contentScrollView.zoomScale)")
        var fr = self.photoView.frame
        fr.origin = CGPointZero
        
        if fr.width < self.contentScrollView.frame.width {
            fr.origin.x = (self.contentScrollView.frame.width - fr.width ) / 2
        }
        if fr.height < self.contentScrollView.frame.height {
            fr.origin.y = (self.contentScrollView.frame.height - fr.height) / 2
        }
        self.photoView.frame = fr
    }
}
