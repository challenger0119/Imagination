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
        let format = DateFormatter()
        format.dateFormat = "yyyy-MM-dd HH:mm:SS"
        return format.string(from: Date())
    }
    static func today()->String{
        let format = DateFormatter()
        format.dateFormat = "yyyy-MM-dd"
        return format.string(from: Date())
    }
    static func clock()->String{
        let format = DateFormatter()
        format.dateFormat = "HH:mm:SS"
        return format.string(from: Date())
    }
    static func dateFromString(_ time:String) -> Date? {
        let format = DateFormatter()
        format.dateFormat = "yyyy-MM-dd HH:mm:SS"
        return format.date(from: time)
    }
    static func dayOfDate(_ date:Date) -> String {
        let format = DateFormatter()
        format.dateFormat = "yyyy-MM-dd"
        return format.string(from: date)
    }
    static func clockOfDate(_ date:Date) -> String {
        let format = DateFormatter()
        format.dateFormat = "HH:mm:SS"
        return format.string(from: date)
    }
    
    class func timestamp()->TimeInterval{
        return Date().timeIntervalSince1970
    }
    class func stringTimestamp()->String{
        let timsp = Time.timestamp()
        let string = String(timsp)
        return string.replacingOccurrences(of: ".", with: "") //去掉小数点
    }
}
