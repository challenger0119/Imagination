//
//  Item.swift
//  Imagination
//
//  Created by Star on 16/1/2.
//  Copyright © 2016年 Star. All rights reserved.
//

import UIKit

class Item: NSObject {
    let happy = (color:UIColor.orangeColor(),index:1)
    let justok = (color:UIColor.greenColor(),index:2)
    let why = (color:UIColor.redColor(),index:3)
    
    var content:String//内容
    var time:String//时间
    var mood:Int//心情
    init(time:String,content:String,mood:Int) {
        self.content = content
        self.time = time
        self.mood = mood
        super.init()
    }
    
    func toDictionary() -> Dictionary<String,String> {
        let cc = self.content + "-" + "\(self.mood)"
        return Dictionary.init(dictionaryLiteral: (self.time,cc))
    }
    func finalString() -> String{
        return self.content + "-" + "\(self.mood)"
    }
    init(contentString:String,time:String) {
        self.time = time
        
        let array = contentString.componentsSeparatedByString("-")
        if array.count >= 2 {
            self.content = array[0]
            let mm = array[1]
            self.mood = Int(mm)!
            
        } else {
            self.content = "错误"
            self.mood = 0
        }
        super.init()
    }
}
