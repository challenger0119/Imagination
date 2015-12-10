//
//  AuthorityViewController.swift
//  Imagination
//
//  Created by Star on 15/11/18.
//  Copyright © 2015年 Star. All rights reserved.
//

import UIKit
import LocalAuthentication

class AuthorityViewController: UIViewController,UITextFieldDelegate {
    @IBOutlet weak var password: UITextField!
    
    override func viewDidLoad() {
        password.delegate = self
    }

    func check() {
        if let text = password.text {
            if !text.isEmpty {
                checkAuthority(text)
            }
        }
    }
    
    func checkAuthority(passwd:String){
        if passwd == "5233" {
            /*
            let storeboad = UIStoryboard.init(name: "Main", bundle: NSBundle.mainBundle())
            let vc = storeboad.instantiateViewControllerWithIdentifier("inittab")
            self.presentViewController(vc, animated: true, completion: nil)
            */
            self.dismissViewControllerAnimated(true, completion: nil)
        }else{
            let alert = UIAlertController.init(title: "提示", message: "抱歉，证据不足哦！", preferredStyle: UIAlertControllerStyle.Alert)
            let action = UIAlertAction.init(title: "好的", style: UIAlertActionStyle.Default, handler: nil)
            alert.addAction(action)
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        check()
        return true
    }
}
