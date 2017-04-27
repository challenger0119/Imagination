//
//  MoodShowViewController.swift
//  Imagination
//
//  Created by Star on 2017/4/24.
//  Copyright © 2017年 Star. All rights reserved.
//

import UIKit
import MapKit
import AVFoundation
class MoodShowViewController: UIViewController {
    
    var multiMediaBufferDic:[Int:MultiMediaFile]?
    var text:String = ""
    var pInfo:(name:String,latitude:Double,longtitude:Double)?
    var exitAnimation:((Void)->Void)?
    var state = 0
    fileprivate var mapView:UIView?
    
    init(contentText:String,contentDic:[Int:MultiMediaFile]?,state:Int,placeInfo:(name:String,latitude:Double,longtitude:Double)?) {
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
        
        if pInfo != nil && pInfo!.latitude != 0 {
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
        
        
        if self.multiMediaBufferDic != nil{
            let font = UIFont(name: "Helvetica", size: 15.0)
            let mstring = NSMutableAttributedString(string: self.text, attributes: [NSFontAttributeName:font!,NSParagraphStyleAttributeName:paragraghStyle,NSForegroundColorAttributeName:Item.moodColor[state]])
            
            var keys = Array(self.multiMediaBufferDic!.keys)
            keys.sort()
            var i:Int = 0 //插入补偿 解决排版问题
            for key in keys {
                if let mf = self.multiMediaBufferDic![key] {
                    let imageWidth = textView.frame.width - 10;
                    if mf.type == .image {
                        let image = UIImage.init(contentsOfFile: mf.storePath)!
                        let textAttach = NSTextAttachment(data:FileManager.imageData(image: image), ofType: mf.type.rawValue)
                        let imageHeight = image.size.height / image.size.width * imageWidth
                        textAttach.image = MultiMediaFile.roundCornerImage(image, frame: CGRect(x: 0, y: 0, width: imageWidth, height: imageHeight))
                        let imageAttributeString = NSAttributedString(attachment:textAttach)
                        mstring.insert(imageAttributeString, at: key+i)
                        i += 1
                    }else if mf.type == .voice {
                        do{
                            let data = try Data.init(contentsOf: URL.init(fileURLWithPath: mf.storePath))
                            let textAttach = NSTextAttachment(data:data, ofType: mf.type.rawValue)
                            let image = UIImage.init(named: "audio")!
                            let imageHeight = image.size.height / image.size.width * imageWidth
                            textAttach.image = MultiMediaFile.roundCornerImage(image, frame: CGRect(x: 0, y: 0, width: imageWidth, height: imageHeight))
                            let imageAttributeString = NSAttributedString(attachment:textAttach)
                            mstring.insert(imageAttributeString, at: key+i)
                            i += 1
                        }catch{
                            Dlog(error.localizedDescription)
                        }
                    }else if mf.type == .video {
                        do{
                            let url = URL.init(fileURLWithPath: mf.storePath)
                            let data = try Data.init(contentsOf: url)
                            let textAttach = NSTextAttachment(data:data, ofType: mf.type.rawValue)
                            let image = MultiMediaFile.viedoShot(withURL: url)!
                            let imageHeight = image.size.height / image.size.width * imageWidth
                            textAttach.image = MultiMediaFile.roundCornerImage(image, frame: CGRect(x: 0, y: 0, width: imageWidth, height: imageHeight))
                            let imageAttributeString = NSAttributedString(attachment:textAttach)
                            mstring.insert(imageAttributeString, at: key+i)
                            i += 1
                        }catch{
                            Dlog(error.localizedDescription)
                        }
                    }
                }
            }
            textView.attributedText = mstring
        }
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(closeVC)))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
