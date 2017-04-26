//
//  MultiMediaFile.swift
//  Imagination
//
//  Created by Star on 2017/4/26.
//  Copyright © 2017年 Star. All rights reserved.
//

import UIKit
enum MutiMediaType:String {
    case image = "Image",voice = "Voice",video = "Video",def = "multi"
}
class MultiMediaFile: NSObject {
    var type:MutiMediaType = .def
    var storePath:String = "" {
        didSet{
            Dlog(storePath)
            name = (storePath as NSString).lastPathComponent
            Dlog(name)
        }
    }
    var name:String = ""
    var obj:AnyObject?
    
    func nameWithPosition(pos:Int)->String{
        return name + Item.multiMediaNameSeparator + String(pos)
    }
}
