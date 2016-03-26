//
//  animation protocol.swift
//  ibuydeal
//
//  Created by jiangjiang on 3/15/16.
//  Copyright © 2016 jiangjiang. All rights reserved.
//


import UIKit
protocol presentingVCDeleage:class {
    func viewToBeAnimated() -> UIView
    
    func dismissAnimatonComplete()

}

extension presentingVCDeleage {
    func dismissAnimatonComplete(){
    }
}
