//
//  AppDelegate.swift
//  LTDouBanFM
//
//  Created by liu ting on 16/2/27.
//  Copyright © 2016年 liu ting. All rights reserved.
//

import UIKit
import RESideMenu
import AFSoundManager


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    var sideMenuController:RESideMenu?
    
    let myAudioPlayer = LTAudioPlayer()
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        let mainSB = UIStoryboard.init(name: "Main", bundle: nil)
        let mainVC = mainSB.instantiateViewControllerWithIdentifier("mainVC")
        let sideVC = mainSB.instantiateViewControllerWithIdentifier("sideVC")
        
        sideMenuController = RESideMenu.init(contentViewController: mainVC, leftMenuViewController: sideVC, rightMenuViewController: nil)
        sideMenuController?.scaleContentView = false
        sideMenuController?.scaleMenuView = false
        self.window?.rootViewController = sideMenuController
        do {
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print(" error")
        }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        } catch {
            print(" error")
        }
        return true
    }

    
    func applicationWillResignActive(application: UIApplication) {
        if myAudioPlayer.audioPlayer?.status == AFSoundStatus.Playing {
            UIApplication.sharedApplication().beginReceivingRemoteControlEvents()

            self.becomeFirstResponder()
            
 //           LTAudioPlayer().configBackgroundPlayingInfo!()
            
        } else {
            
            UIApplication.sharedApplication().endReceivingRemoteControlEvents()
            self.resignFirstResponder()
        }
        
        
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        UIApplication.sharedApplication().endReceivingRemoteControlEvents()
        self.resignFirstResponder()
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    override func remoteControlReceivedWithEvent(event: UIEvent?) {
        print("did receive REMOTE event")
        if event!.type == UIEventType.RemoteControl {
            switch event!.subtype {
            case UIEventSubtype.RemoteControlPause: myAudioPlayer.pause()
            case UIEventSubtype.RemoteControlPlay: myAudioPlayer.play()
//            case UIEventSubtype.RemoteControlNextTrack: nextSong(nextButton)
                
            default:break
                
                
            }
        }
    }


}

