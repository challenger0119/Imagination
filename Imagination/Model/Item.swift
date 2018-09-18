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
    
    func getColor() -> UIColor {
        return Item.moodColor[self.rawValue]
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
    
    // MARK: - static
    static let coolColor = UIColor.orange
    static let justOkColor = UIColor.init(red: 4.0/255.0, green: 119.0/255.0, blue: 240.0/255.0, alpha: 1.0)
    static let whyColor = UIColor.red
    static let defaultColor = UIColor.init(red: 239.0/255.0, green: 239.0/255.0, blue: 244.0/255.0, alpha: 1)
    
    static let separator = "<->"
    static let oldSeparator = "-"
    static let multiMediaSeparator = ";"
    static let gpsSeparator = ","
    static let multiMediaIndicator = "->"
    static let multiMediaNameSeparator = "_"
    static let multiMediaFileNameTimeSperator = Item.gpsSeparator //不干扰情况下，一时想不到别的了...
    
    fileprivate static let moodColor = [UIColor.darkGray,Item.coolColor,Item.justOkColor,Item.whyColor]
   
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
    @objc dynamic var location:String = "" {
        didSet{
            var sb = location.components(separatedBy: Item.gpsSeparator)
            self.place = (sb[0] ,Double(sb[1])!,Double(sb[2])!)
        }
    }
    
    let medias = List<Media>()
    
    override class func primaryKey() -> String? {
        return "timeString"
    }
    
    // MARK: - non-DB properties
    var place:(name:String,latitude:Double,longtitude:Double) = ("",0,0)
    var multiMedias:[Int:Media]? = nil
    var moodType:MoodType = .None
    
    
    override class func ignoredProperties() -> [String] {
        return ["place","multiMedias","moodType"]
    }
    
    
    func getMediaDescription() -> String{
        var mediaDescription:String = ""
        self.medias.forEach { (md) in
            mediaDescription += "[\(md.mediaType.rawValue)]"
        }
        return mediaDescription
    }
    /*
    convenience init(withTime time:String, contentString:String) {
        
        var array = contentString.components(separatedBy: Item.separator)
        if array.count < 2 {
            array = contentString.components(separatedBy: Item.oldSeparator) //之前版本的
        }
        if array.count >= 2 {
            self.content = array[0]
            if array.count == 2 {
                self.place = ("",0,0)
            }else{
                if array.count == 4 {
                    //gps数据在最后一个
                    var string = array[3]
                    var sb = string.components(separatedBy: Item.gpsSeparator)
                    self.place = (sb[0] ,Double(sb[1])!,Double(sb[2])!)
                    
                    string = array[2]
                    
                    sb = string.components(separatedBy: Item.multiMediaSeparator)
                    self.multiMediasDescrip += "\n"
                    
                    for file in sb {
                        
                        let fileDescrip = file.components(separatedBy: Item.multiMediaIndicator)
                        if fileDescrip.count != 2 {
                            continue
                        }
                        
                        let type = fileDescrip[0]
                        
                        let fileinfo = fileDescrip[1].components(separatedBy: Item.multiMediaNameSeparator)
                        let filename = fileinfo[0]
                        let position = fileinfo[1]
                        
                        let mf = MultiMediaFile()
                        switch type {
                        case MultiMediaType.image.rawValue:
                            mf.type = .image
                            mf.storePath = FileManager.imageFilePathWithName(name: filename)
                        case MultiMediaType.voice.rawValue:
                            mf.type = .voice
                            mf.storePath = FileManager.audioFilePathWithName(name: filename)
                        case MultiMediaType.video.rawValue:
                            mf.type = .video
                            mf.storePath = FileManager.videoFilePathWithName(name: filename)
                        default:
                            break
                        }
                        
                        if self.multiMedias == nil {
                            self.multiMedias = [Int(position)!:mf]
                        }else{
                            let _ = self.multiMedias?.updateValue(mf, forKey: Int(position)!)
                        }
                        self.multiMediasDescrip += "[\(type)]"
                    }
                }else{
                    let string = array[2]
                    var sbs = string.components(separatedBy: Item.gpsSeparator)
                    if sbs.count <= 2{
                        sbs = string.components(separatedBy: Item.multiMediaSeparator)
                        self.multiMediasDescrip += "\n"
                        for file in sbs {
                            let fileDescrip = file.components(separatedBy: Item.multiMediaIndicator)
                            if fileDescrip.count != 2 {
                                continue
                            }
                            let type = fileDescrip[0]
                            
                            let fileinfo = fileDescrip[1].components(separatedBy: Item.multiMediaNameSeparator)
                            let filename = fileinfo[0]
                            let position = fileinfo[1]
                            
                            let mf = MultiMediaFile()
                            switch type {
                            case MultiMediaType.image.rawValue:
                                mf.type = .image
                                mf.storePath = FileManager.imageFilePathWithName(name: filename)
                            case MultiMediaType.voice.rawValue:
                                mf.type = .voice
                                mf.storePath = FileManager.audioFilePathWithName(name: filename)
                            case MultiMediaType.video.rawValue:
                                mf.type = .video
                                mf.storePath = FileManager.videoFilePathWithName(name: filename)
                            default:
                                break
                            }
                            
                            if self.multiMedias == nil {
                                self.multiMedias = [Int(position)!:mf]
                            }else{
                                let _ = self.multiMedias?.updateValue(mf, forKey: Int(position)!)
                            }
                            self.multiMediasDescrip += "[\(type)]"
                        }
                        self.place = ("",0,0)
                    }else{
                        self.place = (sbs[0] ,Double(sbs[1])!,Double(sbs[2])!)
                    }
                }
            }
            
        } else {
            //容错，不会出现的地方 因为Array至少=2
            self.content = contentString
            self.place = ("",0,0)
        }
    }
    */
    
    
    class func locationStringWithName(GPSName:String,latitude:Double,longtitude:Double) -> String{
        return "\(GPSName)\(self.gpsSeparator)\(latitude)\(self.gpsSeparator)\(longtitude)"
    }
    
    //xxx<->xxx
    class func itemString(_ content:String,mood:Int) ->Item {
        let item = Item()
        item.content = content
        item.mood = mood
        return item
    }
    
    //xxx<->xxx<->xx,xx,xx
    class func itemString(_ content:String,mood:Int,GPSName:String,latitude:Double,longtitude:Double) -> Item {
        let item = self.itemString(content, mood: mood)
        item.location = self.locationStringWithName(GPSName: GPSName, latitude: latitude, longtitude: longtitude)
        return item
    }
    
    //xxx<->xxx<->img->xx_xx;img->xx_xx;voice->xx_xx
    class func itemString(Content content:String,mood:Int,multiMedia:[Int:Media]) -> Item {
        let item = self.itemString(content, mood: mood)
        
        multiMedia.forEach { (key, value) in
            value.position = key
            item.medias.append(value)
        }
        
        return item
    }
    
    //xxx<->xxx<->img->xx_xx;img->xx_xx;voice->xx_xx<->xx,xx,xx
    class func itemString(Content content:String,mood:Int,GPSName:String,latitude:Double,longtitude:Double,multiMedia:[Int:Media]) -> Item {
        let item = self.itemString(Content: content, mood: mood, multiMedia: multiMedia)
        item.location = self.locationStringWithName(GPSName: GPSName, latitude: latitude, longtitude: longtitude)
        return item
    }
}
