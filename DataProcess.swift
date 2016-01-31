//
//  DataProcess.swift
//  ibuydeal
//
//  Created by jiangjiang on 1/30/16.
//  Copyright © 2016 jiangjiang. All rights reserved.
//

import Foundation

func json<T>(url: NSURL, type: T) -> T {
    let bytes = NSData(contentsOfURL: url)
    let jsondata = try! NSJSONSerialization.JSONObjectWithData(bytes!, options: .AllowFragments)
    let castedJson = jsondata as! T
    return castedJson
}



func encodeURL(url: String) -> NSURL {
    let formatedURL = url.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
    let url = NSURL(string: formatedURL!)
    return url!
}