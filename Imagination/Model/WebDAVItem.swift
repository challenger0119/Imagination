//
//  WebDAVItem.swift
//  Imagination
//
//  Created by Miaoqi Wang on 2019/4/22.
//  Copyright © 2019 Star. All rights reserved.
//

import Foundation

class WebDAVItem {
    
    enum ParseStatus {
        case none, parsing, parsed
    }
    
    let path:String
    let date:String
    let size:Double
    let signature:String
    let author:String
    let type:String
    let name:String
    
    var parseStatus:ParseStatus = .none
    
    init(withPath path:String, date:String, size:Double, signature:String, author:String, type:String, name:String) {
        self.path = path
        self.date = date
        self.size = size
        self.signature = signature
        self.author = author
        self.type = type
        self.name = name
    }
}


