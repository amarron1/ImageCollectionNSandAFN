//
//  CustomCell.swift
//  ImageCollectionNSandAFN
//
//  Created by amarron on 2015/07/01.
//  Copyright (c) 2015年 amarron. All rights reserved.
//

import UIKit

class CustomCell: UICollectionViewCell {
    var photoImageView: UIImageView!
    
    override init(frame: CGRect){
        super.init(frame: frame)
        self.backgroundColor = UIColor.lightGrayColor()
        photoImageView = UIImageView(frame:  CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height))
        photoImageView.contentMode = UIViewContentMode.ScaleAspectFit
        contentView.addSubview(photoImageView)
        
    }
    required init(coder aDecoder: NSCoder){
        super.init(coder: aDecoder)
    }
    
    override func prepareForReuse()
    {
        super.prepareForReuse()
        self.photoImageView.image = nil
    }
    
    
}
