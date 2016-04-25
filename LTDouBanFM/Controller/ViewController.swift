//
//  ViewController.swift
//  LTDouBanFM
//
//  Created by liu ting on 16/2/27.
//  Copyright © 2016年 liu ting. All rights reserved.
//

import UIKit
import SwiftyJSON
import AFSoundManager



class ViewController: UIViewController {
    
    @IBOutlet weak var backgroundPic: UIImageView!
    
    @IBOutlet weak var albumPic: UIImageView!

    @IBOutlet weak var rotatingView: DiscView!

    @IBOutlet weak var needlePic: UIImageView!
    
    @IBOutlet weak var slider: UISlider!
    
    @IBOutlet weak var playedTimeLabel: UILabel!
    
    @IBOutlet weak var totalTimeLabel: UILabel!
    
    @IBOutlet weak var pauseAndResumeButton: UIButton!
    
    @IBOutlet weak var songTitleLabel: UILabel!
    
    @IBOutlet weak var singerNameLabel: UILabel!
    
    @IBOutlet weak var nextButton: UIButton!
    
    
    
    var showSideMenu = false
    var playedTime:Int = 0
    var myAudioPlayer = LTAudioPlayer()
    
    //用来控制播放与暂停button的图片
    var playingAudio = true {
        didSet {
            if playingAudio {
                pauseAndResumeButton.setImage(UIImage(named: "pause"), forState: .Normal)
            } else {
                
                pauseAndResumeButton.setImage(UIImage(named: "resume"), forState: .Normal)
            }
        }
    }
    
    
    //每次歌曲信息重置后都重新设置图片，播放新的音频
    var songInfo:SongInfo? {
        didSet{
            setAlbumPicture((self.songInfo?.pictureURL)!)
            songTitleLabel.text = self.songInfo?.songTitle
            singerNameLabel.text = self.songInfo?.artist
//            myAudioPlayer.configBackgroundPlayingInfo = {
//                ()->Void in
//                self.setBackgroundPlayingInfoOnScreen()
//            }
            myAudioPlayer.playSongWithURL((songInfo?.songURL)!, feedbackblock: { (item) -> Void in
                
                    self.playedTime = item.timePlayed
                    self.totalTimeLabel.text = self.timeLabelText(item.duration)
                    self.playedTimeLabel.text = self.timeLabelText(item.timePlayed)
                    self.slider.value = Float(item.timePlayed) / Float(item.duration)
                
                    print(item.timePlayed)
                
                }) { () -> Void in
                    print("a song end")
                    
                    self.getSongInfo(self.channelID)
            }

        }
    }
    
    //重置channelID后播放新的channel
    var channelID:Int = 0 {
        didSet{
            if playingAudio {
                myAudioPlayer.pause()
                playSelectedChannel(self.channelID) 
            } else {
                playingAudio = true
            
                resumePlayingAnimation({ () -> Void in
                self.playSelectedChannel(self.channelID)
                })
            }
            print("channelID is \(channelID)")
        }
    }
    

    //MARK:view life cycle
    
    //第一次load view时默认播放channel 0
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpSlider()
        playSelectedChannel(channelID)
        print("view controller did load")
        
    }
    //添加blur效果，在view did layout subview之后，调整needle的anchor
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        let needleOldFrame = needlePic.frame
        needlePic.layer.anchorPoint = CGPointMake(0.25, 0.15)
        needlePic.frame = needleOldFrame
        addBlurView()
        print("channelID is \(channelID)")

        UIApplication.sharedApplication().endReceivingRemoteControlEvents()
        self.resignFirstResponder()
    }
    //status bar 默认红色
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    

    
    //MARK: actions
    
    @IBAction func showSideMenu(sender: UIButton) {
        
        showSideMenu = !showSideMenu
        
        if showSideMenu{
            sideMenuViewController.presentLeftMenuViewController()
            print("SHOW side menu")
        } else {
            print("HIDE side menu")
            sideMenuViewController.hideMenuViewController()
            
        }
        
    }
    
    @IBAction func didClickPauseButton(sender: UIButton) {
        
        playingAudio = !playingAudio
        if playingAudio {
            resumePlayingAnimation(){()-> Void in
                self.myAudioPlayer.play()
            }
        } else {
            stopPlayingAnimation(){()-> Void in
                self.myAudioPlayer.pause()
            }

        }
    }
    
    
    @IBAction func nextSong(sender: UIButton) {
        
        
        slider.value = 0
        playedTimeLabel.text = "00:00"
        totalTimeLabel.text = "00:00"
        
        if playingAudio {
            
            myAudioPlayer.pause()
        
            
            self.playSelectedChannel(self.channelID)
            
        } else {
            playingAudio = true
            resumePlayingAnimation(){ Void in
                self.playSelectedChannel(self.channelID)
            }
        }


    }
    
    //MARK: METHODS
    
    //MARK: 设置UI
    func setUpSlider(){
        
        slider.setThumbImage(UIImage(named: "cm2_efc_switch_on"), forState: .Normal)
        
    }
    
    func addBlurView() {
        
        let blurEffect = UIBlurEffect.init(style: .Light)
        let blurEffectView = UIVisualEffectView.init(effect: blurEffect)
        blurEffectView.frame = self.backgroundPic.bounds
        backgroundPic.addSubview(blurEffectView)
        
        print(blurEffectView.frame)
        
    }
    
    //MARK: 播放与暂停控制
    //播放所选中的频道
    func playSelectedChannel(channelID:Int) {
        print("play selected channel")
        //从网络请求歌曲信息
        getSongInfo(channelID)
        rotatingView.rotate()
        
    }
    //暂停后继续播放，动画结束后播放音频
    func resumePlayingAnimation(completion:(()->Void)?) {
        
        print("start playing audio")
        
        UIView.animateWithDuration(0.5, delay: 0, options: .CurveLinear, animations: { () -> Void in
            
            self.needlePic.transform = CGAffineTransformRotate(self.needlePic.transform, CGFloat(M_PI/8))
            }) { (finished) -> Void in
            self.rotatingView.resumeAnimation()
                if completion != nil {
                    completion!()
                }
        }
    }
    
    //暂停播放
    func stopPlayingAnimation(completion:(()->Void)?) {
        
        if (completion != nil) {
            completion!()
        }
        print("stop playing audio")
        
        rotatingView.pauseAnimation()

        
        UIView.animateWithDuration(0.5, delay: 0, options: .CurveLinear, animations: { () -> Void in
            
            self.needlePic.transform = CGAffineTransformRotate(self.needlePic.transform, CGFloat(-M_PI/8))
            
            }) { (finished) -> Void in
                
        }
    }
    

    
    //MARK:网络请求相关
    
    //请求歌曲信息
    func getSongInfo(channelID:Int){
        
        print("get song info")
        
        HTTPToolKit().getHTTPResponse(songURLString, parameters: ["channel":channelID,"type":"n","from":"baidu"]) { (responseObject) -> Void in
            
            print(responseObject.request)
            
            if responseObject.result.error == nil {
            
                let jsonData = responseObject.data
                let json = JSON(data: jsonData!)
                let songJSON = json["song"].arrayValue.first!
            
            
                self.songInfo = SongInfo(
                    artist: songJSON["artist"].stringValue,
                    songTitle: songJSON["title"].stringValue,
                    pictureURL: songJSON["picture"].stringValue,
                    songURL: songJSON["url"].stringValue)
                
            }
            else {
                print("get song failed \(responseObject.result.error)")
            }
        }
       

    }
    //设置图片
    func setAlbumPicture(picURL:NSURL) {
        
        print("set album picture")

        if let albumPicData = NSData(contentsOfURL: picURL) {

            self.albumPic.image = UIImage(data: albumPicData)
        
            self.backgroundPic.image = UIImage(data: albumPicData)
        }
    }

    //时间转换
    func timeLabelText(seconds:Int)->String{
        
        var min = 0;
        var sec = 0;
        
        sec = seconds % 60
        min = (seconds - sec)/60
        
        let text = {(num:Int)->String in
            return num < 10 ? "0\(num)":"\(num)"
        }
        
        return text(min)+":"+text(sec)

    }
    
    //MARK:后台播放控制

    func setBackgroundPlayingInfoOnScreen() {
        
        let artWork = MPMediaItemArtwork(image: UIImage(named: "album")!)
        
        let playingInfo:[String:AnyObject] = [MPMediaItemPropertyAlbumTitle:"专辑名", MPMediaItemPropertyArtist:"歌手名",
            MPMediaItemPropertyTitle:"歌曲名",
            MPMediaItemPropertyArtwork:artWork]
        MPNowPlayingInfoCenter.defaultCenter().nowPlayingInfo = playingInfo
        
    }
    
    
    override func remoteControlReceivedWithEvent(event: UIEvent?) {
        print("did receive REMOTE event")
        if event!.type == UIEventType.RemoteControl {
            switch event!.subtype {
            case UIEventSubtype.RemoteControlPause: myAudioPlayer.pause()
            case UIEventSubtype.RemoteControlPlay: myAudioPlayer.play()
            case UIEventSubtype.RemoteControlNextTrack: nextSong(nextButton)
                
            default:break
                
                
            }
        }
    }
    
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
//        if myAudioPlayer.audioPlayer!.status == AFSoundStatus.Playing {
            UIApplication.sharedApplication().beginReceivingRemoteControlEvents()
        
            self.becomeFirstResponder()
            setBackgroundPlayingInfoOnScreen()
//        
//        } else {
//        
//            UIApplication.sharedApplication().endReceivingRemoteControlEvents()
//            self.resignFirstResponder()
//        }
    }
    
    
//    func setRemoteControlWithEvent(receivedEvent:UIEvent) {
////        
////        let remoteCommandCenter = MPRemoteCommandCenter.sharedCommandCenter()
////        remoteCommandCenter.pauseCommand.addTargetWithHandler { (event) -> MPRemoteCommandHandlerStatus in
////            self.myAudioPlayer.pause()
////            return MPRemoteCommandHandlerStatus.Success
////        }
////        remoteCommandCenter.playCommand.addTargetWithHandler { (event) -> MPRemoteCommandHandlerStatus in
////            self.myAudioPlayer.play()
////            return MPRemoteCommandHandlerStatus.Success
////        }
////        remoteCommandCenter.nextTrackCommand.addTargetWithHandler { (event) -> MPRemoteCommandHandlerStatus in
////            self.nextSong(nextButton)
////            return MPRemoteCommandHandlerStatus.su
////        }
//        if receivedEvent.type == UIEventType.RemoteControl {
//            switch receivedEvent.subtype {
//            case UIEventSubtype.RemoteControlPause: myAudioPlayer.pause()
//            case UIEventSubtype.RemoteControlPlay: myAudioPlayer.play()
//            case UIEventSubtype.RemoteControlNextTrack: nextSong(nextButton)
//                
//            default:break
//                
//                
//            }
//        }
    
 //   }
    

}


