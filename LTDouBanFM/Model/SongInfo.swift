//
//  SongInfo.swift
//  LTDouBanFM
//
//  Created by liu ting on 16/3/1.
//  Copyright © 2016年 liu ting. All rights reserved.
//

import Foundation

struct SongInfo {
    
    let artist:String
    let songTitle:String
    let pictureURL:NSURL
    let songURL:NSURL
    
    init(artist:String, songTitle:String, pictureURL:String, songURL:String) {
        self.artist = artist
        self.songTitle = songTitle
        self.pictureURL = NSURL(string: pictureURL)!
        self.songURL = NSURL(string: songURL)!
    }
    
}