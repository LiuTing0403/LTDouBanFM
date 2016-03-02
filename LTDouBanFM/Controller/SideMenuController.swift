//
//  SideMenuController.swift
//  LTDouBanFM
//
//  Created by liu ting on 16/2/29.
//  Copyright © 2016年 liu ting. All rights reserved.
//

import UIKit
import SwiftyJSON
import RESideMenu

class SideMenuController: UITableViewController, RESideMenuDelegate {
    
    var channelList:[Channel] = []
    var selectedChannel = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        getChannelList()
        print("side menu view did load")
        sideMenuViewController.delegate = self
        
    }


    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {

        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return channelList.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        cell.textLabel?.text = channelList[indexPath.row].name

        return cell
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        sideMenuViewController.hideMenuViewController()

        selectedChannel = channelList[indexPath.row].channel_id
        
        
    }


    func getChannelList(){
        
        HTTPToolKit().getHTTPResponse(channelURLString){ (responseObject) -> Void in
            
            if responseObject.result.error == nil {
                
                let JSONData = responseObject.data
                
                let json = JSON(data: JSONData!)
                
                let channels = json["channels"].arrayValue
                
                for channel in channels {
                    let name = channel["name"].stringValue
                    let channel_id = channel["channel_id"].stringValue
                    let channelInfo:Channel = Channel(name:name, channel_id: channel_id)
                    
                    self.channelList.append(channelInfo)
                    
                    
                }
                print("get channel list successfully")
                    
                
            }
            else {
                self.channelList = defaultChannelList
                
                
                print("get channel list error, \(responseObject.result.error)")
                
            }
            print(self.channelList)
            self.tableView.reloadData()
            
        }
    }
    
    func sideMenu(sideMenu: RESideMenu!, didHideMenuViewController menuViewController: UIViewController!) {
        
        let mainVC = sideMenu.contentViewController as! ViewController
        mainVC.showSideMenu = false
        
        if mainVC.channelID != selectedChannel {
            mainVC.channelID = selectedChannel

        }
        
    }
    

}
