//
//  PDMediaCollectionViewLayout.swift
//  Pandora
//
//  Created by xiangwenlai on 16/3/19.
//  Copyright © 2016年 xiangwenlai. All rights reserved.
//

import UIKit

protocol PDMediaLayoutDataSource {
    func mediaItemCount() -> Int
    func mediaItemDataArr() -> Array<PDMediaItem>?
    func isReflesh() -> Bool
    func newAppendCount() -> Int
}

class PDMediaCollectionViewLayout: UICollectionViewLayout {
    
    let leftRightMargin: Float = 15
    let itemSpaceGap: Float = 10
    
    var column: Int?
    var attrItems: Array<UICollectionViewLayoutAttributes>?
    var dataSource: PDMediaLayoutDataSource?
    var mediaItems: Array<PDMediaItem>?
    
    var columYArr: Array<Float>?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(col: Int, dataSource: PDMediaLayoutDataSource?) {
        
        self.column = col
        self.attrItems = []
        self.dataSource = dataSource
        
        super.init()
    }
    
    override func prepareLayout() {
        super.prepareLayout()
        
        if self.dataSource != nil {
            
            self.mediaItems = self.dataSource!.mediaItemDataArr()
         
            if self.dataSource!.isReflesh() {
                self.attrItems?.removeAll()
                self.columYArr = []
            }
            self.layoutAttributeItems()
        }
    }
    
    func layoutAttributeItems() {
        
        guard self.column > 0 && self.mediaItems != nil
            else {
                return
        }
        
        let collectionViewWidth = self.collectionView?.bounds.size.width
        let itemWidth = (Float(collectionViewWidth!) - self.leftRightMargin * 2 - Float((self.column! - 1)) * self.itemSpaceGap) / Float(self.column!)
        
        let begin = self.dataSource!.isReflesh() ? 0 : (self.mediaItems!.count - self.dataSource!.newAppendCount())
        print("begin:\(begin)")
        for index in begin ..< (self.mediaItems?.count)! {
            
            let (minIndex, minOffsetY) = self.getMinYOfColumn()
            
            let mediaItem = self.mediaItems![index]
            let wScale = itemWidth / mediaItem.coverWidth
            let height = mediaItem.coverHeight * wScale
            
            let itemFr = CGRectMake(CGFloat(self.leftRightMargin) + CGFloat(minIndex) * CGFloat((itemWidth + self.itemSpaceGap)),
                minOffsetY + CGFloat(self.itemSpaceGap), CGFloat(itemWidth), CGFloat(height))
            
            if minIndex < self.columYArr?.count {
                self.columYArr?[minIndex] = Float(CGRectGetMaxY(itemFr))
            }
            else {
                self.columYArr?.append(Float(CGRectGetMaxY(itemFr)))
            }
            
            
            let attItem: UICollectionViewLayoutAttributes = UICollectionViewLayoutAttributes(forCellWithIndexPath: NSIndexPath(forItem: index, inSection: 0))
            
            attItem.frame = itemFr
            self.attrItems?.append(attItem)
        }
        
    }
    
    func getMinYOfColumn() -> (Int, CGFloat) {
        
        var minY: CGFloat = 0
        var col: Int = 0
        
        for index in 0 ..< Int(self.column!) {
            
            if index >= self.columYArr?.count {
                col = index
                minY = 0
                break
            }
            
            let temp = self.columYArr![index]
            
            if index == 0 {
                minY = CGFloat(temp)
                continue
            }

            if CGFloat(temp) < minY {
                minY = CGFloat(temp)
                col = index
            }
        }
        
        return (col, minY)
        
    }
    
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        var attArr: [UICollectionViewLayoutAttributes] = [UICollectionViewLayoutAttributes]()
        
        for (_, item) in (self.attrItems?.enumerate())! {
            
            if CGRectIntersectsRect(rect, item.frame) {
                attArr.append(item)
            }
            
        }
        
        return attArr
        
    }

    override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        
        guard indexPath.item < self.attrItems?.count else {
                return nil
        }
        
        
        return self.attrItems?[indexPath.item]
    }

    override func collectionViewContentSize() -> CGSize {
        
        guard self.columYArr?.count > 0 else {
            return CGSizeZero
        }
        
        var maxHeight: Float = 0
        
        for (_, height) in (self.columYArr?.enumerate())! {
            
            if height > maxHeight {
                maxHeight = height
            }
        }
        
        return CGSizeMake((self.collectionView?.bounds.width)!, CGFloat(maxHeight + self.leftRightMargin))
    }
}
