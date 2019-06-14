//
//  Time.swift
//  Imagination
//
//  Created by Star on 15/12/1.
//  Copyright © 2015年 Star. All rights reserved.
//

import Foundation

class Time {
    class func now() -> String{
        let format = DateFormatter()
        format.dateFormat = "yyyy-MM-dd HH:mm:SS"
        return format.string(from: Date())
    }
    
    class func today() -> String{
        let format = DateFormatter()
        format.dateFormat = "yyyy-MM-dd"
        return format.string(from: Date())
    }
    
    class func clock() -> String{
        let format = DateFormatter()
        format.dateFormat = "HH:mm:SS"
        return format.string(from: Date())
    }
    
    class func dateFromString(_ time:String) -> Date? {
        let format = DateFormatter()
        format.dateFormat = "yyyy-MM-dd HH:mm:SS"
        return format.date(from: time)
    }
    
    class func dayOfDate(_ date:Date) -> String {
        let format = DateFormatter()
        format.dateFormat = "yyyy-MM-dd"
        return format.string(from: date)
    }
    
    class func monthStringOfDate(_ date:Date) -> String{
        let format = DateFormatter()
        format.dateFormat = "yyyy-MM"
        return format.string(from: date)
    }
    
    class func clockOfDate(_ date:Date) -> String {
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
    
    class func timeIntervalToMMssString(timeInterval:TimeInterval) -> String{
        let intTimeInterval = Int(timeInterval)
        let minute = intTimeInterval / 60
        let secend = intTimeInterval % 60
        let mstring = minute < 10 ? "0\(minute)":"\(minute)"
        let sstring = secend < 10 ? "0\(secend)":"\(secend)"
        return "\(mstring):\(sstring)"
    }

    class func hourAndMinute(ofDate date: Date) -> (Int, Int) {
        return (Calendar.current.component(.hour, from: date), Calendar.current.component(.minute, from: date))
    }
}
