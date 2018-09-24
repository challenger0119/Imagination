//
//  FileManager.swift
//  Imagination
//
//  Created by Star on 15/11/22.
//  Copyright © 2015年 Star. All rights reserved.
//

import Foundation
import UIKit

// 系统文件操作
extension FileManager {
    //MARK: - Base
    
    // 用户可以看到的目录
    class func documentsPath()->String{
        return NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory,FileManager.SearchPathDomainMask.userDomainMask, true)[0] as String
    }
    
    // APP维护的缓存目录 一定程度可删除再生的
    class func cachesPath()->String{
        return NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.cachesDirectory,FileManager.SearchPathDomainMask.userDomainMask, true)[0] as String
    }
    
    // APP存储的用户不可看到的目录
    class func libraryPath()->String{
        return NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true)[0] as String
    }
    
    // 系统维护的缓存目录 可删除再生
    class func tempsPath()->String{
        return NSTemporaryDirectory()
    }

    class func pathOfNameInCaches(_ name:String)->String{
        let path = self.cachesPath()
        return path + ("/"+name)
    }
    
    class func pathOfNameInLib(_ name:String)->String{
        let path = self.libraryPath()
        Dlog(path)
        return path + ("/"+name)
    }
    
    
    class func deleteFile(atPath path:String)->Bool{
        if FileManager.default.fileExists(atPath: path) {
            do{
                try FileManager.default.removeItem(atPath: path)
            }catch{
                Dlog(error.localizedDescription)
                return false
            }
        }
        return true
    }
}

// APP基本文件操作
extension FileManager{
    
    // 创建子文件夹
    class func createSubDirectory(dirPath:String){
        do{
            try FileManager.default.createDirectory(atPath: dirPath, withIntermediateDirectories: true, attributes: nil)
        }catch{
            Dlog(error.localizedDescription)
        }
    }

    // lib中多媒体文件夹
    class func multiMediaFilePath() ->String {
        let path = self.libraryPath() + "/Multimedia"
        createSubDirectory(dirPath: path)
        return path
    }
    
    // 用户可看到的备份文件 可以自己通过iTunes拿出来
    class func backupFilePath()->String{
        let path = self.documentsPath() + "/Backup"
        createSubDirectory(dirPath: path)
        return path
    }
    
    // 用户可看到的导出文件 可以自己通过iTunes拿出来
    class func exportFilePath()->String{
        let path = self.documentsPath() + "/Export"
        createSubDirectory(dirPath: path)
        return path
    }
    
    class func exportFilePath(withName name:String)->String{
        return self.exportFilePath() + "/\(name)"
    }
    
    class func backupFilePath(withName name:String)->String{
        return self.backupFilePath() + "/\(name)"
    }
    
    class func multiMediaDirRelativePath() -> String{
        return "Library/Multimedia"
    }
}

// 图片文件操作
extension FileManager{
    //MARK: - Image
    class func imageFilePath() -> String{
        let path = self.multiMediaFilePath() + "/Pictures"
        createSubDirectory(dirPath: path)
        return path
    }
    class func imageFilePathWithName(name:String)->String{
        return self.imageFilePath() + "/\(name)"
    }
    //全局设置
    static var compression:CGFloat{
        get{
            return 0.5
        }
    }
    
    static var isPng:Bool {
        get{
            return false
        }
    }
    
    class func imageName(name:String)->String{
        if FileManager.isPng {
            return name+".png"
        }else{
            return name+".jpg"
        }
    }
    
    static var imageFormat:String {
        get{
            if self.isPng {
                return "png"
            }else{
                return "jpg"
            }
        }
    }
    //文件操作
    class func imageData(image:UIImage) -> Data? {
        if FileManager.isPng {
            return image.pngData()
        }else{
            return image.jpegData(compressionQuality: FileManager.compression)
        }
    }
    
    fileprivate class func imageFilePathWithTimestamp() -> String{
        return self.imageFilePathWithName(name: FileManager.imageName(name: "image\(Time.stringTimestamp())"))
    }
    
    class func createImageFile(withImage image:UIImage)->String{
        let path:String = FileManager.imageFilePathWithTimestamp()
        let data = FileManager.imageData(image: image)
        if FileManager.default.createFile(atPath: path, contents: data, attributes: nil) {
            return path
        }else{
            return ""
        }
    }
}

// 音频文件
extension FileManager{
    //MARK: - Audio
    class func audioFilePath()->String{
        let path = self.multiMediaFilePath() + "/Audios"
        createSubDirectory(dirPath: path)
        return path
    }
    
    static let audioFormat = "wav"
    class func audioFilePathWithName(name:String)->String{
        return self.audioFilePath() + "/\(name)"
    }
    class func tmpAudioFilePath()->String{
        return self.tempsPath() + "audio\(Time.stringTimestamp()).\(FileManager.audioFormat)"
    }
    fileprivate class func audioFilePathWithTimstamp()->String{
        return self.audioFilePathWithName(name: "audio\(Time.stringTimestamp()).\(FileManager.audioFormat)")
    }
    class func createAudioFile(withPath path:String)->String{
        let topath:String = FileManager.audioFilePathWithTimstamp()
        do{
            try FileManager.default.copyItem(atPath: path, toPath: topath)
            try FileManager.default.removeItem(atPath: path)
        }catch{
            Dlog(error.localizedDescription)
        }
        return topath
    }
}

// 视频文件
extension FileManager{
    // video
    class func videoFilePath() -> String{
        let path = self.multiMediaFilePath() + "/Videos"
        createSubDirectory(dirPath: path)
        return path
    }
    class func videoFilePathWithName(name:String)->String{
        return self.videoFilePath() + "/\(name)"
    }
    static let videoFormat = "mov"
    fileprivate class func videoFilePathWithTimestamp()->String{
        return self.videoFilePathWithName(name: "video\(Time.stringTimestamp()).\(FileManager.videoFormat)")
    }
    class func createVideoFile(withPath path:String)->String{
        let topath:String = FileManager.videoFilePathWithTimestamp()
        do{
            try FileManager.default.copyItem(atPath: path, toPath: topath)
            let _ = FileManager.deleteFile(atPath: path)
        }catch{
            Dlog(error.localizedDescription)
        }
        return topath
    }
}

