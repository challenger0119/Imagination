//
//  MemorySpaceHeaderView.swift
//  Imagination
//
//  Created by Star on 2017/4/28.
//  Copyright © 2017年 Star. All rights reserved.
//

import UIKit

class MemorySpaceHeaderView: UIView {

    var rightLabel:UILabel
    var leftLabel:UILabel
    override init(frame: CGRect) {
        self.leftLabel = UILabel()
        self.rightLabel = UILabel()
        super.init(frame:frame)
        self.leftLabel.frame = CGRect(x: 20, y: 0, width: self.frame.width/2-20, height: self.frame.height)
        self.leftLabel.adjustsFontSizeToFitWidth = true
        
        self.leftLabel.textAlignment = .left
        self.rightLabel.frame = CGRect(x: self.frame.width/2, y: 0, width: self.frame.width/2-20, height: self.frame.height)
        self.rightLabel.adjustsFontSizeToFitWidth = true
        self.rightLabel.textAlignment = .right
        
        self.addSubview(rightLabel)
        self.addSubview(leftLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
