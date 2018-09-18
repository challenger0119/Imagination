//
//  Place.swift
//  Imagination
//
//  Created by Star on 2018/9/18.
//  Copyright © 2018年 Star. All rights reserved.
//

import UIKit
import RealmSwift

class Location: Object {
    @objc dynamic var name:String = ""
    @objc dynamic var latitude:Double = 0
    @objc dynamic var longtitude:Double = 0
    
    let ofItem = LinkingObjects(fromType: Item.self, property: "location")
    
    convenience init(withName name:String, latitude:Double, longtitude:Double) {
        self.init()
        self.name = name
        self.latitude = latitude
        self.longtitude = longtitude
    }
}
