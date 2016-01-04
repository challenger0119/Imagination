//
//  Item.swift
//  Imagination
//
//  Created by Star on 16/1/2.
//  Copyright © 2016年 Star. All rights reserved.
//

import UIKit

class Item: NSObject {
    
    private let moodColor = [UIColor.blackColor(),UIColor.orangeColor(),UIColor.greenColor(),UIColor.redColor()]
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
