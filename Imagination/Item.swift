//
//  Item.swift
//  Imagination
//
//  Created by Star on 16/1/2.
//  Copyright © 2016年 Star. All rights reserved.
//

import UIKit

class Item: NSObject {
    static let coolColor = UIColor.orangeColor()
    static let justOkColor = UIColor.init(red: 4.0/255.0, green: 119.0/255.0, blue: 240.0/255.0, alpha: 1.0)
    static let whyColor = UIColor.redColor()
    private let moodColor = [UIColor.blackColor(),Item.coolColor,Item.justOkColor,Item.whyColor]
    var mood:Int//心情
    
    var content:String//内容
    var color:UIColor
    
    init(contentString:String) {
        
        let array = contentString.componentsSeparatedByString("-")
        if array.count >= 2 {
            self.content = array[0]
            self.mood = Int(array[1])!
            self.color = self.moodColor[self.mood]
        } else {
            self.content = contentString
            self.mood = 0
            self.color = self.moodColor[self.mood]
        }
        super.init()
    }
    
    static func ItemString(content:String,mood:Int) ->String {
        return content + "-" + "\(mood)"
    }
}
