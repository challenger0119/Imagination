//
//  WebDAVConfig.swift
//  Imagination
//
//  Created by Miaoqi Wang on 2019/4/27.
//  Copyright © 2019 Star. All rights reserved.
//

import Foundation

struct WebDAVConfig {

    private static let userDefault = UserDefaults(suiteName: "WebDAVConfig")
    let server: String
    let username: String
    let password: String

    func store() {
        guard server.isEmpty == false else {
            return
        }
        WebDAVConfig.userDefault?.set(server, forKey: "server")
        WebDAVConfig.userDefault?.set(username, forKey: "username")
        WebDAVConfig.userDefault?.set(password, forKey: "password")
    }

    static func recent() -> WebDAVConfig? {
        if let server = WebDAVConfig.userDefault?.object(forKey: "server") as? String {
            let username: String = WebDAVConfig.userDefault?.object(forKey: "username") as! String
            let password: String = WebDAVConfig.userDefault?.object(forKey: "password") as! String
            return WebDAVConfig(server: server, username: username, password: password)
        } else {
            return nil
        }
    }
}
