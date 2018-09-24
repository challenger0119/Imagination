//
//  Item.swift
//  Imagination
//
//  Created by Star on 16/1/2.
//  Copyright © 2016年 Star. All rights reserved.
//

import UIKit
import RealmSwift

enum MoodType:Int {
    case None,Cool,OK,Why   // 爽 一般 问苍天
}

extension MoodType{
    
    // MARK: - static
    static let coolColor = UIColor.orange
    static let justOkColor = UIColor.init(red: 4.0/255.0, green: 119.0/255.0, blue: 240.0/255.0, alpha: 1.0)
    static let whyColor = UIColor.red
    static let defaultColor = UIColor.init(red: 239.0/255.0, green: 239.0/255.0, blue: 244.0/255.0, alpha: 1)
    
    fileprivate static let moodColor = [UIColor.darkGray,MoodType.coolColor,MoodType.justOkColor,MoodType.whyColor]
    
    func getColor() -> UIColor {
        return MoodType.moodColor[self.rawValue]
    }
    
    func getDescription() -> String{
        switch self {
        case .Cool:
            return "Cool"
        case .OK:
            return "Just OK"
        case .Why:
            return "Confused"
        default:
            return "NA"
        }
    }
}

class Item:Object{
    static let gpsSeparator = ","
    
    // MARK: - DB properties
    @objc dynamic var timestamp:TimeInterval = 0 {
        didSet{
            let date = Date(timeIntervalSince1970: timestamp)
            self.dayString = Time.dayOfDate(date)
            self.monthString = Time.monthStringOfDate(date)
            self.timeString = Time.clockOfDate(date)
        }
    }
    @objc dynamic var monthString:String = ""
    @objc dynamic var dayString:String = ""
    @objc dynamic var timeString:String = ""
    @objc dynamic var content:String = ""
    @objc dynamic var mood:Int = 0
    @objc dynamic var location:Location? = nil;
    
    let medias = List<Media>()  // **获取的到值顺序不保证
    
    override class func primaryKey() -> String? {
        return "timeString"
    }
    
    // MARK: - non-DB properties
    var moodType:MoodType{
        get{
            return MoodType(rawValue: self.mood)!
        }
        set{
            self.mood = newValue.rawValue
        }
    }

    override class func ignoredProperties() -> [String] {
        return ["place","moodType"]
    }
    
    
    func getMediaDescription() -> String{
        var mediaDescription:String = "\n"
        self.medias.forEach { (md) in
            mediaDescription += "[\(md.mediaType.rawValue)]"
        }
        return mediaDescription
    }
}
