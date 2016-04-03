//
//  PDVideoViewController.swift
//  Pandora
//
//  Created by xiangwenlai on 16/3/19.
//  Copyright © 2016年 xiangwenlai. All rights reserved.
//

import UIKit

class PDVideoViewController: UICollectionViewController {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(collectionViewLayout layout: UICollectionViewLayout) {
        super.init(collectionViewLayout: layout)
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.collectionView!.collectionViewLayout = UICollectionViewFlowLayout()
        self.collectionView?.backgroundColor = UIColor(red: 0.57, green: 0.45, blue: 0.98, alpha: 1);
        
    }
    
}
