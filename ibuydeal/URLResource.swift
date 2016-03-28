//
//  URLResource.swift
//  ibuydeal
//
//  Created by jiangjiang on 3/28/16.
//  Copyright © 2016 jiangjiang. All rights reserved.
//

import Foundation
let host = "http://54.223.65.44:8100/"
let imageURL = host + "static/image/"
let videoURL = host + "static/video/"
let cartImageURL = NSURL(string:imageURL + "util/cart")!
let likeImageURL = NSURL(string:imageURL + "util/like")!