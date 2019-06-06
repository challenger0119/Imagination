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
    let serverName: String
    let server: String
    let username: String
    let password: String

    func store() {
        guard server.isEmpty == false else {
            return
        }
        WebDAVConfig.userDefault?.set(serverName, forKey: "serverName")
        WebDAVConfig.userDefault?.set(server, forKey: "server")
        WebDAVConfig.userDefault?.set(username, forKey: "username")
        WebDAVConfig.userDefault?.set(password, forKey: "password")
    }

    static func recent() -> WebDAVConfig? {
        if let server = WebDAVConfig.userDefault?.object(forKey: "server") as? String {
            let serverName: String = WebDAVConfig.userDefault?.object(forKey: "serverName") as! String
            let username: String = WebDAVConfig.userDefault?.object(forKey: "username") as! String
            let password: String = WebDAVConfig.userDefault?.object(forKey: "password") as! String
            return WebDAVConfig(serverName: serverName, server: server, username: username, password: password)
        } else {
            return nil
        }
    }

    static func emptyConfig() -> WebDAVConfig {
        return WebDAVConfig(serverName: "", server: "", username: "", password: "")
    }

    static func reset() {
        WebDAVConfig.userDefault?.removeObject(forKey: "serverName")
        WebDAVConfig.userDefault?.removeObject(forKey: "server")
        WebDAVConfig.userDefault?.removeObject(forKey: "username")
        WebDAVConfig.userDefault?.removeObject(forKey: "password")
    }
}
