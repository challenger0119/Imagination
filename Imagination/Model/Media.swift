//
//  Media.swift
//  Imagination
//
//  Created by Star on 2018/9/17.
//  Copyright © 2018年 Star. All rights reserved.
//

import UIKit
import AVFoundation
import RealmSwift

enum MediaType:String {
    case image = "Image", voice = "Voice", video = "Video", def = "multi"
}

class Media: Object {
    
    @objc var position:Int = 0
    @objc var name:String = ""
    @objc var type:String = MediaType.def.rawValue {
        didSet{
            self.mediaType = MediaType(rawValue: type)!
        }
    }
    @objc var path:String = ""
    
    var mediaType:MediaType = .def
    var obj:AnyObject?
    
    let ofItem = LinkingObjects(fromType: Item.self, property: "medias")
    
    override class func ignoredProperties() -> [String] {
        return ["mediaType","obj"]
    }
    
    //圆角图
    class func roundCornerImage(_ image:UIImage,frame:CGRect)->UIImage {
        UIGraphicsBeginImageContextWithOptions(frame.size, false, UIScreen.main.scale)
        UIBezierPath(roundedRect: frame, cornerRadius: 5).addClip()
        image.draw(in: frame)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
    //视频截图
    class func viedoShot(withURL url:URL)->UIImage?{
        let avasset = AVURLAsset(url: url)
        let generator = AVAssetImageGenerator.init(asset: avasset)
        generator.appliesPreferredTrackTransform = true //竖屏视频需要
        var image:UIImage?
        do{
            var actualTIme:CMTime = CMTime()
            let cimage = try generator.copyCGImage(at: CMTimeMakeWithSeconds(0.5, 10), actualTime: &actualTIme)
            
            //CMTimeShow(actualTIme)
            image = UIImage.init(cgImage: cimage)
        }catch{
            Dlog(error.localizedDescription)
        }
        return image
    }
}
