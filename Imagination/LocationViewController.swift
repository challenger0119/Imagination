//
//  LocationViewController.swift
//  Imagination
//
//  Created by Star on 16/8/27.
//  Copyright © 2016年 Star. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
let reusableIdentifier = "MapTableViewCell"
class LocationViewController: UIViewController,CLLocationManagerDelegate,UITableViewDataSource,UITableViewDelegate,MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var tableView: UITableView!
    var locManager:CLLocationManager!
    var places:[CLPlacemark]?
    var placeSelected:((place:CLPlacemark)->Void)?
    let coder = CLGeocoder()
    var animation:UIActivityIndicatorView!
    var placeToShow:CLLocationCoordinate2D? //外面传进来
    override func viewDidLoad() {
        super.viewDidLoad()
        locManager = CLLocationManager()
        locManager.delegate = self
        locManager.desiredAccuracy = kCLLocationAccuracyBest
        locManager.distanceFilter = 1000.0
        locManager.requestWhenInUseAuthorization()
        locManager.requestAlwaysAuthorization()
        
        
        //self.mapView.userTrackingMode = .Follow
        self.mapView.delegate = self
        
        tableView.delegate = self
        tableView.dataSource = self
        
        animation = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        animation.frame = CGRectMake(self.view.frame.width/2-50, self.view.frame.height/2-50, 100, 100)
        self.view .addSubview(animation)
        
        if self.placeToShow != nil {
            let cor = reverseTransformCoordinate(self.placeToShow!)
            self.addAnnotationWithCoordinate(CLLocation(latitude: cor.latitude,longitude: cor.longitude))
        }else{
            locManager.startUpdatingLocation()
        }
    }

    func addAnnotationWithCoordinate(loc:CLLocation) {
        animation.startAnimating()
        coder.reverseGeocodeLocation(loc, completionHandler: {
            pls,error in
            self.animation.stopAnimating()
            if error == nil {
                
                if let place = pls?.first {
                    let region = MKCoordinateRegionMakeWithDistance(place.location!.coordinate, 2000, 2000)
                    self.mapView.setRegion(region, animated: true)
                    self.mapView.addAnnotation(Annotation(coor: place.location!.coordinate,pMark: place))
                    self.mapView.addAnnotation(Annotation(coor: place.location!.coordinate, pMark: place))
                }
                self.places = pls
                self.tableView.reloadData()
            }else{
                print(error?.description);
            }
        })
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //MARK: -Location
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
       // print(locations);//这里的坐标不准确
        
        self.locManager.stopUpdatingLocation()
        if let newLocation = locations.last {
            self.addAnnotationWithCoordinate(newLocation)
        }
    }

    //MARK: -Table
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let pls = self.places {
            return pls.count
        }else{
            return 0
        }
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(reusableIdentifier, forIndexPath: indexPath)
        cell.textLabel?.text = self.places![indexPath.row].name
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if self.placeSelected != nil {
            let place = self.places![indexPath.row]
            self.placeSelected!(place:place)
        }
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    //MARK: MapViewDelegate
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if let annoView = mapView.dequeueReusableAnnotationViewWithIdentifier(reusableIdentifier) {
            annoView.annotation = annotation
            return annoView
        }else{
            let annoVIew = MKPinAnnotationView.init(annotation: annotation, reuseIdentifier: reusableIdentifier)
            annoVIew.canShowCallout = true
            annoVIew.pinTintColor = MKPinAnnotationView.redPinColor()
            //annoVIew.animatesDrop = true
            annoVIew.highlighted = true
            annoVIew.draggable = true
            return annoVIew
        }
    }
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, didChangeDragState newState: MKAnnotationViewDragState, fromOldState oldState: MKAnnotationViewDragState) {
        let cor = reverseTransformCoordinate(view.annotation!.coordinate)
        if newState == .Ending {
            animation.startAnimating()
            let loc = CLLocation(latitude: cor.latitude, longitude: cor.longitude)
            self.coder.reverseGeocodeLocation(loc, completionHandler: {
                pls,error in
                self.animation.stopAnimating()
                if error == nil {
                    if let place = pls?.first {
                        self.mapView.removeAnnotation(view.annotation!)
                        self.mapView.addAnnotation(Annotation(coor: place.location!.coordinate, pMark: place))
                    }
                    self.places = pls
                    self.tableView.reloadData()
                }else{
                    print(error?.description);
                }
                
            })
        }
        
    }
    
    func mapViewDidFailLoadingMap(mapView: MKMapView, withError error: NSError) {
        print(error.debugDescription)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    //地址有偏移 code的结果在location的右下角
    //第一个前提是 系统自我定位时候 获取的location不正确 而coder后的是正确的
    //第二个前提是 annotationview 拖拽后拿到的location是正确的 经过coder后不正确了 所以这里在didchangeDrageState里使用reverseTranslate修正
    //具体原因有待搜寻
    func transformCoordinate(cor:CLLocationCoordinate2D)->CLLocationCoordinate2D{
        let newx = cor.latitude*(30.501500482611835/30.503810239337618)
        let newy = cor.longitude*(114.42497398363371/114.41945126570926)
        return CLLocationCoordinate2D(latitude: newx,longitude: newy)
    }
    
    func reverseTransformCoordinate(cor:CLLocationCoordinate2D) -> CLLocationCoordinate2D {
        let newx = cor.latitude/(30.501500482611835/30.503810239337618)
        let newy = cor.longitude/(114.42497398363371/114.41945126570926)
        return CLLocationCoordinate2D(latitude: newx, longitude: newy)
    }

}