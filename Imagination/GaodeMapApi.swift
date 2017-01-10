//
//  GaodeMapApi.swift
//  Imagination
//
//  Created by Star on 2017/1/10.
//  Copyright © 2017年 Star. All rights reserved.
//

import UIKit
import Foundation
import CoreLocation

class GaodeMapApi: NSObject {
    //http://lbs.amap.com/api/webservice/guide/api/georegeo/#geo
    
    class func getNearByLocations(cor:CLLocationCoordinate2D)->[String]{
        let request = URLRequest(url:URL(string: "http://restapi.amap.com/v3/geocode/regeo?key=b62433a0d53d3b34eb8118264934f700&location=\(cor.longitude),\(cor.latitude)&extensions=all")!)
        Dlog(request.url?.absoluteString)
        let session = URLSession.shared
        
        let task = session.dataTask(with: request) { (data, respond, error) in
            if let dd = data {
                do {
                    let dic  = try JSONSerialization.jsonObject(with: dd)
                    Dlog(dic)
                }catch{
                    Dlog(error.localizedDescription)
                }
            }
        }
        task.resume()
        return []
    }
}
