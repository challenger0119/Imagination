//
//  ContentShowViewController.swift
//  Imagination
//
//  Created by Star on 2017/4/27.
//  Copyright © 2017年 Star. All rights reserved.
//

import UIKit
import CoreLocation
import AVKit
import AVFoundation
class ContentShowViewController: UIViewController {
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
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let imageView = UIImageView(frame: self.view.frame)
        imageView.image = UIImage.blurImage(of: UIApplication.shared.keyWindow, withBlurNumber: 1)
        self.view.addSubview(imageView)
        
        let closeBtn = UIButton(frame: CGRect(x: self.view.frame.width-80, y: 20, width: 80, height: 30))
        closeBtn.setTitle("Close", for: .normal)
        closeBtn.titleLabel?.textAlignment = .right
        closeBtn.setTitleColor(Item.moodColor[state], for: .normal)
        closeBtn.addTarget(self, action: #selector(closeVC), for: .touchUpInside)
        self.view.addSubview(closeBtn)
        
        
        let textView = UIScrollView(frame: CGRect(x: 20, y: 50, width: self.view.frame.width-40, height: self.view.frame.height-70))
        textView.layer.cornerRadius = 5.0
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
        
        var usedHeight:CGFloat = 0
        if self.multiMediaBufferDic != nil{
            var keys = Array(self.multiMediaBufferDic!.keys)
            keys.sort()
            var keyIndex = 0
            var lastMuliIndex = -1
            let contentend = (self.text.characters.count > keys.last!) ? (self.text.characters.count):keys.last!
            for drawIndex in 0...contentend {
                if keyIndex < keys.count && drawIndex == keys[keyIndex] {
                    if let mf = self.multiMediaBufferDic![drawIndex] {
                        let imageWidth = textView.frame.width - 10;
                        if mf.type == .image {
                            let image = UIImage.init(contentsOfFile: mf.storePath)!
                            let imageHeight = image.size.height / image.size.width * imageWidth
                            textView.addSubview(
                                buttonFactory(frame: CGRect(x:0,y:usedHeight,width:textView.frame.width,height:imageHeight),
                                              backgroundImage: MultiMediaFile.roundCornerImage(image, frame: CGRect(x: 0, y: 0, width: imageWidth, height: imageHeight)), tag: keyIndex)
                            )
                            usedHeight += imageHeight
                        }else if mf.type == .voice {
                            let image = UIImage.init(named: "audio")!
                            let imageHeight = image.size.height / image.size.width * imageWidth
                            textView.addSubview(
                                buttonFactory(frame: CGRect(x:0,y:usedHeight,width:textView.frame.width,height:imageHeight),
                                              backgroundImage: MultiMediaFile.roundCornerImage(image, frame: CGRect(x: 0, y: 0, width: imageWidth, height: imageHeight)),
                                              tag: keyIndex)
                            )
                            usedHeight += imageHeight
                        }else if mf.type == .video {
                            let url = URL.init(fileURLWithPath: mf.storePath)
                            let image = MultiMediaFile.viedoShot(withURL: url)!
                            let imageHeight = image.size.height / image.size.width * imageWidth
                            textView.addSubview(
                                buttonFactory(frame: CGRect(x:0,y:usedHeight,width:textView.frame.width,height:imageHeight),
                                              backgroundImage: MultiMediaFile.roundCornerImage(image, frame: CGRect(x: 0, y: 0, width: imageWidth, height: imageHeight)), tag: keyIndex)
                            )
                            usedHeight += imageHeight
                        }
                    }
                    lastMuliIndex = drawIndex
                    keyIndex += 1
                }else if drawIndex == lastMuliIndex + 1 {
                    let start = self.text.index(text.startIndex, offsetBy: lastMuliIndex + 1)
                    var offset = 0
                    if keyIndex < keys.count {
                        offset = keys[keyIndex]
                    }else{
                        offset = contentend
                    }
                    let end = self.text.index(text.startIndex, offsetBy: offset)
                    let rg = Range(uncheckedBounds: (start,end))
                    let substring = self.text.substring(with: rg)
                    let height = (substring as NSString).boundingRect(with: CGSize(width:textView.frame.width,height:textView.frame.height), options: [NSStringDrawingOptions.usesLineFragmentOrigin,.usesFontLeading], attributes: [NSFontAttributeName:UIFont.systemFont(ofSize: 15)], context: nil).size.height
                    textView.addSubview(
                        labelFactory(frame: CGRect(x:0,y:usedHeight,width:textView.frame.width,height:height), content: substring, textColor: Item.moodColor[state])
                    )
                    usedHeight += height
                }
            }
        }
        textView.contentSize = CGSize(width: textView.frame.size.width, height: usedHeight)
    }
    
    func buttonFactory(frame:CGRect,backgroundImage:UIImage,tag:Int)->UIButton{
        let btn = UIButton(type: .roundedRect)
        btn.frame = frame
        btn.setBackgroundImage(backgroundImage, for: .normal)
        btn.tag = tag
        btn.addTarget(self, action: #selector(btnClicked), for: .touchUpInside)
        return btn
    }
    func labelFactory(frame:CGRect,content:String,textColor:UIColor)->UILabel{
        let label = UILabel(frame: frame)
        label.text = content
        label.textColor = textColor
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 15)
        return label
    }

    func btnClicked(sender:UIButton){
        var keys = Array(self.multiMediaBufferDic!.keys)
        keys.sort()
        let mf = self.multiMediaBufferDic![keys[sender.tag]]!
        switch mf.type {
        case .image:
            let vc = ImageViewController(withImage: UIImage.init(contentsOfFile: mf.storePath)!)
            let nav = UINavigationController(rootViewController: vc)
            nav.navigationBar.isTranslucent = false
            self.present(nav, animated: true, completion: {
                
            })
            
        case .video:
            let playView = AVPlayerViewController()
            let playitem = AVPlayerItem(asset: AVAsset(url: URL.init(fileURLWithPath: mf.storePath)))
            let player = AVPlayer(playerItem: playitem)
            playView.player = player
            self.present(playView, animated: true, completion: {
            })
        case .voice:
            let vc = AudioViewController(withFile: mf.storePath)
            let nav = UINavigationController(rootViewController: vc)
            nav.navigationBar.isTranslucent = false
            self.present(nav, animated: true, completion: {
                
            })
        default:
            break
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
