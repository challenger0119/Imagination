//
//  Annotation.swift
//  GPSTry
//
//  Created by Star on 16/7/14.
//  Copyright © 2016年 Star. All rights reserved.
//

import UIKit
import MapKit
class Annotation: NSObject,MKAnnotation {
    var streetAddress:String?
    var city:String?
    var state:String?
    var zip:String?
    var title: String?
    var subtitle: String?
    var coordinate:CLLocationCoordinate2D
    init(coor:CLLocationCoordinate2D,pMark:CLPlacemark? = nil){
        self.coordinate = coor

        if let placeMark = pMark {
            self.streetAddress = placeMark.thoroughfare
            self.city = placeMark.locality
            self.state = placeMark.administrativeArea
            self.zip = placeMark.postalCode
            self.title = placeMark.thoroughfare
            self.subtitle = placeMark.locality
        }else{
            self.title = "您在这里"
        }
        
    }
    
}
