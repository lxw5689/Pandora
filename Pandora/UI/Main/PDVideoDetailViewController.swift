//
//  PDVideoDetailViewController.swift
//  Pandora
//
//  Created by xiangwenlai on 16/5/21.
//  Copyright © 2016年 xiangwenlai. All rights reserved.
//

import UIKit
import AVFoundation

class PDVideoDetailViewController: UIViewController {
    
    @IBOutlet weak var videoView: PDVideoPlayView!
    @IBOutlet weak var loadingView: UIActivityIndicatorView!
    
    @IBOutlet weak var progressBar: PDVideoProgressBar!
    @IBOutlet weak var tipsLabel: UILabel!
    var targetUrl: String?
    var videoItem: PDVideoItem!
    var player: AVPlayer!
    var playItem: AVPlayerItem!
    var timeObserver: AnyObject?
    
    static func instanceFromNib() -> PDVideoDetailViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let videoDetailVC = storyboard.instantiateViewControllerWithIdentifier("PDVideoDetailViewController") as! PDVideoDetailViewController
        
        return videoDetailVC
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if targetUrl != nil {
            loadingView.startAnimating()
            PDVideoManager.sharedManager.requestDetailVideo(targetUrl!, complete: { (item, error) in
                self.updateVideoInfo(item, error: error)
            })
        }
    }
    
    func updateVideoInfo(item: PDVideoItem?, error: NSError?) {
        if error != nil || item == nil || item!.videoUrl == nil {
            tipsLabel.text = "视频下载加载失败！"
            tipsLabel.hidden = false
            loadingView.stopAnimating()
        } else {
            tipsLabel.hidden = true
            videoItem = item
            self.setupVideoPlayer()
        }
    }
    
    func setupVideoPlayer() {
        let asset = AVURLAsset(URL: NSURL(string: videoItem.videoUrl!)!)
        if playItem != nil {
            playItem.removeObserver(self, forKeyPath: "status")
        }
        if timeObserver != nil && player != nil {
            player.removeTimeObserver(timeObserver!)
        }
        playItem = AVPlayerItem(asset: asset, automaticallyLoadedAssetKeys: ["duration"])
        player = AVPlayer(playerItem: playItem)
        
        playItem.addObserver(self,
                             forKeyPath: "status",
                             options: .New,
                             context: nil)
        videoView.setPlayer(player)
        timeObserver = player.addPeriodicTimeObserverForInterval(CMTimeMake(30, 60), queue: dispatch_get_main_queue()) { [weak self] (time) in
            self?.updateProgressBar(time)
        }
    }
    
    func updateProgressBar(time: CMTime) {
        let seconds = CMTimeGetSeconds(time)
        let duration = CMTimeGetSeconds(playItem.duration)
        
        if duration > 0 {
            let progress = seconds / duration
            progressBar.playProgress = CGFloat(progress)
            progressBar.time = Int(seconds)
        }
    }
    
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if keyPath != nil && keyPath == "status" {
            if let change = change {
                let value = change[NSKeyValueChangeNewKey]
                let status = value?.integerValue
                
                if status != nil &&  AVPlayerItemStatus(rawValue: status!) == .ReadyToPlay {
                    let duration = CMTimeGetSeconds(playItem.duration)
                    progressBar.duration = Int(duration)
                    player.play()
                    loadingView.stopAnimating()
                }
            }
        }
    }
}