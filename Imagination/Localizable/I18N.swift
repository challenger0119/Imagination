//
//  I18N.swift
//  Imagination
//
//  Created by Miaoqi Wang on 2019/12/8.
//  Copyright © 2019 Star. All rights reserved.
//

import UIKit

class I18N {
    class func string(_ key: String) -> String {
        return NSLocalizedString(key, comment: "")
    }
}
