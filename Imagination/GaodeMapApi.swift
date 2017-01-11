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
    
    
    class func getNearByLocations(cor:CLLocationCoordinate2D,rst:@escaping (([(name:String,coor:CLLocationCoordinate2D)])->Void)){
        var result = [(name:String,coor:CLLocationCoordinate2D)]()
        
        let reach = Reachability.forInternetConnection()
        
        let status = reach!.currentReachabilityStatus()
        if status == NotReachable {
            rst(result)
            return
        }
        let request = URLRequest(url:URL(string: "http://restapi.amap.com/v3/geocode/regeo?key=b62433a0d53d3b34eb8118264934f700&location=\(cor.longitude),\(cor.latitude)&extensions=all")!)
        Dlog(request.url?.absoluteString)
        
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (data, respond, error) in
            
            
            if let dd = data {
                do {
                    let dic  = try JSONSerialization.jsonObject(with: dd) as! Dictionary<String,AnyObject>
                    Dlog(dic)
                    if Int(dic["status"] as! String)!  == 1 {
                        let regeocodes = dic["regeocode"] as! Dictionary<String,AnyObject>
                        
                        let addressComponent = regeocodes["addressComponent"] as! Dictionary<String,AnyObject>
                        let address = regeocodes["formatted_address"] as! String
                        let streetNumber = addressComponent["streetNumber"] as! Dictionary<String,AnyObject>
                        let location = streetNumber["location"] as! String
                        let array = location.components(separatedBy: ",")
                        if array.count == 2 {
                            let coor = CLLocationCoordinate2D(latitude: Double(array[1])!, longitude: Double(array[0])!)
                            result.append((address,coor))
                        }else{
                            result.append((address,CLLocationCoordinate2D()))
                        }
                        
                        let pois = regeocodes["pois"] as! [Dictionary<String,AnyObject>]
                        for poi in pois {
                            let pname = poi["name"] as! String
                            let plocation = poi["location"] as! String
                            let parray = plocation.components(separatedBy: ",")
                            if parray.count == 2 {
                                let pcoor = CLLocationCoordinate2D(latitude: Double(parray[1])!, longitude: Double(parray[0])!)
                                result.append((pname,pcoor))
                            }else{
                                result.append((pname,CLLocationCoordinate2D()))
                            }
                        }
                        
                    }else{
                        Dlog(dic)
                    }
                    
                }catch{
                    Dlog(error.localizedDescription)
                }
            }
            rst(result)
        }
        task.resume()
    }
}
