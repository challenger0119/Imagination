//
//  MoreViewController.swift
//  Imagination
//
//  Created by Star on 15/12/9.
//  Copyright © 2015年 Star. All rights reserved.
//

import UIKit

class MoreViewController: UITableViewController {
    
    @IBOutlet weak var resent: UITableViewCell!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        updateRecentDetail()
    }
    
    func updateRecentDetail() {
        DataCache.shareInstance.checkFileExist()
        if let fs = DataCache.shareInstance.fileState {
            if fs.lastDate != " " {
                resent.detailTextLabel?.text = "上次备份于\(fs.lastDate) \n该项只备份上次备份日期到今天的内容并导出"
            }
        }
    }
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == 0 {
            DataCache.shareInstance.backupToNow()
            updateRecentDetail()
        } else if indexPath.row == 1 {
            DataCache.shareInstance.backupAll()
            updateRecentDetail()
        } else if indexPath.row == 2 {
            
        } else if indexPath.row == 3 {
            
        }
    }

}
