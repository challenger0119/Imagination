//
//  FileManager.swift
//  Imagination
//
//  Created by Star on 15/11/22.
//  Copyright © 2015年 Star. All rights reserved.
//

import Foundation

class FileManager: NSFileManager {
    class func pathOfName(name:String)->String{
        let documetPaths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentationDirectory,NSSearchPathDomainMask.UserDomainMask, true)
        let path = documetPaths[0] as String
        return path.stringByAppendingString(name)
    }
}
