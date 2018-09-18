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
import RealmSwift

class ContentShowViewController: UIViewController {
    var multiMedias:List<Media>?
    var text:String = ""
    var pInfo:Location?
    var exitAnimation:(() -> Void)?
    var mood:MoodType
    fileprivate var mapView:UIView?
    
    init(withItem item:Item) {
        self.multiMedias = item.medias
        self.text = item.content
        self.pInfo = item.location
        self.mood = item.moodType
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func closeVC(){
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
    
    @objc func showMap(){
        if  mapView == nil {
            mapView = IndicatorMapView(frame: CGRect(x: 20, y: self.view.frame.height-50-200, width: self.view.frame.width-40, height: 200),coor:CLLocationCoordinate2D(latitude: pInfo!.latitude, longitude: pInfo!.longtitude))
            self.view.addSubview(mapView!)
        }else{
            mapView!.isHidden = !mapView!.isHidden
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let imageView = UIImageView(frame: self.view.frame)
        imageView.image = UIImage.blurImage(of: UIApplication.shared.keyWindow, withBlurNumber: 1)
        self.view.addSubview(imageView)
        let closeBtn = UIButton(frame: CGRect(x: self.view.frame.width - 80, y: 20, width: 80, height: 30))
        closeBtn.setTitle("Close", for: .normal)
        closeBtn.titleLabel?.textAlignment = .right
        closeBtn.setTitleColor(self.mood.getColor(), for: .normal)
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
            locBtn.setTitleColor(self.mood.getColor(), for: .normal)
            locBtn.setTitle(pInfo!.name, for: .normal)
            locBtn.titleLabel?.adjustsFontSizeToFitWidth = true
            locBtn.addTarget(self, action: #selector(showMap), for: .touchUpInside)
        }
        
        var usedHeight:CGFloat = 0
        if let medias = self.multiMedias{
            var keyIndex = 0
            var lastMuliIndex = -1
            let contentend = (self.text.count > medias.last!.position) ? (self.text.count):medias.last!.position
            for drawIndex in 0...contentend {
                if keyIndex < medias.count && drawIndex == medias[keyIndex].position {
                    
                    let mf = medias[keyIndex]
                    let imageWidth = textView.frame.width - 10;
                    if mf.mediaType == .image {
                        
                        if let image = UIImage(contentsOfFile: mf.path) {
                            let imageHeight = image.size.height / image.size.width * imageWidth
                            textView.addSubview(
                                buttonFactory(frame: CGRect(x:0,y:usedHeight,width:textView.frame.width,height:imageHeight),
                                              backgroundImage: Media.roundCornerImage(image, frame: CGRect(x: 0, y: 0, width: imageWidth, height: imageHeight)), tag: keyIndex)
                            )
                            usedHeight += imageHeight
                        }
                    }else if mf.mediaType == .voice {
                        let btn = UIButton(type: .roundedRect)
                        btn.frame = CGRect(x:0,y:usedHeight,width:textView.frame.width,height:50)
                        btn.tag = keyIndex
                        let audio = AudioRecord(withFile:mf.path)
                        let timeString = Time.timeIntervalToMMssString(timeInterval: audio.playerDuration())
                        btn.setTitle("录音 \(timeString)", for: .normal)
                        btn.addTarget(self, action: #selector(btnClicked), for: .touchUpInside)
                        textView.addSubview(btn)
                        usedHeight += 50
                    }else if mf.mediaType == .video {
                        let url = URL.init(fileURLWithPath: mf.path)
                        let image = Media.viedoShot(withURL: url)!
                        let imageHeight = image.size.height / image.size.width * imageWidth
                        textView.addSubview(
                            buttonFactory(frame: CGRect(x:0,y:usedHeight,width:textView.frame.width,height:imageHeight),
                                          backgroundImage: Media.roundCornerImage(image, frame: CGRect(x: 0, y: 0, width: imageWidth, height: imageHeight)), tag: keyIndex)
                        )
                        usedHeight += imageHeight
                    }
                    
                    lastMuliIndex = drawIndex
                    keyIndex += 1
                }else if drawIndex == lastMuliIndex + 1 {
                    let start = self.text.index(text.startIndex, offsetBy: lastMuliIndex + 1)
                    var offset = 0
                    if keyIndex < medias.count {
                        offset = medias[keyIndex].position
                    }else{
                        offset = contentend
                    }
                    let end = self.text.index(text.startIndex, offsetBy: offset)
                    let substring = String(self.text[start..<end])
                    let height = (substring as NSString).boundingRect(with: CGSize(width:textView.frame.width,height:textView.frame.height), options: [NSStringDrawingOptions.usesLineFragmentOrigin,.usesFontLeading], attributes: [NSAttributedStringKey.font:UIFont.systemFont(ofSize: 15)], context: nil).size.height
                    textView.addSubview(
                        labelFactory(frame: CGRect(x:0,y:usedHeight,width:textView.frame.width,height:height), content: substring, textColor: self.mood.getColor())
                    )
                    usedHeight += height
                }
            }
        }else{
            let height = (self.text as NSString).boundingRect(with: CGSize(width:textView.frame.width,height:textView.frame.height), options: [NSStringDrawingOptions.usesLineFragmentOrigin,.usesFontLeading], attributes: [NSAttributedStringKey.font:UIFont.systemFont(ofSize: 15)], context: nil).size.height
            textView.addSubview(
                labelFactory(frame: CGRect(x:0,y:usedHeight,width:textView.frame.width,height:height), content: self.text, textColor: self.mood.getColor()))
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

    @objc func btnClicked(sender:UIButton){
        
        let mf = self.multiMedias![sender.tag]
        switch mf.mediaType {
        case .image:
            let vc = ImageViewController(withImage: UIImage.init(contentsOfFile: mf.path)!)
            let nav = UINavigationController(rootViewController: vc)
            nav.navigationBar.isTranslucent = false
            self.present(nav, animated: true, completion: {
                
            })
            
        case .video:
            let playView = AVPlayerViewController()
            let playitem = AVPlayerItem(asset: AVAsset(url: URL.init(fileURLWithPath: mf.path)))
            let player = AVPlayer(playerItem: playitem)
            playView.player = player
            self.present(playView, animated: true, completion: {
            })
        case .voice:
            let vc = AudioViewController(withFile: mf.path)
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
