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
    
    static let seperator = "<->"
    
    fileprivate let moodColor = [UIColor.darkGray,Item.coolColor,Item.justOkColor,Item.whyColor]
    fileprivate let moodStrings = ["NA","Cool","Just OK","Confused"]
   
    var mood:Int//心情
    var content:String//内容
    var color:UIColor
    var moodString:String
    var place:(name:String,latitude:Double,longtitude:Double)
    
    init(contentString:String) {
        
        let array = contentString.components(separatedBy: Item.seperator)
        if array.count >= 2 {
            self.content = array[0]
            self.mood = Int(array[1])!
            if array.count >= 3{
                let string = array[2]
                let sb = string.components(separatedBy: ",")
                self.place = (sb[0] ,Double(sb[1])!,Double(sb[2])!)
            }else{
                self.place = ("",0,0)
            }
        } else {
            self.content = contentString
            self.mood = 0
            self.place = ("",0,0)
        }
        self.color = self.moodColor[self.mood]
        self.moodString = self.moodStrings[self.mood]
        super.init()
    }
    
    class func ItemString(_ content:String,mood:Int) ->String {
        return content + self.seperator + "\(mood)"
    }
    
    class func ItemString(_ content:String,mood:Int,GPSName:String,latitude:Double,longtitude:Double) ->String {
        return content + self.seperator + "\(mood)" + self.seperator + "\(GPSName),\(latitude),\(longtitude)"
    }
}
