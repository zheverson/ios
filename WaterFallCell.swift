//
//  CollectionViewCell.swift
//  ibuydeal
//
//  Created by jiangjiang on 1/30/16.
//  Copyright © 2016 jiangjiang. All rights reserved.
//

import UIKit

class WaterFallCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var creator_thumb: UIImageView!
    
    @IBOutlet weak var name: UILabel!
    
    @IBOutlet weak var title: UILabel!
    
    @IBOutlet weak var video_thumb: UIImageView!
    
    
}

struct layoutStruct {
    let itemSpace:CGFloat = 10
    let sectionInsets = UIEdgeInsetsMake(20, 10, 10, 10)
    let lineSpace:CGFloat = 10
}