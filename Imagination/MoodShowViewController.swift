//
//  MoodShowViewController.swift
//  Imagination
//
//  Created by Star on 2017/4/24.
//  Copyright © 2017年 Star. All rights reserved.
//

import UIKit
import MapKit
class MoodShowViewController: UIViewController {
    
    var multiMediaBufferDic:[Int:AnyObject]?
    var text:String = ""
    var pInfo:(name:String,latitude:Double,longtitude:Double)?
    var exitAnimation:((Void)->Void)?
    var state = 0
    fileprivate var mapView:UIView?
    
    init(contentText:String,contentDic:[Int:AnyObject]?,state:Int,placeInfo:(name:String,latitude:Double,longtitude:Double)?) {
        self.multiMediaBufferDic = contentDic
        self.text = contentText
        self.pInfo = placeInfo
        self.state = state
        super.init(nibName: nil, bundle: nil)
    }

    func closeVC(){
        UIView.animate(withDuration: 0.2, animations: {
            self.view.alpha = 0
        }, completion: {
            boo in
            if boo {
                self.dismiss(animated: false, completion: {
                    
                })
            }
        })
    }
    func showMap(){
        if  mapView == nil {
            mapView = IndicatorMapView(frame: CGRect(x: 20, y: self.view.frame.height-50-200, width: self.view.frame.width-40, height: 200),coor:CLLocationCoordinate2D(latitude: pInfo!.latitude, longitude: pInfo!.longtitude))
            self.view.addSubview(mapView!)
        }else{
            mapView?.removeFromSuperview()
        }
    }
    func cutImage(_ image:UIImage,frame:CGRect)->UIImage {
        UIGraphicsBeginImageContextWithOptions(frame.size, false, UIScreen.main.scale)
        UIBezierPath(roundedRect: frame, cornerRadius: 5).addClip()
        image.draw(in: frame)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let imageView = UIImageView(frame: self.view.frame)
        imageView.image = UIImage.blurImage(of: UIApplication.shared.keyWindow, withBlurNumber: 1)
        self.view.addSubview(imageView)
        let textView = UITextView(frame: CGRect(x: 20, y: 40, width: self.view.frame.width-40, height: self.view.frame.height-60))
        textView.isEditable = false
        textView.layer.cornerRadius = 5.0
        textView.clipsToBounds = true
        textView.textColor = Item.moodColor[self.state]
        self.view.addSubview(textView)
        
        if pInfo != nil {
            var tframe = textView.frame
            tframe.size.height = tframe.size.height - 30
            textView.frame = tframe
            let locBtn = UIButton(frame: CGRect(x: 20, y: self.view.frame.height-50, width: textView.frame.width, height: 30))
            self.view.addSubview(locBtn)
            locBtn.layer.cornerRadius = 5.0
            locBtn.setTitleColor(Item.moodColor[state], for: .normal)
            locBtn.setTitle(pInfo!.name, for: .normal)
            locBtn.titleLabel?.adjustsFontSizeToFitWidth = true
            locBtn.addTarget(self, action: #selector(showMap), for: .touchUpInside)
        }
        
        
        let paragraghStyle = NSMutableParagraphStyle()
        paragraghStyle.lineSpacing = 5
        paragraghStyle.alignment = .left
        paragraghStyle.lineBreakMode = .byCharWrapping
        paragraghStyle.allowsDefaultTighteningForTruncation = true
        
        let font = UIFont(name: "Helvetica", size: 15.0)
        let mstring = NSMutableAttributedString(string: self.text, attributes: [NSFontAttributeName:font!,NSParagraphStyleAttributeName:paragraghStyle,NSForegroundColorAttributeName:Item.moodColor[state]])
        if self.multiMediaBufferDic != nil{
            var keys = Array(self.multiMediaBufferDic!.keys)
            keys.sort()
            var i:Int = 0 //插入补偿 解决排版问题
            for key in keys {
                if let multimedia = self.multiMediaBufferDic![key] {
                    if multimedia.isKind(of: UIImage.self) {
                        let image = multimedia as! UIImage
                        let textAttach = NSTextAttachment(data:nil, ofType: nil)
                        let imageWidth = textView.frame.width - 10;
                        let imageHeight = image.size.height / image.size.width * imageWidth
                        textAttach.image = cutImage(image, frame: CGRect(x: 0, y: 0, width: imageWidth, height: imageHeight))
                        let imageAttributeString = NSAttributedString(attachment:textAttach)
                        
                        mstring.insert(imageAttributeString, at: key+i)
                        i += 1
                    }
                }
            }
        }
        textView.attributedText = mstring
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(closeVC)))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
