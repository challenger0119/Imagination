//
//  WebDavMananger.swift
//  Imagination
//
//  Created by Miaoqi Wang on 2019/6/11.
//  Copyright © 2019 Star. All rights reserved.
//

import UIKit

class WebDavSyncMananger {
    static let shared: WebDavSyncMananger = WebDavSyncMananger()

    var syncDirHref: String {
        didSet {
            UserDefaults.standard.set(syncDirHref, forKey: "WebDavMananger.syncDirHref")
        }
    }

    init() {
        if let href = UserDefaults.standard.object(forKey: "WebDavMananger.syncDirHref") as? String {
            self.syncDirHref = href
        } else {
            self.syncDirHref = ""
        }
    }

    func synchronization() {
        if !syncDirHref.isEmpty {
            let fileDir = FileManager.exportFilePath()
            do {
                let files = try FileManager.default.subpathsOfDirectory(atPath: fileDir)
                files.forEach { (f) in
                    let path = syncDirHref.hasSuffix("/") ? syncDirHref + f : syncDirHref + "/\(f)"
                    WebDAV.shared.uploadFile(filePath: "\(fileDir)/\(f)", atPath: path)
                }
            } catch {
                print(error)
            }
        }
    }
}
