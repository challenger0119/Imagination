//
//  MoreViewController.swift
//  Imagination
//
//  Created by Star on 15/12/9.
//  Copyright © 2015年 Star. All rights reserved.
//

import UIKit

class MoreViewController: UITableViewController {
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == 0 {
            DataCache.shareInstance.backupToNow()
        } else if indexPath.row == 1 {
            DataCache.shareInstance.backupAll()
        } else if indexPath.row == 2 {
            
        } else if indexPath.row == 3 {
            
        }
    }

}
