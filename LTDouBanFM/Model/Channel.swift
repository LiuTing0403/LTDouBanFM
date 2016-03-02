//
//  Channel.swift
//  LTDouBanFM
//
//  Created by liu ting on 16/2/29.
//  Copyright © 2016年 liu ting. All rights reserved.
//

import Foundation

struct Channel {
    
    let name:String
    let channel_id:Int
    
    init(name:String, channel_id:String) {
        self.name = name
        self.channel_id = Int(channel_id)!
    }
    
}