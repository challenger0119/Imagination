//
//  MoreViewController.swift
//  Imagination
//
//  Created by Star on 15/12/9.
//  Copyright © 2015年 Star. All rights reserved.
//

import UIKit
import MessageUI

class MoreViewController: UITableViewController,DataPickerDelegate,MFMailComposeViewControllerDelegate {
    let dCache = DataCache.shareInstance
    var picker:DataPicker?
    @IBOutlet weak var resent: UITableViewCell!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        updateRecentDetail()
    }
    
    func updateRecentDetail() {
        dCache.checkFileExist()
        if let fs = dCache.fileState {
            if fs.lastDate != " " {
                resent.detailTextLabel?.text = "上次备份于\(fs.lastDate) \n该项只备份上次备份日期到今天的内容并导出"
            }
        }
    }
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == 0 {
            sendBackupToMail(dCache.backupToNow())
            updateRecentDetail()
        } else if indexPath.row == 1 {
            sendBackupToMail(dCache.backupAll())
            updateRecentDetail()
        } else if indexPath.row == 2 {
            picker = DataPicker.init(frame: CGRectMake(20, (self.view.frame.height-200)/2-50, self.view.frame.width-40, 200), dele: self)
            self.view.addSubview(picker!)
        } else if indexPath.row == 3 {
            sendByEmail("", fileName: "建议")
        }
    }
    
    func dataPickerResult(first: String, second: String) {
        sendExportToMail(dCache.createExportDataFile(first, to: second))
    }
    
    
    
    func sendBackupToMail(name:String) {
        sendByEmail(FileManager.TxtFileInDocuments(name), fileName: name+".txt")
    }
    func sendExportToMail(name:String) {
        sendByEmail(FileManager.TxtFileInCaches(name), fileName: name+".txt")
    }
    func sendByEmail(filePath:String,fileName:String) {
        let vc = MFMailComposeViewController.init()
        vc.mailComposeDelegate = self
        vc.setSubject(fileName)
        vc.setToRecipients(["miaoqi0119@163.com"])
        
        let senddata = NSData.init(contentsOfFile: filePath)
        if let dd = senddata {
            vc.addAttachmentData(dd, mimeType: "text/plain", fileName: fileName)
        }
        
        self.presentViewController(vc, animated: true, completion: nil)
    }
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        self .dismissViewControllerAnimated(true, completion: nil)
        if result == MFMailComposeResultSent {
            let alert = UIAlertController.init(title: "提示", message: "发送成功", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction.init(title: "好的", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
}
