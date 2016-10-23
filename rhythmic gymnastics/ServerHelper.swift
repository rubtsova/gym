//
//  ServerHelper.swift
//  rhythmic gymnastics
//
//  Created by Sergey Pronin on 11/25/15.
//  Copyright © 2015 Admin. All rights reserved.
//

import UIKit

let SharedSession = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())

class ServerHelper: NSObject {
    class func syncSettings() {
        guard let userId = NSUserDefaults.standardUserDefaults().objectForKey("user-id") as? String else { return }
        print(userId)
        let URL = NSURL(string: "https://dev-pronin.appspot.com/api/swift/gymnastics?user_id=" + userId.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!)!
        
        SharedSession.dataTaskWithRequest(NSURLRequest(URL: URL)) { data, response, error in
            
            if let data = data {
                do {
                    guard let json = try NSJSONSerialization.JSONObjectWithData(data, options: []) as? [String: AnyObject] else { return }
                    guard let settings = json["settings"] as? [[String: AnyObject]] else { return }
                    let defaults = NSUserDefaults.standardUserDefaults()
                    for setting in settings {
                        defaults.setObject(setting["value"], forKey: setting["key"] as! String)
                    }
                    defaults.synchronize()
                } catch { }
            }
            
        }.resume()
    }
    
    class func sendFeedback(email: String, text: String) {
        guard let userId = NSUserDefaults.standardUserDefaults().objectForKey("user-id") as? String else { return }
        let URL = NSURL(string: "https://dev-pronin.appspot.com/api/swift/gymnastics")!
        
        let params: [String: String] = [
            "user_id": userId,
            "email": email,
            "text": text
        ]
        let body = params.map({ "\($0)=" + $1.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())! }).joinWithSeparator("&")
        
        let request = NSMutableURLRequest(URL: URL)
        request.HTTPMethod = "POST"
        request.HTTPBody = body.dataUsingEncoding(NSUTF8StringEncoding)
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        SharedSession.dataTaskWithRequest(request).resume()
    }
}
