//
//  FileManager.swift
//  Imagination
//
//  Created by Star on 15/11/22.
//  Copyright © 2015年 Star. All rights reserved.
//

import Foundation

class FileManager: NSFileManager {
    
 
    class func pathOfNameInCaches(name:String)->String{
        let documetPaths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.CachesDirectory,NSSearchPathDomainMask.UserDomainMask, true)
        let path = documetPaths[0] as String
        return path.stringByAppendingString("/"+name)
    }
    class func TxtFileInCaches(name:String) -> String {
        let file = FileManager.pathOfNameInCaches(name)
        return file.stringByAppendingString(".txt")
    }
    
    
    class func pathOfNameInDocuments(name:String)->String{
        let documetPaths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory,NSSearchPathDomainMask.UserDomainMask, true)
        let path = documetPaths[0] as String
        return path.stringByAppendingString("/"+name)
    }
    
    class func TxtFileInDocuments(name:String) -> String {
        let file = FileManager.pathOfNameInDocuments(name)
        return file.stringByAppendingString(".txt")
    }
}
