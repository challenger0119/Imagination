//
//  CustomTableViewCell.swift
//  Imagination
//
//  Created by Star on 16/1/5.
//  Copyright © 2016年 Star. All rights reserved.
//

import UIKit

class CustomTableViewCell: UITableViewCell {

    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var content: UITextView!
    override func awakeFromNib() {
        super.awakeFromNib()
        content.layer.cornerRadius = 3.0
        content.isUserInteractionEnabled = false
        time.textColor = UIColor(white: 0.5, alpha: 1.0)
        content.textColor = UIColor(white: 0.4, alpha: 1.0)
    }
}
