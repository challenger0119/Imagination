//
//  WebDavMananger.swift
//  Imagination
//
//  Created by Miaoqi Wang on 2019/6/11.
//  Copyright © 2019 Star. All rights reserved.
//

import UIKit

struct SyncItem {
    let filePath: String
    var isSyncing: Bool = false
    var error: Error?

    init(filePath: String) {
        self.filePath = filePath
    }
}

class WebDavMananger {
    static let mananger: WebDavMananger = WebDavMananger()

    let webDav = WebDAV()

    var destination: String {
        return webDav.config.server + "/Imagination"
    }
    var syncQueue: [SyncItem] = []

    func synchronization() {
        let fileDir = FileManager.backupFilePath()
        do {
            let files = try FileManager.default.subpathsOfDirectory(atPath: fileDir)
            files.forEach { (f) in
                webDav.uploadFile(filePath: "\(fileDir)/\(f)", atPath: destination + "/\(f)")
            }
        } catch {
            print(error)
        }
    }
}
