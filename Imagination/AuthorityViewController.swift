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
        useTouchId()
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
    
    func useTouchId()
    {
        let authenticationContext = LAContext()
        var error: NSError?
        
        let isTouchIdAvailable = authenticationContext.canEvaluatePolicy(.DeviceOwnerAuthenticationWithBiometrics,
            error: &error)
        
        if isTouchIdAvailable
        {
            authenticationContext.evaluatePolicy(.DeviceOwnerAuthenticationWithBiometrics, localizedReason: "需要验证指纹", reply: {
                (success, error) -> Void in
                if success
                {
                    self.checkAuthority("5233")
                }
            })
        }
    }

}


