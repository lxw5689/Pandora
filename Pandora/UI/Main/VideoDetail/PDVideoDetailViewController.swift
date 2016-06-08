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
    @IBOutlet weak var closeBtn: UIButton!
    @IBOutlet weak var progressBar: PDVideoProgressBar!
    @IBOutlet weak var tipsLabel: UILabel!
    
    let presentAnimator = PDVideoDetailPresentAnimator()
    let dismissAnimator = PDVideoDetailDismissAnimator()
    
    enum PDPlayerStatus {
        case UnSet, Loading, Play, Pause, Finish
    }
    
    @IBOutlet weak var playBtn: UIButton!
    
    var targetUrl: String?
    var videoItem: PDVideoItem!
    var player: AVPlayer!
    var playItem: AVPlayerItem!
    var timeObserver: AnyObject?
    var isShowingTool = true
    var isAnimating = false
    
    var playStatus: PDPlayerStatus = .UnSet {
        didSet {
            if playStatus == .Play || playStatus == .Pause {
                let isPlaying = (playStatus == .Play)
                playBtn.setBackgroundImage(UIImage(named: isPlaying ? "play" : "pause"), forState: .Normal)
                if isPlaying {
                    self.delayHideTool()
                }
            } else if playStatus == .Loading {
                playBtn.hidden = true
                self.showToolAnimated(true)
            }
        }
    }
    
    static func instanceFromNib() -> PDVideoDetailViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let videoDetailVC = storyboard.instantiateViewControllerWithIdentifier("PDVideoDetailViewController") as! PDVideoDetailViewController
        
        return videoDetailVC
    }
        
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        print("hhh")
    }
    
    @IBAction func closeAction(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func playBtnAction(sender: AnyObject) {
        guard (playStatus == .Play || playStatus == .Pause) else {
            return
        }
        if playStatus == .Play {
            playStatus = .Pause
            player.pause()
        } else {
            playStatus = .Play
            player.play()
        }
    }
    @IBAction func onVideoViewTap(sender: UITapGestureRecognizer) {
        guard !isAnimating else {
            return
        }
        self.showToolAnimated(!isShowingTool)
    }
    
    deinit {
        if timeObserver != nil {
            player.removeTimeObserver(timeObserver!)
        }
        self.unRegisterPlayerItemKVO()
    }
    
    func showToolAnimated(show: Bool) {
        
        guard show != isShowingTool && !isAnimating else {
            return
        }
        
        if show {
            progressBar.hidden = false
            progressBar.alpha = 0
            closeBtn.alpha = 0
            closeBtn.hidden = false
            isAnimating = true
            if playStatus != .Loading {
                playBtn.hidden = false
                playBtn.alpha = 0
            }
            UIView.animateWithDuration(0.3,
                                       delay: 0,
                                       options: .CurveEaseInOut,
                                       animations: { 
                                        self.progressBar.alpha = 1
                                        self.closeBtn.alpha = 1
                                        if self.playStatus != .Loading {
                                            self.playBtn.alpha = 1
                                        }
                }, completion: { (finish) in
                    if self.playStatus == .Play  && !self.progressBar.seekingTime {
                        self.delayHideTool()
                    }
                    self.isAnimating = false
            })
        } else {
            progressBar.hidden = false
            progressBar.alpha = 1
            closeBtn.alpha = 1
            closeBtn.hidden = false
            isAnimating = true
            
            UIView.animateWithDuration(0.3,
                                       delay: 0,
                                       options: .CurveEaseInOut,
                                       animations: {
                                        self.progressBar.alpha = 0
                                        self.closeBtn.alpha = 0
                                        if self.playStatus != .Loading {
                                            self.playBtn.alpha = 0
                                        }
                }, completion: { (finish) in
                    self.isAnimating = false
                    self.progressBar.hidden = true
                    self.closeBtn.hidden = true
                    
                    self.playBtn.hidden = true
            })
        }
        isShowingTool = show
    }
    
    func delayHideTool() {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (Int64(NSEC_PER_SEC) * 5)), dispatch_get_main_queue(), { () -> Void in
                self.showToolAnimated(false)
        })
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if targetUrl != nil {
            loadingView.startAnimating()
            PDVideoManager.sharedManager.requestDetailVideo(targetUrl!, complete: { (item, error) in
                self.updateVideoInfo(item, error: error)
            })
        }
        progressBar.progressChangeHandler = {
            [weak self] progres in
            self?.updateProgress(progres)
        }
        
        self.transitioningDelegate = self
    }
    
    func updateProgress(progres: CGFloat) {
        if progres > 0 && playItem != nil {
            let duration: CMTime = playItem.duration
            let seconds = CMTimeGetSeconds(duration)
            let seekSeconds = seconds * Float64(progres)
            
            let seekTime = CMTime(seconds: seekSeconds, preferredTimescale: duration.timescale)
            player.seekToTime(seekTime, completionHandler: { (success) in
                self.progressBar.seekingTime = false
                print("seek time finish:\(success)")
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
    
    func registerPlayerItemKVO() {
        guard playItem != nil else {
            return
        }
        playItem.addObserver(self,
                             forKeyPath: "status",
                             options: .New,
                             context: nil)
        playItem.addObserver(self,
                             forKeyPath: "loadedTimeRanges",
                             options: .New,
                             context: nil)
        playItem.addObserver(self,
                             forKeyPath: "playbackLikelyToKeepUp",
                             options: .New,
                             context: nil)
        playItem.addObserver(self,
                             forKeyPath: "playbackBufferEmpty",
                             options: .New,
                             context: nil)
    }
    
    func unRegisterPlayerItemKVO() {
        if playItem != nil {
            playItem.removeObserver(self, forKeyPath: "status")
            playItem.removeObserver(self, forKeyPath: "loadedTimeRanges")
            playItem.removeObserver(self, forKeyPath: "playbackLikelyToKeepUp")
            playItem.removeObserver(self, forKeyPath: "playbackBufferEmpty")
        }
    }
    
    func setupVideoPlayer() {
        let asset = AVURLAsset(URL: NSURL(string: videoItem.videoUrl!)!)

        self.unRegisterPlayerItemKVO()
        if timeObserver != nil && player != nil {
            player.removeTimeObserver(timeObserver!)
        }
        playItem = AVPlayerItem(asset: asset, automaticallyLoadedAssetKeys: ["duration"])
        player = AVPlayer(playerItem: playItem)
        self.registerPlayerItemKVO()
        
        videoView.setPlayer(player)
        timeObserver = player.addPeriodicTimeObserverForInterval(CMTimeMake(30, 60), queue: dispatch_get_main_queue()) { [weak self] (time) in
            self?.updateProgressBar(time)
        }
        playStatus = .Loading
    }
    
    func updateProgressBar(time: CMTime) {
        guard !progressBar.seekingTime else {
            return
        }
        let seconds = CMTimeGetSeconds(time)
        let duration = CMTimeGetSeconds(playItem.duration)
        
        if duration > 0 {
            let progress = seconds / duration
            progressBar.playProgress = CGFloat(progress)
            progressBar.time = Int(seconds)
        }
    }
    
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if keyPath == "status" {
            if let change = change {
                let value = change[NSKeyValueChangeNewKey]
                let status = value?.integerValue
                
                if status != nil &&  AVPlayerItemStatus(rawValue: status!) == .ReadyToPlay {
                    let duration = CMTimeGetSeconds(playItem.duration)
                    progressBar.duration = Int(duration)
                    player.play()
                    loadingView.stopAnimating()
                    playStatus = .Play
                    progressBar.seekEnable = true
                }
            }
        }
        else if keyPath == "loadedTimeRanges" {
            if let change = change {
                let array = change[NSKeyValueChangeNewKey] as? Array<NSValue>
                
                if array != nil && array!.count > 0 {
                    let value = array![array!.endIndex - 1].CMTimeRangeValue
                    let start = CMTimeGetSeconds(value.start)
                    let duration = CMTimeGetSeconds(value.duration)
                    let total = CMTimeGetSeconds(playItem.duration)
                    
                    let progress: CGFloat = CGFloat((start + duration) / total)
                    progressBar.loadProgress = progress
                    print("load progress:\(progress)")
                }
                
            }
        }
        else if keyPath == "playbackLikelyToKeepUp" {
            if let change = change {
                let result = change[NSKeyValueChangeNewKey]
                let likelyKeepUp = result?.boolValue
                if (likelyKeepUp != nil) && likelyKeepUp! {
                    if playStatus != .Pause {
                        player.play()
                        loadingView.stopAnimating()
                        playStatus = .Play
                        progressBar.seekEnable = true
                    }
                }
            }
        }
        else if keyPath == "playbackBufferEmpty" {
            if let change = change {
                let result = change[NSKeyValueChangeNewKey]
                let empty = result?.boolValue
                if (empty != nil) && empty! {
                    loadingView.startAnimating()
                    playStatus = .Loading
                }
            }
        }
    }
}

//MARK: UIViewControllerTransitioningDelegate
extension PDVideoDetailViewController: UIViewControllerTransitioningDelegate {
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return presentAnimator
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return dismissAnimator
    }
}