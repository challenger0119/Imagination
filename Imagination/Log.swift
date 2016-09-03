//
//  Log.swift
//  Imagination
//
//  Created by Star on 16/9/3.
//  Copyright © 2016年 Star. All rights reserved.
//

import Foundation

func Dlog<T>(message: T,
                    file: String = #file,
                    method: String = #function,
                    line: Int = #line)
{
    #if DEBUG
        print("\((file as NSString).lastPathComponent)[\(line)], \(method): \(message)")
    #endif
}