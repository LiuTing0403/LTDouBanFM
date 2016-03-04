//
//  LTAudioPlayer.swift
//  LTDouBanFM
//
//  Created by liu ting on 16/3/3.
//  Copyright © 2016年 liu ting. All rights reserved.
//

import AFSoundManager

private let myAudioPlayer = LTAudioPlayer()

class LTAudioPlayer: NSObject {
    
    var audioPlayer:AFSoundPlayback?
    var audioItem:AFSoundItem?
    var configBackgroundPlayingInfo:(()->Void)?
    
    class var sharedInstance:LTAudioPlayer {
        return myAudioPlayer
    }
    
    func playSongWithURL(songURL:NSURL, feedbackblock:(AFSoundItem!)->Void, finishedBlock:()->Void) {
    
        audioItem = AFSoundItem(streamingURL: songURL)
        audioPlayer = AFSoundPlayback(item: audioItem)
        
        if audioPlayer != nil {
            audioPlayer!.play()
        
            audioPlayer?.listenFeedbackUpdatesWithBlock({ (item) -> Void in
                feedbackblock(item)
                }, andFinishedBlock: { () -> Void in
                    finishedBlock()
            })
        }
    }
    
    func pause() {
        audioPlayer?.pause()
    }
    
    func play() {
        audioPlayer?.play()
    }
    

}
