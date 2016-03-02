//
//  HTTPTool.swift
//  LTDouBanFM
//
//  Created by liu ting on 16/2/29.
//  Copyright © 2016年 liu ting. All rights reserved.
//


import Alamofire

private let netWorkKit = HTTPToolKit()

class HTTPToolKit: NSObject {
    
    class var sharedInstance:HTTPToolKit {
    
        return netWorkKit
    }
    
    
    
    func getHTTPResponse(urlString:String, parameters:[String:AnyObject]?, completion:(responseObject:Response<AnyObject, NSError>)-> Void) {
        
        Alamofire.request(.GET, urlString, parameters: parameters).responseJSON { (response) -> Void in
            completion(responseObject: response)
        }
    }
    
    func getHTTPResponse(urlString:String, completion:(responseObject:Response<AnyObject, NSError>)-> Void) {
        
        Alamofire.request(.GET, urlString).responseJSON { (response) -> Void in
            completion(responseObject: response)
        }
    }
    

}
