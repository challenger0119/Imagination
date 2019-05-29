//
//  WebDAVItem.swift
//  Imagination
//
//  Created by Miaoqi Wang on 2019/4/22.
//  Copyright © 2019 Star. All rights reserved.
//

import Foundation

struct WebDAVItem {
    static let keys = ["href", "getlastmodified", "getcontentlength", "signature", "owner", "getcontenttype", "displayname"]

    var href: String = ""
    var getlastmodified: String = ""
    var getcontentlength: String = ""
    var signature: String = ""
    var owner: String = ""
    var getcontenttype: String = ""
    var displayname: String = ""
    var isFather: Bool = false
    var isDirectory: Bool {
        return getcontenttype == "httpd/unix-directory"
    }

    init() {}

    mutating func set(key: String, value: String) -> Bool {
        switch key {
        case "href":
            self.href = value
        case "getlastmodified":
            self.getlastmodified = value
        case "getcontentlength":
            self.getcontentlength = value
        case "signature":
            self.signature = value
        case "owner":
            self.owner = value
        case "getcontenttype":
            self.getcontenttype = value
        case "displayname":
            self.displayname = value
        default:
            break
        }
        return key == "status"
    }
}


