//
//  LaunchViewController.swift
//  Imagination
//
//  Created by YouJuny on 2020/5/5.
//  Copyright © 2020 Star. All rights reserved.
//

import UIKit
import SnapKit

class LaunchViewController: UIViewController {

    lazy var label: UILabel = {
        let lb = UILabel()
        lb.numberOfLines = 0
        lb.font = UIFont.preferredFont(forTextStyle: .title3)
        lb.lineBreakMode = .byWordWrapping
        lb.textColor = Theme.Color.grey()
        lb.text = Notification.hitokotoBody ?? ""
        return lb
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
                
        view.addSubview(label)
        label.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.left.greaterThanOrEqualToSuperview().offset(16)
            make.right.lessThanOrEqualToSuperview().inset(16)
            make.top.greaterThanOrEqualToSuperview().offset(16)
            make.bottom.lessThanOrEqualToSuperview().inset(16)
        }
    }
}
