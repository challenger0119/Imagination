//
//  MoodShowImageView.swift
//  Imagination
//
//  Created by Star on 2017/4/24.
//  Copyright © 2017年 Star. All rights reserved.
//

import UIKit
import MapKit
class MoodShowImageView: UIImageView {

    var multiMediaBufferDic:[Int:AnyObject]?
    var text:String = ""
    var pInfo:(name:String,latitude:Double,longtitude:Double)?
    var exitAnimation:((Void)->Void)?
    var animationTime:TimeInterval = 0.2
    fileprivate var mapView:UIView?
    init(frame: CGRect,contentText:String,contentDic:[Int:AnyObject]?,state:Int,placeInfo:(name:String,latitude:Double,longtitude:Double)?) {
        self.multiMediaBufferDic = contentDic
        self.text = contentText
        self.pInfo = placeInfo
        super.init(frame: frame)
        self.isUserInteractionEnabled = true
        
        let textView = UITextView(frame: CGRect(x: 20, y: 40, width: self.frame.width-40, height: self.frame.height-60))
        textView.isEditable = false
        textView.layer.cornerRadius = 5.0
        textView.clipsToBounds = true
        textView.textColor = Item.moodColor[state]
        self.addSubview(textView)
        
        if pInfo != nil {
            var tframe = textView.frame
             tframe.size.height = tframe.size.height - 30
            textView.frame = tframe
            let locBtn = UIButton(frame: CGRect(x: 20, y: self.frame.height-50, width: textView.frame.width, height: 30))
            self.addSubview(locBtn)
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
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(closeView)))
    }

    func closeView(){
        if exitAnimation != nil {
            UIView.animate(withDuration: animationTime, animations: {
                self.exitAnimation!()
            }, completion: {
                boo in
                if boo {
                    self.removeFromSuperview()
                }
            })
        }else{
            self.removeFromSuperview()
        }
    }
    func showMap(){
        if  mapView == nil {
            mapView = IndicatorMapView(frame: CGRect(x: 20, y: self.frame.height-50-200, width: self.frame.width-40, height: 200),coor:CLLocationCoordinate2D(latitude: pInfo!.latitude, longitude: pInfo!.longtitude))
            self.addSubview(mapView!)
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


}
