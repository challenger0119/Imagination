//
//  Theme.swift
//  Imagination
//
//  Created by YouJuny on 2018/9/24.
//  Copyright © 2018年 Star. All rights reserved.
//

import Foundation

class Theme {
    static let lineSpace:CGFloat = 5
    
    class Color {
        class func dark() -> UIColor {
            return UIColor(white: 0, alpha: 1.0)
        }

        class func white() -> UIColor {
          return UIColor(white: 255, alpha: 1.0)
        }

        class func grey() -> UIColor {
            return UIColor(white: 0.5, alpha: 1.0);
        }

        class func lightGrey() -> UIColor {
            return UIColor(white: 0.6, alpha: 1.0)
        }
    }
}
