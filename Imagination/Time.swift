//
//  Time.swift
//  Imagination
//
//  Created by Star on 15/12/1.
//  Copyright © 2015年 Star. All rights reserved.
//

import Foundation

class Time: NSObject {
    static func now()->String{
        let format = NSDateFormatter()
        format.dateFormat = "yyyy-MM-dd HH:mm:SS"
        return format.stringFromDate(NSDate.init(timeIntervalSinceNow: 0))
    }
    static func today()->String{
        let format = NSDateFormatter()
        format.dateFormat = "yyyy-MM-dd"
        return format.stringFromDate(NSDate.init(timeIntervalSinceNow: 0))
    }
    static func clock()->String{
        let format = NSDateFormatter()
        format.dateFormat = "HH:mm:SS"
        return format.stringFromDate(NSDate.init(timeIntervalSinceNow: 0))
    }
    static func dateFromString(time:String) -> NSDate {
        let format = NSDateFormatter()
        return format.dateFromString(time)!
    }
}
