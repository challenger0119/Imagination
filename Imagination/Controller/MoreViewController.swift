//
//  MoreViewController.swift
//  Imagination
//
//  Created by Star on 15/12/9.
//  Copyright © 2015年 Star. All rights reserved.
//

import UIKit
import MessageUI

class MoreViewController: UITableViewController, MFMailComposeViewControllerDelegate {
    let dCache = DataCache.share
    let pickerViewTag = 111
    var datePicker: UIDatePicker?

    @IBOutlet weak var reminder: UITableViewCell!
    @IBOutlet weak var cloundSyncCell: UITableViewCell!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableView.automaticDimension
        updateReminder()
        updateCloudSyncCell()
        let backItem = UIBarButtonItem()
        backItem.title = "返回"
        self.navigationItem.backBarButtonItem = backItem
    }
    
    // MARK: - Method
    
    @objc func cancelDatePicker() {
        let pickerView = UIApplication.shared.keyWindow?.viewWithTag(pickerViewTag)
        UIView.animate(withDuration: 0.2, animations: {
            pickerView?.alpha = 0
        }) { (_) in
            pickerView?.removeFromSuperview()
        }
    }
    
    func updateReminder() {
        if Notification.isReminder {
            if let clock = Notification.fireTime {
                reminder.detailTextLabel?.text = "\(clock.hour):\(clock.minute)"
            }
        } else {
            reminder.detailTextLabel?.text = "每天特定时段会提示更新心情"
        }
    }

    func updateCloudSyncCell() {
        if let config = WebDAVConfig.recent() {
            cloundSyncCell.detailTextLabel?.text = config.serverName
        }
    }
    
    @objc func didSelectTime(){
        cancelDatePicker()
        let time = Time.hourAndMinute(ofDate: datePicker!.date)
        Notification.createNotificaion(at: time.0, minute: time.1, identifier: "notification")
        updateReminder()
    }
    
    func isValidateEmail(_ email:String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let emailTest = NSPredicate.init(format: "SELF MATCHES %@", emailRegex)
        return emailTest.evaluate(with: email, substitutionVariables: nil)
    }
 
    func syncBackup(files:[String])  {
        if files.count == 0 {
            let alert = UIAlertController.init(title: "提示", message: "无内容可备份", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction.init(title: "好的", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        sendByEmail(filePaths: files)
    }
    
    func sendTestEmail(toAddr mail:String){
        sendEmail(subject: "[Imagination] Hi,我在这！我将把备份文件发到这里", recipients: [mail])
    }
    
    @discardableResult
    func sendEmail(subject:String,recipients:[String]?,attachments:[String] = []) -> Bool {
        guard MFMailComposeViewController.canSendMail() else {
            return false
        }
        let vc = MFMailComposeViewController()
        vc.mailComposeDelegate = self
        
        vc.setToRecipients(recipients)
        vc.setSubject(subject)
        
        for file in attachments {
            let senddata = try? Data.init(contentsOf: URL(fileURLWithPath: file))
            if let dd = senddata {
                vc.addAttachmentData(dd, mimeType: "", fileName: (file as NSString).lastPathComponent)
            }
        }
        self.present(vc, animated: true, completion: nil)
        return true
    }

    @discardableResult
    func sendByEmail(filePaths:[String],addtional:String = "") -> Bool {
        guard let mail = self.dCache.email else {
            let alert = UIAlertController.init(title: "设置邮箱", message: "请输入邮箱地址", preferredStyle: UIAlertController.Style.alert)
            alert.addTextField(configurationHandler: {
                (email:UITextField) -> Void in
                email.clearButtonMode = UITextField.ViewMode.whileEditing
                if let mail = self.dCache.email {
                    email.placeholder = mail
                }
            })
            alert.addAction(UIAlertAction.init(title: "确定", style: UIAlertAction.Style.default, handler: {
                (confirm:UIAlertAction) -> Void in
                let emailField = (alert.textFields?.first)! as UITextField
                if self.isValidateEmail(emailField.text!) {
                    self.dCache.email = emailField.text

                    let alert = UIAlertController.init(title: "提示", message: "已设置邮箱：\(emailField.text ?? "")", preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "发送", style: .default, handler: {
                        al in
                        self.sendByEmail(filePaths: filePaths, addtional: addtional)
                    }))
                    alert.addAction(UIAlertAction(title: "取消", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                } else {
                    let alert = UIAlertController.init(title: "提示", message: "邮箱地址格式不对", preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction.init(title: "好的", style: UIAlertAction.Style.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }))
            alert.addAction(UIAlertAction.init(title: "取消", style: UIAlertAction.Style.cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return false
        }
        
        return sendEmail(subject: (filePaths.first! as NSString).lastPathComponent, recipients: [mail], attachments: filePaths)
    }
    
    //MARK: - EmailDelegate
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        self .dismiss(animated: true, completion: nil)
        if result == .sent {
            let alert = UIAlertController.init(title: "提示", message: "发送成功", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction.init(title: "好的", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    lazy var actionItems: [[(Int) -> Void]] = {
        let section1: [(Int) -> Void] = [
            { _ in
                if let pickerVC = self.storyboard?.instantiateViewController(withIdentifier: "DataPickerViewController") as? DataPickerViewController {
                    pickerVC.selected = {
                        from, to in
                        self.syncBackup(files: self.dCache.createExportDataFile(from, to: to))
                    }
                    pickerVC.modalPresentationStyle = .overCurrentContext
                    self.tabBarController?.present(pickerVC, animated: false, completion: nil)
                }
            },
            { _ in
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert,.sound,.badge]) { (success, error) in
                    if error != nil {
                        Dlog(error?.localizedDescription)
                    } else {
                        Dlog("requestAuthorization \(success)")                        
                        DispatchQueue.main.async {
                            guard success else {
                                 let alert = UIAlertController.init(title: "提示", message: "请在设置中打开通知权限后重试", preferredStyle: UIAlertController.Style.alert)
                                 alert.addAction(UIAlertAction.init(title: "好的", style: UIAlertAction.Style.default, handler: nil))
                                 self.present(alert, animated: true, completion: nil)
                                 return
                             }
                             if Notification.isReminder {
                                Notification.isReminder = false
                                Notification.cancelAllNotifications()
                                self.updateReminder()
                                return
                            }

                            
                            
                            let pickerBack = UIView(frame: CGRect(x: 20, y: self.view.frame.height/2-133, width: self.view.frame.width - 40, height: 266))
                            pickerBack.backgroundColor = UIColor.white
                            pickerBack.layer.cornerRadius = 10
                            let btn = UIButton.init(frame: CGRect(x: pickerBack.frame.width - 52, y: 8, width: 40, height: 40))
                            btn.setImage(UIImage(named: "check"), for: .normal)
                            btn.addTarget(self, action: #selector(self.didSelectTime), for: UIControl.Event.touchUpInside)
                            pickerBack.addSubview(btn)
                            let cancelBtn = UIButton(frame: CGRect(x: 12, y: 8, width: 40, height: 40))
                            cancelBtn.setImage(UIImage(named: "cancel"), for: .normal)
                            cancelBtn.addTarget(self, action: #selector(self.cancelDatePicker), for: UIControl.Event.touchUpInside)
                            pickerBack.addSubview(cancelBtn)

                            self.datePicker = UIDatePicker(frame:CGRect(x: 0, y: 48, width: pickerBack.frame.width, height: 216))
                            self.datePicker!.datePickerMode = UIDatePicker.Mode.time
                            self.datePicker?.timeZone = TimeZone.current
                            pickerBack.addSubview(self.datePicker!)
                            
                            
                            let pickerBackMask = UIView(frame: UIScreen.main.bounds)
                            pickerBackMask.tag = self.pickerViewTag
                            pickerBackMask.backgroundColor = Theme.Color.grey().withAlphaComponent(0.5)
                            pickerBackMask.addSubview(pickerBack)
                            pickerBack.center = pickerBackMask.center
                            UIApplication.shared.keyWindow?.addSubview(pickerBackMask)
                            
                            pickerBackMask.alpha = 0
                            UIView.animate(withDuration: 0.2) {
                                pickerBackMask.alpha = 1.0
                            }
                        }
                    }
                }
            },
            {
                _ in
                let storeboad = UIStoryboard.init(name: "Main", bundle: Bundle.main)
                let vc = storeboad.instantiateViewController(withIdentifier: "authority") as! AuthorityViewController
                vc.vType = AuthorityViewController.type.changePass
                self.present(vc, animated: true, completion: nil)
            },
            { _ in
                WebDavSyncMananger.shared.synchronization()
                self.navigationController?.pushViewController(WebDAVViewController(), animated: true)
            },
            { _ in }
        ]

        return [section1]
    }()
}

extension MoreViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView .deselectRow(at: indexPath, animated: true)
        actionItems[indexPath.section][indexPath.row](indexPath.row)
    }
}
