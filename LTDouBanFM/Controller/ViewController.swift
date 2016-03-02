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
    
  
    var playingAudio = true {
        didSet {
            if playingAudio {
                
                resumePlayingAudio()
                pauseAndResumeButton.setImage(UIImage(named: "pause"), forState: .Normal)
            } else {
                
                stopPlayingAudio()
                pauseAndResumeButton.setImage(UIImage(named: "resume"), forState: .Normal)
            }
        }
    }
    
    var showSideMenu = false
    
    var songInfo:SongInfo? {
        //每次歌曲信息重置后都重新设置图片，播放新的音频
        didSet{
            setAlbumPicture((self.songInfo?.pictureURL)!)
            songTitleLabel.text = self.songInfo?.songTitle
            singerNameLabel.text = self.songInfo?.artist
            playAudio((self.songInfo?.songURL)!)
        }
    }
    
    var player:AFSoundPlayback?
    var audioItem:AFSoundItem?
    var playedTime:Int = 0
    var channelID:Int = 0 {
        //重置channelID后播放新的channel
        didSet{
            stopPlayingAudio()
        
            playSelectedChannel(channelID)
            playingAudio = true
            print("channelID is \(channelID)")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpSlider()

        playSelectedChannel(channelID)
        print("view controller did load")
        
    }
     override func viewDidAppear(animated: Bool) {
        let needleOldFrame = needlePic.frame
        needlePic.layer.anchorPoint = CGPointMake(0.25, 0.15)
        needlePic.frame = needleOldFrame
        
        addBlurView()

        print("channelID is \(channelID)")
    }
    
    override func viewDidLayoutSubviews() {
//        addBlurView()
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
    
    @IBAction func pauseAndResumeButton(sender: UIButton) {
        

        playingAudio = !playingAudio
        print(playingAudio.boolValue)
    }
    
    
    @IBAction func nextSong(sender: UIButton) {
        
        
        slider.value = 0
        playedTimeLabel.text = "00:00"
        totalTimeLabel.text = "00:00"
        if playingAudio {
            playingAudio = false
        }
        playingAudio = true
        playSelectedChannel(channelID)

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
    func resumePlayingAudio() {
        
        print("start playing audio")
        
        UIView.animateWithDuration(0.5, delay: 0, options: .CurveLinear, animations: { () -> Void in
            
            self.needlePic.transform = CGAffineTransformRotate(self.needlePic.transform, CGFloat(M_PI/8))
            }) { (finished) -> Void in
            self.rotatingView.resumeAnimation()
            self.player?.play()
        }
    }
    
    //暂停播放
    func stopPlayingAudio() {
        
        print("stop playing audio")
        
        rotatingView.pauseAnimation()
        player?.pause()
        
        UIView.animateWithDuration(0.5, delay: 0, options: .CurveLinear, animations: { () -> Void in
            
            self.needlePic.transform = CGAffineTransformRotate(self.needlePic.transform, CGFloat(-M_PI/8))
            
            }) { (finished) -> Void in
                
        }
    }
    

    
    //MARK:网络请求相关
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
    
    func setAlbumPicture(picURL:NSURL) {
        
        print("set album picture")

        if let albumPicData = NSData(contentsOfURL: picURL) {

            self.albumPic.image = UIImage(data: albumPicData)
        
            self.backgroundPic.image = UIImage(data: albumPicData)
        }
    }
    
    func playAudio(songURL:NSURL) {
        
        print("play Audio with URL")
        
        audioItem = AFSoundItem(streamingURL: songURL)
        player = AFSoundPlayback(item: audioItem)
        player!.play()
        
        player!.listenFeedbackUpdatesWithBlock({ (item) -> Void in
            
            self.playedTime = item.timePlayed
            self.totalTimeLabel.text = self.timeLabelText(item.duration)
            self.playedTimeLabel.text = self.timeLabelText(item.timePlayed)
            self.slider.value = Float(item.timePlayed) / Float(item.duration)
            
            }) { (item) -> Void in
                
                print("a song end")
                
                self.getSongInfo(self.channelID)
                
        }
        

    }
    
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
    
    
    
    

}


