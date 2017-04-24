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
    var multiMediaFile:[String:String]?
    var multiMedias:[Int:AnyObject]?
    var multiMediasDescrip:String = ""
    
    enum MutiMediaType:String {
        case image = "Image",voice = "Voice",video = "Video",def = "multi"
    }
    
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
                        let data = FileManager.multimediaFileWith(Name: file)
                        if data.obj == nil {
                            //无数据
                            continue
                        }
                        let fileinfo = fileDescrip[1].components(separatedBy: Item.multiMediaNameSeparator)
                        
                        if self.multiMedias == nil {
                            self.multiMedias = [Int(fileinfo[1])!:data.obj!]
                        }else{
                            let _ = self.multiMedias?.updateValue(data.obj!, forKey: Int(fileinfo[1])!)
                        }
                        
                        if self.multiMediaFile == nil {
                            self.multiMediaFile = [fileDescrip[0]:fileDescrip[1]]
                        }else{
                            let _ = self.multiMediaFile?.updateValue(fileDescrip[1], forKey: fileDescrip[0])
                        }
                        self.multiMediasDescrip += "[\(fileDescrip[0])]"
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
                            let data = FileManager.multimediaFileWith(Name: file)
                            if data.obj == nil {
                                //无数据
                                continue
                            }
                            let fileinfo = fileDescrip[1].components(separatedBy: Item.multiMediaNameSeparator)
                            
                            if self.multiMedias == nil {
                                self.multiMedias = [Int(fileinfo[1])!:data.obj!]
                            }else{
                                let _ = self.multiMedias?.updateValue(data.obj!, forKey: Int(fileinfo[1])!)
                            }
                            
                            if self.multiMediaFile == nil {
                                self.multiMediaFile = [fileDescrip[0]:fileDescrip[1]]
                            }else{
                                let _ = self.multiMediaFile?.updateValue(fileDescrip[1], forKey: fileDescrip[0])
                            }
                            self.multiMediasDescrip += "[\(fileDescrip[0])]"
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
    
    class func multiMediaFileNameTime(day:String,time:String) -> String{
        return day+multiMediaFileNameTimeSperator+time
    }
    class func getMultiMediaNameArray(MultiMedia multiMedia:[Int:AnyObject],multiMediaName:String)->[String]{
        func getMediaTypeString(obj:AnyObject)->String?{
            if obj.isKind(of: UIImage.self) {
                return self.MutiMediaType.image.rawValue
            }else{
                return nil
            }
        }
        var multiMediaoArray = [String]()
        
        let keyArray = Array(multiMedia.keys)
        for key in keyArray{
            if let obj = multiMedia[key] {
                if let type = getMediaTypeString(obj: obj){
                    var tmpStr = "\(type)\(self.multiMediaIndicator)\(self.multiMediaName(name: multiMediaName, position: key))"
                    if keyArray.index(of: key) != keyArray.count-1 {
                        tmpStr += self.multiMediaSeparator
                    }
                    multiMediaoArray.append(tmpStr)
                }
            }
        }
        return multiMediaoArray
    }
    
    class func getMultiMediaNameBaseDic(MultiMedia multiMedia:[Int:AnyObject],multiMediaName:String)->[String:AnyObject]{
        func getMediaTypeString(obj:AnyObject)->String?{
            if obj.isKind(of: UIImage.self) {
                return self.MutiMediaType.image.rawValue
            }else{
                return self.MutiMediaType.def.rawValue
            }
        }
        var multiMediaDic = [String:AnyObject]()
        
        let keyArray = Array(multiMedia.keys)
        for key in keyArray{
            if let obj = multiMedia[key] {
               multiMediaDic.updateValue(obj, forKey: self.multiMediaName(name: multiMediaName, position: key))
            }
        }
        return multiMediaDic
    }
    
    //xxx_12
    class func multiMediaName(name nm:String,position pos:Int)->String{
        return "\(nm)\(self.multiMediaNameSeparator)\(pos)"
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
    class func itemString(Content content:String,mood:Int,multiMedia:[Int:AnyObject],multiMediaName:String) ->String {
        
        var multiMediaoString:String = ""
        let multiMediaArray = self.getMultiMediaNameArray(MultiMedia: multiMedia,multiMediaName: multiMediaName)
        for str in multiMediaArray {
            multiMediaoString += str
        }
        return self.itemString(content, mood: mood) + self.separator + multiMediaoString
    }
    //xxx<->xxx<->img->xx_xx;img->xx_xx;voice->xx_xx<->xx,xx,xx
    class func itemString(Content content:String,mood:Int,GPSName:String,latitude:Double,longtitude:Double,multiMedia:[Int:AnyObject],multiMediaName:String) ->String {
        
        return self.itemString(Content: content, mood: mood, multiMedia: multiMedia, multiMediaName: multiMediaName) + self.separator + "\(GPSName)\(self.gpsSeparator)\(latitude)\(self.gpsSeparator)\(longtitude)"
    }
}
