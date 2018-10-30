//
//  IndicatorMapView.swift
//  Imagination
//
//  Created by Star on 2017/4/24.
//  Copyright © 2017年 Star. All rights reserved.
//

import UIKit
import MapKit
class IndicatorMapView: UIView,MKMapViewDelegate {
    
    init(frame: CGRect,coor:CLLocationCoordinate2D) {
        super.init(frame: frame)
        let backView = IndicatorMapViewBack(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height))
        self.addSubview(backView)
        let mapView = MKMapView(frame: CGRect(x: 0, y: 0, width: backView.frame.width, height: backView.mapHeight))
        mapView.delegate = self
        mapView.clipsToBounds = true
        backView.addSubview(mapView)
        
        let animation = UIActivityIndicatorView(style: .gray)
        animation.frame = CGRect(x:self.frame.width/2-50,y:self.frame.height/2-50,width:100, height:100)
        self.addSubview(animation)
        animation.startAnimating()
        let coder = CLGeocoder()
        
        let loc = CLLocation(latitude: coor.latitude, longitude: coor.longitude)
        coder.reverseGeocodeLocation(loc, completionHandler: {
            pls,error in
            animation.stopAnimating()
            if error == nil {
                if let place = pls?.first {
                    let region = MKCoordinateRegion.init(center: place.location!.coordinate, latitudinalMeters: 1500, longitudinalMeters: 1500)
                    mapView.setRegion(region, animated: true)
                    mapView.addAnnotation(Annotation(coor: place.location!.coordinate,pMark: place))
                }
            }else{
                Dlog(error!.localizedDescription);
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "提示", message: "定位需要网络", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "好的", style: .default, handler: { (act) in
                    }))
                    self.removeFromSuperview()
                }
            }
        })
 
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    //MARK: MapViewDelegate
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annoView = mapView.dequeueReusableAnnotationView(withIdentifier: "IndicatorMapView") {
            annoView.annotation = annotation
            return annoView
        }else{
            let annoVIew = MKPinAnnotationView.init(annotation: annotation, reuseIdentifier: "IndicatorMapView")
            annoVIew.canShowCallout = true
            annoVIew.pinTintColor = MKPinAnnotationView.redPinColor()
            annoVIew.isHighlighted = true
            annoVIew.isDraggable = true
            return annoVIew
        }
    }

}
