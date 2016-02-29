//
//  ViewController.swift
//  LTDouBanFM
//
//  Created by liu ting on 16/2/27.
//  Copyright © 2016年 liu ting. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var backgroundPic: UIImageView!
    
    @IBOutlet weak var albumPic: UIImageView!
    
    
    @IBOutlet weak var rotatingView: DiscView!
    

    @IBOutlet weak var needlePic: UIImageView!
  


    
    
    
    var animating = true

    override func viewDidLoad() {
        super.viewDidLoad()


        
        addBlurView()
        rotatingView.rotate()
    }
    
    override func viewDidAppear(animated: Bool) {
        let needleOldFrame = needlePic.frame
        needlePic.layer.anchorPoint = CGPointMake(0.25, 0.15)
        needlePic.frame = needleOldFrame

    }
    
    @IBAction func showSideMenu(sender: UIButton) {
        
        if animating{
            stopPlayingAudio()
            

        }
        else {
            startPlayingAudio()
            
            
        }
        animating = !animating
        
    }
    
    func addBlurView() {
        
        let blurEffect = UIBlurEffect.init(style: .Light)
        let blurEffectView = UIVisualEffectView.init(effect: blurEffect)
        blurEffectView.frame = self.view.bounds
        backgroundPic.addSubview(blurEffectView)
  
    }
 
    func startPlayingAudio() {
        
        UIView.animateWithDuration(0.5, delay: 0, options: .CurveLinear, animations: { () -> Void in
            
            self.needlePic.transform = CGAffineTransformRotate(self.needlePic.transform, CGFloat(M_PI/8))
            }) { (finished) -> Void in
             self.rotatingView.resumeAnimation()
        }
    }
    
    func stopPlayingAudio() {
        
        rotatingView.pauseAnimation()
        
        UIView.animateWithDuration(0.5, delay: 0, options: .CurveLinear, animations: { () -> Void in
            
            self.needlePic.transform = CGAffineTransformRotate(self.needlePic.transform, CGFloat(-M_PI/8))
            
            }) { (finished) -> Void in
                
                
        }
    }


}

