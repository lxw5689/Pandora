//
//  ViewController.swift
//  Pandora
//
//  Created by xiangwenlai on 16/3/13.
//  Copyright © 2016年 xiangwenlai. All rights reserved.
//

import UIKit

class PDMainViewController: UIViewController {
    
    @IBOutlet weak var containerView: UIView!
    
    var vcsArr: Array<UICollectionViewController>
    
    var curDisplayVC: UICollectionViewController?
    
    required init?(coder aDecoder: NSCoder) {
        
        let photoViewController: PDPhotoViewController = PDPhotoViewController.instanceFromNib()
        let videoViewController: PDVideoViewController = PDVideoViewController.instanceFromNib()
        
        self.vcsArr = [photoViewController, videoViewController]
        
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.showMediaViewController(self.vcsArr[0])
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func showMediaViewController(displayVC : UICollectionViewController) {
        
        if self.curDisplayVC != nil {
            self.curDisplayVC!.willMoveToParentViewController(nil)
            self.curDisplayVC!.view.removeFromSuperview()
            self.curDisplayVC!.removeFromParentViewController()
        }
        
        self.addChildViewController(displayVC)
        self.containerView.addSubview(displayVC.view)
        displayVC.didMoveToParentViewController(self)

        displayVC.view.frame = self.containerView.bounds
        displayVC.view.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
        
        print("\(self.containerView.bounds)")
        
        self.curDisplayVC = displayVC
    }
    
    @IBAction func onPhotoAction(sender: AnyObject) {
        
        let photoVC = self.vcsArr[0]
        
        self.showMediaViewController(photoVC)
        
    }
    
    @IBAction func onVideoAction(sender: AnyObject) {
        
        let videoVC = self.vcsArr[1]
        
        self.showMediaViewController(videoVC)
        
    }
    
  }

