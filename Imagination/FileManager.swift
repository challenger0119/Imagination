//
//  FileManager.swift
//  Imagination
//
//  Created by Star on 15/11/22.
//  Copyright © 2015年 Star. All rights reserved.
//

import Foundation
import UIKit

extension FileManager {
    
 
    class func documentsPath()->String{
        return NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory,FileManager.SearchPathDomainMask.userDomainMask, true)[0] as String
    }
    
    class func cachesPath()->String{
        return NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.cachesDirectory,FileManager.SearchPathDomainMask.userDomainMask, true)[0] as String
    }
    
    class func pathOfNameInCaches(_ name:String)->String{
        let path = self.cachesPath()
        return path + ("/"+name)
    }
    class func TxtFileInCaches(_ name:String) -> String {
        let file = FileManager.pathOfNameInCaches(name)
        return file + ".txt"
    }
    
    
    class func pathOfNameInDocuments(_ name:String)->String{
        let path = self.documentsPath()
        return path + ("/"+name)
    }
    
    class func TxtFileInDocuments(_ name:String) -> String {
        let file = FileManager.pathOfNameInDocuments(name)
        return file + ".txt"
    }
    
    //MARK: - store image
    
    class func imagePathWithName(_ name:String)->String{
        return self.documentsPath() + "/Pictures/\(name)"
    }
    class func jpegImagePathWithName(_ name:String)->String{
        return self.imagePathWithName(name) + ".jpg"
    }
    class func pngImagePathWithName(_ name:String)->String {
        return self.imagePathWithName(name) + ".png"
    }
    
    var compression:CGFloat{
        get{
            return 0.5
        }
    }
    var isPng:Bool {
        get{
            return false
        }
    }
    
    func createImageFileWithName(_ name:String,image:UIImage)->Bool{
        do{
            try self.createDirectory(atPath: FileManager.documentsPath() + "/Pictures", withIntermediateDirectories: true, attributes: nil)
        }catch{
            print("error createfile")
        }
        
        var data:Data!
        var path:String!
        if isPng {
            data = UIImagePNGRepresentation(image)
            path = FileManager.pngImagePathWithName(name)
        }else{
            data = UIImageJPEGRepresentation(image, compression)
            path = FileManager.jpegImagePathWithName(name)
        }
        print(path)
        return self.createFile(atPath: path, contents: data, attributes: nil)
    }
    
    func deleteImageFileWithName(_ name:String)->Bool{
        do{
            if isPng {
                try self.removeItem(atPath: FileManager.pngImagePathWithName(name))
            }else{
                try self.removeItem(atPath: FileManager.jpegImagePathWithName(name))
            }
            return true
        }catch{
            return false
        }
    }
    
    class func allImageFilePaths()->[String]?{
        return FileManager.default.subpaths(atPath: self.documentsPath() + "/Pictures")
    }

    
}
