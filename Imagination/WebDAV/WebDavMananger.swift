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

    let webDav = WebDAV()

    var syncQueue: [SyncItem] = []

    func syncFiles(ofPath path: String  ) {
        syncQueue.forEach { (item) in
            if !item.isSyncing {
                webDav.uploadFile(filePath: item.filePath, atPath: path)
            }
        }
    }

    func synchronization() {
        let fileDir = FileManager.backupFilePath()

    }
}
