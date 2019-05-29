//
//  WebDAVLoginViewController.swift
//  Imagination
//
//  Created by Miaoqi Wang on 2019/4/27.
//  Copyright © 2019 Star. All rights reserved.
//

import UIKit

class WebDAVLoginViewController: UIViewController {

    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var serverTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "关闭", style: .done, target: self, action: #selector(close))
    }

    @IBAction func confirm(_ sender: Any) {
        let server = serverTextField.text ?? ""
        let username = usernameTextField.text ?? ""
        let password = passwordTextField.text ?? ""
        let alert = UIAlertController(title: "确认", message: "服务器地址：\(server)\n用户名：\(username)\n密码：\(password)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default, handler: { (action) in
            WebDAVConfig(server: server, username: username, password: password).store()
            self.dismiss(animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: { (action) in

        }))
        self.present(alert, animated: true, completion: nil)
    }

    @objc
    func close() {
        self.dismiss(animated: true, completion: nil)
    }
}
