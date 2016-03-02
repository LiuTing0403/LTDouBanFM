//
//  DiscView.swift
//  LTDouBanFM
//
//  Created by liu ting on 16/2/28.
//  Copyright © 2016年 liu ting. All rights reserved.
//

import UIKit

class DiscView: UIView {

    func rotate() {
        print("rotating")
        let rotatingAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotatingAnimation.fromValue = 0
        rotatingAnimation.toValue = M_PI
        rotatingAnimation.duration = 30
        rotatingAnimation.cumulative = true
        rotatingAnimation.repeatCount = MAXFLOAT
        
        layer.addAnimation(rotatingAnimation, forKey: "rotationAnimation")
        
    }
    
    func pauseAnimation() {
        print("pause disc rotating animation")
        let pausedTime = layer.convertTime(CACurrentMediaTime(), fromLayer: nil)
        layer.speed = 0
        layer.timeOffset = pausedTime
    }
    
    func resumeAnimation() {
        
        print("resume disc rotating animation")
        let pausedTime = layer.timeOffset
        layer.speed = 1
        layer.timeOffset = 0
        layer.beginTime = 0
        let timeSincePause = layer.convertTime(CACurrentMediaTime(), fromLayer: nil) - pausedTime
        layer.beginTime = timeSincePause
    }

}
