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
        self.contentScrollView.zoomScale = 1.0
        self.contentScrollView.minimumZoomScale = 1.0
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
            let w = minRate * imgSize.width
            let h = minRate * imgSize.height
            
            self.contentScrollView.maximumZoomScale = w / h * 2
            
            self.photoView.image = image
            let vGap = (self.contentScrollView.bounds.height - h) / 2
            let hGap = (self.contentScrollView.bounds.width - w) / 2
            
            self.photoViewTopCons.constant = vGap
            self.photoViewBottomCons.constant = vGap
            self.photoViewLeadingCons.constant = hGap
            self.photoViewTrailingCons.constant = hGap
            
            self.contentScrollView.pinchGestureRecognizer?.removeTarget(self, action: #selector(PDPhotoCell.onPinchGesture))
            self.contentScrollView.pinchGestureRecognizer?.addTarget(self, action: #selector(PDPhotoCell.onPinchGesture))
        }
    }
    
    func onDoubleTapGesture(gesture: UITapGestureRecognizer) {
        
        var point = gesture.locationInView(self.photoView)
        
        var zoomScale = self.contentScrollView.maximumZoomScale
        if self.zoomed {
            point = CGPointMake(self.photoView.bounds.width / 2, self.photoView.bounds.height / 2)
            zoomScale = 1.0
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
    
    func scrollViewDidZoom(scrollView: UIScrollView) {
        
        self.zoomed = !self.zoomed
        self.updatePhotoViewConstraint()
    }
    
    func updatePhotoViewConstraint() {
        
        var w = self.photoView.frame.width
        var h = self.photoView.frame.height
        let image = self.photoView.image
        if let image = image {
            if !self.zoomed {
                let imgSize = image.size
                let scrSize = UIScreen.mainScreen().bounds.size
                let wRate = scrSize.width / imgSize.width
                let hRate = scrSize.height / imgSize.height
                
                let minRate = min(wRate, hRate)
                w = minRate * imgSize.width
                h = minRate * imgSize.height
            }
        }
        

        
        var wGap = (self.contentScrollView.frame.width - w) / 2
        var hGap = (self.contentScrollView.frame.height - h) / 2
        if wGap < 0 {
            wGap = 0
        }
        if hGap < 0 {
            hGap = 0
        }
        
        self.photoViewTopCons.constant = hGap
        self.photoViewBottomCons.constant = hGap
        self.photoViewLeadingCons.constant = wGap
        self.photoViewTrailingCons.constant = wGap
        self.layoutIfNeeded()
    }
}
