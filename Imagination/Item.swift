//
//  Item.swift
//  Imagination
//
//  Created by Star on 16/1/2.
//  Copyright © 2016年 Star. All rights reserved.
//

import UIKit

class Item: NSObject {
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
    
    static let moodColor = [UIColor.darkGray,Item.coolColor,Item.justOkColor,Item.whyColor]
    fileprivate let moodStrings = ["NA","Cool","Just OK","Confused"]
   
    var mood:Int//心情
    var content:String//内容
    var color:UIColor
    var moodString:String
    var place:(name:String,latitude:Double,longtitude:Double)
    //var multiMediaFile:[String:String]?
    var multiMedias:[Int:MultiMediaFile]?
    var multiMediasDescrip:String = ""
    
    
    
    init(contentString:String) {
        
        var array = contentString.components(separatedBy: Item.separator)
        if array.count < 2 {
            array = contentString.components(separatedBy: Item.oldSeparator) //之前版本的
        }
        if array.count >= 2 {
            self.content = array[0]
            self.mood = Int(array[1])!
            
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
                        case MutiMediaType.image.rawValue:
                            mf.type = .image
                            mf.storePath = FileManager.imageFilePathWithName(filename)
                        case MutiMediaType.voice.rawValue:
                            mf.type = .voice
                            mf.storePath = FileManager.audioFilePathWithName(name: filename)
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
                            case MutiMediaType.image.rawValue:
                                mf.type = .image
                                mf.storePath = FileManager.imageFilePathWithName(filename)
                            case MutiMediaType.voice.rawValue:
                                mf.type = .voice
                                mf.storePath = FileManager.audioFilePathWithName(name: filename)
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
            self.mood = 0
            self.place = ("",0,0)
        }
        self.color = Item.moodColor[self.mood]
        self.moodString = self.moodStrings[self.mood]
        super.init()
    }
    
    class func getMultiMediaNameArray(multiMedia:[Int:MultiMediaFile])->[String]{
        var multiMediaoArray = [String]()
        let keyArray = Array(multiMedia.keys)
        for key in keyArray{
            if let obj = multiMedia[key] {
                var tmpStr = "\(obj.type.rawValue)\(self.multiMediaIndicator)\(obj.nameWithPosition(pos: key))"
                if keyArray.index(of: key) != keyArray.count-1 {
                    tmpStr += self.multiMediaSeparator
                }
                multiMediaoArray.append(tmpStr)
            }
        }
        return multiMediaoArray
    }
    
    //xxx<->xxx
    class func itemString(_ content:String,mood:Int) ->String {
        return content + self.separator + "\(mood)"
    }
    //xxx<->xxx<->xx,xx,xx
    class func itemString(_ content:String,mood:Int,GPSName:String,latitude:Double,longtitude:Double) ->String {
        return self.itemString(content, mood: mood) + self.separator + "\(GPSName)\(self.gpsSeparator)\(latitude)\(self.gpsSeparator)\(longtitude)"
    }
    
    //xxx<->xxx<->img->xx_xx;img->xx_xx;voice->xx_xx
    class func itemString(Content content:String,mood:Int,multiMedia:[Int:MultiMediaFile]) ->String {
        
        var multiMediaoString:String = ""
        let multiMediaArray = self.getMultiMediaNameArray(multiMedia: multiMedia)
        for str in multiMediaArray {
            multiMediaoString += str
        }
        return self.itemString(content, mood: mood) + self.separator + multiMediaoString
    }
    //xxx<->xxx<->img->xx_xx;img->xx_xx;voice->xx_xx<->xx,xx,xx
    class func itemString(Content content:String,mood:Int,GPSName:String,latitude:Double,longtitude:Double,multiMedia:[Int:MultiMediaFile]) ->String {
        
        return self.itemString(Content: content, mood: mood, multiMedia: multiMedia) + self.separator + "\(GPSName)\(self.gpsSeparator)\(latitude)\(self.gpsSeparator)\(longtitude)"
    }
}
